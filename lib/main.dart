import 'package:expense_tracker/screens/charts.dart';
import 'package:expense_tracker/screens/dashboard.dart';
import 'package:expense_tracker/screens/new_expense.dart';
import 'package:expense_tracker/screens/settings.dart';
import 'package:expense_tracker/screens/transactions.dart';
import 'package:expense_tracker/utils/event_bus_singleton.dart';
import 'package:expense_tracker/utils/events.dart';
import 'package:expense_tracker/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const Root());
}

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  int navIndex = 1;
  int previousIndex = 1;

  final List<Widget> screens = const [Charts(), Dashboard(), Transactions()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var instance = await SharedPreferences.getInstance();
      bool launchDialog =
          !(instance.containsKey("Income")) || instance.getInt("Income") == 0;
      if (launchDialog) {
        int income = 0;
        Get.dialog(
          barrierDismissible: false,
          AlertDialog(
            titlePadding: EdgeInsets.all(10.0),
            contentPadding: EdgeInsets.all(10),
            title: Center(child: const Text("Welcome")),
            alignment: Alignment.center,
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Please tell us your monthly income."),
                SizedBox(height: 10.0),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Income (₹)",
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    income = int.parse(value);
                  },
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                SizedBox(height: 20.0),
                MaterialButton(
                  onPressed: () async {
                    if (income.isEqual(0)) {
                      return;
                    }
                    await instance.setInt("Income", income);
                    Get.back();
                    appEventBus.fire(ExpensesUpdatedEvent());
                  },
                  color: Colors.blue,
                  minWidth: double.infinity,
                  child: Text("Let's go"),
                ),
              ],
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Expense Tracker"),
            backgroundColor: Colors.lightBlue,
            actions: [
              Builder(
                builder: (context) {
                  return IconButton(
                    onPressed: () {
                      Get.bottomSheet(
                        const Settings(),
                        backgroundColor: isDarkTheme(context)
                            ? Colors.black
                            : Colors.white,
                      );
                    },
                    icon: const Icon(Icons.settings),
                  );
                },
              ),
            ],
          ),
          body: screens[navIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.query_stats),
                label: "Charts",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: "Dashboard",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: "Transactions",
              ),
            ],
            currentIndex: navIndex,
            onTap: (i) {
              setState(() {
                previousIndex = navIndex;
                navIndex = i;
              });
            },
          ),
          floatingActionButton: Builder(
            builder: (context) {
              return FloatingActionButton(
                onPressed: () {
                  Get.bottomSheet(
                    const NewExpense(),
                    isScrollControlled: true,
                    backgroundColor: isDarkTheme(context)
                        ? Colors.black
                        : Colors.white,
                    ignoreSafeArea: false,
                  );
                },
                child: const Icon(Icons.add),
              );
            },
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
    );
  }
}
