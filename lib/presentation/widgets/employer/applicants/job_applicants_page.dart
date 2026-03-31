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

  @override
  void initState() {
    super.initState();
    _loadApplicants();
  }

  Future<void> _loadApplicants() async {
    setState(() {
      _isLoading = true;
    });

    final applications = await _repository.fetchJobApplicants(widget.jobId);

    if (!mounted) return;

    setState(() {
      _allApplications = applications;
      _isLoading = false;
    });
    _filterApplicants(_searchController.text);
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
                suffixIcon: const Icon(Icons.filter_list),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredApplications.isEmpty
                ? Center(
                    child: Text(
                      _allApplications.isEmpty
                          ? 'No applicants found for this job'
                          : 'No applicants match your search',
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredApplications.length,
                    itemBuilder: (context, index) => ApplicantCard(
                      application: _filteredApplications[index],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
