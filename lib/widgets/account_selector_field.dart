import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Brand badge metadata for a Malaysian bank.
class BankLogoStyle {
  final String code;
  final Color bgColor;
  final Color fgColor;

  const BankLogoStyle({
    required this.code,
    required this.bgColor,
    this.fgColor = Colors.white,
  });
}

/// Lookup table mapping Malaysian bank names to their brand monogram badge.
const Map<String, BankLogoStyle> malaysianBankLogos = {
  'Maybank': BankLogoStyle(code: 'MBB', bgColor: Color(0xFFFFC400), fgColor: Color(0xFF111827)),
  'CIMB Bank': BankLogoStyle(code: 'CIMB', bgColor: Color(0xFFDC2626)),
  'Public Bank': BankLogoStyle(code: 'PBB', bgColor: Color(0xFFB91C1C)),
  'RHB Bank': BankLogoStyle(code: 'RHB', bgColor: Color(0xFF0284C7)),
  'Hong Leong Bank': BankLogoStyle(code: 'HLB', bgColor: Color(0xFF1D4ED8)),
  'AmBank': BankLogoStyle(code: 'AM', bgColor: Color(0xFFE11D48)),
  'Bank Islam Malaysia': BankLogoStyle(code: 'BIMB', bgColor: Color(0xFF991B1B)),
  'Bank Muamalat': BankLogoStyle(code: 'BMMB', bgColor: Color(0xFFEA580C)),
  'Bank Rakyat': BankLogoStyle(code: 'BR', bgColor: Color(0xFF0369A1)),
  'BSN (Bank Simpanan Nasional)': BankLogoStyle(code: 'BSN', bgColor: Color(0xFF0284C7)),
  'OCBC Bank Malaysia': BankLogoStyle(code: 'OCBC', bgColor: Color(0xFFDC2626)),
  'UOB Malaysia': BankLogoStyle(code: 'UOB', bgColor: Color(0xFF1E3A8A)),
  'HSBC Malaysia': BankLogoStyle(code: 'HSBC', bgColor: Color(0xFFDB0011)),
  'Standard Chartered Malaysia': BankLogoStyle(code: 'SCB', bgColor: Color(0xFF059669)),
  'Alliance Bank': BankLogoStyle(code: 'ALB', bgColor: Color(0xFF0F766E)),
  'Affin Bank': BankLogoStyle(code: 'AB', bgColor: Color(0xFF1E40AF)),
  'MBSB Bank': BankLogoStyle(code: 'MBSB', bgColor: Color(0xFF0E7490)),
  'Agrobank': BankLogoStyle(code: 'AGRO', bgColor: Color(0xFF15803D)),
  'Kuwait Finance House Malaysia': BankLogoStyle(code: 'KFH', bgColor: Color(0xFF047857)),
  'Citibank Malaysia': BankLogoStyle(code: 'CITI', bgColor: Color(0xFF1D4ED8)),
  'GXBank': BankLogoStyle(code: 'GX', bgColor: Color(0xFF4F46E5)),
  'AEON Bank': BankLogoStyle(code: 'AEON', bgColor: Color(0xFF9333EA)),
  'Boost Bank': BankLogoStyle(code: 'BST', bgColor: Color(0xFFEA580C)),
  'Al Rajhi Bank Malaysia': BankLogoStyle(code: 'ARB', bgColor: Color(0xFF1E3A8A)),
  'Bank of China Malaysia': BankLogoStyle(code: 'BOC', bgColor: Color(0xFFB91C1C)),
};

Widget buildBankLogoBadge(String bankName) {
  final style = malaysianBankLogos[bankName] ??
      BankLogoStyle(
        code: bankName.length >= 3
            ? bankName.substring(0, 3).toUpperCase()
            : bankName.toUpperCase(),
        bgColor: AppColors.primary,
      );
  return Container(
    width: 34,
    height: 24,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: style.bgColor,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      style.code,
      style: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w800,
        color: style.fgColor,
        letterSpacing: -0.2,
      ),
      maxLines: 1,
      overflow: TextOverflow.clip,
    ),
  );
}

/// Expandable catalog of licensed Malaysian commercial, Islamic, and digital banks.
const List<String> malaysianBanks = [
  'Maybank',
  'CIMB Bank',
  'Public Bank',
  'RHB Bank',
  'Hong Leong Bank',
  'AmBank',
  'Bank Islam Malaysia',
  'Bank Muamalat',
  'Bank Rakyat',
  'BSN (Bank Simpanan Nasional)',
  'OCBC Bank Malaysia',
  'UOB Malaysia',
  'HSBC Malaysia',
  'Standard Chartered Malaysia',
  'Alliance Bank',
  'Affin Bank',
  'MBSB Bank',
  'Agrobank',
  'Kuwait Finance House Malaysia',
  'Citibank Malaysia',
  'GXBank',
  'AEON Bank',
  'Boost Bank',
  'Al Rajhi Bank Malaysia',
  'Bank of China Malaysia',
];

/// Reusable rounded Account selector field matching FinWise light-mode form styling.
///
/// Supports selecting between **Cash**, **Bank** (with a searchable Malaysian
/// bank list), and **E-Wallet** (**Touch 'n Go eWallet**).
class AccountSelectorField extends StatelessWidget {
  final String? accountType;
  final String? accountName;
  final String? errorText;
  final double borderRadius;
  final EdgeInsetsGeometry contentPadding;
  final void Function(String accountType, String accountName) onSelected;

