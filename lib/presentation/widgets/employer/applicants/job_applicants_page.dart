import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/job_applicant_model.dart';
import 'package:jobgo/data/repositories/job_application_repository.dart';
import 'package:jobgo/presentation/widgets/employer/applicants/applicant_card.dart';

class JobApplicantsPage extends StatefulWidget {
  final String jobTitle;
  final int totalApplicants;
  final String jobId;

  const JobApplicantsPage({
    super.key,
    required this.jobTitle,
    required this.totalApplicants,
    required this.jobId,
  });

  @override
  State<JobApplicantsPage> createState() => _JobApplicantsPageState();
}

class _JobApplicantsPageState extends State<JobApplicantsPage> {
  final TextEditingController _searchController = TextEditingController();
  final JobApplicationRepository _repository = JobApplicationRepository();

  List<JobApplicantModel> _allApplications = [];
  List<JobApplicantModel> _filteredApplications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadApplicants();
  }

  Future<void> _loadApplicants({bool refresh = false}) async {
    setState(() {
      _isLoading = true;
      if (!refresh) {
        _errorMessage = null;
      }
    });

    try {
      final applications = await _repository.fetchJobApplicants(widget.jobId);
      if (!mounted) return;

      setState(() {
        _allApplications = applications;
        _errorMessage = null;
      });
      _filterApplicants(_searchController.text);
    } catch (e) {
      if (!mounted) return;

      if (_allApplications.isEmpty) {
        setState(() {
          _errorMessage = 'Không tải được danh sách ứng viên.';
          _filteredApplications = [];
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Refresh thất bại: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterApplicants(String query) {
    final lowerQuery = query.trim().toLowerCase();
    setState(() {
      _filteredApplications = _allApplications.where((application) {
        if (lowerQuery.isEmpty) return true;
        return application.searchableText.contains(lowerQuery);
      }).toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterApplicants('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applicantCount = _isLoading
        ? widget.totalApplicants
        : _allApplications.length;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.jobTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              '$applicantCount APPLICANTS',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              onChanged: _filterApplicants,
              decoration: InputDecoration(
                hintText: 'Search candidates...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.trim().isEmpty
                    ? const Icon(Icons.filter_list)
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _clearSearch,
                      ),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadApplicants(refresh: true),
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 56,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _loadApplicants(refresh: true),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_filteredApplications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Text(
              _allApplications.isEmpty
                  ? 'No applicants found for this job'
                  : 'No applicants match your search',
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filteredApplications.length,
      itemBuilder: (context, index) =>
          ApplicantCard(application: _filteredApplications[index]),
    );
  }
}
