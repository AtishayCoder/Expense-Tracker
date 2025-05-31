import "package:expense_tracker/models/expense.dart";
import "package:expense_tracker/storage/expense_store.dart";

class ExpenseManager {
  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  Future<void> loadExpenses() async {
    _expenses = await ExpenseStorage.loadExpenses();
  }

  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
    await ExpenseStorage.saveExpenses(_expenses);
  }

  Future<void> deleteExpense(int index) async {
    _expenses.removeAt(index);
    await ExpenseStorage.saveExpenses(_expenses);
  }

  double getTotal() {
    return _expenses.fold(0, (sum, e) => sum + e.amount);
  }

  Future<void> clearAllExpenses() async {
    _expenses.clear();
    await ExpenseStorage.clearExpenses();
  }
}

final ExpenseManager expenseManagerInstance = ExpenseManager();
