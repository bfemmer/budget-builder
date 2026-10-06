class Profile {
  final int id;
  final String firstName;
  final String lastName;
  final String rank;
  final String dutyStation;
  final String gender;
  final String dateOfBirth;
  final String familySize;
  final String email;

  Profile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.rank,
    required this.dutyStation,
    required this.gender,
    required this.dateOfBirth,
    required this.familySize,
    required this.email,
  });

  String get fullName => '$firstName $lastName';
}
