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

final RegExp _studentEmailRegex =
    RegExp(r'^[A-Za-z]\.[^@\s]+@alustudent\.com$', caseSensitive: false);

final RegExp _staffEmailRegex =
    RegExp(r'^[^@\s]+@alueducation\.com$', caseSensitive: false);

/// Sign-up rule: ALU student email (for example a.lastname@alustudent.com).
String? studentEmail(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Email is required';
  if (!_studentEmailRegex.hasMatch(v)) {
    return 'Use your ALU student email (e.g. a.lastname@alustudent.com)';
  }
  return null;
}

/// Staff email rule: any local part at @alueducation.com.
String? staffEmail(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Email is required';
  if (!_staffEmailRegex.hasMatch(v)) {
    return 'Use your ALU staff email (e.g. name@alueducation.com)';
  }
  return null;
}

/// Login rule: accepts either an ALU student or staff address.
String? aluEmail(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Email is required';
  if (_studentEmailRegex.hasMatch(v) || _staffEmailRegex.hasMatch(v)) {
    return null;
  }
  return 'Use your ALU email (student or staff)';
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

String? validateTitle(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Title is required';
  if (v.length < 5) return 'Title must be at least 5 characters';
  if (v.length > 80) return 'Title must be at most 80 characters';
  return null;
}

String? validateDescription(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Description is required';
  if (v.length < 15) {
    return 'Please add a few more details (at least 15 characters)';
  }
  if (v.length > 500) return 'Description must be at most 500 characters';
  return null;
}

String? validateCategory(String? value) {
  if (value == null || value.isEmpty) return 'Please select a category';
  return null;
}

String? validateLocation(String? value) {
  if (value == null || value.isEmpty) return 'Please select a location';
  return null;
}

String? validateSpecifyLocation(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Please specify a location';
  if (v.length < 3) return 'Location must be at least 3 characters';
  return null;
}
