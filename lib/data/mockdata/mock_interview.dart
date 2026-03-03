class MockInterviewSchedule {
  final int id;                // i_id
  final DateTime interviewDate; // i_interview_date
  final String interviewType;   // i_interview_type (e.g. 'Phone Screen', 'On-site', 'Video Call')
  final String location;        // i_location
  final String contactPerson;   // i_contact_person
  final String? note;           // i_note
  final int employerId;         // e_id → FK to employers
  final int candidateId;        // c_id → FK to candidates

  const MockInterviewSchedule({
    required this.id,
    required this.interviewDate,
    required this.interviewType,
    required this.location,
    required this.contactPerson,
    this.note,
    required this.employerId,
    required this.candidateId,
  });
  /// Formatted date string
  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[interviewDate.month - 1];
    final day = interviewDate.day;
    final year = interviewDate.year;
    return '$month $day, $year';
  }

  /// Formatted time string
  String get formattedTime {
    final hour = interviewDate.hour;
    final minute = interviewDate.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$h:$minute $period';
  }

  
}
final List<MockInterviewSchedule> mockInterviewSchedules = [
  MockInterviewSchedule(
    id: 1,
    interviewDate: DateTime(2026, 3, 7, 10, 0),
    interviewType: 'On-site',
    location: 'Văn phòng Global Design Systems, London',
    contactPerson: 'Ms. Anna HR',
    note: 'Mang theo CV bản cứng',
    employerId: 1,
    candidateId: 2,
  ),
  MockInterviewSchedule(
    id: 2,
    interviewDate: DateTime(2026, 3, 8, 14, 30),
    interviewType: 'Video Call',
    location: 'Zoom link: https://zoom.us/j/123456789',
    contactPerson: 'Mr. John HR',
    note: 'Chuẩn bị portfolio',
    employerId: 1,
    candidateId: 3,
  ),
  MockInterviewSchedule(
    id: 3,
    interviewDate: DateTime(2026, 3, 10, 9, 0),
    interviewType: 'Phone Screen',
    location: 'Số điện thoại: +44 123 456 789',
    contactPerson: 'Ms. Emily Recruiter',
    note: 'Phỏng vấn vòng sơ loại',
    employerId: 2,
    candidateId: 1,
  ),
];
