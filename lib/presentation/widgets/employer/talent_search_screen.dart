import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/mockdata/mock_candidate.dart';
import 'package:jobgo/presentation/widgets/employer/candidate_card_widget.dart';

class TalentSearchScreen extends StatefulWidget {
  const TalentSearchScreen({super.key});

  @override
  State<TalentSearchScreen> createState() => _TalentSearchScreenState();
}

class _TalentSearchScreenState extends State<TalentSearchScreen> {
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterChips(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Text(
                'RECOMMENDED CANDIDATES (${_displayedCandidates.length})',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHint,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Expanded(child: _buildCandidateList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Find Talent',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.tune, color: AppColors.textPrimary),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          decoration: const InputDecoration(
            hintText: 'Skills, Job Title or Name',
            hintStyle: TextStyle(color: AppColors.textHint),
            prefixIcon: Icon(Icons.search, color: AppColors.primary),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
          onChanged: (value) {
            _searchQuery = value;
            _applyFilters();
          },
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            _buildCustomDropdown(
              value: _selectedRole,
              items: const ['All Roles', 'Designer', 'Developer', 'Engineer'],
              isPrimary: true,
              onChanged: (val) {
                if (val != null) {
                  _selectedRole = val;
                  _applyFilters();
                }
              },
            ),
            const SizedBox(width: 8),
            _buildCustomDropdown(
              hint: 'Experience Level',
              value: _selectedExperience,
              items: const ['All', 'Senior', 'Junior', 'Intern'],
              onChanged: (val) {
                _selectedExperience = val;
                _applyFilters();
              },
            ),
            const SizedBox(width: 8),
            _buildCustomDropdown(
              hint: 'Location',
              value: _selectedLocation,
              items: const ['All', 'London', 'San Francisco', 'Berlin'],
              onChanged: (val) {
                _selectedLocation = val;
                _applyFilters();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDropdown({
    String? hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    bool isPrimary = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isPrimary ? AppColors.primary : AppColors.border,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isDense: true,
          value: value,
          hint: hint != null
              ? Text(
                  hint,
                  style: TextStyle(
                    color: isPrimary ? AppColors.white : AppColors.textPrimary,
                    fontSize: 13,
                  ),
                )
              : null,
          icon: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: isPrimary ? AppColors.white : AppColors.textSecondary,
              size: 16,
            ),
          ),
          dropdownColor: AppColors.white,
          style: TextStyle(
            color: isPrimary ? AppColors.white : AppColors.textPrimary,
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCandidateList() {
    if (_displayedCandidates.isEmpty) {
      return const Center(
        child: Text(
          'No candidates found matching your criteria.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: _displayedCandidates.length,
      itemBuilder: (context, index) {
        final candidate = _displayedCandidates[index];
        final List<String> skillList = candidate.skill
            .split(',')
            .map((s) => s.trim())
            .toList();
        final String formattedSalary =
            '${(candidate.desiredSalaryMin / 1000).toStringAsFixed(0)}k';
        final String combinedInfo =
            '${candidate.address} • \$$formattedSalary+';

        return CandidateCardWidget(
          name: candidate.fullName,
          title: candidate.experience,
          info: combinedInfo,
          skills: skillList,
          avatarUrl: candidate.avatarUrl,
        );
      },
    );
  }
}
