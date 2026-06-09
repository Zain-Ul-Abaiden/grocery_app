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
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();

    final success = await ref.read(authProvider.notifier).login(phone, name);

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
                    "Taza Grocery Store",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Har cheez fresh, har waqt sasti!",
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
                      hintText: "Enter Phone Number (e.g. +923001234567)",
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

                  // Optional Name input (for auto-registration)
                  Text(
                    "Full Name (Optional)",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      hintText: "Enter your name (For new registration)",
                      prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Submit Button
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _submit,
                    child: authState.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text("Aage Barhein (Login / Sign Up)"),
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
                            "Khaas Offer: Cash on Delivery bilkul muft aur koi OTP ki jhanjhat nahi!",
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
