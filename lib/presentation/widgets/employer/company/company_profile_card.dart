import 'package:flutter/material.dart';
import '../../../../core/configs/theme/app_colors.dart';

class CompanyProfileCard extends StatelessWidget {
  final String companyName;
  final String imagePath;
  final String description;
  final String location;
  final String website;

  const CompanyProfileCard({
    super.key,
    required this.companyName,
    required this.imagePath,
    required this.description,
    required this.location,
    required this.website,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo + tên công ty
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(imagePath),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    companyName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Giới thiệu
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Địa điểm
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.redAccent),
                const SizedBox(width: 8),
                Text(location, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),

            // Website
            Row(
              children: [
                const Icon(Icons.language, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(website, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}