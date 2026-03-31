import 'candidate_supabase_model.dart';
import 'job_model.dart';

enum ApplicationStatus {
  pending,
  reviewing,
  interview,
  hired,
  rejected,
  withdrawn,
}

class JobApplicantModel {
  final int applicationId;
  final int jobId;
  final int candidateId;
  final String coverLetter;
  final String? internalNotes;
  final ApplicationStatus status;
  final String cvUrl;
  final DateTime? appliedAt;
  final DateTime? updatedAt;
  final CandidateSupabaseModel candidate;
  final JobModel? job;

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
    this.job,
  });

  factory JobApplicantModel.fromJson(Map<String, dynamic> json) {
    final candidateJson = json['candidates'] as Map<String, dynamic>?;
    final jobJson = json['jobs'] as Map<String, dynamic>?;

    return JobApplicantModel(
      applicationId: _toInt(json['a_id'] ?? json['id']) ?? 0,
      jobId: _toInt(json['j_id'] ?? json['job_id']) ?? 0,
      candidateId: _toInt(json['c_id'] ?? json['candidate_id']) ?? 0,
      coverLetter: _stringValue(json['a_cover_letter'] ?? json['cover_letter']),
      internalNotes: _nullableStringValue(
        json['a_internal_notes'] ?? json['internal_notes'],
      ),
      status: _toStatus(json['a_status'] ?? json['status']),
      cvUrl: _stringValue(json['a_cv_url'] ?? json['cv_url']),
      appliedAt: _toDateTime(json['a_applied_at'] ?? json['applied_at']),
      updatedAt: _toDateTime(json['a_updated_at'] ?? json['updated_at']),
      candidate: CandidateSupabaseModel.fromJson(
        candidateJson ?? const <String, dynamic>{},
      ),
      job: jobJson != null ? JobModel.fromJson(jobJson) : null,
    );
  }

  String get statusLabel => status.name.toUpperCase();

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
    final baseScore = switch (status) {
      ApplicationStatus.interview => 95,
      ApplicationStatus.reviewing => 91,
      ApplicationStatus.pending => 87,
      ApplicationStatus.hired => 98,
      ApplicationStatus.rejected => 72,
      ApplicationStatus.withdrawn => 68,
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

  static ApplicationStatus _toStatus(dynamic value) {
    if (value == null) return ApplicationStatus.pending;
    final statusStr = value.toString().trim().toLowerCase();
    if (statusStr == 'reviewed') return ApplicationStatus.reviewing;
    return ApplicationStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => ApplicationStatus.pending,
    );
  }

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
