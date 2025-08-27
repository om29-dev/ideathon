class Investment {
  final int? id;
  final String name;
  final String type; // 'stock', 'mutual_fund', 'crypto', 'bond', 'sip'
  final double purchasePrice;
  final double currentPrice;
  final double quantity;
  final DateTime purchaseDate;
  final String? broker;
  final String? notes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Investment({
    this.id,
    required this.name,
    required this.type,
    required this.purchasePrice,
    required this.currentPrice,
    required this.quantity,
    required this.purchaseDate,
    this.broker,
    this.notes,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  double get investedAmount => purchasePrice * quantity;
  double get currentValue => currentPrice * quantity;
  double get gainLoss => currentValue - investedAmount;
  double get gainLossPercentage => (gainLoss / investedAmount) * 100;
  bool get isProfit => gainLoss > 0;

  String get typeIcon {
    switch (type.toLowerCase()) {
      case 'stock':
        return '📈';
      case 'mutual_fund':
        return '📊';
      case 'crypto':
        return '₿';
      case 'bond':
        return '🏦';
      case 'sip':
        return '💰';
      default:
        return '💼';
    }
  }

  String get displayType {
    switch (type.toLowerCase()) {
      case 'stock':
        return 'Stock';
      case 'mutual_fund':
        return 'Mutual Fund';
      case 'crypto':
        return 'Cryptocurrency';
      case 'bond':
        return 'Bond';
      case 'sip':
        return 'SIP';
      default:
        return type;
    }
  }

  int get holdingDays {
    final now = DateTime.now();
    return now.difference(purchaseDate).inDays;
  }

  String get holdingPeriod {
    final days = holdingDays;
    if (days < 30) {
      return '$days days';
    } else if (days < 365) {
      return '${(days / 30).floor()} months';
    } else {
      return '${(days / 365).floor()} years';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'purchase_price': purchasePrice,
      'current_price': currentPrice,
      'quantity': quantity,
      'purchase_date': purchaseDate.toIso8601String(),
      'broker': broker,
      'notes': notes,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Investment.fromMap(Map<String, dynamic> map) {
    return Investment(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      purchasePrice: map['purchase_price']?.toDouble() ?? 0.0,
      currentPrice: map['current_price']?.toDouble() ?? 0.0,
      quantity: map['quantity']?.toDouble() ?? 0.0,
      purchaseDate: DateTime.parse(map['purchase_date']),
      broker: map['broker'],
      notes: map['notes'],
      isActive: (map['is_active'] ?? 1) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  Investment copyWith({
    int? id,
    String? name,
    String? type,
    double? purchasePrice,
    double? currentPrice,
    double? quantity,
    DateTime? purchaseDate,
    String? broker,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Investment(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      currentPrice: currentPrice ?? this.currentPrice,
      quantity: quantity ?? this.quantity,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      broker: broker ?? this.broker,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
