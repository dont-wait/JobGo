import 'package:jobgo/data/mockdata/mock_interview.dart';

import 'mock_jobs.dart';

/// Application status enum matching ERD `a_status varchar(20)`
enum ApplicationStatus {
  pending,
  reviewing,
  interview,
  hired,
  rejected,
  withdrawn,
}

/// Model matching ERD `applications` table
class MockApplication {
  final int id; // a_id
  final String coverLetter; // a_cover_letter
  final ApplicationStatus status; // a_status
  final String cvUrl; // a_cv_url
  final String? internalNotes; // a_internal_notes
  final DateTime appliedAt; // a_applied_at
  final DateTime updatedAt; // a_updated_at
  final String jobId; // j_id → FK to jobs
  final int candidateId; // c_id → FK to candidates

  // Denormalized job info for UI convenience
  final String jobTitle;
  final String company;
  final String location;
  final String logoColor;
  final String logoText;
  final String? logoUrl;

  // Interview schedule (only for interview-stage applications)
  final MockInterviewSchedule? interviewSchedule;

  const MockApplication({
    required this.id,
    required this.coverLetter,
    required this.status,
    required this.cvUrl,
    this.internalNotes,
    required this.appliedAt,
    required this.updatedAt,
    required this.jobId,
    required this.candidateId,
    required this.jobTitle,
    required this.company,
    required this.location,
    required this.logoColor,
    required this.logoText,
    this.logoUrl,
    this.interviewSchedule,
  });

  /// Helper: create from a MockJob
  static MockApplication fromJob({
    required int id,
    required MockJob job,
    required ApplicationStatus status,
    required DateTime appliedAt,
    String coverLetter = '',
    String cvUrl = '',
    String? internalNotes,
    int candidateId = 1,
  }) {
    return MockApplication(
      id: id,
      coverLetter: coverLetter,
      status: status,
      cvUrl: cvUrl,
      internalNotes: internalNotes,
      appliedAt: appliedAt,
      updatedAt: appliedAt,
      jobId: job.id,
      candidateId: candidateId,
      jobTitle: job.title,
      company: job.company,
      location: job.location,
      logoColor: job.logoColor,
      logoText: job.logoText,
      logoUrl: job.logoUrl,
    );
  }

  String get statusLabel {
    switch (status) {
      case ApplicationStatus.pending:
        return 'PENDING';
      case ApplicationStatus.reviewing:
        return 'REVIEWING';
      case ApplicationStatus.interview:
        return 'INTERVIEW';
      case ApplicationStatus.hired:
        return 'HIRED';
      case ApplicationStatus.rejected:
        return 'REJECTED';
      case ApplicationStatus.withdrawn:
        return 'WITHDRAWN';
    }
  }

  String get appliedTimeAgo {
    final now = DateTime(2026, 3, 2);
    final diff = now.difference(appliedAt);
    if (diff.inDays == 0) return 'Applied today';
    if (diff.inDays == 1) return 'Applied 1 day ago';
    if (diff.inDays < 7) return 'Applied ${diff.inDays} days ago';
    if (diff.inDays < 14) return 'Applied 1 week ago';
    return 'Applied ${(diff.inDays / 7).floor()} weeks ago';
  }
}

