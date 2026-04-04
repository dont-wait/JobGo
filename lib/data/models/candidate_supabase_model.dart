class CandidateSupabaseModel {
  final int cId;
  final String? fullName;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? skill;
  final String? phone;
  final String? avatarUrl;
  final String? education;
  final String? experience;
  final String? resume;
  final double? desiredSalaryMin;
  final double? desiredSalaryMax;
  final int uId;
  final String? email;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? title;
  final String? summary;

  CandidateSupabaseModel({
    required this.cId,
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.skill,
    this.phone,
    this.avatarUrl,
    this.education,
    this.experience,
    this.resume,
    this.desiredSalaryMin,
    this.desiredSalaryMax,
    required this.uId,
    this.email,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.title,
    this.summary,
  });

  factory CandidateSupabaseModel.fromJson(Map<String, dynamic> json) {
    final user = json['users'] as Map<String, dynamic>?;
    return CandidateSupabaseModel(
      cId: _toInt(json['c_id']) ?? 0,
      fullName: _nullableStringValue(
        json['c_full_name'] ?? json['fullName'] ?? user?['u_name'],
      ),
      dateOfBirth: _nullableStringValue(json['c_date_of_birth']),
      gender: _nullableStringValue(json['c_gender']),
      address: _nullableStringValue(json['c_address']),
      skill: _nullableStringValue(json['c_skill']),
      phone: _nullableStringValue(json['c_phone'] ?? user?['u_phone']),
      avatarUrl: _nullableStringValue(json['c_avatar_url']),
      education: _nullableStringValue(json['c_education']),
      experience: _nullableStringValue(json['c_experience']),
      resume: _nullableStringValue(json['c_resume']),
      desiredSalaryMin: _toDouble(json['c_desired_salary_min']),
      desiredSalaryMax: _toDouble(json['c_desired_salary_max']),
      uId: _toInt(json['u_id']) ?? 0,
      email: _nullableStringValue(user?['u_email'] ?? json['u_email']),
      role: _nullableStringValue(user?['u_role'] ?? json['u_role']),
      createdAt: _toDateTime(json['c_created_at'] ?? json['created_at']),
      updatedAt: _toDateTime(json['c_updated_at'] ?? json['updated_at']),
      title: _nullableStringValue(json['c_title']),
      summary: _nullableStringValue(json['c_summary']),
    );
  }

  CandidateSupabaseModel copyWith({
    int? cId,
    String? fullName,
    String? dateOfBirth,
    String? gender,
    String? address,
    String? skill,
    String? phone,
    String? avatarUrl,
    String? education,
    String? experience,
    String? resume,
    double? desiredSalaryMin,
    double? desiredSalaryMax,
    int? uId,
    String? email,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    String? summary,
  }) {
    return CandidateSupabaseModel(
      cId: cId ?? this.cId,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      skill: skill ?? this.skill,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      resume: resume ?? this.resume,
      desiredSalaryMin: desiredSalaryMin ?? this.desiredSalaryMin,
      desiredSalaryMax: desiredSalaryMax ?? this.desiredSalaryMax,
      uId: uId ?? this.uId,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      summary: summary ?? this.summary,
    );
  }

  String get displayName => _cleanValue(fullName, fallback: 'Candidate');

  String get displayExperience =>
      _cleanValue(experience, fallback: 'Open to opportunities');

  String get displayTitle {
    final titleText = _cleanValue(title, fallback: '');
    if (titleText.isNotEmpty) return titleText;

    final summaryText = _cleanValue(summary, fallback: '');
    if (summaryText.isNotEmpty) return summaryText;

    return 'Open to opportunities';
  }

  String get cleanSummary => _cleanValue(summary, fallback: '');

  bool get hasSummary => cleanSummary.isNotEmpty;

  String get displaySummary => cleanSummary;

  String get displayHeadline {
    return displayTitle;
  }

  String get displayLocation =>
      _cleanValue(address, fallback: 'Location not set');

  String get displayEducation =>
      _cleanValue(education, fallback: 'Education not provided');

  String get displayEmail =>
      _cleanValue(email, fallback: 'Email not available');

  String get displayPhone =>
      _cleanValue(phone, fallback: 'Phone not available');

  List<String> get skillList => _splitSkillList(skill);

  String get roleLabel {
    final searchBlob =
        '${title ?? ''} ${summary ?? ''} ${experience ?? ''} ${skill ?? ''}'
            .toLowerCase();
    if (searchBlob.contains('design') ||
        searchBlob.contains('figma') ||
        searchBlob.contains('ui/ux') ||
        searchBlob.contains('ux')) {
      return 'Designer';
    }

    if (searchBlob.contains('devops') ||
        searchBlob.contains('engineer') ||
        searchBlob.contains('aws') ||
        searchBlob.contains('docker') ||
        searchBlob.contains('linux')) {
      return 'Engineer';
    }

    if (searchBlob.contains('flutter') ||
        searchBlob.contains('dart') ||
        searchBlob.contains('react') ||
        searchBlob.contains('node') ||
        searchBlob.contains('developer') ||
        searchBlob.contains('full stack')) {
      return 'Developer';
    }

    if (searchBlob.contains('product')) {
      return 'Product';
    }

    if (searchBlob.contains('marketing')) {
      return 'Marketing';
    }

    return 'Professional';
  }

  String get seniorityLabel {
    final searchBlob =
        '${title ?? ''} ${summary ?? ''} ${experience ?? ''} ${skill ?? ''}'
            .toLowerCase();
    if (searchBlob.contains('intern')) {
      return 'Intern';
    }
    if (searchBlob.contains('junior') || searchBlob.contains('entry')) {
      return 'Junior';
    }
    if (searchBlob.contains('senior') ||
        searchBlob.contains('lead') ||
        searchBlob.contains('principal')) {
      return 'Senior';
    }
    return 'Mid';
  }

  String get salaryLabel {
    if (desiredSalaryMin != null && desiredSalaryMax != null) {
      return '${_formatMoney(desiredSalaryMin!)} - ${_formatMoney(desiredSalaryMax!)}';
    }

    if (desiredSalaryMin != null) {
      return 'From ${_formatMoney(desiredSalaryMin!)}';
    }

    if (desiredSalaryMax != null) {
      return 'Up to ${_formatMoney(desiredSalaryMax!)}';
    }

    return 'Negotiable';
  }

  String get searchableText => [
    displayName,
    displayTitle,
    displaySummary,
    displayExperience,
    displayLocation,
    displayEducation,
    displayEmail,
    displayPhone,
    roleLabel,
    seniorityLabel,
    skillList.join(' '),
  ].join(' ').toLowerCase();

  String get initials {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'C';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  String get resumeFileName {
    final rawResume = _cleanValue(resume, fallback: '');
    if (rawResume.isEmpty) {
      return '${displayName.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}_resume.pdf';
    }

    final parsedUri = Uri.tryParse(rawResume);
    final fileName = parsedUri?.pathSegments.isNotEmpty == true
        ? parsedUri!.pathSegments.last
        : rawResume;
    return fileName.isEmpty
        ? '${displayName.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}_resume.pdf'
        : fileName;
  }

  static String _cleanValue(String? value, {required String fallback}) {
    final cleaned = _nullableStringValue(value);
    return cleaned == null || cleaned.isEmpty ? fallback : cleaned;
  }

  static String? _nullableStringValue(dynamic value) {
    if (value == null) return null;
    var cleaned = value.toString().trim();
    if (cleaned.isEmpty || cleaned.toLowerCase() == 'null') return null;
    cleaned = cleaned.replaceAll('\\', '');
    while (cleaned.isNotEmpty &&
        (cleaned.startsWith('[') ||
            cleaned.startsWith('{') ||
            cleaned.startsWith('"') ||
            cleaned.startsWith("'"))) {
      cleaned = cleaned.substring(1).trim();
    }
    while (cleaned.isNotEmpty &&
        (cleaned.endsWith(']') ||
            cleaned.endsWith('}') ||
            cleaned.endsWith('"') ||
            cleaned.endsWith("'"))) {
      cleaned = cleaned.substring(0, cleaned.length - 1).trim();
    }
    return cleaned.isEmpty ? null : cleaned;
  }

  static List<String> _splitSkillList(String? value) {
    final cleanedValue = _nullableStringValue(value);
    if (cleanedValue == null) return const [];

    final results = <String>[];
    final normalized = cleanedValue.replaceAll('\\', '');

    void addValue(String entry) {
      var cleaned = entry.trim();
      if (cleaned.isEmpty) return;
      cleaned = cleaned.replaceAll('\\', '');
      while (cleaned.isNotEmpty &&
          (cleaned.startsWith('[') ||
              cleaned.startsWith('{') ||
              cleaned.startsWith('"') ||
              cleaned.startsWith("'"))) {
        cleaned = cleaned.substring(1).trim();
      }
      while (cleaned.isNotEmpty &&
          (cleaned.endsWith(']') ||
              cleaned.endsWith('}') ||
              cleaned.endsWith('"') ||
              cleaned.endsWith("'"))) {
        cleaned = cleaned.substring(0, cleaned.length - 1).trim();
      }
      if (cleaned.isNotEmpty) {
        results.add(cleaned);
      }
    }

    if (normalized.startsWith('[') && normalized.endsWith(']')) {
      final inner = normalized.substring(1, normalized.length - 1);
      for (final part in inner.split(RegExp(r'[\r\n,]+'))) {
        addValue(part);
      }
      return results;
    }

    for (final part in normalized.split(RegExp(r'[\r\n,]+'))) {
      addValue(part);
    }

    return results;
  }

  static String _formatMoney(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      final kValue = (value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1);
      return '\$${kValue}k';
    }
    return '\$${value.toStringAsFixed(value % 1 == 0 ? 0 : 2)}';
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
