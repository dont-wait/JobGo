import 'package:flutter/material.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
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
        selectedCategory != 'Select Category' &&
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
          decoration: InputDecoration(
            hintText: '${loc.example}: Senior Flutter Developer',
          ),
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
                  child: Text(e == 'Select Category' ? loc.selectCategory : e),
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
          decoration: const InputDecoration(hintText: 'City, Country'),
        ),
      ],
    );
  }
}
