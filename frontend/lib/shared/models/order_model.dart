class OrderItemModel {
  final int id;
  final String? productId;
  final String? productName;
  final String? productUnit;
  final int quantity;
  final double priceAtPurchase;
  final double subtotal;

  OrderItemModel({
    required this.id,
    this.productId,
    this.productName,
    this.productUnit,
    required this.quantity,
    required this.priceAtPurchase,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int,
      productId: json['product_id'] as String?,
      productName: json['product_name'] as String?,
      productUnit: json['product_unit'] as String?,
      quantity: json['quantity'] as int,
      priceAtPurchase: double.parse(json['price_at_purchase'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
    );
  }
}

class OrderModel {
  final String id;
  final String? userId;
  final double totalPrice;
  final String status; // pending, confirmed, out_for_delivery, delivered, cancelled
  final String paymentMethod;
  final String deliveryAddress;
  final String contactPhone;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    this.userId,
    required this.totalPrice,
    required this.status,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.contactPhone,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      totalPrice: double.parse(json['total_price'].toString()),
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String,
      deliveryAddress: json['delivery_address'] as String,
      contactPhone: json['contact_phone'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Human-friendly status label for the customer.
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
