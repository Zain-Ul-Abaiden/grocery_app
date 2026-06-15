import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/core/constants/colors.dart';
import 'package:grocery_app/features/orders/data/order_provider.dart';

class OrderStatusScreen extends ConsumerWidget {
  final String orderId;
  const OrderStatusScreen({super.key, required this.orderId});

  Widget _buildStep(String title, String desc, bool isCompleted, bool isCurrent, IconData icon) {
    Color stepColor = isCompleted ? AppColors.primary : (isCurrent ? AppColors.warning : AppColors.textLight);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primaryLight : (isCurrent ? const Color(0xFFFFF4EB) : AppColors.greyLight),
                shape: BoxShape.circle,
                border: Border.all(color: stepColor, width: 2),
              ),
              child: Icon(icon, size: 18, color: stepColor),
            ),
            Container(
              width: 2,
              height: 40,
              color: isCompleted ? AppColors.primary : AppColors.borderLight,
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isCurrent ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
              Text(
                desc,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailsProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Order Tracking",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          // Go back one step (to the order list it came from); fall back to home.
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(child: Text("Order details could not be found.")),
        data: (order) {
          final s = order.status.toLowerCase();

          final bool isCancelled = s == 'cancelled';
          final bool isDelivered = s == 'delivered';
          bool confirmed = s == 'confirmed' || s == 'out_for_delivery' || s == 'delivered';
          bool outForDelivery = s == 'out_for_delivery' || s == 'delivered';
          bool delivered = s == 'delivered';

          final Color stampColor = isDelivered
              ? AppColors.success
              : isCancelled
                  ? Colors.redAccent
                  : AppColors.warning;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(orderDetailsProvider(orderId));
            },
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                // STATUS STAMP
                Center(
                  child: Column(
                    children: [
                      Transform.rotate(
                        angle: -0.15,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: stampColor, width: 3),
                            borderRadius: BorderRadius.circular(10),
                            color: stampColor.withOpacity(0.08),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isDelivered ? Icons.verified_rounded : isCancelled ? Icons.cancel_rounded : Icons.timelapse_rounded,
                                color: stampColor,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                order.statusLabel.toUpperCase(),
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20, color: stampColor, letterSpacing: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isCancelled
                            ? "This order was cancelled"
                            : isDelivered
                                ? "Your order has been delivered"
                                : "Thank You! Your order is on its way",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Order ID: ${order.id.substring(0, 8).toUpperCase()}",
                        style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // TRACKING PIPELINE (hidden for cancelled orders)
                if (isCancelled)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Colors.redAccent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "This order has been cancelled. If you have any questions, please contact the store.",
                            style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      _buildStep(
                        "Order Received",
                        "Your order has been placed.",
                        confirmed,
                        s == 'pending',
                        Icons.receipt_long_rounded,
                      ),
                      _buildStep(
                        "Store Confirm & Packing",
                        "The store is packing your order.",
                        outForDelivery,
                        s == 'confirmed',
                        Icons.inventory_2_outlined,
                      ),
                      _buildStep(
                        "Out for Delivery",
                        "Your rider is on the way.",
                        delivered,
                        s == 'out_for_delivery',
                        Icons.delivery_dining_rounded,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: delivered ? AppColors.primaryLight : AppColors.greyLight,
                              shape: BoxShape.circle,
                              border: Border.all(color: delivered ? AppColors.primary : AppColors.textLight, width: 2),
                            ),
                            child: Icon(Icons.celebration_rounded, size: 18, color: delivered ? AppColors.primary : AppColors.textLight),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Delivered",
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: delivered ? AppColors.textPrimary : AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  "Delivered safely and order complete!",
                                  style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textLight),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // ITEMS BOUGHT
                Text(
                  "Order Items",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: order.items.length,
                    separatorBuilder: (c, i) => const Divider(height: 16, color: AppColors.borderLight),
                    itemBuilder: (context, index) {
                      final item = order.items[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName ?? "Product",
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  "Unit: ${item.productUnit} x ${item.quantity} packets",
                                  style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "Rs. ${item.subtotal.round()}",
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                          )
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Grand Total display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Pay cash on delivery:", style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary)),
                    Text("Rs. ${order.totalPrice.round()}", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
