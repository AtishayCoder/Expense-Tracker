import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/storage/expense_manager.dart';
import 'package:expense_tracker/utils/event_bus_singleton.dart';
import 'package:expense_tracker/utils/events.dart';
import 'package:expense_tracker/utils/theme.dart';
import 'package:fl_chart/fl_chart.dart';
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
  double? needTotal;
  double? wantTotal;
  final double radius = 80;

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
    await expenseManagerInstance.loadExpenses();
    income = (await SharedPreferences.getInstance()).getInt("Income")!;
    totalSpent = expenseManagerInstance.getTotal();
    totalExpenses = expenseManagerInstance.expenses.length;
    remainingBalance = (income ?? 0.0) - (totalSpent ?? 0.0);
    needTotal = 0.0;
    wantTotal = 0.0;
    var needs = expenseManagerInstance.expenses.where(
      (element) => element.category == ExpenseCategory.need,
    );
    for (var e in needs) {
      needTotal = (needTotal ?? 0.0) + e.amount;
    }
    var wants = expenseManagerInstance.expenses.where(
      (element) => element.category == ExpenseCategory.want,
    );
    for (var e in wants) {
      wantTotal = (wantTotal ?? 0.0) + e.amount;
    }
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
                    // Basics
                    Card(
                      elevation: 9,
                      color: isDarkTheme(context)
                          ? Colors.grey[850]
                          : Colors.grey[50],
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Income: ₹ ${NumberFormat.decimalPattern().format((income ?? 0.0))}",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "Total Spent: ₹ ${NumberFormat.decimalPattern().format(totalSpent ?? 0.0)}",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "Balance Left: ₹ ${NumberFormat.decimalPattern().format((remainingBalance ?? 0.0))}",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16,
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
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            // Needs
                            // Wants
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        // Needs
                        Expanded(
                          child: Card(
                            elevation: 9,
                            color: isDarkTheme(context)
                                ? Colors.grey[850]
                                : Colors.grey[50],
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Needs Total: ₹ ${NumberFormat.decimalPattern().format((needTotal ?? 0.0))}",
                                    style: TextStyle(),
                                  ),
                                  Text(
                                    "% of income: ${(((needTotal ?? 0.0) / (income ?? 0.0)) * 100).toStringAsFixed(2)}%",
                                    style: TextStyle(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Wants
                        Expanded(
                          child: Card(
                            elevation: 9,
                            color: isDarkTheme(context)
                                ? Colors.grey[850]
                                : Colors.grey[50],
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Wants Total: ₹ ${NumberFormat.decimalPattern().format((wantTotal ?? 0.0))}",
                                    style: TextStyle(),
                                  ),
                                  Text(
                                    "% of income: ${(((wantTotal ?? 0.0) / (income ?? 0.0)) * 100).toStringAsFixed(2)}%",
                                    style: TextStyle(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Charts
                    SizedBox(height: 40.0),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: PieChart(
                                  PieChartData(
                                    centerSpaceRadius: 0,
                                    sections: [
                                      PieChartSectionData(
                                        value: (needTotal ?? 0.0),
                                        color: Colors.orange,
                                        showTitle: true,
                                        title: "Needs",
                                        titleStyle: TextStyle(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        titlePositionPercentageOffset: 0.65,
                                        radius: radius,
                                      ),
                                      PieChartSectionData(
                                        value: (wantTotal ?? 0.0),
                                        color: Colors.blue,
                                        showTitle: true,
                                        title: "Wants",
                                        radius: radius,
                                        titleStyle: TextStyle(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        titlePositionPercentageOffset: 0.65,
                                      ),
                                      PieChartSectionData(
                                        value:
                                            (income ?? 0.0) -
                                            (totalSpent ?? 0.0),
                                        color: Colors.green,
                                        showTitle: true,
                                        title: "Savings",
                                        titleStyle: TextStyle(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        radius: radius,
                                        titlePositionPercentageOffset: 0.65,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Your Budget",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: PieChart(
                                  PieChartData(
                                    centerSpaceRadius: 0,
                                    sections: [
                                      PieChartSectionData(
                                        value: 50,
                                        color: Colors.orange,
                                        showTitle: true,
                                        title: "Needs",
                                        radius: radius,
                                        titleStyle: TextStyle(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      PieChartSectionData(
                                        value: 30,
                                        color: Colors.blue,
                                        showTitle: true,
                                        title: "Wants",
                                        radius: radius,
                                        titleStyle: TextStyle(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      PieChartSectionData(
                                        value: 20,
                                        color: Colors.green,
                                        showTitle: true,
                                        title: "Savings",
                                        radius: radius,
                                        titleStyle: TextStyle(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        titlePositionPercentageOffset: 0.65,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Target Budget",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Top expenses
                    SizedBox(height: 40.0),
                    Card(
                      elevation: 9,
                      color: isDarkTheme(context)
                          ? Colors.grey[850]
                          : Colors.grey[50],
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Latest expenses",
                                style: TextStyle(
                                  fontSize: 17.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            expenseManagerInstance.expenses.isNotEmpty
                                ? Align(
                                    alignment: Alignment.center,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount:
                                          expenseManagerInstance
                                                  .expenses
                                                  .length >
                                              5
                                          ? 5
                                          : expenseManagerInstance
                                                .expenses
                                                .length,
                                      itemBuilder: (context, index) {
                                        List<Expense> expenses =
                                            expenseManagerInstance.expenses;
                                        expenses.sort(
                                          (a, b) => b.date.compareTo(a.date),
                                        );
                                        var expense = expenses[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4.0,
                                          ),
                                          child: Text(
                                            '${expense.title}: ₹ ${NumberFormat.decimalPattern().format(expense.amount)} (${expense.category.name}) - ${expense.date.day}/${expense.date.month}/${expense.date.year}',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "No expenses found.",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Card(
                      elevation: 9,
                      color: isDarkTheme(context)
                          ? Colors.grey[850]
                          : Colors.grey[50],
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Costly expenses",
                                style: TextStyle(
                                  fontSize: 17.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            expenseManagerInstance.expenses.isNotEmpty
                                ? Align(
                                    alignment: Alignment.center,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount:
                                          expenseManagerInstance
                                                  .expenses
                                                  .length >
                                              5
                                          ? 5
                                          : expenseManagerInstance
                                                .expenses
                                                .length,
                                      itemBuilder: (context, index) {
                                        List<Expense> expenses =
                                            expenseManagerInstance.expenses;
                                        expenses.sort(
                                          (a, b) =>
                                              b.amount.compareTo(a.amount),
                                        );
                                        var expense = expenses[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4.0,
                                          ),
                                          child: Text(
                                            '${expense.title}: ₹ ${NumberFormat.decimalPattern().format(expense.amount)} (${expense.category.name}) - ${expense.date.day}/${expense.date.month}/${expense.date.year}',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "No expenses found.",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
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
