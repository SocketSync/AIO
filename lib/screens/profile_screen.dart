import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../providers/profile_provider.dart';
import '../providers/savings_goal_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/auth_service.dart';
import '../services/profile_export_service.dart';
import '../theme/app_theme.dart';
import '../widgets/profile/danger_zone_modal.dart';
import '../widgets/profile/data_privacy_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _budgetController = TextEditingController();
  bool _isExporting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _syncControllers(ProfileProvider profile) {
    _nameController.text = profile.displayName;
    _usernameController.text = profile.username;
    _bioController.text = profile.bio;
    _phoneController.text = profile.phone;
    _budgetController.text = profile.monthlyBudget.toStringAsFixed(2);
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.alertCoral : AppColors.secondary,
      ),
    );
  }

  Future<void> _save(ProfileProvider profile) async {
    if (!_formKey.currentState!.validate()) return;
    final success = await profile.save(context.read<AuthService>());
    if (!mounted) return;
    if (success) {
      final theme = context.read<ThemeProvider>();
      await theme.setThemeMode(_themeMode(profile.themePreference));
      _showMessage('Profile updated successfully.');
    } else {
      _showMessage(profile.errorMessage ?? 'Failed to update profile.',
          isError: true);
    }
  }

  Future<void> _reset(ProfileProvider profile) async {
    await profile.reset();
    if (!mounted) return;
    _syncControllers(profile);
  }

  Future<void> _export(ProfileProvider profile) async {
    setState(() => _isExporting = true);
    try {
      final auth = context.read<AuthService>();
      final transactions = context.read<TransactionProvider>().transactions;
      final goals = context.read<SavingsGoalProvider>().goals;
      final user = auth.currentUser;
      final exportProfile = UserProfile(
        id: user?.id ?? '',
        email: profile.email,
        displayName: profile.displayName,
        username: profile.username,
        bio: profile.bio,
        avatarUrl: profile.avatarUrl,
        phone: profile.phone,
        occupation: profile.bio,
        currency: profile.currency,
        monthlyBudget: profile.monthlyBudget,
        themePreference: profile.themePreference,
        aiInsightsEnabled: profile.aiInsightsEnabled,
        overspendingAlertsEnabled: profile.overspendingAlertsEnabled,
      );
      final fileName = await ProfileExportService().downloadProfileData(
        profile: exportProfile,
        transactions: transactions,
        savingsGoals: goals,
      );
      if (!mounted) return;
      _showMessage('Downloaded $fileName');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Could not export profile data.', isError: true);
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _deleteAccount() async {
    final auth = context.read<AuthService>();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DangerZoneModal(authService: auth),
    );
    if (confirmed != true || !mounted) return;
    context.read<TransactionProvider>().clear();
    context.read<SavingsGoalProvider>().clear();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  ThemeMode _themeMode(String value) {
    if (value == 'light') return ThemeMode.light;
    if (value == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = ProfileProvider();
        provider.load(context.read<AuthService>());
        return provider;
      },
      child: Consumer<ProfileProvider>(
        builder: (context, profile, _) {
          if (!profile.isLoading &&
              _nameController.text.isEmpty &&
              profile.displayName.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _syncControllers(profile);
            });
          }

          final initial = profile.displayName.isNotEmpty
              ? profile.displayName.characters.first.toUpperCase()
              : 'U';

          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile & Settings'),
              actions: [
                TextButton(
                  onPressed: profile.isDirty && !profile.isSaving
                      ? () => _reset(profile)
                      : null,
                  child: const Text('Reset'),
                ),
                TextButton(
                  onPressed: profile.isDirty && !profile.isSaving
                      ? () => _save(profile)
                      : null,
                  child: profile.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
            body: profile.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _ProfileHeader(
                          initial: initial,
                          avatarUrl: profile.avatarUrl,
                          avatarBytes: profile.avatarBytes,
                          displayName: profile.displayName,
                          email: profile.email,
                          onPickAvatar: () async {
                            final error = await profile.pickAvatar();
                            if (error != null && mounted) {
                              _showMessage(error, isError: true);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Personal Details',
                          icon: Icons.person,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                  labelText: 'Display Name'),
                              onChanged: profile.setDisplayName,
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                      ? 'Display name is required'
                                      : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _usernameController,
                              decoration:
                                  const InputDecoration(labelText: 'Username'),
                              onChanged: profile.setUsername,
                              validator: (value) =>
                                  RegExp(r'^[A-Za-z0-9_]{3,30}$')
                                          .hasMatch(value?.trim() ?? '')
                                      ? null
                                      : '3-30 letters, numbers, or underscores',
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _bioController,
                              maxLength: 160,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Bio',
                                alignLabelWithHint: true,
                              ),
                              onChanged: profile.setBio,
                              validator: (value) => (value?.length ?? 0) <= 160
                                  ? null
                                  : 'Bio must be 160 characters or fewer',
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                  labelText: 'Phone Number'),
                              onChanged: profile.setPhone,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Account',
                          icon: Icons.mail,
                          children: [
                            TextFormField(
                              initialValue: profile.email,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                suffixIcon: Icon(Icons.lock_outline),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Appearance & Notifications',
                          icon: Icons.tune,
                          children: [
                            DropdownButtonFormField<String>(
                              initialValue: profile.themePreference,
                              decoration:
                                  const InputDecoration(labelText: 'Theme'),
                              items: const [
                                DropdownMenuItem(
                                    value: 'light', child: Text('Light')),
                                DropdownMenuItem(
                                    value: 'dark', child: Text('Dark')),
                                DropdownMenuItem(
                                    value: 'system', child: Text('System')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  profile.setThemePreference(value);
                                }
                              },
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('AI Spending Insights'),
                              value: profile.aiInsightsEnabled,
                              onChanged: profile.setAiInsightsEnabled,
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Overspending Alerts'),
                              value: profile.overspendingAlertsEnabled,
                              onChanged: profile.setOverspendingAlertsEnabled,
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: profile.currency,
                              decoration:
                                  const InputDecoration(labelText: 'Currency'),
                              items: const [
                                DropdownMenuItem(
                                    value: 'RM', child: Text('RM')),
                                DropdownMenuItem(
                                    value: 'USD', child: Text('USD')),
                                DropdownMenuItem(
                                    value: 'SGD', child: Text('SGD')),
                                DropdownMenuItem(
                                    value: 'EUR', child: Text('EUR')),
                                DropdownMenuItem(
                                    value: 'GBP', child: Text('GBP')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  profile.setCurrency(value);
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _budgetController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: const InputDecoration(
                                  labelText: 'Monthly Budget'),
                              onChanged: (value) {
                                final budget = double.tryParse(value);
                                if (budget != null) {
                                  profile.setMonthlyBudget(budget);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DataPrivacySection(
                          isExporting: _isExporting,
                          onExport: () => _export(profile),
                        ),
                        const SizedBox(height: 16),
                        _DangerZone(onDelete: _deleteAccount),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String initial;
  final String? avatarUrl;
  final Uint8List? avatarBytes;
  final String displayName;
  final String email;
  final VoidCallback onPickAvatar;

  const _ProfileHeader({
    required this.initial,
    required this.avatarUrl,
    required this.avatarBytes,
    required this.displayName,
    required this.email,
    required this.onPickAvatar,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar;
    if (avatarBytes != null) {
      avatar = CircleAvatar(
        radius: 44,
        backgroundImage: MemoryImage(avatarBytes!),
      );
    } else if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: 44,
        backgroundImage:
            avatarUrl!.startsWith('http') ? NetworkImage(avatarUrl!) : null,
        child: avatarUrl!.startsWith('http')
            ? null
            : Text(initial,
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      );
    } else {
      avatar = CircleAvatar(
        radius: 44,
        child: Text(initial,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      );
    }
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              children: [
                avatar,
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IconButton(
                    onPressed: onPickAvatar,
                    tooltip: 'Upload avatar',
                    icon: const Icon(Icons.photo_camera),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(displayName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(email, style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
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
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  final VoidCallback onDelete;

  const _DangerZone({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.alertCoralSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.alertCoral),
      ),
      child: ListTile(
        leading: const Icon(Icons.delete_forever, color: AppColors.alertCoral),
        title: const Text(
          'Danger Zone',
          style: TextStyle(
              color: AppColors.alertCoral, fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Permanently delete your account and data'),
        trailing: FilledButton(
          onPressed: onDelete,
          style: FilledButton.styleFrom(backgroundColor: AppColors.alertCoral),
          child: const Text('Delete Account'),
        ),
      ),
    );
  }
}
