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