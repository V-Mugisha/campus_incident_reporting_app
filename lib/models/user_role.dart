/// Roles supported by the app.
enum UserRole {
  student,
  staff;

  /// Parses a role name (as stored in Firestore) into a [UserRole].
  /// Unknown or missing values default to [UserRole.student] (least privilege).
  static UserRole fromName(String? name) {
    return UserRole.values.firstWhere(
      (role) => role.name == name,
      orElse: () => UserRole.student,
    );
  }
}
