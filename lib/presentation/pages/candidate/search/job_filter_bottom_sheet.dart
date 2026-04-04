import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/presentation/providers/job_search_controller.dart';

class JobFilterBottomSheet extends StatefulWidget {
  final SearchFilterOptions initialFilters;

  const JobFilterBottomSheet({super.key, required this.initialFilters});

  @override
  State<JobFilterBottomSheet> createState() => _JobFilterBottomSheetState();
}

class _JobFilterBottomSheetState extends State<JobFilterBottomSheet> {
  late bool fullTime;
  late bool partTime;
  late bool remote;
  late bool contract;
  late RangeValues salaryRange;
  late List<String> selectedExperiences;
  late final TextEditingController locationController;

  @override
  void initState() {
    super.initState();
    fullTime = widget.initialFilters.fullTime;
    partTime = widget.initialFilters.partTime;
    remote = widget.initialFilters.remote;
    contract = widget.initialFilters.contract;
    salaryRange = widget.initialFilters.salaryRange;
    selectedExperiences = List<String>.from(widget.initialFilters.experiences);
    locationController = TextEditingController(
      text: widget.initialFilters.location,
    );
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  void _clearAll() {
    setState(() {
      fullTime = false;
      partTime = false;
      remote = false;
      contract = false;
      salaryRange = SearchFilterOptions.defaultSalaryRange;
      selectedExperiences.clear();
      locationController.clear();
    });
  }

  String _formatSalaryValue(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  void _applyFilters() {
    Navigator.pop(
      context,
      SearchFilterOptions(
        fullTime: fullTime,
        partTime: partTime,
        remote: remote,
        contract: contract,
        salaryRange: salaryRange,
        experiences: List<String>.from(selectedExperiences),
        location: locationController.text.trim(),
      ),
    );
  }

  Widget _buildJobTypeCheckbox(
    String title,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            shape: const CircleBorder(),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.filters,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: _clearAll,
                      child: Text(
                        loc.clearAll,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.employmentType,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildJobTypeCheckbox(
                      loc.fullTime,
                      fullTime,
                      (val) => setState(() => fullTime = val ?? false),
                    ),
                    _buildJobTypeCheckbox(
                      loc.partTime,
                      partTime,
                      (val) => setState(() => partTime = val ?? false),
                    ),
                    _buildJobTypeCheckbox(
                      loc.remote,
                      remote,
                      (val) => setState(() => remote = val ?? false),
                    ),
                    _buildJobTypeCheckbox(
                      loc.contract,
                      contract,
                      (val) => setState(() => contract = val ?? false),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      loc.salaryRange,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        salaryRange.start.round() == salaryRange.end.round()
                            ? '\$${_formatSalaryValue(salaryRange.start.round())}+'
                            : '\$${_formatSalaryValue(salaryRange.start.round())} - \$${_formatSalaryValue(salaryRange.end.round())}+',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    RangeSlider(
                      values: salaryRange,
                      min: 0,
                      max: SearchFilterOptions.defaultSalaryRange.end,
                      divisions: 100,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.lightBackground,
                      onChanged: (values) {
                        setState(() {
                          salaryRange = values;
                        });
                      },
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('\$0'), Text('\$10,000+')],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      loc.experienceLevel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children:
                          [
                            loc.entryLevel,
                            loc.midLevel,
                            loc.seniorLevel,
                            loc.leadLevel,
                          ].map((level) {
                            final isSelected = selectedExperiences.contains(
                              level,
                            );
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedExperiences.remove(level);
                                  } else {
                                    selectedExperiences.add(level);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.lightBackground,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  level,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      loc.location,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                          icon: const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.textHint,
                          ),
                          border: InputBorder.none,
                          hintText: loc.enterLocationHint,
                          hintStyle: const TextStyle(color: AppColors.textHint),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _applyFilters,
                        child: Text(
                          loc.showResults,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
