class JobModerationItem {
  final String id;
  final String title;
  final String company;
  final String location;
  final String salaryRange;
  final DateTime postedDate;
  final String status; // 'pending', 'approved', 'rejected'
  final List<String> rejectionReasons;
  final String? description;

  JobModerationItem({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salaryRange,
    required this.postedDate,
    required this.status,
    this.rejectionReasons = const [],
    this.description,
  });

  factory JobModerationItem.fromJson(Map<String, dynamic> json) {
    return JobModerationItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      location: json['location'] as String? ?? '',
      salaryRange: json['salaryRange'] as String? ?? '',
      postedDate: json['postedDate'] != null
          ? DateTime.parse(json['postedDate'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? 'pending',
      rejectionReasons: (json['rejectionReasons'] as List?)
              ?.map((item) => item as String)
              .toList() ??
          [],
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'salaryRange': salaryRange,
      'postedDate': postedDate.toIso8601String(),
      'status': status,
      'rejectionReasons': rejectionReasons,
      'description': description,
    };
  }

  JobModerationItem copyWith({
    String? id,
    String? title,
    String? company,
    String? location,
    String? salaryRange,
    DateTime? postedDate,
    String? status,
    List<String>? rejectionReasons,
    String? description,
  }) {
    return JobModerationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      salaryRange: salaryRange ?? this.salaryRange,
      postedDate: postedDate ?? this.postedDate,
      status: status ?? this.status,
      rejectionReasons: rejectionReasons ?? this.rejectionReasons,
      description: description ?? this.description,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(postedDate);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
