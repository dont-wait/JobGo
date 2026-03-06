class CandidateModel {
  final int id;
  final String fullName;
  final String dateOfBirth;
  final String gender;
  final String address;
  final String skill;
  final String phone;
  final String avatarUrl;
  final String education;
  final String experience;
  final String cvUrl;
  final double desiredSalaryMin;
  final double desiredSalaryMax;
  final String email;
  CandidateModel({
    required this.id,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    required this.skill,
    required this.phone,
    required this.avatarUrl,
    required this.education,
    required this.experience,
    required this.cvUrl,
    required this.desiredSalaryMin,
    required this.desiredSalaryMax,
    required this.email,
  });
}

final List<CandidateModel> mockCandidatesData = [
  CandidateModel(
    id: 1,
    fullName: 'Sarah Jenkins',
    dateOfBirth: '1995-08-12',
    gender: 'Female',
    address: 'London',
    skill: 'Figma, React, UI/UX',
    phone: '0901234567',
    avatarUrl: 'https://i.pravatar.cc/150?img=1',
    education: 'Master of Design',
    experience: 'Senior Product Designer',
    cvUrl: 'https://example.com/cv/sarah.pdf',
    desiredSalaryMin: 85000,
    desiredSalaryMax: 100000,
    email: 'candidate@gmail.com',
  ),
  CandidateModel(
    id: 2,
    fullName: 'David Chen',
    dateOfBirth: '1998-03-25',
    gender: 'Male',
    address: 'San Francisco',
    skill: 'Flutter, Dart, Node',
    phone: '0987654321',
    avatarUrl: 'https://i.pravatar.cc/150?img=11',
    education: 'BSc Computer Science',
    experience: 'Full Stack Developer',
    cvUrl: 'https://example.com/cv/david.pdf',
    desiredSalaryMin: 140000,
    desiredSalaryMax: 160000,
    email: 'candidate1@gmail.com',
  ),
  CandidateModel(
    id: 3,
    fullName: 'Amara Okafor',
    dateOfBirth: '1993-11-05',
    gender: 'Female',
    address: 'Berlin',
    skill: 'AWS, Docker, Linux',
    phone: '0912345678',
    avatarUrl: 'https://i.pravatar.cc/150?img=5',
    education: 'BEng Software',
    experience: 'DevOps Engineer',
    cvUrl: 'https://example.com/cv/amara.pdf',
    desiredSalaryMin: 95000,
    desiredSalaryMax: 120000,
    email: 'candidate2@gmail.com',
  ),
  // Test candidate account
  CandidateModel(
    id: 4,
    fullName: 'Test Candidate',
    dateOfBirth: '1995-01-01',
    gender: 'Male',
    address: 'Test City',
    skill: 'Flutter, Dart, React',
    phone: '0123456789',
    avatarUrl: 'https://i.pravatar.cc/150?img=20',
    education: 'BSc Information Technology',
    experience: 'Full Stack Developer',
    cvUrl: 'https://example.com/cv/test.pdf',
    desiredSalaryMin: 80000,
    desiredSalaryMax: 120000,
    email: 'candidate@gmail.com',
  ),
];
