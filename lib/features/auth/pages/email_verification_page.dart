import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login_page.dart';
import '../providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  const EmailVerificationScreen({super.key, required this.email});

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  bool _isEmailVerified = false;
  bool _isChecking = false;
  int _checkCount = 0;

  @override
  void initState() {
    super.initState();
    _startCheckingEmail();
  }

  void _startCheckingEmail() => _scheduleNextCheck();

  void _scheduleNextCheck() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _checkEmailVerification();
    });
  }

  Future<void> _checkEmailVerification() async {
    if (_isEmailVerified || _checkCount >= 10) return;
    setState(() => _isChecking = true);
    try {
      final authService = ref.read(authServiceProvider);
      final isVerified = await authService.isEmailVerified();
      if (isVerified) {
        setState(() => _isEmailVerified = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email verified! Please log in.'), backgroundColor: AppColors.success),
          );
          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
          });
        }
        return;
      }
    } catch (_) {}
    setState(() { _isChecking = false; _checkCount++; });
    if (_checkCount < 10 && mounted) _scheduleNextCheck();
  }

  Future<void> _resendVerificationEmail() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.resendVerificationEmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email resent!'), backgroundColor: AppColors.primary),
      );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.error),
      );
      }
    }
  }

  void _retryChecking() {
    setState(() { _checkCount = 0; _isChecking = false; });
    _startCheckingEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(''), backgroundColor: Colors.transparent),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: _isEmailVerified ? AppColors.success.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  _isEmailVerified ? Icons.verified : Icons.email_outlined,
                  size: 40,
                  color: _isEmailVerified ? AppColors.success : AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _isEmailVerified ? 'Email Verified!' : 'Verify Your Email',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Text(
                _isEmailVerified ? 'Redirecting to login...' : 'We sent a verification link to:\n${widget.email}',
                style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (!_isEmailVerified) ...[
                if (_isChecking)
                  const CircularProgressIndicator(color: AppColors.primary)
                else if (_checkCount >= 10)
                  Column(children: [
                    const Text('Still not verified?', style: TextStyle(color: AppColors.primary)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _resendVerificationEmail,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: const Text('Resend Email', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 8),
                    TextButton(onPressed: _retryChecking, child: const Text('Check Again', style: TextStyle(color: AppColors.primary))),
                  ]),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false),
                  child: const Text('Back to Login', style: TextStyle(color: AppColors.textMuted)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}