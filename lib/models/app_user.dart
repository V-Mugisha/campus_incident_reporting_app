import 'user_role.dart';

/// A signed-in user with their profile loaded from the `users` collection.
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.department,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? department;
  final DateTime? createdAt;

  String get firstName {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '';
    final first = parts.first;
    final last = parts.length > 1 ? parts.last : '';
    final letters = (first.isNotEmpty ? first[0] : '') +
        (last.isNotEmpty ? last[0] : '');
    return letters.toUpperCase();
  }
}
