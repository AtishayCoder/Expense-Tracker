import 'package:expense_tracker/screens/charts.dart';
import 'package:expense_tracker/screens/dashboard.dart';
import 'package:expense_tracker/screens/new_expense.dart';
import 'package:expense_tracker/screens/settings.dart';
import 'package:expense_tracker/screens/transactions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Expense Tracker"),
            backgroundColor: Colors.lightBlue,
            actions: [
              IconButton(
                onPressed: () {
                  Get.bottomSheet(const Settings());
                },
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              final offsetAnimation = Tween<Offset>(
                begin: Offset(navIndex > previousIndex ? 1 : -1, 0),
                end: Offset.zero,
              ).animate(animation);
              return SlideTransition(position: offsetAnimation, child: child);
            },
            child: Container(
              key: ValueKey<int>(navIndex),
              child: screens[navIndex],
            ),
          ),
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
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
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
