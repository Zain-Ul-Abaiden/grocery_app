import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/core/constants/colors.dart';
import 'package:grocery_app/features/cart/data/cart_provider.dart';
import 'package:grocery_app/features/orders/data/order_provider.dart';
import 'package:grocery_app/features/products/presentation/home_screen.dart';
import 'package:grocery_app/features/products/presentation/categories_tab.dart';
import 'package:grocery_app/features/cart/presentation/cart_screen.dart';
import 'package:grocery_app/features/notifications/presentation/notifications_screen.dart';
import 'package:grocery_app/features/profile/presentation/profile_screen.dart';

/// Currently selected bottom-navigation tab. Any screen can switch tabs by
/// setting this (e.g. the home cart bar jumps to the Cart tab).
final selectedTabProvider = StateProvider<int>((ref) => 0);

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  static const _tabs = [
    HomeTab(),
    CategoriesTab(),
    CartTab(),
    NotificationsTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(selectedTabProvider);
    final cartState = ref.watch(cartProvider);
    final cartCount = cartState.summary?.items.length ?? 0;

    // Unread notification count = active orders the user hasn't viewed yet.
    final read = ref.watch(readNotificationsProvider);
    final activeOrders = ref.watch(activeOrdersProvider).valueOrNull ?? [];
    final unreadCount = activeOrders.where((o) => !read.contains(o.id)).length;

    return Scaffold(
      body: IndexedStack(index: index, children: _tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -2)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: index,
            onTap: (i) {
              ref.read(selectedTabProvider.notifier).state = i;
              // Viewing the Notification tab marks current notifications read.
              if (i == 3) {
                final orders = ref.read(activeOrdersProvider).valueOrNull ?? [];
                final read = ref.read(readNotificationsProvider);
                ref.read(readNotificationsProvider.notifier).state = {...read, ...orders.map((o) => o.id)};
              }
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textLight,
            selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: GoogleFonts.outfit(fontSize: 12),
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: "Home"),
              const BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view_rounded), label: "Categories"),
              BottomNavigationBarItem(
                icon: _CartIcon(count: cartCount, active: false),
                activeIcon: _CartIcon(count: cartCount, active: true),
                label: "Cart",
              ),
              BottomNavigationBarItem(
                icon: _BadgeIcon(icon: Icons.notifications_outlined, count: unreadCount),
                activeIcon: _BadgeIcon(icon: Icons.notifications_rounded, count: unreadCount),
                label: "Notification",
              ),
              const BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: "Profile"),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  const _BadgeIcon({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                "$count",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}

class _CartIcon extends StatelessWidget {
  final int count;
  final bool active;
  const _CartIcon({required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(active ? Icons.shopping_bag_rounded : Icons.shopping_bag_outlined),
        if (count > 0)
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                "$count",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: AppColors.onPrimary, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}
