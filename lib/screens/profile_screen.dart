import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _occupationController;
  late TextEditingController _budgetController;
  late TextEditingController _currentPassController;
  late TextEditingController _newPassController;
  late TextEditingController _confirmPassController;

  String _selectedCurrency = 'RM';
  String? _selectedAvatarEmoji;
  bool _hideCurrentPass = true;
  bool _hideNewPass = true;
  bool _hideConfirmPass = true;
  bool _aiInsightsEnabled = true;
  bool _alertsEnabled = true;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthService>(context, listen: false);
    final user = auth.currentUser;

    _nameController = TextEditingController(text: user?.displayName ?? 'Demo Finwise');
    _emailController = TextEditingController(text: user?.email ?? 'demo@finwise-app.xyz');
    _phoneController = TextEditingController(text: '');
    _occupationController = TextEditingController(text: '');
    _budgetController = TextEditingController(text: '2500.00');
    _currentPassController = TextEditingController();
    _newPassController = TextEditingController();
    _confirmPassController = TextEditingController();
    _selectedAvatarEmoji = user?.photoUrl;

    if (user != null) {
      DatabaseService().getUserProfile(
        userId: user.id,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
      ).then((profile) {
        if (mounted) {
          setState(() {
            if (profile.phone != null && profile.phone!.isNotEmpty) {
              _phoneController.text = profile.phone!;
            }
            if (profile.occupation != null && profile.occupation!.isNotEmpty) {
              _occupationController.text = profile.occupation!;
            }
            if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
              _selectedAvatarEmoji = profile.avatarUrl;
            }
            _selectedCurrency = profile.currency;
            _budgetController.text = profile.monthlyBudget.toStringAsFixed(2);
          });
        }
      }).catchError((_) {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _occupationController.dispose();
    _budgetController.dispose();
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _openAvatarPicker() {
    final emojis = ['🦊', '🦉', '🦁', '🚀', '💎', '🌟', '🧑‍💼', '👩‍💻', '🕶️', '💼', '🎓', '🏆'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Choose Profile Avatar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: emojis.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final e = emojis[index];
                  return InkWell(
                    onTap: () {
                      setState(() => _selectedAvatarEmoji = e);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderNeutral),
                      ),
                      alignment: Alignment.center,
                      child: Text(e, style: const TextStyle(fontSize: 22)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() => _selectedAvatarEmoji = null);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset to Initial Letter'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    final auth = Provider.of<AuthService>(context, listen: false);

    // Security Check: Demo account is strictly prohibited from altering profile information
    if (auth.currentUser?.email.toLowerCase().trim() == 'demo@finwise-app.xyz' ||
        auth.currentUser?.id == '00000000-0000-4000-8000-000000000001') {
      _showDemoRestrictedDialog();
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final success = await auth.updateUserProfile(
      newName: _nameController.text.trim(),
      newEmail: _emailController.text.trim(),
      currentPassword: _currentPassController.text.isNotEmpty ? _currentPassController.text : null,
      newPassword: _newPassController.text.isNotEmpty ? _newPassController.text : null,
      photoUrl: _selectedAvatarEmoji,
      phone: _phoneController.text.trim(),
      occupation: _occupationController.text.trim(),
      currency: _selectedCurrency,
      monthlyBudget: double.tryParse(_budgetController.text),
    );

    if (!mounted) return;

    if (success) {
      _currentPassController.clear();
      _newPassController.clear();
      _confirmPassController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Profile and database updated successfully!'),
            ],
          ),
          backgroundColor: AppColors.secondary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Failed to update profile.'),
          backgroundColor: AppColors.alertCoral,
        ),
      );
    }
  }

  void _showDemoRestrictedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.shield_outlined, color: AppColors.alertCoral, size: 44),
        title: const Text(
          'Demo Account Restricted',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'On the demo account, you cannot delete or alter profile info. The demo account is strictly for demonstrating input and output functions (transactions, expenses, and analytics), while editing or deleting the profile is strictly prohibited.',
          style: TextStyle(fontSize: 13, height: 1.5),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteProfile() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final user = auth.currentUser;
    if (user?.email.toLowerCase().trim() == 'demo@finwise-app.xyz' ||
        user?.id == '00000000-0000-4000-8000-000000000001') {
      _showDemoRestrictedDialog();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.delete_forever, color: AppColors.alertCoral, size: 40),
        title: const Text(
          'Permanently Delete Profile?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: const Text(
          'This will permanently delete your user profile, all recorded transactions, and cloud authentication credentials from Supabase.\n\nThis action is irreversible. Are you sure you wish to proceed?',
          style: TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.alertCoral),
            child: const Text('Permanently Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await auth.deleteAccount();
      if (!mounted) return;
      if (success) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Failed to delete account.'),
            backgroundColor: AppColors.alertCoral,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;
    final displayName = user?.displayName ?? _nameController.text;
    final initial = (displayName.isNotEmpty ? displayName[0] : 'U').toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'User Profile & Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: auth.isLoading ? null : _saveChanges,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // HERO AVATAR CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryContainer, AppColors.primary],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _openAvatarPicker,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.white,
                          child: (_selectedAvatarEmoji != null && _selectedAvatarEmoji!.isNotEmpty)
                              ? (_selectedAvatarEmoji!.startsWith('http')
                                  ? ClipOval(
                                      child: Image.network(
                                        _selectedAvatarEmoji!,
                                        width: 88,
                                        height: 88,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Text(initial, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                      ),
                                    )
                                  : Text(_selectedAvatarEmoji!, style: const TextStyle(fontSize: 36)))
                              : Text(
                                  initial,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.photo_camera, size: 16, color: AppColors.secondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? _emailController.text,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: _openAvatarPicker,
                    icon: const Icon(Icons.image, size: 16, color: Colors.white),
                    label: const Text(
                      'Change Profile Picture',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // SECTION 1: Personal Details
            _buildSectionCard(
              title: 'Personal Details',
              subtitle: 'Identity and contact information',
              icon: Icons.person,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.badge, size: 20),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.call, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _occupationController,
                  decoration: const InputDecoration(
                    labelText: 'Bio / Occupation',
                    prefixIcon: Icon(Icons.work, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // SECTION 2: Account & Email Credentials
            _buildSectionCard(
              title: 'Account Credentials',
              subtitle: 'Primary email used for sign-in and sync',
              icon: Icons.mail,
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.alternate_email, size: 20),
                  ),
                  validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Changing your email automatically migrates your transaction database securely.',
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // SECTION 3: Security & Password
            _buildSectionCard(
              title: 'Security & Password',
              subtitle: 'Update your access password (optional)',
              icon: Icons.lock_reset,
              children: [
                TextFormField(
                  controller: _currentPassController,
                  obscureText: _hideCurrentPass,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: const Icon(Icons.key, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_hideCurrentPass ? Icons.visibility : Icons.visibility_off, size: 20),
                      onPressed: () => setState(() => _hideCurrentPass = !_hideCurrentPass),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _newPassController,
                  obscureText: _hideNewPass,
                  decoration: InputDecoration(
                    labelText: 'New Password (Min 6 chars)',
                    prefixIcon: const Icon(Icons.lock, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_hideNewPass ? Icons.visibility : Icons.visibility_off, size: 20),
                      onPressed: () => setState(() => _hideNewPass = !_hideNewPass),
                    ),
                  ),
                  validator: (v) {
                    if (v != null && v.isNotEmpty && v.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPassController,
                  obscureText: _hideConfirmPass,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: const Icon(Icons.check_circle, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_hideConfirmPass ? Icons.visibility : Icons.visibility_off, size: 20),
                      onPressed: () => setState(() => _hideConfirmPass = !_hideConfirmPass),
                    ),
                  ),
                  validator: (v) {
                    if (_newPassController.text.isNotEmpty && v != _newPassController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // SECTION 4: Financial Preferences
            _buildSectionCard(
              title: 'Financial Preferences',
              subtitle: 'Currency and budget limits',
              icon: Icons.payments,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedCurrency,
                  decoration: const InputDecoration(
                    labelText: 'Primary Currency',
                    prefixIcon: Icon(Icons.currency_exchange, size: 20),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'RM', child: Text('RM - Malaysian Ringgit')),
                    DropdownMenuItem(value: 'USD', child: Text('\$ - US Dollar')),
                    DropdownMenuItem(value: 'SGD', child: Text('S\$ - Singapore Dollar')),
                    DropdownMenuItem(value: 'EUR', child: Text('€ - Euro')),
                    DropdownMenuItem(value: 'GBP', child: Text('£ - British Pound')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedCurrency = v);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _budgetController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Monthly Budget Limit',
                    prefixText: '$_selectedCurrency ',
                    prefixIcon: const Icon(Icons.account_balance_wallet, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // SECTION 5: AI & Notification Preferences
            _buildSectionCard(
              title: 'AI & Smart Preferences',
              subtitle: 'Automated intelligence and alerts',
              icon: Icons.psychology,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('AI Spending Insights', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Weekly budget analysis & tips', style: TextStyle(fontSize: 11)),
                  value: _aiInsightsEnabled,
                  activeThumbColor: AppColors.secondary,
                  onChanged: (v) => setState(() => _aiInsightsEnabled = v),
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Overspending Alerts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Notify when budget reaches 85%', style: TextStyle(fontSize: 11)),
                  value: _alertsEnabled,
                  activeThumbColor: AppColors.secondary,
                  onChanged: (v) => setState(() => _alertsEnabled = v),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // SECTION 6: Account Actions
            _buildSectionCard(
              title: 'Account Actions',
              subtitle: 'Session & logout',
              icon: Icons.manage_accounts,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.logout, color: AppColors.alertCoral),
                  title: const Text(
                    'Sign Out of FinWise',
                    style: TextStyle(color: AppColors.alertCoral, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.alertCoral),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sign Out')),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await auth.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                      }
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_forever, color: AppColors.alertCoral),
                  title: const Text(
                    'Delete Profile & Account',
                    style: TextStyle(color: AppColors.alertCoral, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  subtitle: const Text(
                    'Permanently remove profile and data from Supabase',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.alertCoral),
                  onTap: _confirmDeleteProfile,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Prominent Save Button
            FilledButton.icon(
              onPressed: auth.isLoading ? null : _saveChanges,
              icon: const Icon(Icons.save),
              label: Text(auth.isLoading ? 'Saving Changes...' : 'Save Profile Changes'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Material(
      color: Colors.white,
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderNeutral),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}
