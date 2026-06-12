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
          "Order Tracking (Taza safar)",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => context.go('/'),
        ),
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(child: Text("Order details could not be found.")),
        data: (order) {
          final s = order.status.toLowerCase();
          
          bool confirmed = s == 'confirmed' || s == 'out_for_delivery' || s == 'delivered';
          bool outForDelivery = s == 'out_for_delivery' || s == 'delivered';
          bool delivered = s == 'delivered';

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(orderDetailsProvider(orderId));
            },
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                // SUCCESS GREETING
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 64, color: AppColors.primary),
                      const SizedBox(height: 12),
                      Text(
                        "Shukriya! Order Receive Ho Gaya",
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
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

                // TRACKING PIPELINE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      _buildStep(
                        "Order Received",
                        "Apka order system mein dakhil ho gaya hai.",
                        confirmed,
                        s == 'pending',
                        Icons.receipt_long_rounded,
                      ),
                      _buildStep(
                        "Store Confirm & Packing",
                        "Dukandar saman check karke pack kar raha hai.",
                        outForDelivery,
                        s == 'confirmed',
                        Icons.inventory_2_outlined,
                      ),
                      _buildStep(
                        "Out for Delivery",
                        "Humar rider apke ghar ke liye nikal chuka hai.",
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
                                  "Saman safely delivered aur transaction complete!",
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
                    Text("Pate par Cash ada karein:", style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary)),
                    Text("Rs. ${order.totalPrice.round()}", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 36),

                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text("Home Screen par Wapis Jayein"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
