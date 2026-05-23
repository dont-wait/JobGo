import 'dart:developer' as dev;

import 'package:jobgo/data/models/ai_cv_analysis_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AiCvAnalysisRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const _table = 'application_ai_analysis';

  Future<AiCvAnalysisModel?> fetchCachedAnalysis({
    required int applicationId,
    required int jobId,
    required String cvUrl,
    required String languageCode,
  }) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('application_id', applicationId)
          .eq('job_id', jobId)
          .eq('cv_url', cvUrl)
          .eq('language_code', languageCode)
          .maybeSingle();

      if (response == null) return null;
      return AiCvAnalysisModel.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    } catch (e) {
      dev.log('fetchCachedAnalysis failed: $e');
      return null;
    }
  }

  Future<Map<int, AiCvAnalysisModel>> fetchByApplicationIds(
    List<int> applicationIds,
    String languageCode,
  ) async {
    if (applicationIds.isEmpty) return const {};

    try {
      final response = await _supabase
          .from(_table)
          .select()
          .inFilter('application_id', applicationIds)
          .eq('language_code', languageCode)
          .order('updated_at', ascending: false);
      final rows = (response as List<dynamic>)
          .map((e) => AiCvAnalysisModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      final byApplication = <int, AiCvAnalysisModel>{};
      for (final row in rows) {
        final id = row.applicationId;
        if (id == null) continue;
        byApplication.putIfAbsent(id, () => row);
      }
      return byApplication;
    } catch (e) {
      dev.log('fetchByApplicationIds failed: $e');
      return const {};
    }
  }

  Future<AiCvAnalysisModel?> saveAnalysis(AiCvAnalysisModel analysis) async {
    try {
      final payload = analysis.toDbMap()
        ..['updated_at'] = DateTime.now().toUtc().toIso8601String();
      final result = await _supabase
          .from(_table)
          .upsert(
            payload,
            onConflict: 'application_id,job_id,cv_url,language_code',
          )
          .select()
          .maybeSingle();

      if (result == null) return null;
      return AiCvAnalysisModel.fromJson(
        Map<String, dynamic>.from(result as Map),
      );
    } catch (e) {
      dev.log('saveAnalysis failed: $e');
      return null;
    }
  }
}
