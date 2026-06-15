import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/core/constants/colors.dart';
import 'package:grocery_app/features/orders/data/order_provider.dart';
import 'package:grocery_app/shared/models/order_model.dart';

class MyOrdersScreen extends ConsumerStatefulWidget {
  const MyOrdersScreen({super.key});
  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(orderNotifierProvider.notifier).fetchMyOrders());
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'out_for_delivery':
        return Colors.purple;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(orderNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary), onPressed: () => context.pop()),
        title: Text("My Orders", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18)),
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => _empty(),
        data: (orders) {
          if (orders.isEmpty) return _empty();
          return RefreshIndicator(
            onRefresh: () => ref.read(orderNotifierProvider.notifier).fetchMyOrders(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final OrderModel order = orders[index];
                return GestureDetector(
                  onTap: () => context.push('/order-status/${order.id}'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("#${order.id.substring(0, 8).toUpperCase()}", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: _statusColor(order.status).withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                              child: Text(order.statusLabel, style: GoogleFonts.outfit(color: _statusColor(order.status), fontWeight: FontWeight.w600, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text("${order.items.length} item(s)  •  Rs. ${order.totalPrice.round()}", style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(order.deliveryAddress, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(color: AppColors.textLight, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied_rounded, size: 100, color: AppColors.borderLight),
            const SizedBox(height: 16),
            Text("No Order History", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text("Go and order your favourite products!", textAlign: TextAlign.center, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
