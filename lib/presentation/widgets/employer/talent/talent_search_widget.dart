import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/data/models/candidate_supabase_model.dart';
import 'package:jobgo/presentation/widgets/common/profile_avatar.dart';
import 'package:jobgo/presentation/widgets/employer/talent/candidate_card_widget.dart';

class TalentSearchWidget extends StatelessWidget {
  final List<CandidateSupabaseModel> candidates;
  final bool isLoading;
  final String selectedRole;
  final String selectedExperience;
  final String selectedLocation;
  final List<String> roleOptions;
  final List<String> experienceOptions;
  final List<String> locationOptions;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onRoleChanged;
  final ValueChanged<String> onExperienceChanged;
  final ValueChanged<String> onLocationChanged;
  final VoidCallback onRetry;
  final ValueChanged<CandidateSupabaseModel> onCandidateTap;

  const TalentSearchWidget({
    super.key,
    required this.candidates,
    required this.isLoading,
    required this.selectedRole,
    required this.selectedExperience,
    required this.selectedLocation,
    required this.roleOptions,
    required this.experienceOptions,
    required this.locationOptions,
    required this.onSearchChanged,
    required this.onRoleChanged,
    required this.onExperienceChanged,
    required this.onLocationChanged,
    required this.onRetry,
    required this.onCandidateTap,
  });

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
                'RECOMMENDED CANDIDATES (${candidates.length})',
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
                icon: const Icon(Icons.tune, color: AppColors.textPrimary),
                onPressed: onRetry,
                tooltip: 'Refresh candidates',
              ),
              const ProfileAvatar(role: UserRole.employer),
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
              color: Colors.black.withValues(alpha: 0.05),
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
          onChanged: onSearchChanged,
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
              value: selectedRole,
              items: roleOptions,
              isPrimary: true,
              onChanged: onRoleChanged,
            ),
            const SizedBox(width: 8),
            _buildCustomDropdown(
              value: selectedExperience,
              items: experienceOptions,
              onChanged: onExperienceChanged,
            ),
            const SizedBox(width: 8),
            _buildCustomDropdown(
              value: selectedLocation,
              items: locationOptions,
              onChanged: onLocationChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDropdown({
    required String value,
    required List<String> items,
    required void Function(String) onChanged,
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
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) {
              onChanged(val);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCandidateList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (candidates.isEmpty) {
      return const Center(
        child: Text(
          'No candidates found matching your criteria.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: candidates.length,
      itemBuilder: (context, index) {
        final candidate = candidates[index];
        return CandidateCardWidget(
          candidate: candidate,
          onViewProfile: () => onCandidateTap(candidate),
          onMessage: () {},
        );
      },
    );
  }
}
