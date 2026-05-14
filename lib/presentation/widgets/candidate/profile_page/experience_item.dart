
import 'package:flutter/material.dart';
import '../../../../core/configs/theme/app_colors.dart';

class ExperienceItem extends StatelessWidget {
  final String title;
  final String company;
  final String time;
  final String description;
  final VoidCallback? onDelete; 


  const ExperienceItem({
    super.key,
    required this.title,
    required this.company,
    required this.time,
    required this.description,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.work, color: AppColors.primary),
            ),
            const SizedBox(width: 12),

            // Nội dung
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  if (company.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(company,
                        style: const TextStyle(
                            color: AppColors.primary, fontSize: 13)),
                  ],
                  if (time.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(time,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textHint)),
                  ],
                  const SizedBox(height: 8),
                  Text(description,
                      style: const TextStyle(fontSize: 14, height: 1.4)),
                ],
              ),
            ),
            IconButton(
            onPressed: onDelete, 
            icon: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}