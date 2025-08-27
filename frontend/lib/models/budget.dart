class Budget {
  final int? id;
  final String category;
  final double monthlyLimit;
  final double spentAmount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final double alertThreshold; // Percentage (0.8 = 80%)
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Budget({
    this.id,
    required this.category,
    required this.monthlyLimit,
    this.spentAmount = 0,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.alertThreshold = 0.8,
    this.createdAt,
    this.updatedAt,
  });

  double get remainingAmount => monthlyLimit - spentAmount;
  double get spentPercentage => spentAmount / monthlyLimit;
  bool get isOverBudget => spentAmount > monthlyLimit;
  bool get isNearLimit => spentPercentage >= alertThreshold;

  String get status {
    if (isOverBudget) return 'Over Budget';
    if (isNearLimit) return 'Near Limit';
    return 'On Track';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'monthly_limit': monthlyLimit,
      'spent_amount': spentAmount,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'alert_threshold': alertThreshold,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id']?.toInt(),
      category: map['category'] ?? '',
      monthlyLimit: map['monthly_limit']?.toDouble() ?? 0.0,
      spentAmount: map['spent_amount']?.toDouble() ?? 0.0,
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      isActive: (map['is_active'] ?? 1) == 1,
      alertThreshold: map['alert_threshold']?.toDouble() ?? 0.8,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  Budget copyWith({
    int? id,
    String? category,
    double? monthlyLimit,
    double? spentAmount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    double? alertThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      spentAmount: spentAmount ?? this.spentAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
