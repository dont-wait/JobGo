import 'candidate_supabase_model.dart';

class JobApplicantModel {
  final int applicationId;
  final int jobId;
  final int candidateId;
  final String coverLetter;
  final String? internalNotes;
  final String status;
  final String cvUrl;
  final DateTime? appliedAt;
  final DateTime? updatedAt;
  final CandidateSupabaseModel candidate;

  const JobApplicantModel({
    required this.applicationId,
    required this.jobId,
    required this.candidateId,
    required this.coverLetter,
    this.internalNotes,
    required this.status,
    required this.cvUrl,
    this.appliedAt,
    this.updatedAt,
    required this.candidate,
  });

  factory JobApplicantModel.fromJson(Map<String, dynamic> json) {
    final candidateJson = json['candidates'] as Map<String, dynamic>?;

    return JobApplicantModel(
      applicationId: _toInt(json['a_id'] ?? json['id']) ?? 0,
      jobId: _toInt(json['j_id'] ?? json['job_id']) ?? 0,
      candidateId: _toInt(json['c_id'] ?? json['candidate_id']) ?? 0,
      coverLetter: _stringValue(json['a_cover_letter'] ?? json['cover_letter']),
      internalNotes: _nullableStringValue(
        json['a_internal_notes'] ?? json['internal_notes'],
      ),
      status: _stringValue(
        json['a_status'] ?? json['status'],
        fallback: 'pending',
      ),
      cvUrl: _stringValue(json['a_cv_url'] ?? json['cv_url']),
      appliedAt: _toDateTime(json['a_applied_at'] ?? json['applied_at']),
      updatedAt: _toDateTime(json['a_updated_at'] ?? json['updated_at']),
      candidate: CandidateSupabaseModel.fromJson(
        candidateJson ?? const <String, dynamic>{},
      ),
    );
  }

  String get statusLabel =>
      status.trim().isEmpty ? 'PENDING' : status.trim().toUpperCase();

  String get appliedTimeAgo {
    final appliedDate = appliedAt;
    if (appliedDate == null) {
      return 'Applied recently';
    }

    final diff = DateTime.now().difference(appliedDate);
    if (diff.inDays <= 0) return 'Applied today';
    if (diff.inDays == 1) return 'Applied 1 day ago';
    if (diff.inDays < 7) return 'Applied ${diff.inDays} days ago';
    if (diff.inDays < 14) return 'Applied 1 week ago';
    return 'Applied ${(diff.inDays / 7).floor()} weeks ago';
  }

  int get matchScore {
    final normalizedStatus = status.trim().toLowerCase();
    final baseScore = switch (normalizedStatus) {
      'interview' => 95,
      'reviewing' => 91,
      'pending' => 87,
      'hired' => 98,
      'rejected' => 72,
      'withdrawn' => 68,
      _ => 85,
    };

    final skillBonus = candidate.skillList.length > 3
        ? 6
        : candidate.skillList.length * 2;
    final score = baseScore + skillBonus;
    return score.clamp(60, 99).toInt();
  }

  String get matchLabel => '$matchScore% Match';

  String get searchableText => [
    coverLetter,
    internalNotes ?? '',
    status,
    candidate.searchableText,
  ].join(' ').toLowerCase();

  static String _stringValue(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final result = value.toString().trim();
    return result.isEmpty ? fallback : result;
  }

  static String? _nullableStringValue(dynamic value) {
    if (value == null) return null;
    final result = value.toString().trim();
    return result.isEmpty || result.toLowerCase() == 'null' ? null : result;
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
