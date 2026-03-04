import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/presentation/widgets/employer/post_job/job_step_progress.dart';
import 'package:jobgo/presentation/widgets/employer/post_job/step1_job_details_widget.dart';
import 'package:jobgo/presentation/widgets/employer/post_job/step2_description_widget.dart';
import 'package:jobgo/presentation/widgets/employer/post_job/step3_perks_salary_widget.dart';

class PostJobPage extends StatefulWidget {
  const PostJobPage({super.key});

  @override
  State<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  int currentStep = 1;

  // Controllers chung cho toàn bộ form
  final jobTitleController = TextEditingController();
  final locationController = TextEditingController();
  final minSalaryController = TextEditingController();
  final maxSalaryController = TextEditingController();
  final descriptionController = TextEditingController();
  final requirementsController = TextEditingController();

  String selectedCategory = 'Select Category';
  String selectedEmploymentType = 'Full-time';
  List<String> selectedBenefits = [];
  List<String> selectedSkills = [];

  void _nextStep() {
    if (currentStep < 3) {
      setState(() => currentStep++);
    } else {
      // TODO: Call API post job
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job posted successfully! 🎉')),
      );
      Navigator.pop(context);
    }
  }

  void _prevStep() {
    if (currentStep > 1) setState(() => currentStep--);
  }

  @override
  void dispose() {
    jobTitleController.dispose();
    locationController.dispose();
    minSalaryController.dispose();
    maxSalaryController.dispose();
    descriptionController.dispose();
    requirementsController.dispose();
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
        title: const Text(
          'Post a New Job',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Save draft
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Draft saved')));
            },
            child: const Text(
              'Save Draft',
              style: TextStyle(
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
          selectedBenefits: selectedBenefits,
          onBenefitsChanged: (benefits) =>
              setState(() => selectedBenefits = benefits),
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
            color: Colors.black.withOpacity(0.05),
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
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
          if (currentStep > 1) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: currentStep == 3
                    ? AppColors.orange
                    : AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                currentStep == 3 ? 'Post Job →' : 'Next Step',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
