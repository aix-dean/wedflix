class CompanyData {
  final String companyId;
  final String name;
  final Map<String, dynamic>? address;
  final String? tin;
  final String? email;
  final String? phone;
  final String? website;
  final String? companyProfile;
  final String? logo;
  final String? businessType;
  final String? position;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String updatedBy;

  CompanyData({
    required this.companyId,
    required this.name,
    this.address,
    this.tin,
    this.email,
    this.phone,
    this.website,
    this.companyProfile,
    this.logo,
    this.businessType,
    this.position,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  factory CompanyData.fromJson(Map<String, dynamic> json) {
    return CompanyData(
      companyId: json['companyId'] ?? '',
      name: json['name'] ?? '',
      address: json['address'],
      tin: json['tin'],
      email: json['email'],
      phone: json['phone'],
      website: json['website'],
      companyProfile: json['company_profile'],
      logo: json['logo'],
      businessType: json['business_type'],
      position: json['position'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      createdBy: json['createdBy'] ?? '',
      updatedBy: json['updatedBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'name': name,
      'address': address,
      'tin': tin,
      'email': email,
      'phone': phone,
      'website': website,
      'company_profile': companyProfile,
      'logo': logo,
      'business_type': businessType,
      'position': position,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }
}