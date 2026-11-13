import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/category_item.dart';
import '../models/transaction_record.dart';
import '../theme/app_theme.dart';

class TransactionCard extends StatefulWidget {
  final TransactionRecord transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final category = CategoryItem.getById(transaction.categoryId);
    final isIncome = transaction.isIncome;
    final currencyFormat = NumberFormat.currency(symbol: 'RM ', decimalDigits: 2);
    final dateFormat = DateFormat('MMM d, yyyy');
    final effectiveItems = transaction.receiptItems.isNotEmpty
        ? transaction.receiptItems
        : TransactionRecord.parseDetailsText(transaction.notes, category: category.name);
    final hasReceiptItems = effectiveItems.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderNeutral),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: hasReceiptItems
            ? () => setState(() => _isExpanded = !_isExpanded)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Description, Minimalist Details & Date/Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Description: ${transaction.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        if (hasReceiptItems) ...[
                          const SizedBox(width: 6),
                          const Text(
                            '🧾',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                    if (hasReceiptItems && _isExpanded) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'Details:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      ...effectiveItems.map((item) {
                        final itemName = (item['item_name'] ?? 'Item').toString();
                        final qty = (item['quantity'] as num?)?.toInt() ?? 1;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 1),
                          child: Text(
                            '${qty}x $itemName',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                              height: 1.3,
                            ),
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const Text(' • ', style: TextStyle(fontSize: 11, color: AppColors.outlineVariant)),
                        Text(
                          dateFormat.format(transaction.date),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    if (!hasReceiptItems && transaction.notes != null && transaction.notes!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        transaction.notes!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'}${currencyFormat.format(transaction.amount)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isIncome ? AppColors.secondary : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isIncome
                          ? AppColors.growthMintSubtle
                          : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isIncome ? 'INCOME' : 'EXPENSE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: isIncome ? AppColors.secondary : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),

              // Context Menu (Edit & Delete)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: AppColors.outline),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onSelected: (val) {
                  if (val == 'edit') {
                    widget.onEdit();
                  } else if (val == 'delete') {
                    widget.onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Edit', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(fontSize: 13, color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
