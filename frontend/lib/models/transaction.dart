class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String category;
  final String? description;
  final String? location;
  final String? imageUrl;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.description,
    this.location,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.name,
      'category': category,
      'description': description,
      'location': location,
      'imageUrl': imageUrl,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      type: TransactionType.values.firstWhere((e) => e.name == json['type']),
      category: json['category'],
      description: json['description'],
      location: json['location'],
      imageUrl: json['imageUrl'],
    );
  }
}

enum TransactionType { income, expense, transfer }

class FinancialInsight {
  final String title;
  final String description;
  final double value;
  final InsightType type;
  final DateTime generatedAt;

  FinancialInsight({
    required this.title,
    required this.description,
    required this.value,
    required this.type,
    required this.generatedAt,
  });
}

enum InsightType { savings, expense, budget, investment, warning, achievement }

class Investment {
  final String id;
  final String name;
  final String symbol;
  final double currentPrice;
  final double purchasePrice;
  final int quantity;
  final DateTime purchaseDate;
  final InvestmentType type;

  Investment({
    required this.id,
    required this.name,
    required this.symbol,
    required this.currentPrice,
    required this.purchasePrice,
    required this.quantity,
    required this.purchaseDate,
    required this.type,
  });

  double get totalValue => currentPrice * quantity;
  double get totalCost => purchasePrice * quantity;
  double get profit => totalValue - totalCost;
  double get profitPercentage => (profit / totalCost) * 100;
}

enum InvestmentType { stock, mutualFund, etf, bond, crypto }
