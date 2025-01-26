import 'package:bara_flutter/models/generated_classes.dart';
import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String userId;
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? studentNumber;
  final ROLE_ENUM role;

  const Profile({
    required this.userId,
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.studentNumber,
    required this.role,
  });

  // Factory constructor to convert from ProfileDTO
  factory Profile.from(VProfile vProfile) {
    return Profile(
      userId: vProfile.userId!,
      id: vProfile.id!,
      email: vProfile.email!,
      firstName: vProfile.firstName!,
      lastName: vProfile.lastName!,
      studentNumber: vProfile.studentNumber,
      role: vProfile.role!,
    );
  }

  // Factory method for the default instance
  static Profile get empty => Profile(
        userId: "00000000-0000-0000-0000-000000000000",
        id: "00000000-0000-0000-0000-000000000000",
        email: "-",
        firstName: "-",
        lastName: "-",
        studentNumber: null,
        role: ROLE_ENUM.guest,
      );

  // Sample student profile for testing
  static Profile sampleStudentProfile({required String email}) => Profile(
        userId: "00000000-0000-0000-0000-000000000000",
        id: "00000000-0000-0000-0000-000000000000",
        email: email,
        firstName: "Sample",
        lastName: "Profile",
        studentNumber: "20210001",
        role: ROLE_ENUM.student,
      );

  // copyWith method to create a new instance with modified fields
  Profile copyWith({
    String? userId,
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? studentNumber,
    ROLE_ENUM? role,
  }) {
    return Profile(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      studentNumber: studentNumber ?? this.studentNumber,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        id,
        email,
        firstName,
        lastName,
        studentNumber ?? '',
        role,
      ];
}
