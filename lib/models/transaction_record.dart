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

  static String formatReceiptItemsToDetails(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return '';
    return items
        .map((it) {
          final qty = (it['quantity'] as num?)?.toInt() ?? 1;
          final name = (it['item_name'] ?? it['name'] ?? '').toString().trim();
          return name.isEmpty ? '' : '${qty < 1 ? 1 : qty}x $name';
        })
        .where((s) => s.isNotEmpty)
        .join('\n');
  }

  static List<Map<String, dynamic>> parseDetailsText(
    String? text, {
    String category = 'General',
  }) {
    final raw = (text ?? '').trim();
    if (raw.isEmpty) return const [];
    var lines = raw
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.length == 1 &&
        lines.first.contains(',') &&
        RegExp(r'\b\d+\s*[x×]\s*', caseSensitive: false).hasMatch(lines.first)) {
      lines = lines.first
          .split(',')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
    }
    final qtyRegex = RegExp(r'^(\d+)\s*[x×]\s+(.+)$', caseSensitive: false);
    final parsed = <Map<String, dynamic>>[];
    for (final line in lines) {
      final clean = line.replaceFirst(RegExp(r'^[-*•]\s*'), '').trim();
      if (clean.isEmpty) continue;
      int qty = 1;
      String name = clean;
      final match = qtyRegex.firstMatch(clean);
      if (match != null) {
        qty = int.tryParse(match.group(1) ?? '1') ?? 1;
        name = (match.group(2) ?? '').trim();
      }
      if (name.isEmpty) continue;
      parsed.add({
        'item_name': name.length > 120 ? name.substring(0, 120) : name,
        'price': 0.0,
        'quantity': qty < 1 ? 1 : (qty > 999 ? 999 : qty),
        'category': category.isEmpty ? 'General' : category,
      });
    }
    return parsed.take(40).toList();
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
    final notesStr = json['notes'] as String?;
    var items = _parseReceiptItems(json['receipt_items']);
    if (items.isEmpty && notesStr != null && notesStr.trim().isNotEmpty) {
      items = parseDetailsText(
        notesStr,
        category: (json['category'] ?? 'General').toString(),
      );
    }
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
      notes: notesStr,
      receiptItems: items,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}
