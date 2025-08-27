class FinancialGoal {
  final int? id;
  final String title;
  final String? description;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String priority; // 'low', 'medium', 'high'
  final String status; // 'active', 'completed', 'paused'
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FinancialGoal({
    this.id,
    required this.title,
    this.description,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.targetDate,
    this.priority = 'medium',
    this.status = 'active',
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  double get progressPercentage => currentAmount / targetAmount;
  double get remainingAmount => targetAmount - currentAmount;
  bool get isCompleted => currentAmount >= targetAmount;

  int get daysRemaining {
    final now = DateTime.now();
    return targetDate.difference(now).inDays;
  }

  bool get isOverdue {
    final now = DateTime.now();
    return targetDate.isBefore(now) && !isCompleted;
  }

  double get requiredMonthlySaving {
    if (isCompleted) return 0;
    final now = DateTime.now();
    final monthsLeft =
        ((targetDate.year - now.year) * 12) + (targetDate.month - now.month);
    if (monthsLeft <= 0) return remainingAmount;
    return remainingAmount / monthsLeft;
  }

  String get priorityIcon {
    switch (priority) {
      case 'high':
        return '🔴';
      case 'medium':
        return '🟡';
      case 'low':
        return '🟢';
      default:
        return '⚪';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'target_date': targetDate.toIso8601String(),
      'priority': priority,
      'status': status,
      'category': category,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory FinancialGoal.fromMap(Map<String, dynamic> map) {
    return FinancialGoal(
      id: map['id']?.toInt(),
      title: map['title'] ?? '',
      description: map['description'],
      targetAmount: map['target_amount']?.toDouble() ?? 0.0,
      currentAmount: map['current_amount']?.toDouble() ?? 0.0,
      targetDate: DateTime.parse(map['target_date']),
      priority: map['priority'] ?? 'medium',
      status: map['status'] ?? 'active',
      category: map['category'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  FinancialGoal copyWith({
    int? id,
    String? title,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? priority,
    String? status,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
