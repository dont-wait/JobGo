class EmployerModel {
  final int? id;
  final int? userId;
  final String companyName;
  final String? logoUrl;
  final String? description;
  final String? website;
  final String? address; // mapped to e_company_address
  final String? industry;
  final String? companySize; // mapped to e_company_size
  final String? phone;
  final String? email;

  // From users table (join)
  final String? contactName;

  // Generated UI fields
  final String logoColor;
  final String logoText;

  EmployerModel({
    this.id,
    this.userId,
    required this.companyName,
    this.logoUrl,
    this.description,
    this.website,
    this.address,
    this.industry,
    this.companySize,
    this.phone,
    this.email,
    this.contactName,
    required this.logoColor,
    required this.logoText,
  });

  factory EmployerModel.fromJson(Map<String, dynamic> json) {
    String getString(String key) {
      final val = json[key];
      return (val == null || val.toString().toLowerCase() == 'null')
          ? ''
          : val.toString();
    }

    final name = getString('e_company_name').isEmpty
        ? 'Unspecified Company'
        : getString('e_company_name');

    // UI Visuals
    final List<String> premiumColors = [
      '0xFF6366F1',
      '0xFF8B5CF6',
      '0xFFEC4899',
      '0xFFF59E0B',
      '0xFF10B981',
      '0xFF3B82F6',
    ];
    final colorIndex = name.hashCode.abs() % premiumColors.length;
    final generatedColor = premiumColors[colorIndex];
    final generatedLogoText = name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();

    // Handling the users join if present
    final userData = json['users'] as Map<String, dynamic>?;
    final fullNameFromUser = userData != null
        ? (userData['u_name'] as String?)
        : null;

    return EmployerModel(
      id: json['e_id'] as int?,
      userId: json['u_id'] as int?,
      companyName: name,
      logoUrl: getString('e_logo_url'),
      description: getString('e_company_description'), // Updated to SQL field
      website: getString('e_website'),
      address: getString('e_company_address'), // Updated to SQL field
      industry: getString('e_industry'),
      companySize: getString('e_company_size'), // Updated to SQL field
      phone: getString('e_phone'),
      email: getString('e_email'),
      contactName: fullNameFromUser,
      logoColor: generatedColor,
      logoText: generatedLogoText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'e_company_name': companyName,
      'e_logo_url': logoUrl,
      'e_company_description': description,
      'e_website': website,
      'e_company_address': address,
      'e_industry': industry,
      'e_company_size': companySize,
      'e_phone': phone,
      'e_email': email,
    };
  }

  EmployerModel copyWith({
    String? companyName,
    String? logoUrl,
    String? description,
    String? website,
    String? address,
    String? industry,
    String? companySize,
    String? phone,
    String? email,
    String? contactName,
  }) {
    return EmployerModel(
      id: id,
      userId: userId,
      companyName: companyName ?? this.companyName,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
      website: website ?? this.website,
      address: address ?? this.address,
      industry: industry ?? this.industry,
      companySize: companySize ?? this.companySize,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      contactName: contactName ?? this.contactName,
      logoColor: logoColor,
      logoText: logoText,
    );
  }
}
