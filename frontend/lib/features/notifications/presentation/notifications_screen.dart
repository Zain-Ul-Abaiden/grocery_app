import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/core/constants/colors.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For MVP, we will display hardcoded notifications or empty state
    // In final product, fetch from SQLite/Firebase
    final notifications = [
      {
        "title": "Welcome to Taza Store!",
        "body": "Enjoy fresh groceries at your doorstep. No delivery fees on your first order!",
        "time": "Just now",
        "icon": Icons.celebration_rounded,
        "color": Colors.orangeAccent,
      },
      {
        "title": "Order Placed Successfully",
        "body": "Your order #ORD-1234 has been placed and will be delivered soon.",
        "time": "2 hours ago",
        "icon": Icons.shopping_bag_rounded,
        "color": AppColors.primary,
      }
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
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
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_off_outlined, size: 80, color: AppColors.textLight),
                  const SizedBox(height: 16),
                  Text(
                    "No Notifications yet",
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "We'll notify you when something important happens.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final note = notifications[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  leading: CircleAvatar(
                    backgroundColor: (note['color'] as Color).withOpacity(0.1),
                    child: Icon(note['icon'] as IconData, color: note['color'] as Color),
                  ),
                  title: Text(
                    note['title'] as String,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note['body'] as String,
                          style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          note['time'] as String,
                          style: GoogleFonts.outfit(color: AppColors.textLight, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  isThreeLine: true,
                );
              },
            ),
    );
  }
}
