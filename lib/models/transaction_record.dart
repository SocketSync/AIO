enum TransactionType {
  income,
  expense,
}

class TransactionRecord {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionRecord({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;

  TransactionRecord copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory TransactionRecord.fromJson(Map<String, dynamic> json) {
    return TransactionRecord(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? 'default_user',
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: (json['type'] == 'income')
          ? TransactionType.income
          : TransactionType.expense,
      categoryId: json['category_id'] as String? ?? 'other',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}

