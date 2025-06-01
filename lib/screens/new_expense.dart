import 'package:expense_tracker/models/decimal_text_input_formatter.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/storage/expense_manager.dart';
import 'package:expense_tracker/utils/event_bus_singleton.dart';
import 'package:expense_tracker/utils/events.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({super.key});

  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  String title = "";
  double amount = 0.0;
  DateTime? date;
  TextEditingController dateC = TextEditingController();
  String desc = "";
  ExpenseCategory? cat;
  Purpose? purpose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        children: [
          // Title
          TextField(
            decoration: InputDecoration(
              labelText: "Title",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            keyboardType: TextInputType.name,
            onChanged: (v) {
              title = v;
            },
          ),
          SizedBox(height: 10),
          // Amount
          TextField(
            decoration: InputDecoration(
              labelText: "Amount",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onChanged: (v) {
              amount = double.parse(v);
            },
            inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: 10),
          // Date
          TextField(
            decoration: InputDecoration(
              labelText: "Date",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            canRequestFocus: false,
            onTap: () async {
              var dateL = await showDatePicker(
                context: context,
                firstDate: DateTime.now().subtract(Duration(days: 30)),
                lastDate: DateTime.now().add(Duration(days: 30)),
              );
              if (dateL != null) {
                dateC.text = "${dateL.day}/${dateL.month}/${dateL.year}";
                date = DateTime(dateL.year, dateL.month, dateL.day);
              }
            },
            controller: dateC,
          ),
          SizedBox(height: 10),
          // Description
          TextField(
            decoration: InputDecoration(
              labelText: "Description",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onChanged: (v) {
              desc = v;
            },
          ),
          SizedBox(height: 10),
          // Category
          DropdownMenu(
            dropdownMenuEntries: [
              DropdownMenuEntry(value: ExpenseCategory.need, label: "Need"),
              DropdownMenuEntry(value: ExpenseCategory.want, label: "Want"),
            ],
            onSelected: (v) {
              cat = v;
            },
            width: double.infinity,
            label: Text("Category"),
          ),
          SizedBox(height: 10),
          // Purpose
          DropdownMenu(
            dropdownMenuEntries: [
              DropdownMenuEntry(value: Purpose.transport, label: "Transport"),
              DropdownMenuEntry(value: Purpose.health, label: "Wellness"),
              DropdownMenuEntry(value: Purpose.education, label: "Education"),
              DropdownMenuEntry(value: Purpose.home, label: "Home"),
              DropdownMenuEntry(value: Purpose.others, label: "Other"),
            ],
            onSelected: (v) {
              purpose = v;
            },
            width: double.infinity,
            label: Text("Purpose"),
          ),
          SizedBox(height: 20),
          // Submit
          MaterialButton(
            onPressed: () async {
              // ignore: unnecessary_null_comparison
              if (title == "" ||
                  amount == 0.0 ||
                  date == null ||
                  desc == "" ||
                  cat == null ||
                  purpose == null) {
                Get.snackbar(
                  "Error",
                  "Please fill all the fields",
                  duration: Duration(seconds: 4),
                );
              } else {
                try {
                  await expenseManagerInstance.addExpense(
                    Expense(
                      title: title,
                      amount: amount,
                      date: date!,
                      desc: desc,
                      category: cat!,
                      purpose: purpose!,
                    ),
                  );
                  Get.back();
                  Get.snackbar(
                    "Success",
                    "Expense has been added successfully!",
                    duration: Duration(seconds: 4),
                  );
                  print(expenseManagerInstance.expenses);
                  appEventBus.fire(ExpensesUpdatedEvent());
                } catch (e) {
                  Get.snackbar(
                    "Error",
                    "Something went wrong! Try again.",
                    duration: Duration(seconds: 4),
                  );
                }
              }
            },
            color: Colors.lightBlue,
            minWidth: double.infinity,
            height: 50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Text("Submit", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
