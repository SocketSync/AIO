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
    return _transactions.where((t) {
      final matchesCategory = _selectedCategory == null || t.categoryId == _selectedCategory;
      final matchesType = _selectedType == null || t.type == _selectedType;
      final matchesQuery = _searchQuery.isEmpty ||
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (t.notes != null && t.notes!.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesType && matchesQuery;
    }).toList();
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

