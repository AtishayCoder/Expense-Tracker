import 'package:expense_tracker/storage/expense_manager.dart';
import 'package:expense_tracker/utils/event_bus_singleton.dart';
import 'package:expense_tracker/utils/events.dart';
import 'package:expense_tracker/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(25),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Builder(
              builder: (context) {
                return MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  onPressed: () {
                    Alert(
                      context: context,
                      type: AlertType.warning,
                      title: "DELETE EXPENSES",
                      desc: "This action cannot be undone. Are you sure?",
                      style: AlertStyle(
                        titleStyle: TextStyle(
                          color: isDarkTheme(context)
                              ? Colors.white
                              : Colors.black,
                        ),
                        descStyle: TextStyle(
                          color: isDarkTheme(context)
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      buttons: [
                        DialogButton(
                          onPressed: () async {
                            await expenseManagerInstance.clearAllExpenses();
                            appEventBus.fire(ExpensesUpdatedEvent());
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          color: Colors.redAccent,
                          child: Text("Delete"),
                        ),
                        DialogButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          color: Colors.green,
                          child: Text("Cancel"),
                        ),
                      ],
                    ).show();
                  },
                  color: Colors.redAccent,
                  height: 50.0,
                  minWidth: double.infinity,
                  child: Text("DELETE ALL EXPENSES"),
                );
              },
            ),
            SizedBox(height: 20.0),
            Builder(
              builder: (context) {
                return MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.green,
                  height: 50.0,
                  minWidth: double.infinity,
                  child: Text("CLOSE"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
