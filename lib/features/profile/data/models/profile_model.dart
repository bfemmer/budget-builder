import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  ProfileModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.rank,
    required super.dutyStation,
    required super.gender,
    required super.dateOfBirth,
    required super.familySize,
    required super.email,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] ?? 1,
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      rank: map['rank'] ?? 'Airman',
      dutyStation: map['duty_station'] ?? '',
      gender: map['gender'] ?? 'Unspecified',
      dateOfBirth: map['date_of_birth'] ?? '',
      familySize: map['family_size'] ?? '',
      email: map['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'rank': rank,
      'duty_station': dutyStation,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'family_size': familySize,
      'email': email,
    };
  }

  ProfileModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? rank,
    String? dutyStation,
    String? gender,
    String? dateOfBirth,
    String? familySize,
    String? email,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      rank: rank ?? this.rank,
      dutyStation: dutyStation ?? this.dutyStation,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      familySize: familySize ?? this.familySize,
      email: email ?? this.email,
    );
  }
}
