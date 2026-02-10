class MockJob {
  final String id;
  final String title;
  final String company;
  final String logoColor;
  final String logoText;
  final String? logoUrl; // URL ảnh từ Cloudinary (null = dùng fallback text)
  final String location;
  final String salary;
  final String type;
  final String postedTime;
  final bool isBookmarked;

  const MockJob({
    required this.id,
    required this.title,
    required this.company,
    required this.logoColor,
    required this.logoText,
    this.logoUrl,
    this.location = '',
    this.salary = '',
    this.type = '',
    this.postedTime = '',
    this.isBookmarked = false,
  });
}

class MockJobs {
  static const List<MockJob> recommendedJobs = [
    MockJob(
      id: '1',
      title: 'Software Engineer',
      company: 'Tech Innovations Inc.',
      logoColor: '0xFF1A3A4A',
      logoText: 'TECHNOLOGY',
    ),
    MockJob(
      id: '2',
      title: 'Registered Nurse',
      company: 'HealthFirst Medical',
      logoColor: '0xFF2D5A3D',
      logoText: 'HF',
    ),
    MockJob(
      id: '3',
      title: 'Financial Analyst',
      company: 'Global Finance Corp.',
      logoColor: '0xFFB8860B',
      logoText: 'GF',
    ),
    MockJob(
      id: '4',
      title: 'UI/UX Designer',
      company: 'Creative Studio',
      logoColor: '0xFF6B21A8',
      logoText: 'CS',
    ),
    MockJob(
      id: '5',
      title: 'Data Scientist',
      company: 'DataDriven Labs',
      logoColor: '0xFF0369A1',
      logoText: 'DL',
    ),
  ];

  static const List<MockJob> recentJobs = [
    MockJob(
      id: '6',
      title: 'Senior Software Engineer',
      company: 'Tech Innovations Inc.',
      logoColor: '0xFF1A3A4A',
      logoText: 'TI',
      type: 'Full-time',
      postedTime: '2 days ago',
    ),
    MockJob(
      id: '7',
      title: 'Registered Nurse',
      company: 'HealthFirst Medical',
      logoColor: '0xFF2D5A3D',
      logoText: 'HF',
      type: 'Full-time',
      postedTime: '3 days ago',
    ),
    MockJob(
      id: '8',
      title: 'Financial Analyst',
      company: 'Global Finance Corp.',
      logoColor: '0xFFB8860B',
      logoText: 'GF',
      type: 'Part-time',
      postedTime: '5 days ago',
    ),
    MockJob(
      id: '9',
      title: 'Marketing Manager',
      company: 'BrandWave Agency',
      logoColor: '0xFFDC2626',
      logoText: 'BW',
      type: 'Full-time',
      postedTime: '1 week ago',
    ),
    MockJob(
      id: '10',
      title: 'Product Designer',
      company: 'PixelPerfect Inc.',
      logoColor: '0xFF7C3AED',
      logoText: 'PP',
      type: 'Remote',
      postedTime: '1 week ago',
    ),
  ];
}
