class SkillModel {
  final int skId;
  final String skName;
  final String? skDescription;
  final int? csYears; // số năm kinh nghiệm

  SkillModel({
    required this.skId,
    required this.skName,
    this.skDescription,
    this.csYears,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      skId: json['sk_id'] as int,
      skName: json['sk_name'] as String,
      skDescription: json['sk_description'] as String?,
      csYears: json['cs_years'] as int?,
    );
  }
}