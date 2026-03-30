import 'package:jobgo/data/mockdata/mock_jobs.dart';

class JobModel {
  final String id;
  final String title;
  final String company;
  final String logoColor;
  final String logoText;
  final String? logoUrl;
  final String location;
  final String salary;
  final String type;
  final String postedTime;
  final bool isBookmarked;
  final String? badge;
  final String? description;
  final List<String>? requirements;
  final List<String>? benefits;
  final List<String>? tags;
  final int? applicants;
  final DateTime? createdAt;

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.logoColor,
    required this.logoText,
    this.logoUrl,
    this.location = '',
    this.salary = '',
    this.type = '',
    this.postedTime = '',
    this.isBookmarked = false,
    this.badge,
    this.description,
    this.requirements,
    this.benefits,
    this.tags,
    this.applicants,
    this.createdAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    // Helper to get string safely with fallback
    String getString(
      Map<String, dynamic> data,
      String key, {
      String defaultValue = '',
    }) {
      final value = data[key];
      if (value == null ||
          value.toString().toLowerCase() == 'null' ||
          value.toString().isEmpty) {
        return defaultValue;
      }
      return value.toString();
    }

    final employer = json['employers'] as Map<String, dynamic>?;
    final companyName = employer != null
        ? getString(employer, 'e_company_name', defaultValue: 'Unknown Company')
        : 'Unknown Company';

    // Generate a consistent color based on company name
    final List<String> colors = [
      '0xFF1A3A4A',
      '0xFF2D5A3D',
      '0xFFB8860B',
      '0xFF6B21A8',
      '0xFF0369A1',
      '0xFFDC2626',
    ];
    final colorIndex = companyName.hashCode.abs() % colors.length;
    final generatedColor = colors[colorIndex];

    // Get logo text from company name (first 2 chars)
    final generatedLogoText = companyName.length >= 2
        ? companyName.substring(0, 2).toUpperCase()
        : companyName.toUpperCase();

    // Calculate relative time for postedTime if j_posted_time is missing
    String timeAgo = getString(json, 'j_posted_time');
    if (timeAgo.isEmpty && json['j_create_at'] != null) {
      try {
        final createdAt = DateTime.parse(json['j_create_at']);
        final diff = DateTime.now().difference(createdAt);
        if (diff.inDays > 0) {
          timeAgo = '${diff.inDays}d ago';
        } else if (diff.inHours > 0) {
          timeAgo = '${diff.inHours}h ago';
        } else if (diff.inMinutes > 0) {
          timeAgo = '${diff.inMinutes}m ago';
        } else {
          timeAgo = 'Just now';
        }
      } catch (_) {
        timeAgo = '';
      }
    }

    // Construct salary range if min/max are available
    String salaryRange = getString(json, 'j_salary');
    final minSalary = json['j_salary_min']?.toString();
    final maxSalary = json['j_salary_max']?.toString();
    if (minSalary != null &&
        maxSalary != null &&
        minSalary.isNotEmpty &&
        maxSalary.isNotEmpty) {
      salaryRange = '$minSalary - $maxSalary';
    }

    return JobModel(
      id: getString(json, 'j_id'),
      title: getString(json, 'j_title'),
      company: companyName,
      logoColor: generatedColor,
      logoText: generatedLogoText,
      logoUrl: employer != null ? getString(employer, 'e_logo_url') : '',
      location: getString(json, 'j_location'),
      salary: salaryRange,
      type: getString(json, 'j_type'),
      postedTime: timeAgo,
      isBookmarked: json['j_is_bookmarked'] ?? false,
      badge: getString(json, 'j_badge'),
      description: json['j_description'] != null
          ? (json['j_description'] is List
                ? (json['j_description'] as List).join('\n')
                : json['j_description'].toString())
          : null,
      requirements: json['j_requirements'] != null
          ? (json['j_requirements'] is List
                ? (json['j_requirements'] as List)
                      .map((e) => e.toString())
                      .toList()
                : json['j_requirements']
                      .toString()
                      .split(',')
                      .map((e) => e.trim())
                      .toList())
          : null,
      benefits: json['j_benefits'] != null
          ? (json['j_benefits'] is List
                ? (json['j_benefits'] as List).map((e) => e.toString()).toList()
                : json['j_benefits']
                      .toString()
                      .split(',')
                      .map((e) => e.trim())
                      .toList())
          : null,
      tags: json['j_tags'] != null && json['j_tags'].toString().isNotEmpty
          ? json['j_tags'].toString().split(',').map((e) => e.trim()).toList()
          : (json['j_category'] != null
                ? [json['j_category'].toString()]
                : null),
      applicants: json['j_application_count'] != null
          ? (json['j_application_count'] as num).toInt()
          : 0,
      createdAt: json['j_create_at'] != null
          ? DateTime.parse(json['j_create_at'])
          : null,
    );
  }

  MockJob toMockJob() {
    return MockJob(
      id: id,
      title: title,
      company: company,
      logoColor: logoColor,
      logoText: logoText,
      logoUrl: logoUrl,
      location: location,
      salary: salary,
      type: type,
      postedTime: postedTime,
      isBookmarked: isBookmarked,
      badge: badge,
      description: description,
      requirements: requirements,
      benefits: benefits,
      tags: tags,
      applicants: applicants,
    );
  }
}
