import 'package:flutter/material.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

class FilterData {
  final bool fullTime;
  final bool partTime;
  final bool remote;
  final bool contract;
  final RangeValues salaryRange;
  final List<String> selectedExperiences;
  final String location;

  const FilterData({
    required this.fullTime,
    required this.partTime,
    required this.remote,
    required this.contract,
    required this.salaryRange,
    required this.selectedExperiences,
    required this.location,
  });
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({
    super.key,
    required this.onApplyFilters,
  });

  final void Function(FilterData) onApplyFilters;
  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  bool fullTime = true;
  bool partTime = false;
  bool remote = true;
  bool contract = false;

  RangeValues salaryRange = const RangeValues(40, 160);

  List<String> selectedExperiences = ['Mid'];

  final TextEditingController locationController = TextEditingController(
    text: 'New York, NY',
  );

  void _clearAll() {
    setState(() {
      fullTime = false;
      partTime = false;
      remote = false;
      contract = false;

      salaryRange = const RangeValues(0, 200);
      selectedExperiences.clear();
      locationController.clear();
    });
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
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    color: Colors.grey.withOpacity(0.4),
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
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: _clearAll,
                      child: Text(
                        'Clear All',
                        style: TextStyle(
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
                    const Text(
                      'Job Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildJobTypeCheckbox(
                      'Full-time',
                      fullTime,
                      (val) => setState(() => fullTime = val ?? false),
                    ),
                    _buildJobTypeCheckbox(
                      'Part-time',
                      partTime,
                      (val) => setState(() => partTime = val ?? false),
                    ),
                    _buildJobTypeCheckbox(
                      'Remote',
                      remote,
                      (val) => setState(() => remote = val ?? false),
                    ),
                    _buildJobTypeCheckbox(
                      'Contract',
                      contract,
                      (val) => setState(() => contract = val ?? false),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Salary Range',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        salaryRange.start.round() == salaryRange.end.round()
                            ? '\$${salaryRange.start.round()}k+'
                            : '\$${salaryRange.start.round()}k - \$${salaryRange.end.round()}k+',
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
                      max: 200,
                      divisions: 40,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.lightBackground,
                      onChanged: (RangeValues values) {
                        setState(() {
                          salaryRange = values;
                        });
                      },
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('\$0'), Text('\$200k+')],
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Experience Level',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: ['Entry', 'Mid', 'Senior', 'Lead'].map((level) {
                        final isSelected = selectedExperiences.contains(level);
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
                    const Text(
                      'Location',
                      style: TextStyle(
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
                        decoration: const InputDecoration(
                          icon: Icon(
                            Icons.location_on_outlined,
                            color: AppColors.textHint,
                          ),
                          border: InputBorder.none,
                          hintText: 'Enter city, state or country',
                          hintStyle: TextStyle(color: AppColors.textHint),
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
                        onPressed: () {
                          // TODO: Áp dụng filter vào danh sách jobs ở SearchPage
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Show Results',
                          style: TextStyle(
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
