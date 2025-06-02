import 'dart:math';

import 'package:change_case/change_case.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/storage/expense_manager.dart';
import 'package:expense_tracker/utils/event_bus_singleton.dart';
import 'package:expense_tracker/utils/events.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';

class Charts extends StatefulWidget {
  const Charts({super.key});

  @override
  State<Charts> createState() => _ChartsState();
}

class _ChartsState extends State<Charts> {
  bool processing = false;

  // Previous 5 days breakdown
  List<FlSpot> _dailyExpenseSpots = [];
  Map<int, DateTime> spotIndexes = {};
  final int _numberOfDaysToShow = 5;

  // Monthly purpose spending breakdown
  Map<Purpose, double> purposeSpending = {};
  final List<Color> _availableColors = [
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.yellow,
    Colors.orange,
    Colors.pink.shade100,
    Colors.teal.shade300,
    Colors.tealAccent,
  ];

  // Spending Rhythm
  Map<int, double> spendingRhythm = {};
  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getData();
      appEventBus.on<ExpensesUpdatedEvent>().listen((event) async {
        print("New data! Fetching...");
        await getData();
      });
    });
  }

  Future<void> getData() async {
    setState(() {
      processing = true;
    });

    try {
      await expenseManagerInstance.loadExpenses();
      // Prev 5 days breakdown
      Map<DateTime, double> dailyTotals = {};
      for (var expense in expenseManagerInstance.expenses) {
        DateTime dateOnly = DateUtils.dateOnly(expense.date);
        dailyTotals[dateOnly] = (dailyTotals[dateOnly] ?? 0) + expense.amount;
      }

      DateTime todayDateOnly = DateUtils.dateOnly(DateTime.now());
      dailyTotals.remove(todayDateOnly);

      List<DateTime> sortedDates = dailyTotals.keys.toList()
        ..sort((a, b) => b.compareTo(a));

      List<FlSpot> newSpots = [];
      Map<int, DateTime> newSpotIndexToDateMap = {};
      int spotIndex = 0;

      for (
        int i = 0;
        i < sortedDates.length && spotIndex < _numberOfDaysToShow;
        i++
      ) {
        DateTime date = sortedDates[i];
        newSpots.add(FlSpot(spotIndex.toDouble(), dailyTotals[date]!));
        newSpotIndexToDateMap[spotIndex] = date;
        spotIndex++;
      }

      _dailyExpenseSpots = newSpots;
      spotIndexes = newSpotIndexToDateMap;

      // Monthly Purpose Breakdown
      purposeSpending = {};
      for (var expense in expenseManagerInstance.expenses) {
        purposeSpending[expense.purpose] =
            (purposeSpending[expense.purpose] ?? 0) + expense.amount;
      }

      // Daily Spending Rhythm
      spendingRhythm = {};
      for (int i = 1; i <= 7; i++) {
        spendingRhythm[i] = 0.0;
      }
      for (var expense in expenseManagerInstance.expenses) {
        int day = expense.date.weekday;
        spendingRhythm[day] = (spendingRhythm[day] ?? 0.0) + expense.amount;
      }
    } catch (e) {
      print("Error fetching chart data: $e");
    }
    setState(() {
      processing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: processing,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Spend Trend - Last 5 Days",
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30.0),
              Transform.translate(
                offset: Offset(-15, 0),
                child: SizedBox(
                  height: 300,
                  child: LineChart(
                    LineChartData(
                      minY: _calculateMinY(),
                      maxY: _calculateMaxY(),
                      minX: -0.5,
                      maxX: (_dailyExpenseSpots.length - 1).toDouble() + 0.5,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        drawHorizontalLine: true,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: _gridLineColor(context),
                          strokeWidth: 1,
                        ),
                        getDrawingVerticalLine: (value) => FlLine(
                          color: _gridLineColor(context),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 45,
                            getTitlesWidget: (value, meta) {
                              if (!value.isFinite) return Container();

                              double snapped = double.parse(
                                value.toStringAsFixed(0),
                              );
                              final yAxisLabels = getYAxisLabels();

                              // Show only if it's an allowed Y label (small tolerance for float precision)
                              bool shouldShow = yAxisLabels.any(
                                (v) => (v - snapped).abs() < 1,
                              );
                              if (!shouldShow) return Container();

                              return SideTitleWidget(
                                meta: meta,
                                space: 4,
                                child: Text(
                                  _formatYAxisLabel(snapped),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 35,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              const style = TextStyle(fontSize: 10);
                              int spotIndex = value.round();
                              DateTime? date = spotIndexes[spotIndex];

                              if (date != null) {
                                DateTime today = DateUtils.dateOnly(
                                  DateTime.now(),
                                );
                                DateTime yesterday = today.subtract(
                                  const Duration(days: 1),
                                );
                                if (date == yesterday) {
                                  return SideTitleWidget(
                                    space: 4,
                                    meta: meta,
                                    child: const Text(
                                      'Yesterday',
                                      style: style,
                                    ),
                                  );
                                } else {
                                  int daysAgo = today.difference(date).inDays;
                                  return SideTitleWidget(
                                    space: 4,
                                    meta: meta,
                                    child: Text(
                                      '$daysAgo days ago',
                                      style: style,
                                    ),
                                  );
                                }
                              }
                              return SideTitleWidget(
                                space: 4,
                                meta: meta,
                                child: const Text('', style: style),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          left: BorderSide(
                            color: _axisLineColor(context),
                            width: 1.5,
                          ),
                          bottom: BorderSide(
                            color: _axisLineColor(context),
                            width: 1.5,
                          ),
                          right: BorderSide.none,
                          top: BorderSide.none,
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _dailyExpenseSpots,
                          isCurved: true,
                          barWidth: 3,
                          color: Theme.of(context).colorScheme.primary,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                  radius: 4,
                                  color: Theme.of(context).colorScheme.primary,
                                  strokeWidth: 1.5,
                                  strokeColor: Theme.of(
                                    context,
                                  ).scaffoldBackgroundColor,
                                ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(50),
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 250),
                  ),
                ),
              ),
              SizedBox(height: 40),
              const Text(
                "Purpose Spending Breakdown",
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              expenseManagerInstance.expenses.isEmpty && purposeSpending.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "No data to show",
                          style: TextStyle(
                            fontSize: 17.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    )
                  : AspectRatio(
                      aspectRatio: 1,
                      child: PieChart(
                        duration: Duration(milliseconds: 300),
                        PieChartData(
                          centerSpaceRadius: 0,
                          sections: [
                            for (
                              int i = 0;
                              i < purposeSpending.keys.length;
                              i++
                            )
                              PieChartSectionData(
                                value:
                                    purposeSpending[purposeSpending.keys
                                        .elementAt(i)] ??
                                    0,
                                color: _availableColors[i],
                                titleStyle: TextStyle(color: Colors.black),
                                showTitle: true,
                                title: purposeSpending.keys
                                    .elementAt(i)
                                    .name
                                    .toCapitalCase(),
                                radius: 150,
                              ),
                          ],
                        ),
                      ),
                    ),
              SizedBox(height: 40),
              const Text(
                "Spending Rhythm by Weekday",
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              Builder(
                builder: (context) {
                  final double maxY =
                      ((spendingRhythm.values.reduce(max) * 1.2) / 1000)
                          .ceil() *
                      1000;
                  final double interval = maxY / 5;

                  return Transform.translate(
                    offset: Offset(-20, 0),
                    child: SizedBox(
                      height: 300,
                      child: BarChart(
                        BarChartData(
                          maxY: maxY,
                          alignment: BarChartAlignment.spaceAround,
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (index, meta) {
                                  return SideTitleWidget(
                                    meta: meta,
                                    child: Builder(
                                      builder: (context) {
                                        return Text(
                                          days[index.toInt()].substring(0, 3),
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                reservedSize: 48,
                                interval: interval,
                                showTitles: !(spendingRhythm.values.every(
                                  (n) => n == 0.0,
                                )),
                                getTitlesWidget: (value, meta) {
                                  String formatted;
                                  if (value >= 1_000_000) {
                                    formatted =
                                        '${(value / 1_000_000).toStringAsFixed(1)}M';
                                  } else if (value >= 1_000) {
                                    formatted =
                                        '${(value / 1000).toStringAsFixed(0)}K';
                                  } else {
                                    formatted = value.toStringAsFixed(0);
                                  }

                                  return SideTitleWidget(
                                    meta: meta,
                                    space: 6,
                                    child: Text(
                                      formatted,
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            drawHorizontalLine: true,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: _gridLineColor(context),
                              strokeWidth: 1,
                            ),
                            getDrawingVerticalLine: (value) => FlLine(
                              color: _gridLineColor(context),
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              left: BorderSide(
                                color: _axisLineColor(context),
                                width: 1.5,
                              ),
                              bottom: BorderSide(
                                color: _axisLineColor(context),
                                width: 1.5,
                              ),
                              right: BorderSide.none,
                              top: BorderSide.none,
                            ),
                          ),
                          barGroups: [
                            for (int i = 1; i <= 7; i++)
                              (BarChartGroupData(
                                x: i - 1,
                                barRods: [
                                  BarChartRodData(
                                    borderRadius: BorderRadius.zero,
                                    width: 17.5,
                                    toY: spendingRhythm[i] ?? 0.0,
                                    fromY: 0,
                                    color: _availableColors[i - 1],
                                  ),
                                ],
                              )),
                          ],
                        ),
                        duration: Duration(milliseconds: 300),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateMinY() {
    if (_dailyExpenseSpots.isEmpty) return 0;
    double minY = _dailyExpenseSpots
        .map((e) => e.y)
        .reduce((a, b) => a < b ? a : b);
    double padding = (_calculateMaxY() - minY) * 0.15;
    return (minY - padding).clamp(0, double.infinity);
  }

  double _calculateMaxY() {
    if (_dailyExpenseSpots.isEmpty) return 10;
    double maxY = _dailyExpenseSpots
        .map((e) => e.y)
        .reduce((a, b) => a > b ? a : b);
    double minY = _dailyExpenseSpots
        .map((e) => e.y)
        .reduce((a, b) => a < b ? a : b);

    if (minY == maxY) return maxY + 10;
    double padding = (maxY - minY) * 0.15;
    return maxY + padding;
  }

  Color _gridLineColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return (isDark ? Colors.white : Colors.black).withAlpha(25);
  }

  Color _axisLineColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  List<double> getYAxisLabels() {
    final usedY = _dailyExpenseSpots.map((e) => e.y).toSet().toList()..sort();

    if (usedY.isEmpty) return [];

    Set<double> finalLabels = {...usedY};

    if (usedY.length < 6) {
      for (int i = 0; i < usedY.length - 1; i++) {
        double a = usedY[i];
        double b = usedY[i + 1];
        double mid = ((a + b) / 2).roundToDouble();

        finalLabels.add(mid);
        if (finalLabels.length >= 6) break;
      }
    }

    return finalLabels.toList()..sort();
  }

  String _formatYAxisLabel(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
