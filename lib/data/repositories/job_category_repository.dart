import 'package:supabase_flutter/supabase_flutter.dart';

class JobCategoryRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<String>> fetchJobCategories() async {
    final tableCandidates = ['category', 'categories'];

    for (final tableName in tableCandidates) {
      try {
        final response = await _supabase.from(tableName).select('*');
        return _extractCategoryNames(response);
      } catch (_) {
        continue;
      }
    }

    throw StateError('Không tải được danh sách danh mục.');
  }

  List<String> _extractCategoryNames(dynamic response) {
    if (response is! List) return const [];

    final categories = response
        .map(_extractCategoryLabel)
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();

    categories.sort(
      (left, right) => left.toLowerCase().compareTo(right.toLowerCase()),
    );
    return categories;
  }

  String? _extractCategoryLabel(dynamic row) {
    final map = row is Map<String, dynamic>
        ? row
        : Map<String, dynamic>.from(row as Map);

    const preferredKeys = [
      'cat_name',
      'category_name',
      'c_name',
      'name',
      'title',
      'label',
      'category',
    ];

    for (final key in preferredKeys) {
      final value = _stringValue(map[key]);
      if (value.isNotEmpty) return value;
    }

    for (final value in map.values) {
      final text = _stringValue(value);
      if (text.isNotEmpty) return text;
    }

    return null;
  }

  String _stringValue(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }
}
