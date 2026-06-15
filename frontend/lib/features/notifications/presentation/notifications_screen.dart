import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/core/constants/colors.dart';
import 'package:grocery_app/features/orders/data/order_provider.dart';
import 'package:grocery_app/shared/models/order_model.dart';

class NotificationsTab extends ConsumerWidget {
  const NotificationsTab({super.key});

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'out_for_delivery':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeOrdersAsync = ref.watch(activeOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text("Notifications", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 22)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(activeOrdersProvider),
        child: activeOrdersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => _empty(),
          data: (orders) {
            if (orders.isEmpty) return _empty();
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) => _OrderCard(order: orders[index], color: _statusColor(orders[index].status)),
            );
          },
        ),
      ),
    );
  }

  Widget _empty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 160),
        const Icon(Icons.notifications_off_outlined, size: 90, color: AppColors.borderLight),
        const SizedBox(height: 16),
        Center(child: Text("No notifications", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.textPrimary))),
        const SizedBox(height: 6),
        Center(child: Text("You have no new notifications right now.", style: GoogleFonts.outfit(color: AppColors.textSecondary))),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final Color color;
  const _OrderCard({required this.order, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/order-status/${order.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(Icons.delivery_dining_rounded, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Order #${order.id.substring(0, 8).toUpperCase()}", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text("Status: ${order.statusLabel}", style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
                  Text("Rs. ${order.totalPrice.round()}  •  Tap to track", style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textLight, size: 16),
          ],
        ),
      ),
    );
  }
}
