import 'package:expense_tracker/screens/charts.dart';
import 'package:expense_tracker/screens/dashboard.dart';
import 'package:expense_tracker/screens/new_expense.dart';
import 'package:expense_tracker/screens/settings.dart';
import 'package:expense_tracker/screens/transactions.dart';
import 'package:expense_tracker/utils/theme.dart';
import 'package:flutter/material.dart';
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
      await (await SharedPreferences.getInstance()).setInt("Income", 100000);
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
