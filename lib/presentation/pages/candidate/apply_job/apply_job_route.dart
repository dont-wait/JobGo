import 'package:flutter/material.dart';
import 'package:jobgo/data/models/job_model.dart';
import 'package:jobgo/presentation/pages/candidate/apply_job/apply_job_page.dart';
import 'package:jobgo/presentation/providers/profile_provider.dart';
import 'package:provider/provider.dart';

/// Navigate tới ApplyJobPage.
/// Sau khi submit xong, nếu user bấm "View Application Status"
/// thì tự động switch sang tab Applications (index 2) trong AppShell.
Future<void> navigateToApply(BuildContext context, JobModel job) async {
  final profileProvider = context.read<ProfileProvider>();
  var candidate = profileProvider.candidate;

  // If profile not loaded yet, try to load it (handles race condition)
  if (candidate == null) {
    await profileProvider.loadProfile();
    candidate = profileProvider.candidate;
  }

  if (candidate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vui lòng đăng nhập để ứng tuyển')),
    );
    return;
  }

  // UC-008: Check if profile is complete (e.g. has resumes)
  if ((candidate.resumes ?? []).isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Vui lòng hoàn thiện hồ sơ (thêm CV) trước khi ứng tuyển',
        ),
        duration: Duration(seconds: 3),
      ),
    );
    // Optionally navigate to UC-003: Navigator.pushNamed(context, '/profile/edit');
    return;
  }

  Navigator.push<String>(
    context,
    MaterialPageRoute(builder: (_) => ApplyJobPage(job: job)),
  );
}
