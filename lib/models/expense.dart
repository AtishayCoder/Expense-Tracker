class Expense {
  final String title;
  final double amount;
  final DateTime date;
  final String desc;
  final ExpenseCategory category;
  final Purpose purpose;

  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.desc,
    required this.category,
    required this.purpose,
  });

  Map<String, dynamic> toJson() => {
    "title": title,
    "amount": amount,
    "date": date.toIso8601String(),
    "desc": desc,
    "category": category == ExpenseCategory.need ? "need" : "want",
    "purpose": purpose.toString().split('.').last,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    title: json["title"],
    amount: json["amount"],
    date: DateTime.parse(json["date"]),
    desc: json["desc"],
    category: json["category"] == "need"
        ? ExpenseCategory.need
        : ExpenseCategory.want,
    purpose: Purpose.values.firstWhere(
      (element) => element.toString().split('.').last == json["purpose"],
    ),
  );
}

enum ExpenseCategory { need, want }

enum Purpose { transport, health, education, home, others }
