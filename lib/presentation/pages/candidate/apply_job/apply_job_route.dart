import 'package:flutter/material.dart';
import 'package:jobgo/data/models/job_model.dart';
import 'package:jobgo/presentation/pages/candidate/apply_job/apply_job_page.dart';

/// Navigate tới ApplyJobPage.
/// Sau khi submit xong, nếu user bấm "View Application Status"
/// thì tự động switch sang tab Applications (index 2) trong AppShell.
void navigateToApply(BuildContext context, JobModel job) {
  // Tìm AppShellState gần nhất trong cây widget

  Navigator.push<String>(
    context,
    MaterialPageRoute(builder: (_) => ApplyJobPage(job: job)),
  );
}
