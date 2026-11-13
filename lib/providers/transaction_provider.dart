import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_record.dart';
import '../services/database_service.dart';

class TransactionProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final _uuid = const Uuid();

  List<TransactionRecord> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentUserId = '';

  // Filters
  String? _selectedCategory;
  TransactionType? _selectedType;
  String _searchQuery = '';

  // Getters
  List<TransactionRecord> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;
  TransactionType? get selectedType => _selectedType;
  String get searchQuery => _searchQuery;

  List<TransactionRecord> get filteredTransactions {
    final q = _searchQuery.toLowerCase();
    return _transactions.where((t) {
      final matchesCategory = _selectedCategory == null || t.categoryId == _selectedCategory;
      final matchesType = _selectedType == null || t.type == _selectedType;
      final matchesReceiptItem = q.isNotEmpty &&
          t.receiptItems.any((item) =>
              (item['item_name'] ?? '').toString().toLowerCase().contains(q) ||
              (item['category'] ?? '').toString().toLowerCase().contains(q));
      final matchesQuery = q.isEmpty ||
          t.title.toLowerCase().contains(q) ||
          (t.notes != null && t.notes!.toLowerCase().contains(q)) ||
          matchesReceiptItem;
      return matchesCategory && matchesType && matchesQuery;
    }).toList();
  }

  String _ordinalDay(int day) {
    if (day > 3 && day < 21) return '${day}th';
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  /// Analyzes the last 14 days of itemized receipt purchases for duplicate/frequent buys.
  String get aiPurchaseInsight {
    final cutoff = DateTime.now().subtract(const Duration(days: 14));
    final recentExpenses = _transactions
        .where((t) => t.isExpense && !t.date.isBefore(cutoff))
        .toList();

    final shoeDates = <DateTime>[];
    final coffeeDates = <DateTime>[];
    double shoeSpend = 0.0;
    double coffeeSpend = 0.0;

    for (final tx in recentExpenses) {
      if (tx.receiptItems.isNotEmpty) {
        for (final item in tx.receiptItems) {
          final name = (item['item_name'] ?? '').toString().toLowerCase();
          final cat = (item['category'] ?? '').toString().toLowerCase();
          final linePrice = ((item['price'] as num?)?.toDouble() ?? 0.0) *
              ((item['quantity'] as num?)?.toInt() ?? 1);
          if (name.contains('shoe') || name.contains('sneaker') || name.contains('footwear')) {
            shoeDates.add(tx.date);
            shoeSpend += linePrice;
          } else if (name.contains('coffee') ||
              name.contains('latte') ||
              name.contains('americano') ||
              cat.contains('coffee')) {
            coffeeDates.add(tx.date);
            coffeeSpend += linePrice;
          }
        }
      } else {
        final lower = tx.title.toLowerCase();
        if (lower.contains('shoe') || lower.contains('sneaker')) {
          shoeDates.add(tx.date);
          shoeSpend += tx.amount;
        } else if (lower.contains('coffee') || lower.contains('cafe')) {
          coffeeDates.add(tx.date);
          coffeeSpend += tx.amount;
        }
      }
    }

    if (shoeDates.length >= 2) {
      shoeDates.sort();
      final d1 = _ordinalDay(shoeDates.first.day);
      final d2 = _ordinalDay(shoeDates.last.day);
      return "✨ FinWise noticed: You bought shoes on the $d1 and the $d2 of this month! Treating yourself is great, but keep an eye on your 'Clothing' budget (RM ${shoeSpend.toStringAsFixed(2)} spent) to avoid overspending this month~";
    }

    if (coffeeDates.length >= 2) {
      return "✨ FinWise noticed: You bought coffee ${coffeeDates.length} times over the last 14 days (RM ${coffeeSpend.toStringAsFixed(2)} total). Brewing at home twice a week could grow your savings!";
    }

    return "✨ FinWise noticed: Your itemized receipt purchases over the last 14 days look well-balanced with no repetitive impulse buys!";
  }

  List<TransactionRecord> get recentTransactions {
    final sorted = List<TransactionRecord>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  double get totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalBalance => totalIncome - totalExpense;

  Map<String, double> get categoryExpenses {
    final map = <String, double>{};
    for (var t in _transactions.where((t) => t.type == TransactionType.expense)) {
      map[t.categoryId] = (map[t.categoryId] ?? 0.0) + t.amount;
    }
    return map;
  }

  // Load transactions for user
  Future<void> fetchTransactions(String userId) async {
    _currentUserId = userId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await _databaseService.getTransactions(userId);
    } catch (e) {
      _errorMessage = 'Failed to load transactions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CREATE: Add transaction
  Future<bool> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required String categoryId,
    required DateTime date,
    String? notes,
    List<Map<String, dynamic>> receiptItems = const [],
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newRecord = TransactionRecord(
        id: _uuid.v4(),
        userId: _currentUserId.isEmpty ? 'guest_user' : _currentUserId,
        title: title,
        amount: amount,
        type: type,
        categoryId: categoryId,
        date: date,
        notes: notes,
        receiptItems: receiptItems,
      );

      final created = await _databaseService.createTransaction(newRecord);
      _transactions.insert(0, created);
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add transaction: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // UPDATE: Update transaction
  Future<bool> updateTransaction(TransactionRecord updatedRecord) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _databaseService.updateTransaction(updatedRecord);
      final index = _transactions.indexWhere((t) => t.id == updated.id);
      if (index != -1) {
        _transactions[index] = updated;
        _transactions.sort((a, b) => b.date.compareTo(a.date));
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update transaction: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // DELETE: Delete transaction
  Future<bool> deleteTransaction(String transactionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _databaseService.deleteTransaction(
        transactionId,
        _currentUserId.isEmpty ? 'guest_user' : _currentUserId,
      );
      if (success) {
        _transactions.removeWhere((t) => t.id == transactionId);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete transaction: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Set filter options
  void setCategoryFilter(String? categoryId) {
    _selectedCategory = categoryId;
    notifyListeners();
  }

  void setTypeFilter(TransactionType? type) {
    _selectedType = type;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = null;
    _selectedType = null;
    _searchQuery = '';
    notifyListeners();
  }
}

