class DashboardStats {
  final int activePostings;
  final int newProfiles;
  final int totalApplications;
  final int totalViews;
  final DateTime lastUpdated;
  final List<ActivityItem> recentActivities;

  DashboardStats({
    required this.activePostings,
    required this.newProfiles,
    required this.totalApplications,
    required this.totalViews,
    required this.lastUpdated,
    required this.recentActivities,
  });

  // Factory method to create from JSON (useful for API responses)
  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      activePostings: json['activePostings'] as int? ?? 0,
      newProfiles: json['newProfiles'] as int? ?? 0,
      totalApplications: json['totalApplications'] as int? ?? 0,
      totalViews: json['totalViews'] as int? ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
      recentActivities: (json['recentActivities'] as List?)
              ?.map((item) => ActivityItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'activePostings': activePostings,
      'newProfiles': newProfiles,
      'totalApplications': totalApplications,
      'totalViews': totalViews,
      'lastUpdated': lastUpdated.toIso8601String(),
      'recentActivities':
          recentActivities.map((activity) => activity.toJson()).toList(),
    };
  }
}

class ActivityItem {
  final String title;
  final String description;
  final DateTime timestamp;
  final String type; // 'application', 'posting', 'view'

  ActivityItem({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
  });

  // Factory method to create from JSON
  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      type: json['type'] as String? ?? 'view',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }
}
