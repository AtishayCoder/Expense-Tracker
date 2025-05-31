import 'dart:async';

import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/storage/expense_manager.dart';
import 'package:expense_tracker/utils/event_bus_singleton.dart';
import 'package:expense_tracker/utils/events.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  List<DataRow> rows = [];
  bool processing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getData();
      appEventBus.on<ExpensesUpdatedEvent>().listen((event) async {
        print("Data manipulated! Fetching new data.");
        await getData();
      });
    });
  }

  Future<void> getData() async {
    setState(() {
      processing = true;
    });
    rows = [];
    await expenseManagerInstance.loadExpenses();
    List<Expense> expenses = expenseManagerInstance.expenses;
    expenses.sort((a, b) => b.date.compareTo(a.date));
    for (var expense in expenses) {
      rows.add(
        DataRow(
          cells: [
            DataCell(Text(expense.title)),
            DataCell(Text(expense.amount.toString())),
            DataCell(
              Text(
                "${expense.date.day}/${expense.date.month}/${expense.date.year}",
              ),
            ),
            DataCell(Text(expense.desc)),
          ],
        ),
      );
    }

    setState(() {
      processing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: processing,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: processing
              ? Container()
              : (rows != [])
              ? DataTable(
                  columns: <DataColumn>[
                    DataColumn(label: Text("Title")),
                    DataColumn(label: Text("Amount")),
                    DataColumn(label: Text("Date")),
                    DataColumn(label: Text("Description")),
                  ],
                  rows: rows,
                  sortAscending: true,
                  sortColumnIndex: 2,
                )
              : Center(
                  child: Text(
                    "No expenses added yet. Use the add button to add a transaction!",
                    style: TextStyle(fontSize: 35.0),
                  ),
                ),
        ),
      ),
    );
  }
}
