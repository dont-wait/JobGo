import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobgo/data/models/job_model.dart';

class SearchFilterOptions {
  static const RangeValues defaultSalaryRange = RangeValues(0, 10000);

  final bool fullTime;
  final bool partTime;
  final bool remote;
  final bool contract;
  final RangeValues salaryRange;
  final List<String> experiences;
  final String location;

  const SearchFilterOptions({
    required this.fullTime,
    required this.partTime,
    required this.remote,
    required this.contract,
    required this.salaryRange,
    required this.experiences,
    required this.location,
  });

  factory SearchFilterOptions.initial() {
    return const SearchFilterOptions(
      fullTime: false,
      partTime: false,
      remote: false,
      contract: false,
      salaryRange: defaultSalaryRange,
      experiences: [],
      location: '',
    );
  }

  bool get isDefault =>
      !fullTime &&
      !partTime &&
      !remote &&
      !contract &&
      salaryRange == defaultSalaryRange &&
      experiences.isEmpty &&
      location.isEmpty;

  SearchFilterOptions copyWith({
    bool? fullTime,
    bool? partTime,
    bool? remote,
    bool? contract,
    RangeValues? salaryRange,
    List<String>? experiences,
    String? location,
  }) {
    return SearchFilterOptions(
      fullTime: fullTime ?? this.fullTime,
      partTime: partTime ?? this.partTime,
      remote: remote ?? this.remote,
      contract: contract ?? this.contract,
      salaryRange: salaryRange ?? this.salaryRange,
      experiences: experiences ?? this.experiences,
      location: location ?? this.location,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchFilterOptions &&
        other.fullTime == fullTime &&
        other.partTime == partTime &&
        other.remote == remote &&
        other.contract == contract &&
        other.salaryRange == salaryRange &&
        listEquals(other.experiences, experiences) &&
        other.location == location;
  }

  @override
  int get hashCode => Object.hash(
    fullTime,
    partTime,
    remote,
    contract,
    salaryRange,
    Object.hashAll(experiences),
    location,
  );
}

class JobSearchProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<JobModel> _allJobs = [];
  String _searchQuery = '';
  String? _selectedQuickFilter;
  SearchFilterOptions _advancedFilters = SearchFilterOptions.initial();
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasLoadedOnce = false;
  String? _errorMessage;
  bool _isDisposed = false;

  List<JobModel> get allJobs => List.unmodifiable(_allJobs);
  String get searchQuery => _searchQuery;
  String? get selectedQuickFilter => _selectedQuickFilter;
  SearchFilterOptions get advancedFilters => _advancedFilters;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  List<JobModel> get filteredJobs {
    final query = _searchQuery.trim().toLowerCase();
    final jobs = _allJobs.where((job) {
      return _matchesQuery(job, query) &&
          _matchesQuickFilter(job) &&
          _matchesAdvancedFilters(job);
    }).toList();

    jobs.sort((left, right) {
      return _relevanceScore(
        right,
        query,
      ).compareTo(_relevanceScore(left, query));
    });

    return jobs;
  }

