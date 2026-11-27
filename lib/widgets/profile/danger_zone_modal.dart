import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class DangerZoneModal extends StatefulWidget {
  final AuthService authService;

  const DangerZoneModal({super.key, required this.authService});

  @override
  State<DangerZoneModal> createState() => _DangerZoneModalState();
}

class _DangerZoneModalState extends State<DangerZoneModal> {
  final _controller = TextEditingController();
  bool _isDeleting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    setState(() => _isDeleting = true);
    final success = await widget.authService.deleteAccount();
    if (!mounted) return;
    Navigator.of(context).pop(success);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded,
          color: AppColors.alertCoral, size: 40),
      title: const Text('Delete account permanently?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This permanently deletes your profile, transactions, savings goals, and authentication record. This cannot be undone.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Download My Data before continuing if you want a copy.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              enabled: !_isDeleting,
              decoration: const InputDecoration(
                labelText: 'Type DELETE to confirm',
              ),
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _isDeleting ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: !_isDeleting && _controller.text.trim() == 'DELETE'
              ? _delete
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.alertCoral,
          ),
          child: _isDeleting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Permanently Delete'),
        ),
      ],
    );
  }
}
