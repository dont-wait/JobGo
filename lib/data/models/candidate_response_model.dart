class CandidateResponseModel {
  final int aId;
  final String candidateName;
  final String message;
  final DateTime responseDate;
  final bool accepted;

  CandidateResponseModel({
    required this.aId,
    required this.candidateName,
    required this.message,
    required this.responseDate,
    required this.accepted,
  });

  factory CandidateResponseModel.fromJson(Map<String, dynamic> json) {
    final candidate = json['candidates'] as Map<String, dynamic>?;
    final status = json['a_status'] as String? ?? '';

    return CandidateResponseModel(
      aId: json['a_id'] as int,
      candidateName: candidate?['c_full_name'] as String? ?? 'Unknown',
      message: json['a_cover_letter'] as String? ?? '',
      responseDate: DateTime.parse(json['a_updated_at'] as String),
      accepted: status == 'accepted',
    );
  }
}