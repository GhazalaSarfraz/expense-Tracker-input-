import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseFormPage extends StatefulWidget {
  const ExpenseFormPage({super.key});

  @override
  State<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends State<ExpenseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _selectedCategory;
  File? _receiptImage;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Food', 'icon': Icons.fastfood},
    {'label': 'Transport', 'icon': Icons.directions_car},
    {'label': 'Shopping', 'icon': Icons.shopping_bag},
    {'label': 'Education', 'icon': Icons.school},
    {'label': 'Bills', 'icon': Icons.receipt_long},
    {'label': 'Other', 'icon': Icons.more_horiz},
  ];

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      _dateController.text = picked.toString().split(' ')[0];
    }
  }

  Future<void> _pickReceipt() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      Map<String, dynamic> expense = {
        'amount': _amountController.text,
        'category': _selectedCategory,
        'date': _dateController.text,
        'receipt': _receiptImage?.path ?? '',
      };

      List<String> expenseList = prefs.getStringList('expenses') ?? [];
      expenseList.add(jsonEncode(expense));
      await prefs.setStringList('expenses', expenseList);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense saved successfully!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.blueGrey,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Expense',
          style: TextStyle(
              fontSize: 24, color: Colors.white, fontWeight: FontWeight.w200),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Amount Field
                  TextFormField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixIcon: const Icon(Icons.attach_money_outlined),
                      labelStyle: labelStyle,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter amount';
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Enter valid amount';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Date Field
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      labelStyle: labelStyle,
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                    ),
                    onTap: () => _pickDate(context),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Select date' : null,
                  ),

                  const SizedBox(height: 16),

                  // Category Chips
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Category',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey)),
                  ),
                  Wrap(
                    spacing: 8,
                    children: _categories.map((cat) {
                      return ChoiceChip(
                        avatar: Icon(cat['icon'], size: 20),
                        label: Text(cat['label']),
                        selected: _selectedCategory == cat['label'],
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? cat['label'] : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  if (_selectedCategory == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text('Please select a category',
                          style: TextStyle(color: Colors.red)),
                    ),

                  const SizedBox(height: 16),

                  // Optional Receipt Upload
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Receipt (Optional)'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueGrey,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: _pickReceipt,
                  ),
                  if (_receiptImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Image.file(_receiptImage!, height: 100),
                    ),

                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w300),
                    ),
                    child: const Text('Submit Expense'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
