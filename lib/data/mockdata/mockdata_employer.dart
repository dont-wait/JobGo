class EmployerMock {
  final int id;
  final String companyName;
  final String email;

  EmployerMock({
    required this.id,
    required this.companyName,
    required this.email,
  });
}

final List<EmployerMock> mockEmployers = [
  EmployerMock(
    id: 1,
    companyName: "Global Design Systems",
    email: "emloyer@gmail.com",
  ),
];