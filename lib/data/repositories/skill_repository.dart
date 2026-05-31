import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jobgo/data/models/skill_model.dart';

class SkillRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<SkillModel>> fetchSkills() async {
    final data = await _supabase
        .from('skill')
        .select('sk_id, sk_name, sk_description')
        .order('sk_name');

    return (data as List<dynamic>)
        .map(
          (row) => SkillModel.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<SkillModel?> findByName(String skillName) async {
    final normalized = normalizeSkillName(skillName);
    if (normalized.isEmpty) return null;

    final row = await _supabase
        .from('skill')
        .select('sk_id, sk_name, sk_description')
        .ilike('sk_name', normalized)
        .maybeSingle();

    if (row == null) return null;
    return SkillModel.fromJson(Map<String, dynamic>.from(row as Map));
  }

  Future<SkillModel> createSkill({
    required String skillName,
    String? description,
  }) async {
    final normalized = normalizeSkillName(skillName);
    final payload = <String, dynamic>{'sk_name': normalized};
    final cleanedDescription = description?.trim();
    if (cleanedDescription != null && cleanedDescription.isNotEmpty) {
      payload['sk_description'] = cleanedDescription;
    }

    final row = await _supabase
        .from('skill')
        .insert(payload)
        .select('sk_id, sk_name, sk_description')
        .single();

    return SkillModel.fromJson(Map<String, dynamic>.from(row as Map));
  }

  Future<SkillModel> getOrCreateSkill({
    required String skillName,
    String? description,
  }) async {
    final existing = await findByName(skillName);
    if (existing != null) return existing;

    try {
      return await createSkill(skillName: skillName, description: description);
    } catch (_) {
      // Handle race conditions or DB unique constraints by re-checking.
      final fallback = await findByName(skillName);
      if (fallback != null) return fallback;
      rethrow;
    }
  }

  static String normalizeSkillName(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
