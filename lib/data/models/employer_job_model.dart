class EmployerJobModel {
  final int? id;
  final int? employerId;
  final String title;
  final String description;
  final String requirementsText;
  final String location;
  final String employmentType;
  final String category;
  final double? salaryMin;
  final double? salaryMax;
  final double? salaryValue;
  final bool salaryNegotiable;
  final int positions;
  final DateTime? deadline;
  final String status;
  final String moderationStatus;
  final int applicationCount;
  final String? badge;
  final List<String> tags;
  final List<String> benefits;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String companyName;
  final String companyLogoUrl;
  final String companyLogoColor;
  final String companyLogoText;

  const EmployerJobModel({
    this.id,
    this.employerId,
    required this.title,
    this.description = '',
    this.requirementsText = '',
    this.location = '',
    this.employmentType = '',
    this.category = '',
    this.salaryMin,
    this.salaryMax,
    this.salaryValue,
    this.salaryNegotiable = false,
    this.positions = 1,
    this.deadline,
    this.status = 'draft',
    this.moderationStatus = 'draft',
    this.applicationCount = 0,
    this.badge,
    this.tags = const [],
    this.benefits = const [],
    this.createdAt,
    this.updatedAt,
    this.companyName = '',
    this.companyLogoUrl = '',
    this.companyLogoColor = '0xFF1A3A4A',
    this.companyLogoText = 'JG',
  });

  EmployerJobModel copyWith({
    int? id,
    int? employerId,
    String? title,
    String? description,
    String? requirementsText,
    String? location,
    String? employmentType,
    String? category,
    double? salaryMin,
    double? salaryMax,
    double? salaryValue,
    bool? salaryNegotiable,
    int? positions,
    DateTime? deadline,
    String? status,
    String? moderationStatus,
    int? applicationCount,
    String? badge,
    List<String>? tags,
    List<String>? benefits,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? companyName,
    String? companyLogoUrl,
    String? companyLogoColor,
    String? companyLogoText,
  }) {
    return EmployerJobModel(
      id: id ?? this.id,
      employerId: employerId ?? this.employerId,
      title: title ?? this.title,
      description: description ?? this.description,
      requirementsText: requirementsText ?? this.requirementsText,
      location: location ?? this.location,
      employmentType: employmentType ?? this.employmentType,
      category: category ?? this.category,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      salaryValue: salaryValue ?? this.salaryValue,
      salaryNegotiable: salaryNegotiable ?? this.salaryNegotiable,
      positions: positions ?? this.positions,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      applicationCount: applicationCount ?? this.applicationCount,
      badge: badge ?? this.badge,
      tags: tags ?? this.tags,
      benefits: benefits ?? this.benefits,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      companyName: companyName ?? this.companyName,
      companyLogoUrl: companyLogoUrl ?? this.companyLogoUrl,
      companyLogoColor: companyLogoColor ?? this.companyLogoColor,
      companyLogoText: companyLogoText ?? this.companyLogoText,
    );
  }

  factory EmployerJobModel.fromJson(Map<String, dynamic> json) {
    final employerMap = _asMap(json['employers']);
    final companyName = _stringValue(
      employerMap['e_company_name'] ??
          employerMap['company_name'] ??
          employerMap['name'] ??
          json['j_company'] ??
          '',
      fallback: 'Unknown Company',
    );

    final logoColor = _stringValue(
      employerMap['logo_color'] ??
          employerMap['e_logo_color'] ??
          json['logo_color'] ??
          _buildColorFromName(companyName),
      fallback: _buildColorFromName(companyName),
    );

    final logoText = _stringValue(
      employerMap['logo_text'] ??
          employerMap['e_logo_text'] ??
          json['logo_text'] ??
          _buildLogoText(companyName),
      fallback: _buildLogoText(companyName),
    );

    return EmployerJobModel(
      id: _intValue(json['j_id'] ?? json['id']),
      employerId: _intValue(json['e_id'] ?? employerMap['e_id']),
      title: _stringValue(
        json['j_title'] ?? json['title'],
        fallback: 'Untitled Job',
      ),
      description: _textValue(json['j_description'] ?? json['description']),
      requirementsText: _textValue(
        json['j_requirements'] ?? json['requirements'],
      ),
      location: _stringValue(json['j_location'] ?? json['location']),
      employmentType: _stringValue(
        json['j_type'] ?? json['job_type'] ?? json['type'],
      ),
      category: _stringValue(json['j_category'] ?? json['category']),
      salaryMin: _doubleValue(json['j_salary_min'] ?? json['salary_min']),
      salaryMax: _doubleValue(json['j_salary_max'] ?? json['salary_max']),
      salaryValue: _doubleValue(json['j_salary'] ?? json['salary']),
      salaryNegotiable: _boolValue(
        json['j_salary_negotiable'] ?? json['salary_negotiable'],
      ),
      positions: _intValue(json['j_positions'] ?? json['positions']) ?? 1,
      deadline: _dateValue(json['j_deadline'] ?? json['deadline']),
      status: _stringValue(
        json['j_status'] ?? json['status'],
        fallback: 'draft',
      ),
      moderationStatus: _stringValue(
        json['j_moderation_status'] ?? json['moderation_status'],
        fallback: 'draft',
      ),
      applicationCount:
          _intValue(json['j_application_count'] ?? json['application_count']) ??
          0,
      badge: _nullableStringValue(json['j_badge'] ?? json['badge']),
      tags: _stringList(json['j_tags'] ?? json['tags']),
      benefits: _stringList(json['j_benefits'] ?? json['benefits']),
      createdAt: _dateValue(json['j_create_at'] ?? json['created_at']),
      updatedAt: _dateValue(json['j_update_at'] ?? json['updated_at']),
      companyName: companyName,
      companyLogoUrl: _stringValue(
        employerMap['e_logo_url'] ?? employerMap['logo_url'] ?? '',
      ),
      companyLogoColor: logoColor,
      companyLogoText: logoText,
    );
  }

  Map<String, dynamic> toSupabasePayload({required int employerId}) {
    final now = DateTime.now().toIso8601String();
    final derivedSalaryValue = _buildSalaryPayloadValue();

    return {
      'e_id': employerId,
      'j_title': title.trim(),
      'j_description': _textPayloadList(description),
      'j_requirements': _textPayloadList(requirementsText),
      'j_location': location.trim(),
      'j_salary': derivedSalaryValue,
      'j_type': employmentType.trim(),
      'j_create_at': createdAt?.toIso8601String() ?? now,
      'j_update_at': now,
      'j_status': status.trim().isEmpty ? 'draft' : status.trim(),
      'j_category': category.trim(),
      'j_salary_min': salaryMin,
      'j_salary_max': salaryMax,
      'j_salary_negotiable': salaryNegotiable,
      'j_positions': positions,
        'j_deadline': deadline?.toIso8601String().split('T').first,
      'j_moderation_status': moderationStatus.trim().isEmpty
          ? 'draft'
          : moderationStatus.trim(),
      'j_application_count': applicationCount,
      'j_badge': _nullableStringValue(badge),
      'j_tags': List<String>.from(tags),
      'j_benefits': List<String>.from(benefits),
    };
  }

  Map<String, dynamic> toUpdatePayload() {
    final now = DateTime.now().toIso8601String();
    final derivedSalaryValue = _buildSalaryPayloadValue();

    return {
      'j_title': title.trim(),
      'j_description': _textPayloadList(description),
      'j_requirements': _textPayloadList(requirementsText),
      'j_location': location.trim(),
      'j_salary': derivedSalaryValue,
      'j_type': employmentType.trim(),
      'j_update_at': now,
      'j_status': status.trim().isEmpty ? 'draft' : status.trim(),
      'j_category': category.trim(),
      'j_salary_min': salaryMin,
      'j_salary_max': salaryMax,
      'j_salary_negotiable': salaryNegotiable,
      'j_positions': positions,
        'j_deadline': deadline?.toIso8601String().split('T').first,
      'j_moderation_status': moderationStatus.trim().isEmpty
          ? 'draft'
          : moderationStatus.trim(),
      'j_application_count': applicationCount,
      'j_badge': _nullableStringValue(badge),
      'j_tags': List<String>.from(tags),
      'j_benefits': List<String>.from(benefits),
    };
  }

  bool get isDraft {
    final normalized = status.toLowerCase();
    return normalized == 'draft' ||
        normalized == 'saved' ||
        normalized == 'pending';
  }

  bool get isActive {
    final normalized = status.toLowerCase();
    return normalized == 'active' ||
        normalized == 'published' ||
        normalized == 'open';
  }

  bool get isClosed {
    final normalized = status.toLowerCase();
    return normalized == 'closed' ||
        normalized == 'expired' ||
        normalized == 'archived';
  }

  String get salaryLabel {
    if (salaryNegotiable && salaryMin == null && salaryMax == null) {
      return 'Negotiable';
    }

    if (salaryMin != null && salaryMax != null) {
      return '\$${_compactMoney(salaryMin!)} - \$${_compactMoney(salaryMax!)}';
    }

    if (salaryMin != null) {
      return 'From \$${_compactMoney(salaryMin!)}';
    }

    if (salaryMax != null) {
      return 'Up to \$${_compactMoney(salaryMax!)}';
    }

    if (salaryValue != null && salaryValue! > 0) {
      return '\$${_compactMoney(salaryValue!)}';
    }

    return 'Negotiable';
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'active':
      case 'published':
      case 'open':
        return 'ACTIVE';
      case 'closed':
      case 'expired':
      case 'archived':
        return 'CLOSED';
      case 'pending':
        return 'PENDING';
      case 'draft':
      case 'saved':
      default:
        return status.trim().isEmpty ? 'DRAFT' : status.toUpperCase();
    }
  }

  String get moderationLabel {
    switch (moderationStatus.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'pending':
        return 'Pending review';
      default:
        return moderationStatus.isEmpty ? 'Draft' : moderationStatus;
    }
  }

  String get positionsLabel {
    return positions <= 1 ? '1 opening' : '$positions openings';
  }

  String get deadlineLabel {
    if (deadline == null) return 'No deadline';
    return 'Deadline ${_formatDate(deadline!)}';
  }

  String get updatedLabel {
    final source = updatedAt ?? createdAt;
    if (source == null) return 'Recently';
    return _formatRelativeTime(source);
  }

  String get missingInfoSummary {
    final missing = <String>[];

    if (title.trim().isEmpty) missing.add('Title');
    if (location.trim().isEmpty) missing.add('Location');
    if (description.trim().isEmpty) missing.add('Description');
    if (requirementsText.trim().isEmpty) missing.add('Requirements');
    if (category.trim().isEmpty) missing.add('Category');
    if (employmentType.trim().isEmpty) missing.add('Type');
    if (deadline == null) missing.add('Deadline');
    if (!salaryNegotiable && salaryMin == null && salaryMax == null) {
      missing.add('Salary range');
    }

    if (missing.isEmpty) {
      return 'Ready to publish';
    }

    final summary = missing.take(3).join(', ');
    return 'Missing: $summary';
  }

  List<String> get requirementBullets {
    return requirementsText
        .split(RegExp(r'\r?\n|•|- '))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<String> get cleanedTags =>
      tags.map(_stripListDecorators).where((item) => item.isNotEmpty).toList();

  List<String> get cleanedBenefits => benefits
      .map(_stripListDecorators)
      .where((item) => item.isNotEmpty)
      .toList();

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static String _stringValue(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  static String? _nullableStringValue(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int? _intValue(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double? _doubleValue(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static bool _boolValue(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    final text = value.toString().trim().toLowerCase();
    return text == 'true' || text == '1' || text == 'yes';
  }

  static DateTime? _dateValue(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static List<String> _stringList(dynamic value) {
    if (value == null) return const [];

    final items = <String>[];

    void addValue(dynamic entry) {
      if (entry == null) return;

      if (entry is List) {
        for (final nested in entry) {
          addValue(nested);
        }
        return;
      }

      final raw = entry.toString().trim();
      if (raw.isEmpty) return;

      if ((raw.startsWith('[') && raw.endsWith(']')) ||
          (raw.startsWith('{') && raw.endsWith('}'))) {
        final inner = raw.substring(1, raw.length - 1).trim();
        if (inner.isEmpty) return;

        if (inner.contains('\n')) {
          for (final part in inner.split('\n')) {
            addValue(part);
          }
          return;
        }

        if (inner.contains(',')) {
          for (final part in inner.split(',')) {
            addValue(part);
          }
          return;
        }

        addValue(inner);
        return;
      }

      if (raw.contains('\n')) {
        for (final part in raw.split('\n')) {
          addValue(part);
        }
        return;
      }

      if (raw.contains(',')) {
        for (final part in raw.split(',')) {
          addValue(part);
        }
        return;
      }

      final cleaned = _stripListDecorators(raw);
      if (cleaned.isNotEmpty) {
        items.add(cleaned);
      }
    }

    addValue(value);
    return items;
  }

  static String _textValue(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    if (value is List) {
      final items = value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
      if (items.isEmpty) return fallback;
      return items.join('\n');
    }

    final text = value.toString().trim();
    if (text.isEmpty) return fallback;

    if ((text.startsWith('[') && text.endsWith(']')) ||
        (text.startsWith('{') && text.endsWith('}'))) {
      final inner = text.substring(1, text.length - 1).trim();
      if (inner.isEmpty) return fallback;

      if (inner.contains('\n')) {
        return inner
            .split('\n')
            .map(_stripListDecorators)
            .where((item) => item.isNotEmpty)
            .join('\n');
      }

      if (inner.contains(',')) {
        return inner
            .split(',')
            .map(_stripListDecorators)
            .where((item) => item.isNotEmpty)
            .join('\n');
      }

      return _stripListDecorators(inner);
    }

    return _stripListDecorators(text);
  }

  static List<String> _textPayloadList(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return const [];

    return text
        .split(RegExp(r'\r?\n+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static String _stripListDecorators(String value) {
    var cleaned = value.trim();

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

    return cleaned;
  }

  static String _buildColorFromName(String companyName) {
    final palette = [
      '0xFF1A3A4A',
      '0xFF0F766E',
      '0xFF7C3AED',
      '0xFFB45309',
      '0xFF0EA5E9',
      '0xFFDC2626',
    ];
    if (companyName.trim().isEmpty) return palette.first;
    return palette[companyName.hashCode.abs() % palette.length];
  }

  static String _buildLogoText(String companyName) {
    final words = companyName
        .split(RegExp(r'\s+'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (words.isEmpty) return 'JG';
    if (words.length == 1) {
      final text = words.first;
      return text.length >= 2
          ? text.substring(0, 2).toUpperCase()
          : text.toUpperCase();
    }

    return '${words.first[0]}${words[1][0]}'.toUpperCase();
  }

  static double _derivedSalaryValue(double? minSalary, double? maxSalary) {
    if (minSalary != null && maxSalary != null) {
      return (minSalary + maxSalary) / 2;
    }
    if (maxSalary != null) return maxSalary;
    if (minSalary != null) return minSalary;
    return 0;
  }

  static String _compactMoney(num value) {
    final absValue = value.abs();
    if (absValue >= 1000000) {
      final compact = value / 1000000;
      return '${compact.toStringAsFixed(compact == compact.roundToDouble() ? 0 : 1)}M';
    }

    if (absValue >= 1000) {
      final compact = value / 1000;
      return '${compact.toStringAsFixed(compact == compact.roundToDouble() ? 0 : 1)}k';
    }

    return value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1);
  }

  double? _buildSalaryPayloadValue() {
    final hasSalaryData =
        salaryValue != null || salaryMin != null || salaryMax != null;
    if (!hasSalaryData) return null;
    return salaryValue ?? _derivedSalaryValue(salaryMin, salaryMax);
  }

  static String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  static String _formatRelativeTime(DateTime value) {
    final difference = DateTime.now().difference(value);

    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes.clamp(1, 59);
      return '${minutes}m ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }

    return _formatDate(value);
  }
}
