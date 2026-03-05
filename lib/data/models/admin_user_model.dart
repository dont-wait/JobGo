class AdminUserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'candidate', 'employer', 'admin'
  final String status; // 'active', 'offline', 'blocked'
  final String? title;
  final String? company;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? lastActive;

  AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.title,
    this.company,
    this.avatarUrl,
    required this.createdAt,
    this.lastActive,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'candidate',
      status: json['status'] as String? ?? 'active',
      title: json['title'] as String?,
      company: json['company'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'title': title,
      'company': company,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive?.toIso8601String(),
    };
  }

  AdminUserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? status,
    String? title,
    String? company,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return AdminUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      title: title ?? this.title,
      company: company ?? this.company,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
