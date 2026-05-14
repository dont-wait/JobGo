class ExperienceModel {
  final int exId;
  final String companyName;
  final String position;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;
  final int cId;

  ExperienceModel({
    required this.exId,
    required this.companyName,
    required this.position,
    this.startDate,
    this.endDate,
    this.description,
    required this.cId,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      exId: json['ex_id'] as int,
      companyName: json['ex_company_name'] as String? ?? '',
      position: json['ex_position'] as String? ?? '',
      startDate: json['ex_start_date'] != null
          ? DateTime.tryParse(json['ex_start_date'])
          : null,
      endDate: json['ex_end_date'] != null
          ? DateTime.tryParse(json['ex_end_date'])
          : null,
      description: json['ex_description'] as String?,
      cId: json['c_id'] as int,
    );
  }

  String get period {
    final start = startDate != null
        ? '${startDate!.month}/${startDate!.year}'
        : '?';
    final end = endDate != null
        ? '${endDate!.month}/${endDate!.year}'
        : 'Present';
    return '$start - $end';
  }
}