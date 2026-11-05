/// Pure form validators. Each returns an error message, or null when valid.
final RegExp _emailRegex = RegExp(r'^[\w.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');

String? validateName(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Full name is required';
  if (v.length < 2) return 'Full name must be at least 2 characters';
  return null;
}

String? validateEmail(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Email is required';
  if (!_emailRegex.hasMatch(v)) return 'Please enter a valid email address';
  return null;
}

/// Sign-up password rule: at least 8 chars with a letter and a number.
String? validatePassword(String? value) {
  final v = value ?? '';
  if (v.isEmpty) return 'Password is required';
  if (v.length < 8) return 'Password must be at least 8 characters';
  if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'[0-9]').hasMatch(v)) {
    return 'Password must include a letter and a number';
  }
  return null;
}

/// Login password rule: required only (rules are not revealed on login).
String? validateLoginPassword(String? value) {
  if (value == null || value.isEmpty) return 'Password is required';
  return null;
}

String? validateConfirmPassword(String? value, String password) {
  if (value == null || value.isEmpty) return 'Please confirm your password';
  if (value != password) return 'Passwords do not match';
  return null;
}
