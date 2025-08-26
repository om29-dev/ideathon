class Expense {
  final String date;
  final String description;
  final String category;
  final double amount;

  Expense({
    required this.date,
    required this.description,
    required this.category,
    required this.amount,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      date: json['date'],
      description: json['description'],
      category: json['category'],
      amount: json['amount'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'description': description,
      'category': category,
      'amount': amount,
    };
  }
}