  Future<void> loadJobs({bool forceRefresh = false}) async {
    if (_isLoading || (_hasLoadedOnce && !forceRefresh)) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      final jobsResponse = await _supabase
          .from('jobs')
          .select('*, employers(*)')
          .eq('j_status', 'active')
          .eq('j_moderation_status', 'approved')
          .order('j_create_at', ascending: false)
          .limit(100);

      final savedJobIds = <dynamic>{};
      if (currentUserId != null) {
        try {
          final savedResponse = await _supabase
              .from('saved_jobs')
              .select('j_id')
              .eq('u_id', currentUserId);
          savedJobIds.addAll((savedResponse as List).map((row) => row['j_id']));
        } catch (_) {}
      }

      _allJobs = (jobsResponse as List)
          .map(
            (row) => _mapJob(
              Map<String, dynamic>.from(row as Map),
              savedJobIds.contains(row['j_id']),
            ),
          )
          .toList();
      _hasLoadedOnce = true;
    } catch (e) {
      _allJobs = [];
      _errorMessage = 'Không tải được dữ liệu từ Supabase.';
      _hasLoadedOnce = true;
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> refreshJobs() async {
    _isRefreshing = true;
    notifyListeners();
    await loadJobs(forceRefresh: true);
  }

  void setSearchQuery(String value) {
    final normalized = value.trim();
    if (_searchQuery == normalized) return;
    _searchQuery = normalized;
    notifyListeners();
  }

  void clearSearchQuery() {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    notifyListeners();
  }

  void setQuickFilter(String? value) {
    if (_selectedQuickFilter == value) return;
    _selectedQuickFilter = value;
    notifyListeners();
  }

  void clearQuickFilter() {
    if (_selectedQuickFilter == null) return;
    _selectedQuickFilter = null;
    notifyListeners();
  }

  void resetAllFilters() {
    final shouldNotify =
        _searchQuery.isNotEmpty ||
        _selectedQuickFilter != null ||
        !_advancedFilters.isDefault;

    _searchQuery = '';
    _selectedQuickFilter = null;
    _advancedFilters = SearchFilterOptions.initial();

    if (shouldNotify) {
      notifyListeners();
    }
  }

  void setAdvancedFilters(SearchFilterOptions value) {
    _advancedFilters = value;
    notifyListeners();
  }

  void resetAdvancedFilters() {
    _advancedFilters = SearchFilterOptions.initial();
    notifyListeners();
  }

  bool _matchesQuery(JobModel job, String query) {
    if (query.isEmpty) return true;

    final searchableText = <String>[
      job.title,
      job.company,
      job.location,
      job.description ?? '',
      job.badge ?? '',
      ...?job.tags,
      ...?job.requirements,
      ...?job.benefits,
    ].join(' ').toLowerCase();

    return searchableText.contains(query);
  }

  bool _matchesQuickFilter(JobModel job) {
    final filter = _selectedQuickFilter;
    if (filter == null || filter.isEmpty) return true;

    switch (filter) {
      case 'Remote':
        return _containsRemote(job.location) ||
            _containsRemote(job.type) ||
            _containsRemote(job.description ?? '');
      case 'Full-time':
        return job.type.toLowerCase().contains('full');
      case 'Part-time':
        return job.type.toLowerCase().contains('part');
      case r'$120k+':
        return _extractSalaryK(job.salary) >= 120;
      case 'Experience':
        return _containsExperience(job);
      default:
        return true;
    }
  }

  bool _matchesAdvancedFilters(JobModel job) {
    final filters = _advancedFilters;

    if (filters.fullTime ||
        filters.partTime ||
        filters.remote ||
        filters.contract) {
      final matchesType =
          (filters.fullTime && job.type.toLowerCase().contains('full')) ||
          (filters.partTime && job.type.toLowerCase().contains('part')) ||
          (filters.contract && job.type.toLowerCase().contains('contract')) ||
          (filters.remote && _containsRemote(job.location));
      if (!matchesType) return false;
    }

    final salaryK = _extractSalaryK(job.salary);
    if (salaryK > 0 &&
        (salaryK < filters.salaryRange.start ||
            salaryK > filters.salaryRange.end)) {
      return false;
    }

    final locationQuery = filters.location.trim().toLowerCase();
    if (locationQuery.isNotEmpty) {
      final locationText = job.location.toLowerCase();
      if (!locationText.contains(locationQuery)) return false;
    }

    if (filters.experiences.isNotEmpty &&
        !_matchesExperienceLevel(job, filters.experiences)) {
      return false;
    }

    return true;
  }

  bool _matchesExperienceLevel(JobModel job, List<String> experiences) {
    final searchableText = <String>[
      job.title,
      job.description ?? '',
      ...?job.tags,
      ...?job.requirements,
    ].join(' ').toLowerCase();

    return experiences.any((experience) {
      return searchableText.contains(experience.toLowerCase());
    });
  }

  bool _containsExperience(JobModel job) {
    final searchableText = <String>[
      job.title,
      job.description ?? '',
      ...?job.tags,
      ...?job.requirements,
    ].join(' ').toLowerCase();

    return searchableText.contains('entry') ||
        searchableText.contains('mid') ||
        searchableText.contains('senior') ||
        searchableText.contains('lead');
  }

  bool _containsRemote(String value) {
    return value.toLowerCase().contains('remote');
  }

  int _extractSalaryK(String salaryText) {
    if (salaryText.trim().isEmpty) return 0;

    final normalized = salaryText.toLowerCase().replaceAll(',', '');
    final withK = RegExp(r'(\d+(?:\.\d+)?)\s*k').firstMatch(normalized);
    if (withK != null) {
      return double.tryParse(withK.group(1) ?? '')?.round() ?? 0;
    }

    final withoutK = RegExp(r'(\d{1,7})').firstMatch(normalized);
    if (withoutK != null) {
      return int.tryParse(withoutK.group(1) ?? '') ?? 0;
    }

    return 0;
  }

  int _relevanceScore(JobModel job, String query) {
    if (query.isEmpty) return 0;

    final title = job.title.toLowerCase();
    final company = job.company.toLowerCase();
    final tags = (job.tags ?? const <String>[]).join(' ').toLowerCase();

    if (title == query) return 100;
    if (title.contains(query)) return 80;
    if (company.contains(query)) return 60;
    if (tags.contains(query)) return 40;
    return 10;
  }

  JobModel _mapJob(Map<String, dynamic> json, bool isBookmarked) {
    final employer = json['employers'];
    final employerMap = employer is Map<String, dynamic>
        ? employer
        : employer is Map
        ? Map<String, dynamic>.from(employer)
        : <String, dynamic>{};

    final company = _stringValue(
      json['j_company'] ??
          json['company_name'] ??
          employerMap['e_name'] ??
          employerMap['company_name'] ??
          employerMap['name'] ??
          'Unknown Company',
      fallback: 'Unknown Company',
    );

    final title = _stringValue(
      json['j_title'] ?? json['title'] ?? json['job_title'] ?? 'Untitled Job',
      fallback: 'Untitled Job',
    );

    final location = _stringValue(
      json['j_location'] ?? json['location'] ?? employerMap['location'] ?? '',
    );

    final salary = _stringValue(
      json['j_salary'] ?? json['salary'] ?? json['j_compensation'] ?? '',
    );

    final type = _stringValue(
      json['j_type'] ?? json['job_type'] ?? json['type'] ?? '',
    );

    final postedTime = _formatPostedTime(
      json['j_create_at'] ?? json['created_at'] ?? json['j_posted_at'],
    );

    final tags = _toStringList(
      json['j_tags'] ?? json['tags'] ?? json['skills'] ?? json['keywords'],
    );

    final requirements = _toStringList(
      json['j_requirements'] ?? json['requirements'],
    );

    final benefits = _toStringList(json['j_benefits'] ?? json['benefits']);

    final description = _textValue(
      json['j_description'] ?? json['description'] ?? '',
    );

    final applicants = _intValue(
      json['j_applicants'] ?? json['applicants'] ?? json['application_count'],
    );

    final badge = _stringValue(
      json['j_badge'] ?? (json['j_is_urgent'] == true ? 'URGENT' : ''),
    );

    return JobModel(
      id: _stringValue(json['j_id'] ?? json['id'], fallback: ''),
      title: title,
      company: company,
      logoColor: _buildLogoColor(company),
      logoText: _buildLogoText(company),
      logoUrl: _stringValue(json['logo_url'] ?? json['company_logo'] ?? ''),
      location: location,
      salary: salary,
      type: type,
      postedTime: postedTime,
      isBookmarked: isBookmarked,
      badge: badge.isEmpty ? null : badge,
      description: description.isEmpty ? null : description,
      requirements: requirements.isEmpty ? null : requirements,
      benefits: benefits.isEmpty ? null : benefits,
      tags: tags.isEmpty ? null : tags,
      applicants: applicants > 0 ? applicants : null,
      status: _stringValue(json['j_status'] ?? json['status'] ?? 'open'),
    );
  }

  String _stringValue(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final result = value.toString().trim();
    return result.isEmpty ? fallback : result;
  }

  List<String> _toStringList(dynamic value) {
    if (value == null) return [];

    final items = <String>[];

    void addValue(dynamic entry) {
      if (entry == null) return;

      if (entry is List) {
        for (final nested in entry) {
          addValue(nested);
        }
        return;
      }

      final raw = entry.toString().trim();
      if (raw.isEmpty) return;

      if ((raw.startsWith('[') && raw.endsWith(']')) ||
          (raw.startsWith('{') && raw.endsWith('}'))) {
        final inner = raw.substring(1, raw.length - 1).trim();
        if (inner.isEmpty) return;

        if (inner.contains('\n')) {
          for (final part in inner.split('\n')) {
            addValue(part);
          }
          return;
        }

        if (inner.contains(',')) {
          for (final part in inner.split(',')) {
            addValue(part);
          }
          return;
        }

        addValue(inner);
        return;
      }

      if (raw.contains('\n')) {
        for (final part in raw.split('\n')) {
          addValue(part);
        }
        return;
      }

      if (raw.contains(',')) {
        for (final part in raw.split(',')) {
          addValue(part);
        }
        return;
      }

      final cleaned = _stripListDecorators(raw);
      if (cleaned.isNotEmpty) {
        items.add(cleaned);
      }
    }

    addValue(value);
    return items;
  }

  String _textValue(dynamic value) {
    if (value == null) return '';
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .join('\n');
    }

    final text = value.toString().trim();
    if (text.isEmpty) return '';

    if ((text.startsWith('[') && text.endsWith(']')) ||
        (text.startsWith('{') && text.endsWith('}'))) {
      final inner = text.substring(1, text.length - 1).trim();
      if (inner.isEmpty) return '';

      if (inner.contains('\n')) {
        return inner
            .split('\n')
            .map(_stripListDecorators)
            .where((item) => item.isNotEmpty)
            .join('\n');
      }

      if (inner.contains(',')) {
        return inner
            .split(',')
            .map(_stripListDecorators)
            .where((item) => item.isNotEmpty)
            .join('\n');
      }

      return _stripListDecorators(inner);
    }

    return _stripListDecorators(text);
  }