class MockApplications {
  static final List<MockApplication> all = [
    // ── Applied / Pending ──
    MockApplication(
      id: 1,
      coverLetter: 'I am excited to apply for the Senior Product Designer role...',
      status: ApplicationStatus.pending,
      cvUrl: 'https://example.com/cv/sarah_designer.pdf',
      appliedAt: DateTime(2026, 2, 28),
      updatedAt: DateTime(2026, 2, 28),
      jobId: '101',
      candidateId: 1,
      jobTitle: 'Senior Product Designer',
      company: 'TechCorp',
      location: 'San Francisco, CA',
      logoColor: '0xFF1A1A2E',
      logoText: 'TC',
    ),
    MockApplication(
      id: 2,
      coverLetter: 'With my experience in frontend development...',
      status: ApplicationStatus.rejected,
      cvUrl: 'https://example.com/cv/sarah_frontend.pdf',
      internalNotes: 'Candidate lacks required React experience',
      appliedAt: DateTime(2026, 2, 23),
      updatedAt: DateTime(2026, 2, 26),
      jobId: '102',
      candidateId: 1,
      jobTitle: 'Frontend Developer',
      company: 'Innovate Studio',
      location: 'Remote',
      logoColor: '0xFF9CA3AF',
      logoText: 'IS',
    ),
    MockApplication(
      id: 3,
      coverLetter: 'I would love to contribute as a UX Researcher...',
      status: ApplicationStatus.hired,
      cvUrl: 'https://example.com/cv/sarah_ux.pdf',
      appliedAt: DateTime(2026, 2, 27),
      updatedAt: DateTime(2026, 3, 1),
      jobId: '103',
      candidateId: 1,
      jobTitle: 'UX Researcher',
      company: 'Global Systems',
      location: 'New York, NY',
      logoColor: '0xFF0A73B7',
      logoText: 'GS',
    ),
    MockApplication(
      id: 4,
      coverLetter: 'My passion for interaction design drives me...',
      status: ApplicationStatus.pending,
      cvUrl: 'https://example.com/cv/sarah_interaction.pdf',
      appliedAt: DateTime(2026, 2, 25),
      updatedAt: DateTime(2026, 2, 25),
      jobId: '104',
      candidateId: 1,
      jobTitle: 'Interaction Designer',
      company: 'Creative Pulse',
      location: 'London, UK',
      logoColor: '0xFFDC2626',
      logoText: 'RE',
      logoUrl: null,
    ),

    // ── Interview stage ──
    MockApplication(
      id: 5,
      coverLetter: 'I am interested in the Mobile Developer position...',
      status: ApplicationStatus.interview,
      cvUrl: 'https://example.com/cv/sarah_mobile.pdf',
      internalNotes: 'Phone screen passed, on-site scheduled',
      appliedAt: DateTime(2026, 2, 20),
      updatedAt: DateTime(2026, 2, 28),
      jobId: '6',
      candidateId: 1,
      jobTitle: 'Senior Flutter Developer',
      company: 'CloudTech Solutions',
      location: 'Remote, US',
      logoColor: '0xFF0A73B7',
      logoText: 'CT',
      interviewSchedule: MockInterviewSchedule(
        id: 1,
        interviewDate: DateTime(2026, 3, 5, 10, 0),
        interviewType: 'Video Call',
        location: 'Google Meet - link will be sent via email',
        contactPerson: 'Emily Carter, HR Manager',
        note: 'Please prepare a 10-min presentation about your recent Flutter project',
        employerId: 1,
        candidateId: 1,
      ),
    ),
    MockApplication(
      id: 6,
      coverLetter: 'As a data-driven professional...',
      status: ApplicationStatus.interview,
      cvUrl: 'https://example.com/cv/sarah_data.pdf',
      appliedAt: DateTime(2026, 2, 18),
      updatedAt: DateTime(2026, 2, 27),
      jobId: '5',
      candidateId: 1,
      jobTitle: 'Data Scientist',
      company: 'DataDriven Labs',
      location: 'San Francisco, CA',
      logoColor: '0xFF0369A1',
      logoText: 'DL',
      interviewSchedule: MockInterviewSchedule(
        id: 2,
        interviewDate: DateTime(2026, 3, 7, 14, 30),
        interviewType: 'On-site',
        location: '456 Market St, Floor 8, San Francisco, CA',
        contactPerson: 'James Wong, Tech Lead',
        note: 'Bring your laptop for a live coding session. Ask for James at reception.',
        employerId: 2,
        candidateId: 1,
      ),
    ),

    // ── More accepted ──
    MockApplication(
      id: 7,
      coverLetter: 'I am thrilled to join the marketing team...',
      status: ApplicationStatus.hired,
      cvUrl: 'https://example.com/cv/sarah_marketing.pdf',
      appliedAt: DateTime(2026, 2, 15),
      updatedAt: DateTime(2026, 2, 28),
      jobId: '9',
      candidateId: 1,
      jobTitle: 'Marketing Manager',
      company: 'BrandWave Agency',
      location: 'Los Angeles, CA',
      logoColor: '0xFFDC2626',
      logoText: 'BW',
    ),

    // ── Reviewing ──
    MockApplication(
      id: 8,
      coverLetter: 'My DevOps experience makes me a strong candidate...',
      status: ApplicationStatus.reviewing,
      cvUrl: 'https://example.com/cv/sarah_devops.pdf',
      appliedAt: DateTime(2026, 2, 26),
      updatedAt: DateTime(2026, 2, 28),
      jobId: '10',
      candidateId: 1,
      jobTitle: 'DevOps Engineer',
      company: 'PixelPerfect Inc.',
      location: 'Remote, Global',
      logoColor: '0xFF7C3AED',
      logoText: 'PP',
    ),
  ];

  /// Filter by tab
  static List<MockApplication> get applied => all
      .where((a) =>
          a.status == ApplicationStatus.pending ||
          a.status == ApplicationStatus.reviewing ||
          a.status == ApplicationStatus.rejected)
      .toList();

  static List<MockApplication> get interviews =>
      all.where((a) => a.status == ApplicationStatus.interview).toList();

  static List<MockApplication> get accepted =>
      all.where((a) => a.status == ApplicationStatus.hired).toList();
}
