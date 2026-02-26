class CandidateModel {
  final int cId;
  final String cFullName;
  final String cDateOfBirth;
  final String cGender;
  final String cAddress;
  final String cSkill;
  final String cPhone;
  final String cAvartaUrl;
  final String cEducation;
  final String cExperience;
  final String cCvUrl;
  final double cDesiredSalaryMin;
  final double cDesiredSalaryMax;

  CandidateModel({
    required this.cId,
    required this.cFullName,
    required this.cDateOfBirth,
    required this.cGender,
    required this.cAddress,
    required this.cSkill,
    required this.cPhone,
    required this.cAvartaUrl,
    required this.cEducation,
    required this.cExperience,
    required this.cCvUrl,
    required this.cDesiredSalaryMin,
    required this.cDesiredSalaryMax,
  });
}

final List<CandidateModel> mockCandidatesData = [
  CandidateModel(
    cId: 1,
    cFullName: 'Sarah Jenkins',
    cDateOfBirth: '1995-08-12',
    cGender: 'Female',
    cAddress: 'London',
    cSkill: 'Figma, React, UI/UX',
    cPhone: '0901234567',
    cAvartaUrl: 'https://i.pravatar.cc/150?img=1',
    cEducation: 'Master of Design',
    cExperience: 'Senior Product Designer',
    cCvUrl: 'https://example.com/cv/sarah.pdf',
    cDesiredSalaryMin: 85000,
    cDesiredSalaryMax: 100000,
  ),
  CandidateModel(
    cId: 2,
    cFullName: 'David Chen',
    cDateOfBirth: '1998-03-25',
    cGender: 'Male',
    cAddress: 'San Francisco',
    cSkill: 'Flutter, Dart, Node',
    cPhone: '0987654321',
    cAvartaUrl: 'https://i.pravatar.cc/150?img=11',
    cEducation: 'BSc Computer Science',
    cExperience: 'Full Stack Developer',
    cCvUrl: 'https://example.com/cv/david.pdf',
    cDesiredSalaryMin: 140000,
    cDesiredSalaryMax: 160000,
  ),
  CandidateModel(
    cId: 3,
    cFullName: 'Amara Okafor',
    cDateOfBirth: '1993-11-05',
    cGender: 'Female',
    cAddress: 'Berlin',
    cSkill: 'AWS, Docker, Linux',
    cPhone: '0912345678',
    cAvartaUrl: 'https://i.pravatar.cc/150?img=5',
    cEducation: 'BEng Software',
    cExperience: 'DevOps Engineer',
    cCvUrl: 'https://example.com/cv/amara.pdf',
    cDesiredSalaryMin: 95000,
    cDesiredSalaryMax: 120000,
  ),
];
