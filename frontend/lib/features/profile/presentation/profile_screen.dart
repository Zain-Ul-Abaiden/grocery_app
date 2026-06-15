import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/core/constants/colors.dart';
import 'package:grocery_app/features/auth/data/auth_provider.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final initial = (user?.name ?? "").trim().isNotEmpty ? user!.name.trim()[0].toUpperCase() : "U";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text("Profile", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 22)),
      ),
      body: ListView(
        children: [
          // Profile header
          Container(
            color: AppColors.primaryLight,
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  child: Text(initial, style: GoogleFonts.outfit(color: AppColors.onPrimary, fontWeight: FontWeight.bold, fontSize: 32)),
                ),
                const SizedBox(height: 12),
                Text(user?.name ?? "Guest", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.textPrimary)),
                Text(user?.phone ?? "", style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _tile(context, Icons.person_outline_rounded, "Profile Details", () => context.push('/profile-details')),
          _tile(context, Icons.receipt_long_outlined, "My Orders", () => context.push('/my-orders')),
          _tile(context, Icons.location_on_outlined, "Addresses", () => context.push('/addresses')),
          _tile(context, Icons.description_outlined, "Terms & Conditions", () => context.push('/terms')),
          _tile(context, Icons.shield_outlined, "Privacy Policy", () => context.push('/privacy')),
          _tile(context, Icons.delete_outline_rounded, "Delete Account", () => _confirmDelete(context, ref), danger: true),
          _tile(context, Icons.logout_rounded, "Logout", () => _confirmLogout(context, ref), danger: true),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool danger = false}) {
    final color = danger ? Colors.redAccent : AppColors.textPrimary;
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: danger ? Colors.redAccent : AppColors.primary),
          title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: color)),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textLight),
          onTap: onTap,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

