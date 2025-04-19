import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class ViewReportPage extends StatefulWidget {
  const ViewReportPage({super.key});

  @override
  State<ViewReportPage> createState() => _ViewReportPageState();
}

class _ViewReportPageState extends State<ViewReportPage> {
  List<Map<String, dynamic>> expenses = [];
  Map<String, double> categoryTotals = {};
  double totalExpenses = 0;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> expenseList = prefs.getStringList('expenses') ?? [];

    final loadedExpenses =
        expenseList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();

    final Map<String, double> totals = {};
    double total = 0;

    for (var exp in loadedExpenses) {
      String cat = exp['category'];
      double amt = double.tryParse(exp['amount']) ?? 0;
      totals[cat] = (totals[cat] ?? 0) + amt;
      total += amt;
    }

    setState(() {
      expenses = loadedExpenses;
      categoryTotals = totals;
      totalExpenses = total;
    });
  }

  Future<void> _deleteExpense(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      expenses.removeAt(index);

      List<String> updatedList = expenses.map((e) => jsonEncode(e)).toList();
      await prefs.setStringList('expenses', updatedList);

      final Map<String, double> totals = {};
      double total = 0;
      for (var exp in expenses) {
        String cat = exp['category'];
        double amt = double.tryParse(exp['amount']) ?? 0;
        totals[cat] = (totals[cat] ?? 0) + amt;
        total += amt;
      }

      setState(() {
        categoryTotals = totals;
        totalExpenses = total;
      });
    }
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.blueGrey,
    ];

    int i = 0;
    return categoryTotals.entries.map((entry) {
      final value = entry.value;
      final percent =
          value / categoryTotals.values.reduce((a, b) => a + b) * 100;
      return PieChartSectionData(
        value: value,
        color: colors[i++ % colors.length],
        title: '${entry.key}\n${percent.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View Report',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontFamily: 'Verdana'),
        ),
        backgroundColor: const Color.fromARGB(255, 175, 202, 248),
      ),
      body: expenses.isEmpty
          ? const Center(child: Text('No expenses found'))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Expenses Pie Chart',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieChartSections(),
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Total Expenses: Rs.${totalExpenses.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent),
                    ),
                    const Divider(),
                    const Text('All Expenses',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final exp = expenses[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: exp['receipt'] != ''
                                ? Image.file(File(exp['receipt']),
                                    width: 50, height: 50, fit: BoxFit.cover)
                                : const Icon(Icons.receipt),
                            title: Text(
                                'Rs. ${exp['amount']} - ${exp['category']}'),
                            subtitle: Text('Date: ${exp['date']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_forever_rounded,
                                  color: Colors.red),
                              onPressed: () => _deleteExpense(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
