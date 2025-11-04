class User {
  final String id;
  final String email;
  final String displayName;
  final String? phone;
  final String? profileImage;
  final String? companyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.phone,
    this.profileImage,
    this.companyId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      phone: json['phone'],
      profileImage: json['profileImage'],
      companyId: json['companyId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'phone': phone,
      'profileImage': profileImage,
      'companyId': companyId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}