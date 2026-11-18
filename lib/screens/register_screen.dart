import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/google_logo.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _termsAccepted = true;
  bool _isSigningUp = false;

  // Live password strength
  bool _hasMinLength = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
    _checkPasswordStrength();
  }

  @override
  void dispose() {
    _passwordController.removeListener(_checkPasswordStrength);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final text = _passwordController.text;
    setState(() {
      _hasMinLength = text.length >= 8;
      _hasNumber = RegExp(r'\d').hasMatch(text);
      _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(text);
    });
  }

  int get _strengthScore {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasNumber) score++;
    if (_hasSpecialChar) score++;
    return score;
  }

  void _showGoogleAccountPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const GoogleLogo(size: 22),
                    const SizedBox(width: 10),
                    const Text(
                      'Google Accounts',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(bottomSheetContext).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sign up with Google',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Select your Gmail account to register on FinWise',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                _buildGoogleAccountTile(
                  name: 'Demo Finwise',
                  email: 'demo@finwise-app.xyz',
                  avatarColor: Colors.teal.shade700,
                  initial: 'D',
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _performGoogleSignUp(email: 'demo@finwise-app.xyz', name: 'Demo Finwise');
                  },
                ),
                const SizedBox(height: 8),
                Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300, style: BorderStyle.solid),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade100,
                      child: const Icon(Icons.person_add_alt_1, color: AppColors.textPrimary, size: 20),
                    ),
                    title: const Text(
                      'Use another Google account',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Register with your personal Gmail',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    onTap: () {
                      Navigator.of(bottomSheetContext).pop();
                      _promptCustomGmailDialog();
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Google will share your name and email with FinWise to create your account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: AppColors.outline),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoogleAccountTile({
    required String name,
    required String email,
    required Color avatarColor,
    required String initial,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: CircleAvatar(
          backgroundColor: avatarColor,
          child: Text(
            initial,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          email,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }

  void _promptCustomGmailDialog() {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              GoogleLogo(size: 20),
              SizedBox(width: 8),
              Text('Enter Gmail', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'your.name@gmail.com',
              labelText: 'Gmail Address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final email = emailCtrl.text.trim();
                if (email.isNotEmpty && email.contains('@')) {
                  Navigator.of(dialogContext).pop();
                  final name = email.split('@')[0].replaceAll('.', ' ');
                  _performGoogleSignUp(email: email, name: name);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Register'),
            ),
          ],
        );
      },
    );
  }

  void _performGoogleSignUp({String? email, String? name}) async {
    setState(() => _isSigningUp = true);
    final user = await AuthService().signInWithGoogle(
      selectedEmail: email,
      selectedName: name,
    );
    setState(() => _isSigningUp = false);

    if (user != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.secondary,
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Google Registration verified: ${user.email}'),
              ),
            ],
          ),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  void _handleFormSubmit() async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Service to continue.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || name.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all registration fields.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters long.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSigningUp = true);

    try {
      final user = await AuthService().signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );

      setState(() => _isSigningUp = false);

      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.secondary,
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Account created for ${user.displayName}! Welcome to FinWise.'),
                ),
              ],
            ),
          ),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      setState(() => _isSigningUp = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.85),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),
        title: const Text(
          'Register',
          style: TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: AppColors.onPrimary, size: 18),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryFixed,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.person_add_alt_1, size: 14, color: AppColors.onSecondaryFixed),
                            SizedBox(width: 4),
                            Text(
                              'SMART ONBOARDING',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSecondaryFixed,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'Step 1 of 2',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Progress Bar 50%
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 6,
                      color: AppColors.surfaceContainerHigh,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.5,
                        child: Container(color: AppColors.secondary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    'Join thousands of users building smarter saving habits and budgeting with AI.',
                    style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.4),
                  ),
                  const SizedBox(height: 16),

                  // FinWise Member Benefit Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryContainer, AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.verified, color: AppColors.secondaryFixed, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FinWise Member Benefit',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondaryFixed,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Register with your Google account to unlock FinWise Pro & AI Financial Assistant free throughout this year.',
                                style: TextStyle(fontSize: 12, color: Colors.white, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Google Sign-Up Primary CTA Button
                  InkWell(
                    onTap: _isSigningUp ? null : _showGoogleAccountPicker,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderNeutral, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isSigningUp)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            )
                          else ...[
                            const GoogleLogo(size: 22),
                            const SizedBox(width: 12),
                            const Flexible(
                              child: Text(
                                'Sign Up with Google (Gmail)',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.surfaceContainerHighest)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Or create manual profile',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppColors.surfaceContainerHighest)),
                      ],
                    ),
                  ),

                  // Full Name input
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Full Name',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderNeutral),
                        ),
                        child: TextField(
                          controller: _nameController,
                          style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
                          decoration: const InputDecoration(
                            hintText: 'e.g. Demo Finwise',
                            prefixIcon: Icon(Icons.person_outline, size: 20, color: AppColors.textMuted),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Gmail input
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Google / Gmail Address',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.growthMintSubtle,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.bolt, size: 10, color: AppColors.secondary),
                                SizedBox(width: 3),
                                Text(
                                  'Instant Perks',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.secondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderNeutral),
                        ),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
                          decoration: const InputDecoration(
                            hintText: 'demo@finwise-app.xyz',
                            prefixIcon: Icon(Icons.mail_outline, size: 20, color: AppColors.textMuted),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Password input with live strength indicator
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create Password',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderNeutral),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(fontSize: 14, color: AppColors.onSurface, letterSpacing: 1.5),
                          decoration: InputDecoration(
                            hintText: '••••••••••••',
                            prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.textMuted),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                size: 20,
                                color: AppColors.textMuted,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Password Strength Indicator Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderNeutral),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Security Strength',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ),
                                Text(
                                  _strengthScore == 3
                                      ? 'Strong Password'
                                      : _strengthScore == 2
                                          ? 'Medium Password'
                                          : 'Weak Password',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _strengthScore == 3
                                        ? AppColors.secondary
                                        : _strengthScore == 2
                                            ? Colors.amber.shade700
                                            : AppColors.alertCoral,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // 3-Segment Progress Bar
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: _strengthScore >= 1
                                          ? (_strengthScore == 1 ? AppColors.alertCoral : AppColors.secondary)
                                          : AppColors.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: _strengthScore >= 2
                                          ? (_strengthScore == 2 ? Colors.amber.shade700 : AppColors.secondary)
                                          : AppColors.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: _strengthScore == 3
                                          ? AppColors.secondary
                                          : AppColors.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Criteria Pills
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                _CriteriaPill(label: '8+ Characters', isValid: _hasMinLength),
                                _CriteriaPill(label: 'Contains Number', isValid: _hasNumber),
                                _CriteriaPill(label: 'Special Symbol', isValid: _hasSpecialChar),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Terms Agreement Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _termsAccepted,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (val) => setState(() => _termsAccepted = val ?? false),
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            'I agree to the Terms of Service, Privacy Policy, and consent to Google account verification.',
                            style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSigningUp ? null : _handleFormSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isSigningUp ? 'Setting up Vault...' : 'Continue to Dashboard',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Community Social Proof
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderNeutral),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: AppColors.primary,
                                child: Text('AY', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(width: 4),
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: AppColors.secondary,
                                child: Text('SL', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '3,420+ active members registered',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield, size: 14, color: AppColors.secondary),
                            SizedBox(width: 4),
                            Text(
                              'Secure',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Footer
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?',
                            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                            },
                            child: const Text(
                              ' Log In',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CriteriaPill extends StatelessWidget {
  final String label;
  final bool isValid;

  const _CriteriaPill({required this.label, required this.isValid});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 13,
          color: isValid ? AppColors.secondary : AppColors.textMuted,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isValid ? AppColors.secondary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
