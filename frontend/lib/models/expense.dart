class Expense {
  final int? id;
  final String date;
  final String description;
  final String category;
  final double amount;
  final String? subcategory;
  final String? paymentMethod;
  final String? location;
  final String? notes;
  final String? receiptImage;
  final bool isRecurring;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Expense({
    this.id,
    required this.date,
    required this.description,
    required this.category,
    required this.amount,
    this.subcategory,
    this.paymentMethod,
    this.location,
    this.notes,
    this.receiptImage,
    this.isRecurring = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      date: json['date'],
      description: json['description'],
      category: json['category'],
      amount: json['amount'].toDouble(),
      subcategory: json['subcategory'],
      paymentMethod: json['payment_method'],
      location: json['location'],
      notes: json['notes'],
      receiptImage: json['receipt_image'],
      isRecurring: json['is_recurring'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'description': description,
      'category': category,
      'amount': amount,
      'subcategory': subcategory,
      'payment_method': paymentMethod,
      'location': location,
      'notes': notes,
      'receipt_image': receiptImage,
      'is_recurring': isRecurring,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'description': description,
      'category': category,
      'amount': amount,
      'subcategory': subcategory,
      'payment_method': paymentMethod,
      'location': location,
      'notes': notes,
      'receipt_image': receiptImage,
      'is_recurring': isRecurring ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id']?.toInt(),
      date: map['date'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      subcategory: map['subcategory'],
      paymentMethod: map['payment_method'],
      location: map['location'],
      notes: map['notes'],
      receiptImage: map['receipt_image'],
      isRecurring: (map['is_recurring'] ?? 0) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  Expense copyWith({
    int? id,
    String? date,
    String? description,
    String? category,
    double? amount,
    String? subcategory,
    String? paymentMethod,
    String? location,
    String? notes,
    String? receiptImage,
    bool? isRecurring,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      subcategory: subcategory ?? this.subcategory,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      receiptImage: receiptImage ?? this.receiptImage,
      isRecurring: isRecurring ?? this.isRecurring,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
