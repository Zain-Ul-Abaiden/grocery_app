import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/core/constants/colors.dart';
import 'package:grocery_app/features/auth/data/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    final success = await ref.read(authProvider.notifier).login(phone, password);

    if (success && mounted) {
      // Redirect to catalog
      context.go('/');
    } else if (mounted) {
      final error = ref.read(authProvider).errorMessage ?? "Login failed.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error, style: GoogleFonts.outfit()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showForgotPassword() {
    final phoneCtrl = TextEditingController();
    final pwdCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Forgot Password", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: "Registered phone number"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pwdCtrl,
              obscureText: true,
              decoration: const InputDecoration(hintText: "New password (min 6 chars)"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel", style: GoogleFonts.outfit(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              final phone = phoneCtrl.text.trim();
              final pwd = pwdCtrl.text.trim();
              if (phone.isEmpty || pwd.length < 6) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text("Enter phone and a 6+ character password", style: GoogleFonts.outfit())));
                return;
              }
              final ok = await ref.read(authProvider.notifier).forgotPassword(phone, pwd);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? "Password reset! Login with your new password." : (ref.read(authProvider).errorMessage ?? "Reset failed"), style: GoogleFonts.outfit()),
                  backgroundColor: ok ? AppColors.success : Colors.redAccent,
                ));
              }
            },
            child: Text("Reset", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Branding Header
                  Icon(
                    Icons.shopping_basket_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Shadab Super Store",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Click. Cart. Chill.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Phone number input
                  Text(
                    "Phone Number",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: "Enter Phone Number (e.g. 03001234567)",
                      prefixIcon: Icon(Icons.phone_android_rounded, color: AppColors.primary),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "Phone number is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Password input
                  Text(
                    "Password",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "Enter your password",
                      prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "Password is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPassword,
                      child: Text("Forgot Password?", style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Submit Button
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _submit,
                    child: authState.isLoading
                        ? const CircularProgressIndicator(color: AppColors.onPrimary)
                        : Text("Login"),
                  ),
                  const SizedBox(height: 24),
                  
                  // Signup Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?", style: GoogleFonts.outfit(color: AppColors.textSecondary)),
                      TextButton(
                        onPressed: () => context.push('/signup'),
                        child: Text("Sign Up", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Promo details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_outlined, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Special offer: Cash on Delivery available — no OTP hassle!",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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
