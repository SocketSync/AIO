import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/category_item.dart';
import '../models/transaction_record.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/account_selector_field.dart';
import '../widgets/responsive_page_container.dart';

/// Full-screen transaction entry UI for recording a new income or expense.
///
/// Captures transaction type (Expense/Income segmented toggle), RM amount,
/// description/title, category chip selection, date via `showDatePicker`, and
/// optional line-item details (plus a Smart Receipt AI scanner shortcut), then
/// submits the validated entry through [TransactionProvider.addTransaction].
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // Form controllers and transaction entry state fields
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  String _selectedCategoryId = 'food_dining';
  String? _selectedAccountType;
  String? _selectedAccountName;
  String? _accountError;
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Validates required transaction fields (`amount > 0`, non-empty
  /// description, and selected category) and surfaces inline `Form` errors or
  /// SnackBar error messages before persisting via `TransactionProvider`.
  Future<void> _handleSave() async {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    final hasAccount =
        _selectedAccountType != null && _selectedAccountName != null;
    if (!hasAccount) {
      setState(() => _accountError = 'Please select an account');
    }
    if (!isFormValid || !hasAccount) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount greater than 0'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedCategoryId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a transaction category'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final rawNote = _noteController.text.trim();
    final rawDetails = _descriptionController.text.trim();
    final categoryName = CategoryItem.getById(_selectedCategoryId).name;
    final parsedItems = rawDetails.isEmpty
        ? const <Map<String, dynamic>>[]
        : TransactionRecord.parseDetailsText(rawDetails, category: categoryName);
    final success = await provider.addTransaction(
      title: rawNote,
      amount: amount,
      type: _selectedType,
      categoryId: _selectedCategoryId,
      accountType: _selectedAccountType,
      accountName: _selectedAccountName,
      date: _selectedDate,
      notes: rawDetails.isEmpty ? null : rawDetails,
      receiptItems: parsedItems,
    );

    setState(() => _isSubmitting = false);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction "$rawNote" saved!'),
          backgroundColor: AppColors.secondary,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableCategories = CategoryItem.defaultCategories
        .where((c) => _selectedType == TransactionType.expense ? c.isExpense : !c.isExpense)
        .toList();

    // Ensure selected category is valid for chosen type
    if (!availableCategories.any((c) => c.id == _selectedCategoryId)) {
      _selectedCategoryId = availableCategories.first.id;
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Transaction',
          style: TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ResponsivePageContainer(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Smart Receipt AI Scan Banner
                InkWell(
                  onTap: () => Navigator.of(context).pushNamed('/scanner'),
                  borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.document_scanner, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Smart Receipt AI',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text('2s auto', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                                ],
                              ),
                              Text(
                                'Scan Receipt with AI',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                              ),
                              Text(
                                'Extract merchant, total & items',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pushNamed('/scanner'),
                          icon: const Icon(Icons.photo_camera, size: 14),
                          label: const Text('Scan', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.sectionSpacing),

                // 1. Expense vs Income Segmented Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedType = TransactionType.expense;
                              _selectedCategoryId = 'food_dining';
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: _selectedType == TransactionType.expense
                                  ? AppColors.surfaceContainerLowest
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _selectedType == TransactionType.expense
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.06),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_downward,
                                  size: 16,
                                  color: _selectedType == TransactionType.expense
                                      ? AppColors.alertCoral
                                      : AppColors.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Expense',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _selectedType == TransactionType.expense
                                          ? AppColors.onSurface
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedType = TransactionType.income;
                              _selectedCategoryId = 'salary';
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: _selectedType == TransactionType.income
                                  ? AppColors.surfaceContainerLowest
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _selectedType == TransactionType.income
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.06),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  size: 16,
                                  color: _selectedType == TransactionType.income
                                      ? AppColors.secondary
                                      : AppColors.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Income',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _selectedType == TransactionType.income
                                          ? AppColors.onSurface
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Amount Input Field (RM)
                const Text(
                  'Amount',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
                    border: Border.all(color: AppColors.borderNeutral, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'RM',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                          decoration: const InputDecoration(
                            hintText: '0.00',
                            border: InputBorder.none,
                          ),
                          // Inline validation: require a positive numeric amount (> 0).
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Enter amount';
                            final n = double.tryParse(val.trim());
                            if (n == null || n <= 0) return 'Enter valid amount > 0';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Category Selector Chips
                const Text(
                  'Category',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableCategories.map((cat) {
                    final isSelected = cat.id == _selectedCategoryId;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryId = cat.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? cat.color.withValues(alpha: 0.16) : AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected ? cat.color : AppColors.borderNeutral,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat.icon, size: 16, color: isSelected ? cat.color : AppColors.textMuted),
                            const SizedBox(width: 6),
                            Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? cat.color : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 4. Account Selection (Cash / Malaysian Bank / TNG eWallet)
                const Text(
                  'Account',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                AccountSelectorField(
                  accountType: _selectedAccountType,
                  accountName: _selectedAccountName,
                  errorText: _accountError,
                  onSelected: (type, name) {
                    setState(() {
                      _selectedAccountType = type;
                      _selectedAccountName = name;
                      _accountError = null;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // 5. Note Field (short text input)
                const Text(
                  'Note',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
                    border: Border.all(color: AppColors.borderNeutral),
                  ),
                  child: TextFormField(
                    controller: _noteController,
                    style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
                    decoration: const InputDecoration(
                      hintText: 'e.g. Monthly groceries, Lunch with friends, Salary',
                      prefixIcon: Icon(Icons.edit_note, color: AppColors.textMuted),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    // Inline validation: require a non-empty transaction note.
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Please provide a note';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // 6. Description Field (multiline text area)
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
                    border: Border.all(color: AppColors.borderNeutral),
                  ),
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13, color: AppColors.onSurface),
                    decoration: const InputDecoration(
                      hintText: 'Additional transaction details (optional)',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 7. Date Selection
                const Text(
                  'Date',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
                      border: Border.all(color: AppColors.borderNeutral),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined, size: 20, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 7. Save Transaction Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 20),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Save Transaction',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

