class CandidateSupabaseModel {
  final int cId;
  final String? fullName;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? skill;
  final String? phone;
  final String? avatarUrl;
  final String? education;
  final String? experience;
  final String? resume;
  final double? desiredSalaryMin;
  final double? desiredSalaryMax;
  final int uId;
  // Từ bảng users
  final String? email;
  final String? role;

  CandidateSupabaseModel({
    required this.cId,
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.skill,
    this.phone,
    this.avatarUrl,
    this.education,
    this.experience,
    this.resume,
    this.desiredSalaryMin,
    this.desiredSalaryMax,
    required this.uId,
    this.email,
    this.role,
  });

  factory CandidateSupabaseModel.fromJson(Map<String, dynamic> json) {
    final user = json['users'] as Map<String, dynamic>?;
    return CandidateSupabaseModel(
      cId: json['c_id'] as int,
      fullName: json['c_full_name'] as String?,
      dateOfBirth: json['c_date_of_birth'] as String?,  
      gender: json['c_gender'] as String?,
      address: json['c_address'] as String?,
      skill: json['c_skill'] as String?,
      phone: json['c_phone'] as String?,
      avatarUrl: json['c_avatar_url'] as String?,
      education: json['c_education'] as String?,
      experience: json['c_experience'] as String?,
      resume: json['c_resume'] as String?,
      desiredSalaryMin: (json['c_desired_salary_min'] as num?)?.toDouble(),
      desiredSalaryMax: (json['c_desired_salary_max'] as num?)?.toDouble(),
      uId: json['u_id'] as int,
      email: user?['u_email'] as String?,
      role: user?['u_role'] as String?,
    );
    
  }
  
  CandidateSupabaseModel copyWith({
    int? cId,
    String? fullName,
    String? dateOfBirth,
    String? gender,
    String? address,
    String? skill,
    String? phone,
    String? avatarUrl,
    String? education,
    String? experience,
    String? resume,
    double? desiredSalaryMin,
    double? desiredSalaryMax,
    int? uId,
    String? email,
    String? role,
  }) {
    return CandidateSupabaseModel(
      cId: cId ?? this.cId,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      skill: skill ?? this.skill,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      resume: resume ?? this.resume,
      desiredSalaryMin: desiredSalaryMin ?? this.desiredSalaryMin,
      desiredSalaryMax: desiredSalaryMax ?? this.desiredSalaryMax,
      uId: uId ?? this.uId,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }

}