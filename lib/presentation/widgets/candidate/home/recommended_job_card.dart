import 'package:flutter/material.dart';
import 'package:jobgo/data/mockdata/mock_jobs.dart';
import 'package:jobgo/presentation/widgets/common/company_logo.dart';

class RecommendedJobCard extends StatelessWidget {
  final MockJob job;
  final VoidCallback? onTap;

  const RecommendedJobCard({super.key, required this.job, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(job.logoColor));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo card
            CompanyLogo(
              imageUrl: job.logoUrl,
              fallbackText: job.logoText,
              backgroundColor: color,
              width: double.infinity,
              height: 100,
              fontSize: 12,
            ),
            const SizedBox(height: 10),
            // Job title
            Text(
              job.title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // Company name
            Text(
              job.company,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time, size: 10, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  job.postedTime,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
