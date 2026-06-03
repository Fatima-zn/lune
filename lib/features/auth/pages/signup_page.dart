import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "../providers/auth_provider.dart";
import "email_verification_page.dart";
import '../../../../core/theme/app_theme.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final confirmEmail = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  DateTime? dob;

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    confirmEmail.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  void signup() async {
    if (firstName.text.trim().isEmpty) { _showMsg("Please enter your first name"); return; }
    if (lastName.text.trim().isEmpty) { _showMsg("Please enter your last name"); return; }
    if (dob == null) { _showMsg("Please select your date of birth"); return; }
    if (email.text.trim().isEmpty) { _showMsg("Please enter your email address"); return; }
    if (!_isValidEmail(email.text.trim())) { _showMsg("Please enter a valid email address"); return; }
    if (email.text.trim() != confirmEmail.text.trim()) { _showMsg("Email addresses don't match"); return; }
    if (password.text.isEmpty) { _showMsg("Please enter a password"); return; }
    if (password.text.length < 6) { _showMsg("Password must be at least 6 characters"); return; }
    if (password.text != confirmPassword.text) { _showMsg("Passwords don't match"); return; }

    final authService = ref.read(authServiceProvider);
    if (!authService.isAtLeast13(dob!)) { _showMsg("You must be at least 13 years old"); return; }

    setState(() => _isLoading = true);

    try {
      await authService.signup(
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        dob: dob!,
        email: email.text.trim(),
        password: password.text,
      );
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => EmailVerificationScreen(email: email.text.trim()),
        ));
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use': message = 'An account already exists with this email.'; break;
        case 'invalid-email': message = 'The email address is not valid.'; break;
        case 'weak-password': message = 'Password is too weak.'; break;
        default: message = 'Registration failed.';
      }
      _showMsg(message);
    } catch (e) {
      _showMsg('An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select your date of birth',
    );
    if (picked != null) setState(() => dob = picked);
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  void _showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 4)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(''), backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                const Text('Join the podcast community', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                const SizedBox(height: 32),

                _buildField(firstName, 'First Name', Icons.person_outline, TextInputAction.next),
                const SizedBox(height: 12),
                _buildField(lastName, 'Last Name', Icons.person_outline, TextInputAction.next),
                const SizedBox(height: 12),

                InkWell(
                  onTap: _isLoading ? null : pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      hintText: 'Date of Birth',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surfaceLight,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.calendar_today, color: AppColors.textMuted),
                    ),
                    child: Text(
                      dob == null ? '' : "${dob!.day}/${dob!.month}/${dob!.year}",
                      style: TextStyle(color: dob == null ? AppColors.textMuted : AppColors.textPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                _buildField(email, 'Email', Icons.email_outlined, TextInputAction.next, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _buildField(confirmEmail, 'Confirm Email', Icons.email_outlined, TextInputAction.next, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),

                _buildField(password, 'Password', Icons.lock_outlined, TextInputAction.next, obscure: _obscurePassword, suffix: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )),
                const SizedBox(height: 12),
                _buildField(confirmPassword, 'Confirm Password', Icons.lock_outlined, TextInputAction.done, obscure: _obscureConfirmPassword, suffix: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ), onSubmitted: (_) => signup()),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ', style: TextStyle(color: AppColors.textMuted)),
                    GestureDetector(
                      onTap: _isLoading ? null : () => context.pop(),
                      child: const Text('Log In', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon, TextInputAction action, {bool obscure = false, Widget? suffix, TextInputType? keyboardType, Function(String)? onSubmitted}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      textInputAction: action,
      keyboardType: keyboardType,
      onSubmitted: onSubmitted,
      textCapitalization: controller == firstName || controller == lastName ? TextCapitalization.words : TextCapitalization.none,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        prefixIcon: Icon(icon, color: AppColors.textMuted),
        suffixIcon: suffix,
      ),
    );
  }
}