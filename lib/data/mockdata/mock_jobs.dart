class MockJob {
  final String id;
  final String title;
  final String company;
  final String logoColor;
  final String logoText;
  final String? logoUrl;
  final String location;
  final String salary;
  final String type;
  final String postedTime;
  final bool isBookmarked;
  final String? badge; // 'URGENT', 'TOP TALENT', etc.
  final String? description;
  final List<String>? requirements;
  final List<String>? benefits;
  final List<String>? tags;
  final int? applicants;

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
    this.badge,
    this.description,
    this.requirements,
    this.benefits,
    this.tags,
    this.applicants,
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
      location: 'Remote, US',
      salary: '\$120k - \$160k',
      type: 'Full-time',
      postedTime: '3h ago',
    ),
    MockJob(
      id: '2',
      title: 'Registered Nurse',
      company: 'HealthFirst Medical',
      logoColor: '0xFF2D5A3D',
      logoText: 'HF',
      location: 'New York, NY',
      salary: '\$80k - \$110k',
      type: 'Full-time',
      postedTime: '5h ago',
    ),
    MockJob(
      id: '3',
      title: 'Financial Analyst',
      company: 'Global Finance Corp.',
      logoColor: '0xFFB8860B',
      logoText: 'GF',
      location: 'Chicago, IL',
      salary: '\$90k - \$130k',
      type: 'Full-time',
      postedTime: '1d ago',
    ),
    MockJob(
      id: '4',
      title: 'UI/UX Designer',
      company: 'Creative Studio',
      logoColor: '0xFF6B21A8',
      logoText: 'CS',
      location: 'Remote',
      salary: '\$100k - \$140k',
      type: 'Full-time',
      postedTime: '2d ago',
    ),
    MockJob(
      id: '5',
      title: 'Data Scientist',
      company: 'DataDriven Labs',
      logoColor: '0xFF0369A1',
      logoText: 'DL',
      location: 'San Francisco, CA',
      salary: '\$150k - \$200k',
      type: 'Full-time',
      postedTime: '3d ago',
    ),
  ];

  static const List<MockJob> recentJobs = [
    MockJob(
      id: '6',
      title: 'Senior Flutter Developer',
      company: 'CloudTech Solutions',
      logoColor: '0xFF0A73B7',
      logoText: 'CT',
      location: 'Remote, US',
      salary: '\$140k - \$180k',
      type: 'Full-time',
      postedTime: '2h ago',
      badge: 'URGENT',
      tags: ['Flutter', 'Dart', 'Firebase'],
      applicants: 5,
      description:
          'CloudTech Solutions is seeking a highly skilled Senior Flutter Developer to join our core product team. You will be responsible for leading the development of our flagship cross-platform mobile application, ensuring high performance and a seamless user experience across iOS and Android platforms.',
      requirements: [
        'Deep expertise in Flutter framework and Dart language.',
        'Extensive experience with Firebase (Auth, Firestore, Cloud Functions).',
        'Proven track record of publishing apps to App Store and Google Play.',
        'Strong understanding of state management (BLoC, Riverpod, or Provider).',
        'Experience with CI/CD pipelines for mobile deployments.',
      ],
      benefits: ['Health & Dental', 'Remote Work', '401k Matching', 'Gym Membership'],
    ),
    MockJob(
      id: '7',
      title: 'Lead Backend Engineer',
      company: 'FinStream Global',
      logoColor: '0xFF1A3A4A',
      logoText: 'FG',
      location: 'New York, NY (Hybrid)',
      salary: '\$160k - \$210k',
      type: 'Full-time',
      postedTime: '5h ago',
      tags: ['Kotlin', 'AWS', 'Microservices'],
      applicants: 8,
      description:
          'FinStream Global is looking for a Lead Backend Engineer to architect and scale our real-time financial data streaming platform. You will lead a team of 5 engineers and work closely with product and data science teams.',
      requirements: [
        'Expert-level proficiency in Kotlin or Java.',
        'Deep experience with AWS services (Lambda, DynamoDB, Kinesis).',
        'Experience leading engineering teams (3+ years).',
        'Strong understanding of distributed systems and microservices.',
        'Experience with real-time data processing pipelines.',
      ],
      benefits: ['Health & Dental', 'Stock Options', '401k Matching', 'Learning Budget'],
    ),
    MockJob(
      id: '8',
      title: 'Product Designer',
      company: 'CreativeFlow Inc.',
      logoColor: '0xFF6B21A8',
      logoText: 'CF',
      location: 'Remote',
      salary: '\$110k - \$145k',
      type: 'Full-time',
      postedTime: '1d ago',
      badge: 'TOP TALENT',
      applicants: 10,
      description:
          'CreativeFlow Inc. is searching for a Product Designer to shape the future of our design collaboration platform. You will work on end-to-end product design, from user research and wireframes to high-fidelity prototypes.',
      requirements: [
        'Strong portfolio demonstrating product design skills.',
        'Proficiency in Figma, Sketch, or Adobe XD.',
        'Experience conducting user research and usability testing.',
        'Understanding of design systems and component libraries.',
        'Ability to translate complex requirements into intuitive interfaces.',
      ],
      benefits: ['Health & Dental', 'Remote Work', 'Unlimited PTO', 'Home Office Stipend'],
    ),
    MockJob(
      id: '9',
      title: 'Marketing Manager',
      company: 'BrandWave Agency',
      logoColor: '0xFFDC2626',
      logoText: 'BW',
      type: 'Full-time',
      location: 'Los Angeles, CA',
      salary: '\$95k - \$130k',
      postedTime: '1 week ago',
      tags: ['Marketing', 'SEO', 'Analytics'],
      applicants: 15,
      description:
          'BrandWave Agency is hiring a Marketing Manager to drive growth strategies for our portfolio of consumer brands. You will own the full marketing funnel from awareness to conversion.',
      requirements: [
        'Experience managing marketing budgets of \$500k+.',
        'Strong analytical skills with proficiency in Google Analytics.',
        'Experience with SEO, SEM, and social media marketing.',
        'Excellent communication and presentation skills.',
      ],
      benefits: ['Health & Dental', 'Performance Bonus', 'Team Events'],
    ),
    MockJob(
      id: '10',
      title: 'DevOps Engineer',
      company: 'PixelPerfect Inc.',
      logoColor: '0xFF7C3AED',
      logoText: 'PP',
      type: 'Remote',
      location: 'Remote, Global',
      salary: '\$130k - \$170k',
      postedTime: '1 week ago',
      tags: ['Docker', 'Kubernetes', 'Terraform'],
      applicants: 12,
      description:
          'PixelPerfect Inc. is looking for a DevOps Engineer to build and maintain our cloud infrastructure. You will design CI/CD pipelines, manage Kubernetes clusters, and ensure 99.99% uptime.',
      requirements: [
        'Strong experience with Docker and Kubernetes.',
        'Proficiency in Terraform or Pulumi for IaC.',
        'Experience with cloud platforms (AWS, GCP, or Azure).',
        'Strong scripting skills (Bash, Python).',
        'Experience with monitoring tools (Prometheus, Grafana, Datadog).',
      ],
      benefits: ['Health & Dental', 'Remote Work', 'Stock Options', 'Learning Budget'],
    ),
  ];
}
