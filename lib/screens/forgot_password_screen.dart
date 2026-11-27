import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

/// Provides the password-reset request, confirmation, and resend flow.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const int _cooldownDurationSeconds = 60;

  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _emailSent = false;
  String? _sentToEmail;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    _emailController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    if (!mounted) return;

    setState(() => _resendCooldown = _cooldownDurationSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldown <= 1) {
        timer.cancel();
        _cooldownTimer = null;
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _handleSendResetLink() async {
    if (_isLoading) return;
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    await _sendResetEmail(_emailController.text.trim());
  }

  Future<void> _handleResendResetLink() async {
    if (_isLoading || _resendCooldown > 0) return;

    final email = (_sentToEmail ?? _emailController.text).trim();
    if (email.isEmpty) return;

    await _sendResetEmail(email);
  }

  Future<void> _sendResetEmail(String email) async {
    setState(() => _isLoading = true);

    final success = await AuthService().sendPasswordResetEmail(email);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (success) {
        _emailSent = true;
        _sentToEmail = email;
      }
    });

    if (success) {
      _startCooldown();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(
            AuthService().errorMessage ??
                'Unable to send reset email. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Header Illustration & Icon
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _emailSent ? AppColors.growthMintSubtle : AppColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _emailSent ? Icons.mark_email_read_outlined : Icons.lock_reset_rounded,
                    size: 36,
                    color: _emailSent ? AppColors.secondary : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title and Description
              Text(
                _emailSent ? 'Check your email' : 'Forgot password?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _emailSent
                    ? 'We have sent a secure password reset link to\n$_sentToEmail'
                    : "No worries! Enter your email address and we'll send you instructions to reset your password.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              if (!_emailSent) ...[
                // Email Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email Address',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'e.g. your.email@gmail.com',
                          prefixIcon: const Icon(Icons.mail_outline, size: 20, color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.surfaceContainerLowest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.borderNeutral),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.borderNeutral),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email address';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSendResetLink,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 1,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.send_rounded, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Send Reset Link',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Success Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderNeutral),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.mark_email_read, color: AppColors.secondary, size: 22),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Email Sent Successfully',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Click the link in the email to set a new password. If you do not see it within a few minutes, check your spam or promotions folder.',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: (_resendCooldown > 0 || _isLoading)
                              ? null
                              : _handleResendResetLink,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            side: const BorderSide(color: AppColors.borderNeutral),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  _resendCooldown > 0
                                      ? 'Resend in ${_resendCooldown}s'
                                      : 'Resend Email',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 24),

              // Back to login button
              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, size: 16, color: AppColors.primary),
                  label: const Text(
                    'Back to Sign In',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'FinWise • Secure Password Recovery',
                  style: TextStyle(fontSize: 11, color: AppColors.outline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

