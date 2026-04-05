import 'package:flutter/material.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/core/constants/job_categories.dart';
import 'package:jobgo/presentation/widgets/employer/post_job/components/employment_type_selector.dart';

class Step1JobDetailsWidget extends StatelessWidget {
  final TextEditingController jobTitleController;
  final TextEditingController locationController;
  final String selectedCategory;
  final String selectedEmploymentType;
  final List<String> categoryOptions;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onEmploymentTypeChanged;

  const Step1JobDetailsWidget({
    super.key,
    required this.jobTitleController,
    required this.locationController,
    required this.selectedCategory,
    required this.selectedEmploymentType,
    required this.categoryOptions,
    required this.onCategoryChanged,
    required this.onEmploymentTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final availableCategories = List<String>.from(categoryOptions);
    if (selectedCategory.isNotEmpty &&
        selectedCategory != JobCategories.defaultCategory &&
        !availableCategories.contains(selectedCategory)) {
      availableCategories.insert(1, selectedCategory);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.jobTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: jobTitleController,
          decoration: InputDecoration(hintText: loc.jobTitleExampleHint),
        ),
        const SizedBox(height: 20),

        Text(
          loc.selectCategory,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedCategory,
          items: availableCategories
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e == JobCategories.defaultCategory
                        ? loc.selectCategory
                        : _categoryLabel(loc, e),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) {
              onCategoryChanged(v);
            }
          },
          decoration: const InputDecoration(),
        ),
        const SizedBox(height: 20),

        EmploymentTypeSelector(
          selectedType: selectedEmploymentType,
          onChanged: onEmploymentTypeChanged,
        ),
        const SizedBox(height: 20),

        Text(loc.location, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: locationController,
          decoration: InputDecoration(hintText: loc.enterLocationHint),
        ),
      ],
    );
  }

  String _categoryLabel(AppLocalizations loc, String category) {
    switch (category) {
      case 'Software Development':
        return loc.softwareDevelopment;
      case 'Design & Creative':
        return loc.designCreative;
      case 'Product Management':
        return loc.productManagement;
      case 'Data Science & Analytics':
        return loc.dataScienceAnalytics;
      case 'DevOps & Infrastructure':
        return loc.devOpsInfrastructure;
      case 'Marketing & Growth':
        return loc.marketingGrowth;
      case 'Sales & Business Development':
        return loc.salesBusinessDevelopment;
      case 'Human Resources':
        return loc.humanResources;
      case 'Finance & Accounting':
        return loc.financeAccounting;
      case 'Operations & Administration':
        return loc.operationsAdministration;
      default:
        return category;
    }
  }
}