void _confirmLogout(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text("Logout", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      content: Text("Are you sure you want to logout?", style: GoogleFonts.outfit()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel", style: GoogleFonts.outfit(color: AppColors.textSecondary))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, minimumSize: const Size(90, 44)),
          onPressed: () async {
            Navigator.pop(ctx);
            await ref.read(authProvider.notifier).logout();
            if (context.mounted) context.go('/login');
          },
          child: Text("Logout", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

void _confirmDelete(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text("Delete Account", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      content: Text("This will permanently delete your account. This action cannot be undone.", style: GoogleFonts.outfit()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel", style: GoogleFonts.outfit(color: AppColors.textSecondary))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, minimumSize: const Size(90, 44)),
          onPressed: () async {
            Navigator.pop(ctx);
            final ok = await ref.read(authProvider.notifier).deleteAccount();
            if (context.mounted) {
              if (ok) {
                context.go('/login');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete account", style: GoogleFonts.outfit())));
              }
            }
          },
          child: Text("Delete", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

// ───────────────────────── Profile Details ─────────────────────────
class ProfileDetailsScreen extends ConsumerStatefulWidget {
  const ProfileDetailsScreen({super.key});
  @override
  ConsumerState<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends ConsumerState<ProfileDetailsScreen> {
  late final TextEditingController _name;
  late final TextEditingController _address;
  final _password = TextEditingController();
  bool _savingProfile = false;
  bool _savingPwd = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _name = TextEditingController(text: user?.name ?? "");
    _address = TextEditingController(text: user?.address ?? "");
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _password.dispose();
    super.dispose();
  }

  void _toast(String msg, {bool ok = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.outfit()), backgroundColor: ok ? AppColors.success : Colors.redAccent));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary), onPressed: () => context.pop()),
        title: Text("Profile Details", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _label("Phone Number"),
          TextField(enabled: false, decoration: InputDecoration(hintText: user?.phone ?? "")),
          const SizedBox(height: 20),
          _label("Full Name"),
          TextField(controller: _name, decoration: const InputDecoration(hintText: "Your name")),
          const SizedBox(height: 20),
          _label("Default Address"),
          TextField(controller: _address, maxLines: 3, decoration: const InputDecoration(hintText: "Your delivery address")),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _savingProfile
                ? null
                : () async {
                    setState(() => _savingProfile = true);
                    final ok = await ref.read(authProvider.notifier).updateProfile(name: _name.text.trim(), address: _address.text.trim());
                    setState(() => _savingProfile = false);
                    _toast(ok ? "Profile updated!" : "Failed to update profile", ok: ok);
                  },
            child: _savingProfile ? const CircularProgressIndicator(color: AppColors.onPrimary) : const Text("Save Profile"),
          ),
          const SizedBox(height: 36),
          const Divider(),
          const SizedBox(height: 12),
          Text("Change Password", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _label("New Password"),
          TextField(controller: _password, obscureText: true, decoration: const InputDecoration(hintText: "Enter new password (min 6 chars)")),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.textPrimary, foregroundColor: Colors.white),
            onPressed: _savingPwd
                ? null
                : () async {
                    if (_password.text.trim().length < 6) {
                      _toast("Password must be at least 6 characters", ok: false);
                      return;
                    }
                    setState(() => _savingPwd = true);
                    final ok = await ref.read(authProvider.notifier).updatePassword(_password.text.trim());
                    setState(() => _savingPwd = false);
                    if (ok) _password.clear();
                    _toast(ok ? "Password updated!" : "Failed to update password", ok: ok);
                  },
            child: _savingPwd ? const CircularProgressIndicator(color: Colors.white) : const Text("Update Password"),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      );
}

// ───────────────────────── Addresses ─────────────────────────
class AddressesScreen extends ConsumerStatefulWidget {
  const AddressesScreen({super.key});
  @override
  ConsumerState<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends ConsumerState<AddressesScreen> {
  late final TextEditingController _address;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _address = TextEditingController(text: ref.read(authProvider).user?.address ?? "");
  }

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary), onPressed: () => context.pop()),
        title: Text("Addresses", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text("Default Delivery Address", style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          TextField(controller: _address, maxLines: 4, decoration: const InputDecoration(hintText: "House no, street, area, city...")),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saving
                ? null
                : () async {
                    setState(() => _saving = true);
                    final ok = await ref.read(authProvider.notifier).updateProfile(address: _address.text.trim());
                    setState(() => _saving = false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok ? "Address saved!" : "Failed to save address", style: GoogleFonts.outfit()),
                        backgroundColor: ok ? AppColors.success : Colors.redAccent,
                      ));
                    }
                  },
            child: _saving ? const CircularProgressIndicator(color: AppColors.onPrimary) : const Text("Save Address"),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Static info pages ─────────────────────────
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});
  @override
  Widget build(BuildContext context) => const _StaticPage(
        title: "Terms & Conditions",
        body:
            "Welcome to Shadab Super Store.\n\nBy using this app you agree to purchase products at the listed prices. Orders are subject to availability and confirmation. Payment is collected as Cash on Delivery at the time of delivery.\n\nWe aim to deliver fresh, quality groceries on time. Prices and product availability may change without prior notice. Delivery is currently free within the serviceable area.\n\nFor any disputes regarding an order, please contact the store before the order is delivered.",
      );
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});
  @override
  Widget build(BuildContext context) => const _StaticPage(
        title: "Privacy Policy",
        body:
            "Shadab Super Store respects your privacy.\n\nWe only collect the information needed to process your orders — your name, phone number, and delivery address. This information is used solely to fulfil and deliver your orders.\n\nWe do not sell or share your personal data with third parties. Your password is stored securely and never shared.\n\nYou may update or delete your account and data at any time from the Profile section.",
      );
}

class _StaticPage extends StatelessWidget {
  final String title;
  final String body;
  const _StaticPage({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary), onPressed: () => context.pop()),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(body, style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
      ),
    );
  }
}
