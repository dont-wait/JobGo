class EmployerMock {
  final int id;
  final String companyName;
  final String email;
  final String fullName;
  final String jobTitle;
  final String phone;
  final String location;
  final String bio;
  final String? avatarPath;
  final String accountType;

  EmployerMock({
    required this.id,
    required this.companyName,
    required this.email,
    required this.fullName,
    required this.jobTitle,
    this.phone = '',
    this.location = '',
    this.bio = '',
    this.avatarPath,
    this.accountType = 'Enterprise Account',
  });
}

final List<EmployerMock> mockEmployers = [
  EmployerMock(
    id: 1,
    companyName: "Global Design Systems",
    email: "employeer@gmail.com",
    fullName: "Jane Doe",
    jobTitle: "HR Manager",
    phone: "+1 234 567 890",
    location: "San Francisco, CA",
    bio:
        "Experienced HR Manager with 8+ years in tech recruitment and team building.",
    avatarPath: "assets/images/role_candidate1.jpg",
    accountType: "Enterprise Account",
  ),
];