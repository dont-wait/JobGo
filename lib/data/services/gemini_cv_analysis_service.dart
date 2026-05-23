import 'dart:convert';

import 'package:jobgo/data/models/ai_cv_analysis_model.dart';
import 'package:jobgo/data/models/candidate_supabase_model.dart';
import 'package:jobgo/data/models/job_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GeminiCvAnalysisService {
  static const String _defaultModel = 'gemini-2.5-flash';
  final SupabaseClient _supabase = Supabase.instance.client;

  static bool isPdfUrl(String url) {
    final lower = url.toLowerCase().trim();
    if (lower.isEmpty) return false;
    final normalized = lower.split('?').first.split('#').first;
    return normalized.endsWith('.pdf');
  }

  Future<AiCvAnalysisModel> analyzeCv({
    required int? applicationId,
    required int jobId,
    required int candidateId,
    required String cvUrl,
    required JobModel job,
    required CandidateSupabaseModel candidate,
    required String coverLetter,
    String languageCode = 'vi',
  }) async {
    final normalizedLanguageCode = _normalizeLanguageCode(languageCode);

    if (!isPdfUrl(cvUrl)) {
      throw UnsupportedError('AI analysis supports PDF only for now.');
    }

    final response = await _supabase.functions.invoke(
      'gemini-cv-analysis',
      body: {
        'applicationId': applicationId,
        'jobId': jobId,
        'candidateId': candidateId,
        'cvUrl': cvUrl,
        'coverLetter': coverLetter,
        'languageCode': normalizedLanguageCode,
        'job': _jobPayload(job),
        'candidate': _candidatePayload(candidate),
      },
    );

    final structured = _decodeAnalysisPayload(response.data);
    final model = _toText(structured['model'], fallback: _defaultModel);

    return AiCvAnalysisModel.fromGeminiJson(
      json: structured,
      applicationId: applicationId,
      jobId: jobId,
      candidateId: candidateId,
      cvUrl: cvUrl,
      languageCode: normalizedLanguageCode,
      model: model,
    );
  }

  Map<String, dynamic> _candidatePayload(CandidateSupabaseModel candidate) {
    return {
      'displayName': candidate.displayName,
      'displayHeadline': candidate.displayHeadline,
      'displaySummary': candidate.displaySummary,
      'displayEducation': candidate.displayEducation,
      'displayLocation': candidate.displayLocation,
      'displayPhone': candidate.displayPhone,
      'displayEmail': candidate.displayEmail,
      'skillList': candidate.skillList,
      'experiences':
          candidate.experiences
              ?.map(
                (e) => {
                  'position': e.position,
                  'companyName': e.companyName,
                  'period': e.period,
                  'description': e.description,
                },
              )
              .toList() ??
          const <Map<String, dynamic>>[],
    };
  }

  Map<String, dynamic> _jobPayload(JobModel job) {
    return {
      'title': job.title,
      'company': job.company,
      'location': job.location,
      'type': job.type,
      'salary': job.formattedSalary,
      'description': job.description ?? '',
      'requirements': job.requirements ?? const <String>[],
      'tags': job.tags ?? const <String>[],
    };
  }

  Map<String, dynamic> _decodeAnalysisPayload(dynamic data) {
    dynamic payload = data;
    if (payload is String) {
      payload = jsonDecode(payload);
    }

    if (payload is Map<String, dynamic>) {
      final analysis = payload['analysis'];
      if (analysis is Map<String, dynamic>) {
        return analysis;
      }
      return payload;
    }

    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);
      final analysis = map['analysis'];
      if (analysis is Map) {
        return Map<String, dynamic>.from(analysis);
      }
      return map;
    }

    throw StateError('Unexpected AI analysis response');
  }

  String _toText(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String _normalizeLanguageCode(String languageCode) {
    final code = languageCode.trim().toLowerCase();
    if (code.startsWith('vi')) return 'vi';
    return 'en';
  }
}
