class UserModel {
  final String id;
  final String phone;
  final String name;
  final String role;
  final String? address;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.phone,
    required this.name,
    required this.role,
    this.address,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phone: json['phone'] as String,
      name: (json['name'] ?? '') as String,
      role: (json['role'] ?? 'user') as String,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'role': role,
      'address': address,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isAdmin => role == 'admin';
}
