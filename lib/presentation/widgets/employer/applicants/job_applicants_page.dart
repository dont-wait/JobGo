import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/data/models/ai_cv_analysis_model.dart';
import 'package:jobgo/data/models/job_applicant_model.dart';
import 'package:jobgo/data/repositories/ai_cv_analysis_repository.dart';
import 'package:jobgo/data/repositories/job_application_repository.dart';
import 'package:jobgo/data/services/gemini_cv_analysis_service.dart';
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
  final AiCvAnalysisRepository _analysisRepository = AiCvAnalysisRepository();
  final GeminiCvAnalysisService _geminiService = GeminiCvAnalysisService();

  List<JobApplicantModel> _allApplications = [];
  List<JobApplicantModel> _filteredApplications = [];
  Map<int, AiCvAnalysisModel> _analysisByApplicationId = {};
  final Set<int> _analyzingApplicationIds = {};
  bool _isLoading = true;
  String? _errorMessage;
  String _sortBy = 'newest';
  String? _currentLanguageCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageCode = Localizations.localeOf(context).languageCode;
    if (_currentLanguageCode == languageCode) return;
    _currentLanguageCode = languageCode;

    if (_allApplications.isNotEmpty) {
      _loadCachedAnalyses(languageCode: languageCode).then((_) {
        if (mounted) {
          _filterApplicants(_searchController.text);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadApplicants();
  }

  Future<void> _loadApplicants({bool refresh = false}) async {
    final jobId = widget.jobId.trim();
    if (jobId.isEmpty) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Job không hợp lệ.';
        _allApplications = [];
        _filteredApplications = [];
      });
      return;
    }

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
      await _loadCachedAnalyses(
        languageCode:
            _currentLanguageCode ?? Localizations.localeOf(context).languageCode,
      );
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
    final filtered = _allApplications.where((application) {
      if (lowerQuery.isEmpty) return true;
      return application.searchableText.contains(lowerQuery);
    }).toList();

    filtered.sort((a, b) {
      if (_sortBy == 'ai_desc') {
        final aScore = _analysisByApplicationId[a.applicationId]?.matchScore ?? -1;
        final bScore = _analysisByApplicationId[b.applicationId]?.matchScore ?? -1;
        return bScore.compareTo(aScore);
      }
      if (_sortBy == 'ai_asc') {
        final aScore = _analysisByApplicationId[a.applicationId]?.matchScore ?? 101;
        final bScore = _analysisByApplicationId[b.applicationId]?.matchScore ?? 101;
        return aScore.compareTo(bScore);
      }
      final aDate = a.appliedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.appliedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    setState(() {
      _filteredApplications = filtered;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterApplicants('');
  }

  Future<void> _loadCachedAnalyses({
    required String languageCode,
  }) async {
    final ids = _allApplications.map((e) => e.applicationId).toList();
    final cached = await _analysisRepository.fetchByApplicationIds(
      ids,
      languageCode,
    );
    if (!mounted) return;
    setState(() {
      _analysisByApplicationId = cached;
    });
  }

  Future<void> _analyzeApplicant(JobApplicantModel application) async {
    final appId = application.applicationId;
    if (_analyzingApplicationIds.contains(appId)) return;
    final cvUrl = application.cvUrl.trim();
    if (!GeminiCvAnalysisService.isPdfUrl(cvUrl)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI analysis supports PDF only for now.')),
      );
      return;
    }

    final job = application.job;
    if (job == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing job details for AI analysis.')),
      );
      return;
    }
    final languageCode = Localizations.localeOf(context).languageCode;

    setState(() => _analyzingApplicationIds.add(appId));
    try {
      final result = await _geminiService.analyzeCv(
        applicationId: appId,
        jobId: application.jobId,
        candidateId: application.candidateId,
        cvUrl: cvUrl,
        job: job,
        candidate: application.candidate,
        coverLetter: application.coverLetter,
        languageCode: languageCode,
      );
      final saved = await _analysisRepository.saveAnalysis(result);
      if (!mounted) return;
      setState(() {
        _analysisByApplicationId[appId] = saved ?? result;
      });
      _filterApplicants(_searchController.text);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Analyze failed: $e')));
    } finally {
      if (mounted) {
        setState(() => _analyzingApplicationIds.remove(appId));
      }
    }
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
            child: Column(
              children: [
                TextField(
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
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Sort:',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _sortBy,
                      items: const [
                        DropdownMenuItem(
                          value: 'newest',
                          child: Text('Newest'),
                        ),
                        DropdownMenuItem(
                          value: 'ai_desc',
                          child: Text('AI score high'),
                        ),
                        DropdownMenuItem(
                          value: 'ai_asc',
                          child: Text('AI score low'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _sortBy = value);
                        _filterApplicants(_searchController.text);
                      },
                    ),
                  ],
                ),
              ],
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
      itemBuilder: (context, index) {
        final application = _filteredApplications[index];
        return ApplicantCard(
          application: application,
          analysis: _analysisByApplicationId[application.applicationId],
          isAnalyzing: _analyzingApplicationIds.contains(
            application.applicationId,
          ),
          onAnalyze: () => _analyzeApplicant(application),
          onApplicationChanged: () => _loadApplicants(refresh: true),
        );
      },
    );
  }
}
