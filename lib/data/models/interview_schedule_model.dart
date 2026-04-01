class InterviewScheduleModel {
  final int id;
  final String candidateName;
  final String jobTitle;
  final DateTime date;
  final String type;
  final String location;
  final String contactPerson;
  final String note;
  final String status;

  InterviewScheduleModel({
    required this.id,
    required this.candidateName,
    required this.jobTitle,
    required this.date,
    required this.type,
    required this.location,
    required this.contactPerson,
    required this.note,
    this.status = 'pending',
  });

  factory InterviewScheduleModel.fromMap(Map<String, dynamic> map) {
    return InterviewScheduleModel(
      id: map['i_id'],
      candidateName: map['candidates']?['c_full_name'] ?? 'Unknown',
      jobTitle: map['jobs']?['j_title'] ?? '',
      date: DateTime.parse(map['i_interview_date']),
      type: map['i_interview_type'] ?? '',
      location: map['i_location'] ?? '',
      contactPerson: map['i_contact_person'] ?? '',
      note: map['i_note'] ?? '',
      status: map['i_status'] ?? 'pending',
    );
  }
}