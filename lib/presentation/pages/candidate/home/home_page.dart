import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/enums/user_role.dart';
import 'package:jobgo/data/models/job_model.dart';
import 'package:jobgo/data/repositories/job_repository.dart';
import 'package:jobgo/presentation/widgets/candidate/home/home_search_bar.dart';
import 'package:jobgo/presentation/widgets/candidate/home/recommended_job_card.dart';
import 'package:jobgo/presentation/widgets/candidate/home/recent_job_tile.dart';
import 'package:jobgo/presentation/pages/candidate/job_detail/job_detail_page.dart';
import 'package:jobgo/presentation/widgets/common/profile_avatar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final JobRepository _jobRepository = JobRepository();
  final TextEditingController _searchController = TextEditingController();

  List<JobModel> _recommendedJobs = [];
  List<JobModel> _recentJobs = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _hasMore = true;
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadJobs({String query = ''}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _hasMore = true;
      _searchQuery = query;
    });

    try {
      final List<Future<List<JobModel>>> futures = [
        _jobRepository.getRecommendedJobs(),
      ];

      if (query.isEmpty) {
        futures.add(_jobRepository.getRecentJobs(page: 0, pageSize: _pageSize));
      } else {
        futures.add(_jobRepository.searchJobs(query));
      }

      final results = await Future.wait(futures);

      if (mounted) {
        setState(() {
          _recommendedJobs = results[0];
          _recentJobs = results[1];
          _isLoading = false;
          // Search results aren't typically paginated in current repository search implementation
          if (query.isNotEmpty || results[1].length < _pageSize) {
            _hasMore = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _loadJobs(query: query);
    });
  }

  Future<void> _loadMoreJobs() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);
    final nextPage = _currentPage + 1;
    final newJobs = await _jobRepository.getRecentJobs(
      page: nextPage,
      pageSize: _pageSize,
    );

    if (mounted) {
      setState(() {
        _recentJobs.addAll(newJobs);
        _currentPage = nextPage;
        _isLoadingMore = false;
        if (newJobs.length < _pageSize) {
          _hasMore = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Home',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Navigate to Dashboard
            },
            icon: const Icon(
              Icons.dashboard_outlined,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Go to Dashboard',
          ),
          const ProfileAvatar(role: UserRole.candidate),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadJobs(query: _searchQuery),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Search bar
                      HomeSearchBar(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        onTap: () {}, // Not needed as it's interactive now
                      ),
                      const SizedBox(height: 24),
                      // Recommended Jobs
                      if (_searchQuery.isEmpty &&
                          _recommendedJobs.isNotEmpty) ...[
                        _buildSectionTitle('Recommended Jobs'),
                        const SizedBox(height: 16),
                        _buildRecommendedJobs(),
                        const SizedBox(height: 28),
                      ],
                      // Recent Job Postings
                      _buildSectionTitle(
                        _searchQuery.isEmpty
                            ? 'Recent Job Postings'
                            : 'Search Results for "$_searchQuery"',
                      ),
                      const SizedBox(height: 8),
                      _buildRecentJobs(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildRecommendedJobs() {
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _recommendedJobs.length,
        itemBuilder: (context, index) {
          final job = _recommendedJobs[index];
          return RecommendedJobCard(
            job: job,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => JobDetailPage(job: job)),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRecentJobs() {
    if (_recentJobs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'No jobs found',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentJobs.length,
          separatorBuilder: (_, __) =>
              const Divider(color: AppColors.divider, height: 1),
          itemBuilder: (context, index) {
            final job = _recentJobs[index];
            return RecentJobTile(
              job: job,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => JobDetailPage(job: job)),
                );
              },
              onBookmark: () {
                // Handled in RecentJobTile via BookmarkProvider
              },
            );
          },
        ),
        if (_hasMore) ...[
          const SizedBox(height: 16),
          _isLoadingMore
              ? const CircularProgressIndicator()
              : TextButton(
                  onPressed: _loadMoreJobs,
                  child: const Text('Load More'),
                ),
        ],
      ],
    );
  }
}
