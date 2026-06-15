import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/core/constants/colors.dart';
import 'package:grocery_app/core/network/api_client.dart';
import 'package:grocery_app/features/orders/data/order_provider.dart';
import 'package:grocery_app/features/products/data/product_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- Add Category Dialog Form ---
  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final imageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Add New Category", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Category Name (e.g. Frozen Food)"),
                    validator: (v) => v?.trim().isEmpty == true ? "Category name is required" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: imageController,
                    decoration: const InputDecoration(
                      labelText: "Image URL Link (Optional)",
                      hintText: "https://images.unsplash.com/...",
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancel", style: GoogleFonts.outfit(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40)),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                
                final dio = ref.read(apiClientProvider);
                try {
                  final response = await dio.post(
                    "/categories",
                    data: {
                      "name": nameController.text.trim(),
                      "image_url": imageController.text.trim().isEmpty ? null : imageController.text.trim(),
                    },
                  );
                  if (response.statusCode == 201 && context.mounted) {
                    ref.invalidate(categoriesProvider); // Force chip refresh
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("New Category Added Successfully!"), backgroundColor: AppColors.primary),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to add category. Name may already exist."), backgroundColor: Colors.redAccent),
                    );
                  }
                }
              },
              child: Text("Create", style: GoogleFonts.outfit()),
            ),
          ],
        );
      },
    );
  }

  // --- Add Product Dialog Form ---
  void _showAddProductDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final discountPriceController = TextEditingController();
    final unitController = TextEditingController(text: "500 gram");
    final stockController = TextEditingController(text: "50");
    final imageController = TextEditingController();
    
    int? selectedCatId;
    final formKey = GlobalKey<FormState>();

    // Query active categories list to bind dropdown
    final categoriesAsync = ref.read(categoriesProvider);

    categoriesAsync.when(
      loading: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Loading categories..."))),
      error: (e, s) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to load categories list."))),
      data: (categoriesList) {
        if (categoriesList.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please create a category first before adding products!")),
          );
          return;
        }

        showDialog(
          context: context,
          builder: (ctx) {
            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: Text("Add New Product", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  content: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Category Selector Dropdown
                          DropdownButtonFormField<int>(
                            value: selectedCatId,
                            hint: Text("Select Category", style: GoogleFonts.outfit(fontSize: 14)),
                            decoration: const InputDecoration(labelText: "Product Category"),
                            items: categoriesList
                                .map((cat) => DropdownMenuItem(
                                      value: cat.id,
                                      child: Text(cat.name, style: GoogleFonts.outfit(fontSize: 14)),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              setDialogState(() => selectedCatId = val);
                            },
                            validator: (v) => v == null ? "Product category is required" : null,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(labelText: "Product Name (e.g. Aloo Cutlets (12pcs))"),
                            validator: (v) => v?.trim().isEmpty == true ? "Product name is required" : null,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: descController,
                            decoration: const InputDecoration(labelText: "Description (Optional)"),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: "Price (Rs.)"),
                                  validator: (v) => v?.trim().isEmpty == true ? "Price is required" : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: discountPriceController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: "Discount Price (Optional)"),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: unitController,
                                  decoration: const InputDecoration(labelText: "Unit size (e.g. 500 gram, 12pcs)"),
                                  validator: (v) => v?.trim().isEmpty == true ? "Unit description is required" : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: stockController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: "Stock count"),
                                  validator: (v) => v?.trim().isEmpty == true ? "Stock is required" : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: imageController,
                            decoration: const InputDecoration(
                              labelText: "Image URL Link (Optional)",
                              hintText: "https://images.unsplash.com/...",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text("Cancel", style: GoogleFonts.outfit(color: AppColors.textSecondary)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40)),
                      onPressed: () async {
                        if (!formKey.currentState!.validate() || selectedCatId == null) return;
                        
                        final dio = ref.read(apiClientProvider);
                        try {
                          final double price = double.parse(priceController.text.trim());
                          final double? discPrice = discountPriceController.text.trim().isEmpty 
                              ? null 
                              : double.parse(discountPriceController.text.trim());
                          final int stock = int.parse(stockController.text.trim());

                          final response = await dio.post(
                            "/products",
                            data: {
                              "category_id": selectedCatId,
                              "name": nameController.text.trim(),
                              "description": descController.text.trim().isEmpty ? null : descController.text.trim(),
                              "price": price,
                              "discount_price": discPrice,
                              "unit": unitController.text.trim(),
                              "stock": stock,
                              "image_url": imageController.text.trim().isEmpty ? null : imageController.text.trim(),
                              "is_available": true
                            },
                          );
                          if (response.statusCode == 201 && context.mounted) {
                            // Invalidate and refresh both lists
                            ref.invalidate(productsProvider);
                            ref.read(productsProvider.notifier).fetchProducts();
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("New Product Added Successfully!"), backgroundColor: AppColors.primary),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Failed to create product. Check input values."), backgroundColor: Colors.redAccent),
                            );
                          }
                        }
                      },
                      child: Text("Create", style: GoogleFonts.outfit()),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);
    final ordersAsync = ref.watch(adminOrdersProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Admin Control Panel",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
            onPressed: () => context.go('/'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
              onPressed: () {
                ref.invalidate(adminDashboardStatsProvider);
                ref.invalidate(adminOrdersProvider);
                ref.invalidate(categoriesProvider);
              },
            )
          ],
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: "Orders & Stats", icon: Icon(Icons.receipt_long_rounded)),
              Tab(text: "Catalog Manager", icon: Icon(Icons.inventory_rounded)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- Tab 1: Orders and Metrics (Existing UI) ---
            RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(adminDashboardStatsProvider);
                ref.invalidate(adminOrdersProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats metrics grid
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: statsAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, s) => const SizedBox.shrink(),
                        data: (stats) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      "Delivered Sales",
                                      "Rs. ${stats['total_revenue']?.round()}",
                                      Icons.monetization_on_rounded,
                                      AppColors.primary,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildStatCard(
                                      "Pending Orders",
                                      "${stats['pending_orders']}",
                                      Icons.pending_actions_rounded,
                                      AppColors.warning,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      "Registered Users",
                                      "${stats['total_users']}",
                                      Icons.people_alt_rounded,
                                      AppColors.info,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildStatCard(
                                      "Out of Stock",
                                      "${stats['out_of_stock_products']}",
                                      Icons.warning_amber_rounded,
                                      AppColors.discountBadge,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        "Customer Orders Management",
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                      ),
                    ),

                    ordersAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => const Center(child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text("Error fetching orders."),
                      )),
                      data: (orders) {
                        if (orders.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Text(
                                "No active orders.",
                                style: GoogleFonts.outfit(color: AppColors.textSecondary),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "ID: ${order.id.substring(0, 8).toUpperCase()}",
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: order.status == 'delivered'
                                                ? AppColors.primaryLight
                                                : (order.status == 'cancelled' ? AppColors.discountBg : const Color(0xFFFFF4EB)),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            order.status.toUpperCase(),
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                              color: order.status == 'delivered'
                                                  ? AppColors.primaryDark
                                                  : (order.status == 'cancelled' ? AppColors.discountBadge : AppColors.warning),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    const Divider(height: 20),
                                    
                                    Text(
                                      "Customer Phone: ${order.contactPhone}",
                                      style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
                                    ),
                                    Text(
                                      "Delivery Address: ${order.deliveryAddress}",
                                      style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(height: 12),

                                    Text(
                                      "Items List:",
                                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    ),
                                    ...order.items.map((i) => Padding(
                                      padding: const EdgeInsets.only(left: 8.0, top: 4),
                                      child: Text(
                                        "• ${i.productName} (${i.productUnit}) x ${i.quantity} packets -> Rs. ${i.subtotal.round()}",
                                        style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                    )),

                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Total: Rs. ${order.totalPrice.round()}",
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary),
                                        ),
                                        
                                        DropdownButton<String>(
                                          hint: Text("Update Status", style: GoogleFonts.outfit(fontSize: 12)),
                                          underline: const SizedBox(),
                                          style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 13),
                                          items: ['pending', 'confirmed', 'out_for_delivery', 'delivered', 'cancelled']
                                              .map((s) => DropdownMenuItem(
                                                    value: s,
                                                    child: Text(s.toUpperCase()),
                                                  ))
                                              .toList(),
                                          onChanged: (val) async {
                                            if (val != null) {
                                              final ok = await ref.read(adminStatusUpdateProvider)(order.id, val);
                                              if (ok && context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text("Order status changed successfully to $val"),
                                                    backgroundColor: AppColors.primary,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // --- Tab 2: Catalog Expansion Manager (New Expander) ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Dynamic Catalog Expansion",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Apne online store par mobile app se direct naye categories aur products barhane ke liye niche diye gaye option select karein.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 36),

                  // 1. Expand Categories Card
                  GestureDetector(
                    onTap: () => _showAddCategoryDialog(context, ref),
                    child: Card(
                      color: AppColors.primaryLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.primary, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        child: Column(
                          children: [
                            const Icon(Icons.create_new_folder_rounded, color: AppColors.primary, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              "Add Category",
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "Cooking Oil, Daal, Frozen food jaisi categories barhein",
                              style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Expand Products Card
                  GestureDetector(
                    onTap: () => _showAddProductDialog(context, ref),
                    child: Card(
                      color: const Color(0xFFFFF4EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.warning, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        child: Column(
                          children: [
                            const Icon(Icons.add_box_rounded, color: AppColors.warning, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              "Add Product",
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFB35900),
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "Kisi bhi category ke andar details, packaging aur price shamil karein",
                              style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
