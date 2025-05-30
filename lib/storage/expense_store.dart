import "dart:convert";

import "package:expense_tracker/models/expense.dart";
import "package:shared_preferences/shared_preferences.dart";

class ExpenseStorage {
  static const _key = 'expenses';

  static Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = expenses.map((e) => e.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  static Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => Expense.fromJson(e)).toList();
  }
}
