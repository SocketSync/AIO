import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class DataPrivacySection extends StatelessWidget {
  final bool isExporting;
  final VoidCallback onExport;

  const DataPrivacySection({
    super.key,
    required this.isExporting,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data & Privacy',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Download a copy of your profile, preferences, transactions, savings goals, and activity.',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: isExporting ? null : onExport,
              icon: isExporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(
                isExporting ? 'Preparing JSON...' : 'Download My Data (JSON)',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
