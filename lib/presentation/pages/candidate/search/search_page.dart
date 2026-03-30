import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/presentation/pages/candidate/search/job_filter_bottom_sheet.dart';
import 'package:jobgo/presentation/providers/job_search_controller.dart';
import 'package:jobgo/presentation/widgets/candidate/search/search_job_card.dart';
import 'package:jobgo/presentation/widgets/common/profile_avatar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late final JobSearchProvider _searchProvider;

  final List<String> _filters = const [
    'Remote',
    'Full-time',
    r'$120k+',
    'Experience',
    'Part-time',
  ];

  @override
  void initState() {
    super.initState();
    _searchProvider = JobSearchProvider()..loadJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchProvider.dispose();
    super.dispose();
  }

  Future<void> _openFilterSheet() async {
    final currentFilters = _searchProvider.advancedFilters;
    final result = await showModalBottomSheet<SearchFilterOptions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return JobFilterBottomSheet(initialFilters: currentFilters);
      },
    );

    if (result != null && mounted) {
      _searchProvider.setAdvancedFilters(result);
    }
  }

  Widget _buildQuickFilterChip(String label, JobSearchProvider provider) {
    final isSelected = provider.selectedQuickFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            provider.setQuickFilter(isSelected ? null : label);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.lightBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<JobSearchProvider>.value(
      value: _searchProvider,
      child: Consumer<JobSearchProvider>(
        builder: (context, provider, _) {
          final jobs = provider.filteredJobs;

          return Scaffold(
            backgroundColor: AppColors.white,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.lightBackground,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: provider.setSearchQuery,
                              decoration: const InputDecoration(
                                hintText: 'Search job title or keyword',
                                hintStyle: TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: AppColors.textHint,
                                  size: 22,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _openFilterSheet,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const ProfileAvatar(role: UserRole.candidate),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      itemBuilder: (context, index) {
                        return _buildQuickFilterChip(_filters[index], provider);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${jobs.length} jobs found',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Row(
                          children: [
                            Icon(
                              Icons.sort_rounded,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Most Relevant',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (provider.isLoading && jobs.isEmpty)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: provider.refreshJobs,
                        child: jobs.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  24,
                                  20,
                                  24,
                                ),
                                children: [
                                  const SizedBox(height: 100),
                                  const Icon(
                                    Icons.search_off_rounded,
                                    size: 56,
                                    color: AppColors.textHint,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    provider.errorMessage ??
                                        'No jobs match your filters.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Center(
                                    child: TextButton(
                                      onPressed: () {
                                        FocusScope.of(context).unfocus();
                                        _searchController.clear();
                                        provider.resetAllFilters();
                                      },
                                      child: const Text('Clear filters'),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  0,
                                  20,
                                  24,
                                ),
                                itemCount: jobs.length,
                                itemBuilder: (context, index) {
                                  final job = jobs[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: SearchJobCard(job: job),
                                  );
                                },
                              ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
