import 'package:flutter/material.dart';

import 'package:jobgo/presentation/widgets/common/adaptive_button_label.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/constants/job_categories.dart';
import 'package:jobgo/data/models/employer_job_model.dart';
import 'package:jobgo/data/repositories/employer_job_repository.dart';
import 'package:jobgo/presentation/widgets/employer/job_preview/job_post_preview_page.dart';
import 'package:jobgo/presentation/widgets/employer/post_job/job_step_progress.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/presentation/widgets/employer/post_job/step1_job_details_widget.dart';
import 'package:jobgo/presentation/widgets/employer/post_job/step2_description_widget.dart';
import 'package:jobgo/presentation/widgets/employer/post_job/step3_perks_salary_widget.dart';

class PostJobPage extends StatefulWidget {
  final EmployerJobModel? initialJob;

  const PostJobPage({super.key, this.initialJob});

  bool get isEditing => initialJob != null;

  @override
  State<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  final EmployerJobRepository _repository = EmployerJobRepository();
  static const int _maxTitleLength = 120;
  static const int _maxLocationLength = 120;
  static const int _maxPositions = 1000;

  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController minSalaryController = TextEditingController();
  final TextEditingController maxSalaryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController requirementsController = TextEditingController();
  final TextEditingController positionsController = TextEditingController(
    text: '1',
  );
  final TextEditingController deadlineController = TextEditingController();

  final List<String> _categoryOptions = JobCategories.categoriesWithDefault;

  int currentStep = 1;
  String selectedCategory = JobCategories.defaultCategory;
  String selectedEmploymentType = 'Full-time';
  List<String> selectedBenefits = [];
  List<String> selectedSkills = [];
  bool salaryNegotiable = false;
  DateTime? selectedDeadline;
  bool _isSaving = false;

  Iterable<TextEditingController> get _controllers => [
    jobTitleController,
    locationController,
    minSalaryController,
    maxSalaryController,
    descriptionController,
    requirementsController,
    positionsController,
    deadlineController,
  ];

  @override
  void initState() {
    super.initState();
    for (final controller in _controllers) {
      controller.addListener(_handleTextChanged);
    }
    _seedFromInitialJob();
  }

  void _seedFromInitialJob() {
    final job = widget.initialJob;
    if (job == null) return;

    jobTitleController.text = job.title;
    locationController.text = job.location;
    minSalaryController.text = job.salaryMin?.toString() ?? '';
    maxSalaryController.text = job.salaryMax?.toString() ?? '';
    descriptionController.text = job.description;
    requirementsController.text = job.requirementsText;
    positionsController.text = job.positions.toString();
    selectedCategory = job.category.isNotEmpty
        ? job.category
        : selectedCategory;
    selectedEmploymentType = job.employmentType.isNotEmpty
        ? job.employmentType
        : selectedEmploymentType;
    selectedBenefits = List<String>.from(job.cleanedBenefits);
    selectedSkills = List<String>.from(job.cleanedTags);
    salaryNegotiable = job.salaryNegotiable;
    selectedDeadline = job.deadline;
    deadlineController.text = job.deadline == null
        ? ''
        : _formatDateForField(job.deadline!);
  }

