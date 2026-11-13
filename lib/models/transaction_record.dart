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
  final List<Map<String, dynamic>> receiptItems;
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
    this.receiptItems = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;
  bool get hasReceiptItems => receiptItems.isNotEmpty;

  TransactionRecord copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    DateTime? date,
    String? notes,
    List<Map<String, dynamic>>? receiptItems,
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
      receiptItems: receiptItems ?? this.receiptItems,
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
      'receipt_items': receiptItems,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toSupabaseMap() {
    final map = <String, dynamic>{
      'user_id': userId,
      'title': title,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'category_id': categoryId,
      'transaction_date': date.toIso8601String(),
      'notes': notes,
      'receipt_items': receiptItems,
    };
    // Include valid UUIDs if already assigned
    if (id.isNotEmpty && !id.startsWith('mock_')) {
      map['id'] = id;
    }
    return map;
  }

  static List<Map<String, dynamic>> _parseReceiptItems(dynamic raw) {
    if (raw is! List) return const [];
    final parsed = <Map<String, dynamic>>[];
    for (final item in raw) {
      if (item is Map) {
        final name = (item['item_name'] ?? item['name'] ?? '').toString().trim();
        if (name.isEmpty) continue;
        final price = (item['price'] as num?)?.toDouble() ??
            double.tryParse((item['price'] ?? '0').toString()) ??
            0.0;
        final qty = (item['quantity'] as num?)?.toInt() ??
            int.tryParse((item['quantity'] ?? '1').toString()) ??
            1;
        final cat = (item['category'] ?? 'General').toString().trim();
        parsed.add({
          'item_name': name,
          'price': price < 0 ? 0.0 : price,
          'quantity': qty < 1 ? 1 : qty,
          'category': cat.isEmpty ? 'General' : cat,
        });
      }
    }
    return parsed;
  }

  factory TransactionRecord.fromJson(Map<String, dynamic> json) {
    return TransactionRecord(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? 'default_user').toString(),
      title: (json['title'] ?? '') as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: (json['type'] == 'income')
          ? TransactionType.income
          : TransactionType.expense,
      categoryId: (json['category_id'] ?? 'other').toString(),
      date: json['transaction_date'] != null
          ? DateTime.parse(json['transaction_date'] as String)
          : (json['date'] != null
              ? DateTime.parse(json['date'] as String)
              : DateTime.now()),
      notes: json['notes'] as String?,
      receiptItems: _parseReceiptItems(json['receipt_items']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}
