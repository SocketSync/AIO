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
  final TextEditingController _nameController = TextEditingController(text: 'Alex Yeoh');
  final TextEditingController _emailController = TextEditingController(text: 'alex.yeoh@gmail.com');
  final TextEditingController _passwordController = TextEditingController(text: 'FinWise2026!');
  bool _obscurePassword = true;
  bool _termsAccepted = true;
  bool _isSigningUp = false;

  // Live password strength
  bool _hasMinLength = true;
  bool _hasNumber = true;
  bool _hasSpecialChar = true;

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

  void _handleGoogleSignUp() async {
    setState(() => _isSigningUp = true);
    final user = await AuthService().signInWithGoogle();
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

  void _handleFormSubmit() {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Service to continue.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    _handleGoogleSignUp();
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
                    onTap: _isSigningUp ? null : _handleGoogleSignUp,
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
                            hintText: 'e.g. Alex Yeoh',
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Google / Gmail Address',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted),
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
                            hintText: 'yourname@gmail.com',
                            prefixIcon: Icon(Icons.mail_outline, size: 20, color: AppColors.textMuted),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Create Password input
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
                          style: const TextStyle(fontSize: 14, color: AppColors.onSurface, letterSpacing: 2),
                          decoration: InputDecoration(
                            hintText: '••••••••••••',
                            prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.textMuted),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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

                      // Password Strength Indicator Card
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Security Strength',
                                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                                Text(
                                  _strengthScore == 3
                                      ? 'Strong Password'
                                      : _strengthScore == 2
                                          ? 'Medium Strength'
                                          : 'Weak Password',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _strengthScore == 3
                                        ? AppColors.secondary
                                        : _strengthScore == 2
                                            ? Colors.orange
                                            : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // 3-Segment Strength Bar
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: _strengthScore >= 1 ? AppColors.secondary : AppColors.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Container(
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: _strengthScore >= 2 ? AppColors.secondary : AppColors.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Container(
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: _strengthScore == 3 ? AppColors.secondary : AppColors.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Criteria Pills
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  const SizedBox(height: 12),

                  // Terms & Conditions Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _termsAccepted,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setState(() => _termsAccepted = val ?? true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'I agree to the Terms of Service, Privacy Policy, and consent to cloud security verification.',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Submit CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleFormSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Continue to Setup Goals', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),

                  // Community Social Proof
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.all(12),
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
