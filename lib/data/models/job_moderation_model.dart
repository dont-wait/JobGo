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
    DateTime parsePostedDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    List<String> parseReasons(dynamic value) {
      if (value is List) {
        return value.map((item) => item.toString()).toList();
      }
      if (value is String && value.trim().isNotEmpty) {
        return value
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }
      return const <String>[];
    }

    return JobModerationItem(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      company: (json['company'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      salaryRange: (json['salaryRange'] ?? '').toString(),
      postedDate: parsePostedDate(json['postedDate']),
      status: (json['status'] ?? 'pending').toString().toLowerCase(),
      rejectionReasons: parseReasons(json['rejectionReasons']),
      description: json['description']?.toString(),
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
