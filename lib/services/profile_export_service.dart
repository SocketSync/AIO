import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';

import '../models/savings_goal.dart';
import '../models/transaction_record.dart';
import '../models/user_profile.dart';

class ProfileExportService {
  Future<String> downloadProfileData({
    required UserProfile profile,
    required List<TransactionRecord> transactions,
    required List<SavingsGoal> savingsGoals,
  }) async {
    final now = DateTime.now();
    final date =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final export = <String, dynamic>{
      'exported_at': now.toIso8601String(),
      'profile': profile.toJson(),
      'preferences': {
        'currency': profile.currency,
        'monthly_budget': profile.monthlyBudget,
        'theme': profile.themePreference,
        'ai_insights_enabled': profile.aiInsightsEnabled,
        'overspending_alerts_enabled': profile.overspendingAlertsEnabled,
      },
      'transactions': transactions.map((item) => item.toJson()).toList(),
      'savings_goals': savingsGoals.map((item) => item.toJson()).toList(),
      'activity': [
        for (final item in transactions)
          {
            'type': 'transaction',
            'id': item.id,
            'title': item.title,
            'created_at': item.createdAt.toIso8601String(),
          },
        for (final item in savingsGoals)
          {
            'type': 'savings_goal',
            'id': item.id,
            'title': item.goalName,
            'created_at': item.createdAt.toIso8601String(),
          },
      ],
    };

    final bytes = Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(export)),
    );
    final fileName = 'user_profile_export_$date';
    await FileSaver.instance.saveFile(
      name: fileName,
      bytes: bytes,
      fileExtension: 'json',
      mimeType: MimeType.json,
    );
    return '$fileName.json';
  }
}
