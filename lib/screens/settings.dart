import 'package:expense_tracker/storage/expense_manager.dart';
import 'package:expense_tracker/utils/event_bus_singleton.dart';
import 'package:expense_tracker/utils/events.dart';
import 'package:expense_tracker/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
            MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              onPressed: () {
                int income = 0;
                Get.dialog(
                  AlertDialog(
                    titlePadding: EdgeInsets.all(10.0),
                    contentPadding: EdgeInsets.all(10),
                    title: Center(child: const Text("Change Income")),
                    alignment: Alignment.center,
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Please tell us your new monthly income."),
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                        SizedBox(height: 20.0),
                        MaterialButton(
                          onPressed: () async {
                            var instance =
                                await SharedPreferences.getInstance();
                            if (income.isEqual(0)) {
                              return;
                            }
                            await instance.setInt("Income", income);
                            Get.back();
                            appEventBus.fire(ExpensesUpdatedEvent());
                          },
                          color: Colors.blue,
                          minWidth: double.infinity,
                          child: Text("Change"),
                        ),
                      ],
                    ),
                  ),
                );
              },
              color: Colors.redAccent,
              height: 50.0,
              minWidth: double.infinity,
              child: Text("CHANGE INCOME"),
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
