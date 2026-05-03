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
    final user = json['users'] as Map<String, dynamic>?;
    final inferredRole = (json['e_id'] ?? json['e_company_name']) != null
        ? 'employer'
        : (json['c_id'] ?? json['c_full_name']) != null
            ? 'candidate'
            : 'candidate';
    return AdminUserModel(
      id: (json['u_id'] ?? user?['u_id'] ?? json['id'] ?? json['c_id'] ?? '')
          .toString(),
      name: (json['u_name'] ??
              json['c_full_name'] ??
              json['name'] ??
              user?['u_name'] ??
              '')
          .toString(),
      email: (json['u_email'] ?? user?['u_email'] ?? json['email'] ?? '')
          .toString(),
      role: (json['u_role'] ?? user?['u_role'] ?? json['role'] ?? inferredRole)
          .toString(),
      status:
          (json['u_status'] ?? user?['u_status'] ?? json['status'] ?? 'active')
              .toString(),
      title: (json['u_title'] ?? json['c_title'] ?? json['title']) as String?,
      company: (json['company_name'] ??
          json['company'] ??
          json['e_company_name']) as String?,
      avatarUrl: (json['u_avatar_url'] ??
          json['c_avatar_url'] ??
          user?['u_avatar_url'] ??
          json['avatarUrl']) as String?,
      createdAt: (json['u_created_at'] ??
                  json['u_create_at'] ??
                  json['c_created_at'] ??
                  user?['u_created_at'] ??
                  user?['u_create_at'] ??
                  json['createdAt']) !=
              null
          ? DateTime.parse(
              (json['u_created_at'] ??
                      json['u_create_at'] ??
                      json['c_created_at'] ??
                      user?['u_created_at'] ??
                      user?['u_create_at'] ??
                      json['createdAt'])
                  .toString(),
            )
          : DateTime.now(),
      lastActive: (json['u_last_active'] ??
                  user?['u_last_active'] ??
                  json['lastActive']) !=
              null
          ? DateTime.parse(
              (json['u_last_active'] ??
                      user?['u_last_active'] ??
                      json['lastActive'])
                  .toString(),
            )
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
