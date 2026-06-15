import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/core/constants/colors.dart';
import 'package:grocery_app/features/auth/data/auth_provider.dart';
import 'package:grocery_app/features/cart/data/cart_provider.dart';
import 'package:grocery_app/features/orders/data/order_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Prefill user's phone number from login state for perfect UX
    final user = ref.read(authProvider).user;
    if (user != null) {
      _phoneController.text = user.phone;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _confirmCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();

    final order = await ref.read(orderNotifierProvider.notifier).createOrder(address, phone);

    if (mounted) {
      setState(() => _isSubmitting = false);
    }

    if (order != null && mounted) {
      // Order placed! Route straight to Order Status Tracking screen
      context.go('/order-status/${order.id}');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to place order. Try again.", style: GoogleFonts.outfit()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Checkout",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: cartState.summary == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  // Order Summary Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order Summary",
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Items:", style: GoogleFonts.outfit(color: AppColors.textSecondary)),
                              Text("${cartState.summary!.items.length} items", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total:", style: GoogleFonts.outfit(color: AppColors.textSecondary)),
                              Text("Rs. ${cartState.summary!.totalPrice.round()}", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Delivery Address Form
                  Text(
                    "Delivery Address",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Enter full address (e.g. House No, Street, Colony, Landmark)",
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 40.0),
                        child: Icon(Icons.home_outlined, color: AppColors.primary),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "Address is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Phone Number for Contact
                  Text(
                    "Contact Phone",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: "Active Phone Number",
                      prefixIcon: Icon(Icons.phone_android_rounded, color: AppColors.primary),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "Phone number is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // Payment Method details
                  Text(
                    "Payment Method",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.payments_rounded, color: AppColors.primary, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Cash on Delivery (COD)",
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "Check your order first, then pay cash on delivery!",
                                style: GoogleFonts.outfit(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _confirmCheckout,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: AppColors.onPrimary)
                        : Text("Place Order (Rs. ${cartState.summary!.totalPrice.round()})"),
                  ),
                ],
              ),
            ),
    );
  }
}
