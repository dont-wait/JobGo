class JobModel {
  final String id;
  final String title;
  final String company;
  final String logoColor;
  final String logoText;
  final String? logoUrl;
  final String location;
  final String salary;
  final double? salaryMin;
  final double? salaryMax;
  final String type;
  final String postedTime;
  final bool isBookmarked;
  final String? badge;
  final String? description;
  final List<String>? requirements;
  final List<String>? benefits;
  final List<String>? tags;
  final int? applicants;

  const JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.logoColor,
    required this.logoText,
    this.logoUrl,
    this.location = '',
    this.salary = '',
    this.salaryMin,
    this.salaryMax,
    this.type = '',
    this.postedTime = '',
    this.isBookmarked = false,
    this.badge,
    this.description,
    this.requirements,
    this.benefits,
    this.tags,
    this.applicants,
  });

  JobModel copyWith({
    String? id,
    String? title,
    String? company,
    String? logoColor,
    String? logoText,
    String? logoUrl,
    String? location,
    String? salary,
    double? salaryMin,
    double? salaryMax,
    String? type,
    String? postedTime,
    bool? isBookmarked,
    String? badge,
    String? description,
    List<String>? requirements,
    List<String>? benefits,
    List<String>? tags,
    int? applicants,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      logoColor: logoColor ?? this.logoColor,
      logoText: logoText ?? this.logoText,
      logoUrl: logoUrl ?? this.logoUrl,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      type: type ?? this.type,
      postedTime: postedTime ?? this.postedTime,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      badge: badge ?? this.badge,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      benefits: benefits ?? this.benefits,
      tags: tags ?? this.tags,
      applicants: applicants ?? this.applicants,
    );
  }

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: (json['j_id'] ?? json['id'] ?? '').toString(),
      title:
          (json['j_title'] ??
                  json['title'] ??
                  json['job_title'] ??
                  'Untitled Job')
              .toString(),
      company:
          (json['j_company'] ??
                  json['company_name'] ??
                  json['company'] ??
                  json['employers']?['e_company_name'] ??
                  'Unknown Company')
              .toString(),
      logoColor:
          (json['logo_color'] ??
                  json['j_logo_color'] ??
                  json['employers']?['logo_color'] ??
                  '0xFF1A3A4A')
              .toString(),
      logoText:
          (json['logo_text'] ??
                  json['j_logo_text'] ??
                  json['employers']?['logo_text'] ??
                  'JG')
              .toString(),
      logoUrl:
          (json['logo_url'] ??
                  json['j_logo_url'] ??
                  json['employers']?['e_logo_url'])
              ?.toString(),
      location: (json['j_location'] ?? json['location'] ?? '').toString(),
      salary:
          (json['j_salary'] ?? json['salary'] ?? json['j_compensation'] ?? '')
              .toString(),
      salaryMin: _toDoubleValue(json['j_salary_min'] ?? json['salary_min']),
      salaryMax: _toDoubleValue(json['j_salary_max'] ?? json['salary_max']),
      type: (json['j_type'] ?? json['job_type'] ?? json['type'] ?? '')
          .toString(),
      postedTime:
          (json['j_posted_at'] ??
                  json['created_at'] ??
                  json['j_create_at'] ??
                  '')
              .toString(),
      isBookmarked: json['j_is_bookmarked'] == true,
      badge: json['j_badge']?.toString(),
      description: json['j_description']?.toString(),
      requirements: _toStringList(
        json['j_requirements'] ?? json['requirements'],
      ),
      benefits: _toStringList(json['j_benefits'] ?? json['benefits']),
      tags: _toStringList(
        json['j_tags'] ?? json['tags'] ?? json['skills'] ?? json['keywords'],
      ),
      applicants: _toIntValue(
        json['j_applicants'] ?? json['applicants'] ?? json['application_count'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'j_id': id,
      'j_title': title,
      'j_company': company,
      'logo_color': logoColor,
      'logo_text': logoText,
      'logo_url': logoUrl,
      'j_location': location,
      'j_salary': salary,
      'j_salary_min': salaryMin,
      'j_salary_max': salaryMax,
      'j_type': type,
      'j_posted_at': postedTime,
      'j_is_bookmarked': isBookmarked,
      'j_badge': badge,
      'j_description': description,
      'j_requirements': requirements,
      'j_benefits': benefits,
      'j_tags': tags,
      'j_applicants': applicants,
    };
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    final text = value.toString().trim();
    if (text.isEmpty) return const [];
    return text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static int? _toIntValue(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _toDoubleValue(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  String get formattedSalary {
    if (salaryMin != null && salaryMax != null) {
      return "${_formatMoney(salaryMin!)} - ${_formatMoney(salaryMax!)}";
    }
    return salary.isNotEmpty ? salary : "Negotiable";
  }

  String _formatMoney(double value) {
    if (value >= 1000000) {
      return "\$${(value / 1000000).toStringAsFixed(1)}M";
    } else if (value >= 1000) {
      final kValue = (value / 1000).toInt();
      return "\$${kValue}k";
    }
    return "\$${value.toInt()}";
  }

  String get postedTimeAgo {
    if (postedTime.isEmpty) return 'Just now';
    try {
      final DateTime dt = DateTime.parse(postedTime);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.isNegative) return 'Just now';

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';

      return '${(diff.inDays / 30).floor()}mo ago';
    } catch (_) {
      return postedTime;
    }
  }
}