  const AccountSelectorField({
    super.key,
    required this.accountType,
    required this.accountName,
    this.errorText,
    this.borderRadius = AppTheme.inputBorderRadius,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    required this.onSelected,
  });

  bool get _hasSelection =>
      accountName != null && accountName!.trim().isNotEmpty;

  IconData _leadingIcon() {
    switch (accountType) {
      case 'Cash':
        return Icons.payments_outlined;
      case 'Bank':
        return Icons.account_balance_outlined;
      case 'E-Wallet':
        return Icons.smartphone_outlined;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  Future<void> _openPicker(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AccountPickerSheet(
        initialAccountType: accountType,
        initialAccountName: accountName,
        onSelected: (type, name) {
          onSelected(type, name);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _openPicker(context),
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: contentPadding,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: errorText != null
                    ? AppColors.error
                    : AppColors.borderNeutral,
                width: errorText != null ? 1.2 : 1.0,
              ),
            ),
            child: Row(
              children: [
                if (accountType == 'Bank' && _hasSelection)
                  buildBankLogoBadge(accountName!)
                else
                  Icon(
                    _leadingIcon(),
                    size: 20,
                    color: _hasSelection ? AppColors.primary : AppColors.textMuted,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _hasSelection ? accountName! : 'Select Account',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          _hasSelection ? FontWeight.w500 : FontWeight.normal,
                      color: _hasSelection
                          ? AppColors.onSurface
                          : AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_hasSelection && accountType != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      accountType!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 6),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              errorText!,
              style: const TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ),
        ],
      ],
    );
  }
}

enum _PickerStep { main, bank, eWallet }

class _AccountPickerSheet extends StatefulWidget {
  final String? initialAccountType;
  final String? initialAccountName;
  final void Function(String accountType, String accountName) onSelected;

  const _AccountPickerSheet({
    this.initialAccountType,
    this.initialAccountName,
    required this.onSelected,
  });

  @override
  State<_AccountPickerSheet> createState() => _AccountPickerSheetState();
}

class _AccountPickerSheetState extends State<_AccountPickerSheet> {
  _PickerStep _step = _PickerStep.main;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _title {
    switch (_step) {
      case _PickerStep.main:
        return 'Select Account';
      case _PickerStep.bank:
        return 'Select Malaysian Bank';
      case _PickerStep.eWallet:
        return 'Select E-Wallet';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final filteredBanks = malaysianBanks
        .where((b) => b.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderNeutral,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (_step != _PickerStep.main)
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        size: 20, color: AppColors.onSurface),
                    onPressed: () {
                      setState(() {
                        _step = _PickerStep.main;
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  ),
                Expanded(
                  child: Text(
                    _title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close,
                      size: 20, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_step == _PickerStep.main) ...[
              _buildAccountTypeTile(
                icon: Icons.payments_outlined,
                title: 'Cash',
                subtitle: 'Physical cash on hand',
                isSelected: widget.initialAccountType == 'Cash',
                onTap: () => widget.onSelected('Cash', 'Cash'),
              ),
              const SizedBox(height: 8),
              _buildAccountTypeTile(
                icon: Icons.account_balance_outlined,
                title: 'Bank',
                subtitle: 'Maybank, CIMB, Public Bank & more',
                isSelected: widget.initialAccountType == 'Bank',
                showChevron: true,
                onTap: () => setState(() => _step = _PickerStep.bank),
              ),
              const SizedBox(height: 8),
              _buildAccountTypeTile(
                icon: Icons.smartphone_outlined,
                title: 'TNG',
                subtitle: "TNG (Touch 'n Go eWallet)",
                isSelected: widget.initialAccountType == 'E-Wallet',
                showChevron: true,
                onTap: () => setState(() => _step = _PickerStep.eWallet),
              ),
            ] else if (_step == _PickerStep.bank) ...[
              TextField(
                controller: _searchController,
                autofocus: false,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search Malaysian bank...',
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textMuted),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              size: 18, color: AppColors.textMuted),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: filteredBanks.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No matching Malaysian bank found',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: filteredBanks.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          color: AppColors.borderNeutral,
                        ),
                        itemBuilder: (_, index) {
                          final bank = filteredBanks[index];
                          final isSelected =
                              widget.initialAccountType == 'Bank' &&
                                  widget.initialAccountName == bank;
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            leading: buildBankLogoBadge(bank),
                            title: Text(
                              bank,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.onSurface,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle,
                                    size: 18, color: AppColors.primary)
                                : null,
                            onTap: () => widget.onSelected('Bank', bank),
                          );
                        },
                      ),
              ),
            ] else if (_step == _PickerStep.eWallet) ...[
              _buildAccountTypeTile(
                icon: Icons.account_balance_wallet_outlined,
                title: "TNG (Touch 'n Go eWallet)",
                subtitle: 'E-Wallet',
                isSelected: widget.initialAccountType == 'E-Wallet' &&
                    widget.initialAccountName == "Touch 'n Go eWallet",
                onTap: () =>
                    widget.onSelected('E-Wallet', "Touch 'n Go eWallet"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTypeTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    bool showChevron = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderNeutral,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (showChevron)
              const Icon(Icons.chevron_right,
                  size: 20, color: AppColors.textMuted)
            else if (isSelected)
              const Icon(Icons.check_circle,
                  size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