  String _stripListDecorators(String value) {
    var cleaned = value.trim();

    while (cleaned.isNotEmpty &&
        (cleaned.startsWith('[') ||
            cleaned.startsWith('{') ||
            cleaned.startsWith('"') ||
            cleaned.startsWith("'"))) {
      cleaned = cleaned.substring(1).trim();
    }

    while (cleaned.isNotEmpty &&
        (cleaned.endsWith(']') ||
            cleaned.endsWith('}') ||
            cleaned.endsWith('"') ||
            cleaned.endsWith("'"))) {
      cleaned = cleaned.substring(0, cleaned.length - 1).trim();
    }

    return cleaned;
  }

  int _intValue(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  String _formatPostedTime(dynamic value) {
    if (value == null) return 'Recently';

    DateTime? dateTime;
    if (value is DateTime) {
      dateTime = value;
    } else {
      dateTime = DateTime.tryParse(value.toString());
    }

    if (dateTime == null) return 'Recently';

    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes.clamp(1, 59);
      return '${minutes}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _buildLogoText(String company) {
    final words = company
        .split(' ')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (words.isEmpty) return 'JG';
    if (words.length == 1) {
      final text = words.first;
      return text.length >= 2
          ? text.substring(0, 2).toUpperCase()
          : text.toUpperCase();
    }

    return words.take(2).map((word) => word[0]).join().toUpperCase();
  }

  String _buildLogoColor(String company) {
    final colors = [
      '0xFF0A73B7',
      '0xFF1A3A4A',
      '0xFF2D5A3D',
      '0xFF6B21A8',
      '0xFF0369A1',
      '0xFFB8860B',
      '0xFF7C3AED',
    ];

    final index = company.hashCode.abs() % colors.length;
    return colors[index];
  }
}