  void _handleTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.removeListener(_handleTextChanged);
      controller.dispose();
    }
    super.dispose();
  }

  EmployerJobModel get _draftJob {
    return EmployerJobModel(
      id: widget.initialJob?.id,
      employerId: widget.initialJob?.employerId,
      title: jobTitleController.text.trim(),
      description: descriptionController.text.trim(),
      requirementsText: requirementsController.text.trim(),
      location: locationController.text.trim(),
      employmentType: selectedEmploymentType,
      category: selectedCategory == JobCategories.defaultCategory
          ? ''
          : selectedCategory,
      salaryMin: _parseSalaryInput(minSalaryController.text),
      salaryMax: _parseSalaryInput(maxSalaryController.text),
      salaryValue: _deriveSalaryValue(),
      salaryNegotiable: salaryNegotiable,
      positions: _parsePositionsOrDefault(),
      deadline: selectedDeadline,
      status: widget.initialJob?.status ?? 'draft',
      moderationStatus: widget.initialJob?.moderationStatus ?? 'draft',
      applicationCount: widget.initialJob?.applicationCount ?? 0,
      badge: widget.initialJob?.badge,
      tags: List<String>.from(selectedSkills),
      benefits: List<String>.from(selectedBenefits),
      createdAt: widget.initialJob?.createdAt,
      updatedAt: widget.initialJob?.updatedAt,
      companyName: widget.initialJob?.companyName ?? '',
      companyLogoUrl: widget.initialJob?.companyLogoUrl ?? '',
      companyLogoColor: widget.initialJob?.companyLogoColor ?? '0xFF1A3A4A',
      companyLogoText: widget.initialJob?.companyLogoText ?? 'JG',
    );
  }

  double? _deriveSalaryValue() {
    final minSalary = _parseSalaryInput(minSalaryController.text);
    final maxSalary = _parseSalaryInput(maxSalaryController.text);

    if (minSalary != null && maxSalary != null) {
      return (minSalary + maxSalary) / 2;
    }

    if (maxSalary != null) return maxSalary;
    if (minSalary != null) return minSalary;
    return null;
  }

  double? _parseSalaryInput(String rawValue) {
    final normalized = rawValue.trim().replaceAll(',', '');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  int? _parsePositionsInput() {
    final rawValue = positionsController.text.trim();
    if (rawValue.isEmpty) return null;
    return int.tryParse(rawValue);
  }

  int _parsePositionsOrDefault() {
    return _parsePositionsInput() ?? 1;
  }

  bool _hasAtLeastOneValue(List<String> items) {
    return items.any((item) => item.trim().isNotEmpty);
  }

  bool _isPastDate(DateTime value) {
    final today = DateUtils.dateOnly(DateTime.now());
    final selected = DateUtils.dateOnly(value);
    return selected.isBefore(today);
  }

  String? _validateSalaryInputs({required bool publish}) {
    final loc = AppLocalizations.of(context);
    final minRaw = minSalaryController.text.trim();
    final maxRaw = maxSalaryController.text.trim();
    final minSalary = _parseSalaryInput(minRaw);
    final maxSalary = _parseSalaryInput(maxRaw);

    if (minRaw.isNotEmpty && minSalary == null) {
      return loc.salaryInvalidNumber;
    }

    if (maxRaw.isNotEmpty && maxSalary == null) {
      return loc.salaryInvalidNumber;
    }

    if (minSalary != null && minSalary <= 0) {
      return loc.salaryMustBePositive;
    }

    if (maxSalary != null && maxSalary <= 0) {
      return loc.salaryMustBePositive;
    }

    if (minSalary != null && maxSalary != null && minSalary > maxSalary) {
      return loc.salaryMinGreaterThanMax;
    }

    if (publish && minSalary == null && maxSalary == null) {
      return loc.salaryRequiredForPublish;
    }

    return null;
  }

  String _formatDateForField(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  String? _validateStep1() {
    final loc = AppLocalizations.of(context);
    final title = jobTitleController.text.trim();
    if (title.isEmpty) {
      return loc.jobTitleRequired;
    }
    if (title.length > _maxTitleLength) {
      return loc.jobTitleTooLong;
    }
    if (selectedCategory == JobCategories.defaultCategory) {
      return loc.pleaseChooseCategory;
    }
    if (selectedEmploymentType.trim().isEmpty) {
      return loc.employmentTypeRequired;
    }
    final location = locationController.text.trim();
    if (location.isEmpty) {
      return loc.locationRequired;
    }
    if (location.length > _maxLocationLength) {
      return loc.locationTooLong;
    }
    return null;
  }

  String? _validateStep2() {
    final loc = AppLocalizations.of(context);
    if (descriptionController.text.trim().isEmpty) {
      return loc.descriptionRequired;
    }
    if (requirementsController.text.trim().isEmpty) {
      return loc.requirementsRequired;
    }
    if (!_hasAtLeastOneValue(selectedSkills)) {
      return loc.chooseAtLeastOneSkill;
    }
    return null;
  }

  String? _validatePublish() {
    final loc = AppLocalizations.of(context);
    final step1Error = _validateStep1();
    if (step1Error != null) return step1Error;

    final step2Error = _validateStep2();
    if (step2Error != null) return step2Error;

    final salaryError = _validateSalaryInputs(publish: true);
    if (salaryError != null) {
      return salaryError;
    }

    final positionsRaw = positionsController.text.trim();
    if (positionsRaw.isEmpty) {
      return loc.positionsGreaterThanZero;
    }

    final positions = _parsePositionsInput();
    if (positions == null) {
      return loc.positionsMustBeWholeNumber;
    }
    if (positions <= 0) {
      return loc.positionsGreaterThanZero;
    }
    if (positions > _maxPositions) {
      return loc.positionsTooLarge;
    }

    if (selectedDeadline == null) {
      return loc.chooseDeadline;
    }

    if (_isPastDate(selectedDeadline!)) {
      return loc.deadlineCannotBePast;
    }

    if (!_hasAtLeastOneValue(selectedBenefits)) {
      return loc.chooseAtLeastOneBenefit;
    }

    return null;
  }

  String? _validateDraftSave() {
    final loc = AppLocalizations.of(context);
    final title = jobTitleController.text.trim();
    if (title.isEmpty) {
      return loc.jobTitleDraftRequired;
    }
    if (title.length > _maxTitleLength) {
      return loc.jobTitleTooLong;
    }

    final location = locationController.text.trim();
    if (location.length > _maxLocationLength) {
      return loc.locationTooLong;
    }

    final positionsRaw = positionsController.text.trim();
    final positions = _parsePositionsInput();
    if (positionsRaw.isNotEmpty && positions == null) {
      return loc.positionsMustBeWholeNumber;
    }
    if (positions != null && positions <= 0) {
      return loc.positionsGreaterThanZero;
    }
    if (positions != null && positions > _maxPositions) {
      return loc.positionsTooLarge;
    }

    final salaryError = _validateSalaryInputs(publish: false);
    if (salaryError != null) {
      return salaryError;
    }

    return null;
  }

  Future<void> _saveDraftDirectly() async {
    if (_isSaving) return;

    final validationError = _validateDraftSave();
    if (validationError != null) {
      _showSnackBar(validationError);
      return;
    }

    await _submitJob(false, popAfterSuccess: true);
  }

  Future<void> _openPreview() async {
    final validationError = _validatePublish();
    if (validationError != null) {
      _showSnackBar(validationError);
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => JobPostPreviewPage(
          job: _draftJob,
          isEditing: widget.isEditing,
          onSubmit: (publish) => _submitJob(publish, popAfterSuccess: false),
        ),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<bool> _submitJob(bool publish, {required bool popAfterSuccess}) async {
    if (_isSaving) return false;

    final loc = AppLocalizations.of(context);
    if (publish) {
      final validationError = _validatePublish();
      if (validationError != null) {
        _showSnackBar(validationError);
        return false;
      }
    }

    setState(() => _isSaving = true);

    try {
      await _repository.saveJob(_draftJob, publish: publish);
      if (!mounted) return false;

      _showSnackBar(
        publish
            ? (widget.isEditing ? loc.jobUpdatedSuccess : loc.jobPostedSuccess)
            : loc.draftSavedSuccess,
        backgroundColor: AppColors.success,
      );

      if (popAfterSuccess) {
        Navigator.pop(context, true);
      }

      return true;
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString());
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  void _nextStep() {
    final validationError = switch (currentStep) {
      1 => _validateStep1(),
      2 => _validateStep2(),
      _ => null,
    };

    if (validationError != null) {
      _showSnackBar(validationError);
      return;
    }

    if (currentStep < 3) {
      setState(() => currentStep++);
    } else {
      _openPreview();
    }
  }

  void _prevStep() {
    if (currentStep > 1) {
      setState(() => currentStep--);
    }
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
          onPressed: _isSaving ? null : () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEditing
              ? AppLocalizations.of(context).editJob
              : AppLocalizations.of(context).postANewJob,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveDraftDirectly,
            child: AdaptiveButtonLabel(
              text: AppLocalizations.of(context).saveDraft,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            JobStepProgress(currentStep: currentStep),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildCurrentStep(),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 1:
        return Step1JobDetailsWidget(
          jobTitleController: jobTitleController,
          locationController: locationController,
          selectedCategory: selectedCategory,
          selectedEmploymentType: selectedEmploymentType,
          categoryOptions: _categoryOptions,
          onCategoryChanged: (v) => setState(() => selectedCategory = v),
          onEmploymentTypeChanged: (v) =>
              setState(() => selectedEmploymentType = v),
        );
      case 2:
        return Step2DescriptionWidget(
          descriptionController: descriptionController,
          requirementsController: requirementsController,
          selectedSkills: selectedSkills,
          onSkillsChanged: (skills) => setState(() => selectedSkills = skills),
        );
      case 3:
        return Step3PerksSalaryWidget(
          minSalaryController: minSalaryController,
          maxSalaryController: maxSalaryController,
          positionsController: positionsController,
          deadlineController: deadlineController,
          salaryNegotiable: salaryNegotiable,
          selectedDeadline: selectedDeadline,
          onSalaryNegotiableChanged: (value) => setState(() {
            salaryNegotiable = value;
          }),
          onDeadlineChanged: (deadline) {
            setState(() {
              selectedDeadline = deadline;
              deadlineController.text = deadline == null
                  ? ''
                  : _formatDateForField(deadline);
            });
          },
          selectedBenefits: selectedBenefits,
          onBenefitsChanged: (benefits) =>
              setState(() => selectedBenefits = benefits),
          previewJob: _draftJob,
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentStep > 1)
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: AdaptiveButtonLabel(
                  text: AppLocalizations.of(context).back,
                ),
              ),
            ),
          if (currentStep > 1) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: currentStep == 3
                    ? AppColors.orange
                    : AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: AdaptiveButtonLabel(
                text: currentStep == 3
                    ? AppLocalizations.of(context).previewJob
                    : AppLocalizations.of(context).nextStep,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
