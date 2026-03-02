import 'package:flutter/material.dart';
import 'package:jobgo/data/mockdata/mock_candidate.dart';
import 'package:jobgo/presentation/widgets/employer/talent/talent_search_widget.dart';

class TalentPage extends StatefulWidget {
  const TalentPage({super.key});

  @override
  State<TalentPage> createState() => _TalentPageState();
}

class _TalentPageState extends State<TalentPage> {
  List<CandidateModel> _displayedCandidates = [];
  String _searchQuery = '';
  String _selectedRole = 'All Roles';
  String? _selectedExperience;
  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _displayedCandidates = List.from(mockCandidatesData);
  }

  void _applyFilters() {
    setState(() {
      _displayedCandidates = mockCandidatesData.where((candidate) {
        final searchLower = _searchQuery.toLowerCase();
        final matchesSearch =
            candidate.fullName.toLowerCase().contains(searchLower) ||
            candidate.skill.toLowerCase().contains(searchLower);

        final matchesRole =
            _selectedRole == 'All Roles' ||
            candidate.experience.toLowerCase().contains(
              _selectedRole.toLowerCase(),
            );

        final matchesExp =
            _selectedExperience == null ||
            _selectedExperience == 'All' ||
            candidate.experience.toLowerCase().contains(
              _selectedExperience!.toLowerCase(),
            );

        final matchesLocation =
            _selectedLocation == null ||
            _selectedLocation == 'All' ||
            candidate.address.toLowerCase() == _selectedLocation!.toLowerCase();

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

  void _onExperienceChanged(String? exp) {
    _selectedExperience = exp;
    _applyFilters();
  }

  void _onLocationChanged(String? location) {
    _selectedLocation = location;
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return TalentSearchWidget(
      candidates: _displayedCandidates,
      selectedRole: _selectedRole,
      selectedExperience: _selectedExperience,
      selectedLocation: _selectedLocation,
      onSearchChanged: _onSearchChanged,
      onRoleChanged: _onRoleChanged,
      onExperienceChanged: _onExperienceChanged,
      onLocationChanged: _onLocationChanged,
    );
  }
}
