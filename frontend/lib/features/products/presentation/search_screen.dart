import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/core/constants/colors.dart';
import 'package:grocery_app/features/products/data/product_provider.dart';
import 'package:grocery_app/features/products/presentation/home_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Auto-focus the field so the keyboard opens immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textInputAction: TextInputAction.search,
            onChanged: _onChanged,
            decoration: InputDecoration(
              hintText: "Search for groceries...",
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                      onPressed: () {
                        _controller.clear();
                        _onChanged('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_query.isEmpty) {
      return _Hint(
        icon: Icons.search_rounded,
        message: "Search by product name",
      );
    }

    final resultsAsync = ref.watch(searchProvider(_query));
    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => _Hint(icon: Icons.error_outline_rounded, message: "Something went wrong."),
      data: (products) {
        if (products.isEmpty) {
          return _Hint(icon: Icons.search_off_rounded, message: "No items found for \"$_query\"");
        }
        return ListView(
          children: [
            const SizedBox(height: 12),
            ProductGrid(products: products),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _Hint extends StatelessWidget {
  final IconData icon;
  final String message;
  const _Hint({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 60, color: AppColors.textLight),
          const SizedBox(height: 12),
          Text(message, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }
}
