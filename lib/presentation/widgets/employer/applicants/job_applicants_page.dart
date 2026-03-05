import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/mockdata/mock_applications.dart';
import 'package:jobgo/data/mockdata/mock_candidate.dart';
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
  List<MockApplication> filteredApplications = [];

  @override
  void initState() {
    super.initState();
    filteredApplications = MockApplications.all
        .where((app) => app.jobId == widget.jobId)
        .toList();
  }

  void _filterApplicants(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredApplications = MockApplications.all.where((app) {
        if (app.jobId != widget.jobId) return false;
        final candidate = mockCandidatesData.firstWhere(
          (c) => c.id == app.candidateId,
          orElse: () => mockCandidatesData.first,
        );
        return candidate.fullName.toLowerCase().contains(lowerQuery) ||
            candidate.skill.toLowerCase().contains(lowerQuery);
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
              '${widget.totalApplicants} APPLICANTS',
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
            child: filteredApplications.isEmpty
                ? const Center(child: Text('No applicants found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredApplications.length,
                    itemBuilder: (context, index) =>
                        ApplicantCard(application: filteredApplications[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
