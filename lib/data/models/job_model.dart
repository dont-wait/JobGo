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

  const JobModel({
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
                  'Unknown Company')
              .toString(),
      logoColor: (json['logo_color'] ?? json['j_logo_color'] ?? '0xFF1A3A4A')
          .toString(),
      logoText: (json['logo_text'] ?? json['j_logo_text'] ?? 'JG').toString(),
      logoUrl: json['logo_url']?.toString(),
      location: (json['j_location'] ?? json['location'] ?? '').toString(),
      salary:
          (json['j_salary'] ?? json['salary'] ?? json['j_compensation'] ?? '')
              .toString(),
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

  factory JobModel.fromMockJob(MockJob job) {
    return JobModel(
      id: job.id,
      title: job.title,
      company: job.company,
      logoColor: job.logoColor,
      logoText: job.logoText,
      logoUrl: job.logoUrl,
      location: job.location,
      salary: job.salary,
      type: job.type,
      postedTime: job.postedTime,
      isBookmarked: job.isBookmarked,
      badge: job.badge,
      description: job.description,
      requirements: job.requirements,
      benefits: job.benefits,
      tags: job.tags,
      applicants: job.applicants,
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
}
