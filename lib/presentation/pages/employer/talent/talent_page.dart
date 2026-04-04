import 'package:flutter/material.dart';
import 'package:jobgo/data/models/candidate_supabase_model.dart';
import 'package:jobgo/data/repositories/candidate_repository.dart';
import 'package:jobgo/presentation/widgets/employer/applicants/candidate_profile_page.dart';
import 'package:jobgo/presentation/widgets/employer/talent/talent_search_widget.dart';

class TalentPage extends StatefulWidget {
  const TalentPage({super.key});

  @override
  State<TalentPage> createState() => _TalentPageState();
}

class _TalentPageState extends State<TalentPage> {
  final CandidateRepository _repository = CandidateRepository();
  List<CandidateSupabaseModel> _allCandidates = [];
  List<CandidateSupabaseModel> _displayedCandidates = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedRole = 'All Roles';
  String _selectedExperience = 'All';
  String _selectedLocation = 'All';

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates({bool refresh = false}) async {
    setState(() {
      _isLoading = true;
      if (!refresh) {
        _errorMessage = null;
      }
    });

    try {
      final candidates = await _repository.fetchCandidates();

      if (!mounted) return;

      setState(() {
        _allCandidates = candidates;
        _errorMessage = null;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        if (_allCandidates.isEmpty) {
          _errorMessage = 'Không tải được danh sách ứng viên.';
          _displayedCandidates = [];
        }
      });

      if (_allCandidates.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Refresh thất bại: $e')));
      }
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedRole = 'All Roles';
      _selectedExperience = 'All';
      _selectedLocation = 'All';
    });
    _applyFilters();
  }

  void _applyFilters() {
    final searchLower = _searchQuery.trim().toLowerCase();

    setState(() {
      _displayedCandidates = _allCandidates.where((candidate) {
        final matchesSearch =
            searchLower.isEmpty ||
            candidate.searchableText.contains(searchLower);

        final matchesRole =
            _selectedRole == 'All Roles' ||
            candidate.roleLabel.toLowerCase() == _selectedRole.toLowerCase();

        final matchesExp =
            _selectedExperience == 'All' ||
            candidate.seniorityLabel.toLowerCase() ==
                _selectedExperience.toLowerCase();

        final matchesLocation =
            _selectedLocation == 'All' ||
            candidate.displayLocation.toLowerCase() ==
                _selectedLocation.toLowerCase();

        return matchesSearch && matchesRole && matchesExp && matchesLocation;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _onRoleChanged(String role) {
    _selectedRole = role;
    _applyFilters();
  }

  void _onExperienceChanged(String exp) {
    _selectedExperience = exp;
    _applyFilters();
  }

  void _onLocationChanged(String location) {
    _selectedLocation = location;
    _applyFilters();
  }

  List<String> get _roleOptions {
    if (_allCandidates.isEmpty) {
      return const ['All Roles', 'Designer', 'Developer', 'Engineer'];
    }

    final roles =
        _allCandidates
            .map((candidate) => candidate.roleLabel)
            .where((role) => role.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    return ['All Roles', ...roles];
  }

  List<String> get _experienceOptions => const [
    'All',
    'Senior',
    'Mid',
    'Junior',
    'Intern',
  ];

  List<String> get _locationOptions {
    if (_allCandidates.isEmpty) {
      return const ['All', 'London', 'San Francisco', 'Berlin'];
    }

    final locations =
        _allCandidates
            .map((candidate) => candidate.displayLocation)
            .where(
              (location) =>
                  location.isNotEmpty && location != 'Location not set',
            )
            .toSet()
            .toList()
          ..sort();

    return ['All', ...locations];
  }

  void _openCandidateProfile(CandidateSupabaseModel candidate) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CandidateProfilePage(candidate: candidate),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TalentSearchWidget(
      candidates: _displayedCandidates,
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      selectedRole: _selectedRole,
      selectedExperience: _selectedExperience,
      selectedLocation: _selectedLocation,
      roleOptions: _roleOptions,
      experienceOptions: _experienceOptions,
      locationOptions: _locationOptions,
      onSearchChanged: _onSearchChanged,
      onRoleChanged: _onRoleChanged,
      onExperienceChanged: _onExperienceChanged,
      onLocationChanged: _onLocationChanged,
      onRetry: () => _loadCandidates(refresh: true),
      onClearFilters: _resetFilters,
      onCandidateTap: _openCandidateProfile,
    );
  }
}
