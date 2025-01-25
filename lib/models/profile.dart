import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String userId;
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? studentNumber;
  final UserRole role;

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
  factory Profile.fromDTO(ProfileDTO dto) {
    return Profile(
      userId: dto.userId,
      id: dto.id,
      email: dto.email,
      firstName: dto.firstName,
      lastName: dto.lastName,
      studentNumber: dto.studentNumber,
      role: dto.role,
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
        role: UserRole.guest,
      );

  // Sample student profile for testing
  static Profile sampleStudentProfile({required String email}) => Profile(
        userId: "00000000-0000-0000-0000-000000000000",
        id: "00000000-0000-0000-0000-000000000000",
        email: email,
        firstName: "Sample",
        lastName: "Profile",
        studentNumber: "20210001",
        role: UserRole.student,
      );

  // copyWith method to create a new instance with modified fields
  Profile copyWith({
    String? userId,
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? studentNumber,
    UserRole? role,
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

enum UserRole {
  superuser,
  admin,
  principal,
  teacher,
  student,
  guest;
}

class ProfileDTO {
  final String userId; // The auth.user id of the session user
  final String id; // The unique id of the student/teacher in the db
  final String email;
  final String firstName;
  final String lastName;
  final String? studentNumber;
  final UserRole role;

  ProfileDTO({
    required this.userId,
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.studentNumber,
    required this.role,
  });
}
