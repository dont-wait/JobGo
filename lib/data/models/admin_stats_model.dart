class AdminStats {
  final int totalUsers;
  final int pendingJobs;
  final double platformRevenue;
  final String revenueGrowth;
  final DateTime lastUpdated;
  final List<ActivityItem> recentActivities;
  final List<GrowthDataPoint> growthData;

  AdminStats({
    required this.totalUsers,
    required this.pendingJobs,
    required this.platformRevenue,
    required this.revenueGrowth,
    required this.lastUpdated,
    required this.recentActivities,
    required this.growthData,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['totalUsers'] as int? ?? 0,
      pendingJobs: json['pendingJobs'] as int? ?? 0,
      platformRevenue: (json['platformRevenue'] as num?)?.toDouble() ?? 0.0,
      revenueGrowth: json['revenueGrowth'] as String? ?? '+0%',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
      recentActivities: (json['recentActivities'] as List?)
              ?.map((item) => ActivityItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      growthData: (json['growthData'] as List?)
              ?.map((item) => GrowthDataPoint.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'pendingJobs': pendingJobs,
      'platformRevenue': platformRevenue,
      'revenueGrowth': revenueGrowth,
      'lastUpdated': lastUpdated.toIso8601String(),
      'recentActivities': recentActivities.map((activity) => activity.toJson()).toList(),
      'growthData': growthData.map((data) => data.toJson()).toList(),
    };
  }
}

class ActivityItem {
  final String title;
  final String description;
  final DateTime timestamp;
  final String type;

  ActivityItem({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      type: json['type'] as String? ?? 'default',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

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

class GrowthDataPoint {
  final String label;
  final double users;
  final double jobs;

  GrowthDataPoint({
    required this.label,
    required this.users,
    required this.jobs,
  });

  factory GrowthDataPoint.fromJson(Map<String, dynamic> json) {
    return GrowthDataPoint(
      label: json['label'] as String? ?? '',
      users: (json['users'] as num?)?.toDouble() ?? 0.0,
      jobs: (json['jobs'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'users': users,
      'jobs': jobs,
    };
  }
}
