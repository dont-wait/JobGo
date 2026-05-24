class AiCvAnalysisModel {
  final int? id;
  final int? applicationId;
  final int jobId;
  final int candidateId;
  final String cvUrl;
  final int matchScore;
  final String summary;
  final List<String> strengths;
  final List<String> gaps;
  final List<String> suggestions;
  final List<String> coverLetterTips;
  final List<String> riskFlags;
  final String languageCode;
  final String model;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AiCvAnalysisModel({
    this.id,
    this.applicationId,
    required this.jobId,
    required this.candidateId,
    required this.cvUrl,
    required this.matchScore,
    required this.summary,
    required this.strengths,
    required this.gaps,
    required this.suggestions,
    required this.coverLetterTips,
    required this.riskFlags,
    required this.languageCode,
    required this.model,
    this.createdAt,
    this.updatedAt,
  });

  factory AiCvAnalysisModel.fromGeminiJson({
    required Map<String, dynamic> json,
    required int? applicationId,
    required int jobId,
    required int candidateId,
    required String cvUrl,
    required String languageCode,
    required String model,
  }) {
    return AiCvAnalysisModel(
      applicationId: applicationId,
      jobId: jobId,
      candidateId: candidateId,
      cvUrl: cvUrl,
      matchScore: _toScore(json['matchScore']),
      summary: _toText(json['summary']),
      strengths: _toStringList(json['strengths']),
      gaps: _toStringList(json['gaps']),
      suggestions: _toStringList(json['suggestions']),
      coverLetterTips: _toStringList(json['coverLetterTips']),
      riskFlags: _toStringList(json['riskFlags']),
      languageCode: languageCode,
      model: model,
    );
  }

  factory AiCvAnalysisModel.fromJson(Map<String, dynamic> json) {
    return AiCvAnalysisModel(
      id: _toInt(json['id']),
      applicationId: _toInt(json['application_id']),
      jobId: _toInt(json['job_id']) ?? 0,
      candidateId: _toInt(json['candidate_id']) ?? 0,
      cvUrl: _toText(json['cv_url']),
      matchScore: _toScore(json['match_score']),
      summary: _toText(json['summary']),
      strengths: _toStringList(json['strengths']),
      gaps: _toStringList(json['gaps']),
      suggestions: _toStringList(json['suggestions']),
      coverLetterTips: _toStringList(json['cover_letter_tips']),
      riskFlags: _toStringList(json['risk_flags']),
      languageCode: _toText(json['language_code'], fallback: 'vi'),
      model: _toText(json['model'], fallback: 'gemini-2.5-flash'),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'application_id': applicationId,
      'job_id': jobId,
      'candidate_id': candidateId,
      'cv_url': cvUrl,
      'match_score': matchScore,
      'summary': summary,
      'strengths': strengths,
      'gaps': gaps,
      'suggestions': suggestions,
      'cover_letter_tips': coverLetterTips,
      'risk_flags': riskFlags,
      'language_code': languageCode,
      'model': model,
    };
  }

  AiCvAnalysisModel copyWith({
    int? id,
    int? applicationId,
    int? jobId,
    int? candidateId,
    String? cvUrl,
    int? matchScore,
    String? summary,
    List<String>? strengths,
    List<String>? gaps,
    List<String>? suggestions,
    List<String>? coverLetterTips,
    List<String>? riskFlags,
    String? languageCode,
    String? model,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AiCvAnalysisModel(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      jobId: jobId ?? this.jobId,
      candidateId: candidateId ?? this.candidateId,
      cvUrl: cvUrl ?? this.cvUrl,
      matchScore: matchScore ?? this.matchScore,
      summary: summary ?? this.summary,
      strengths: strengths ?? this.strengths,
      gaps: gaps ?? this.gaps,
      suggestions: suggestions ?? this.suggestions,
      coverLetterTips: coverLetterTips ?? this.coverLetterTips,
      riskFlags: riskFlags ?? this.riskFlags,
      languageCode: languageCode ?? this.languageCode,
      model: model ?? this.model,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int _toScore(dynamic value) {
    final parsed = _toInt(value) ?? 0;
    return parsed.clamp(0, 100).toInt();
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    final raw = value.toString().trim();
    if (raw.isEmpty) return const [];

    if (raw.startsWith('[') && raw.endsWith(']')) {
      final inner = raw.substring(1, raw.length - 1).trim();
      if (inner.isEmpty) return const [];
      return inner
          .split(',')
          .map((item) => item.replaceAll('"', '').replaceAll("'", '').trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return [raw];
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  static String _toText(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
