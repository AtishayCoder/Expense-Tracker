import 'package:expense_tracker/storage/expense_manager.dart';
import 'package:expense_tracker/utils/event_bus_singleton.dart';
import 'package:expense_tracker/utils/events.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool processing = false;
  int? income;
  double? totalSpent;
  double? remainingBalance;
  int? totalExpenses;

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
    income = (await SharedPreferences.getInstance()).getInt("Income")!;
    totalSpent = expenseManagerInstance.getTotal();
    totalExpenses = expenseManagerInstance.expenses.length;
    remainingBalance = income! - totalSpent!;
    setState(() {
      processing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: processing,
      child: !processing
          ? Padding(
              padding: EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      elevation: 9,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[850]
                          : Colors.grey[50],
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Income: ₹ ${NumberFormat.decimalPattern().format(income!)}",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                Text(
                                  "Total Spent: ₹ ${NumberFormat.decimalPattern().format(totalSpent!)}",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                Text(
                                  "Remaining Balance: ₹ ${NumberFormat.decimalPattern().format(remainingBalance!)}",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                Text(
                                  "Total expenses: $totalExpenses",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Container(),
    );
  }
}
