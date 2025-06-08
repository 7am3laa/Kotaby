String? nameValidation({required String? value}) {
  if (value == null || value.isEmpty) {
    return "Please enter your name";
  }
  if (value.contains(RegExp(r'[0-9]'))) {
    return "Please enter a valid name";
  }
  return null;
}

String? emailValidation({required String? value}) {
  if (value == null || value.isEmpty) {
    return "Please enter your email";
  }
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return "Please enter a valid email";
  }
  return null;
}

String? passwordValidation({
  required String? value,
  bool isConfirm = false,
  String? originalPassword,
}) {
  if (value == null || value.isEmpty) {
    return "Please enter your password";
  }
  if (value.length < 8) {
    return "Password must be at least 8 characters";
  }
  if (isConfirm && originalPassword != null && value != originalPassword) {
    return "Passwords do not match";
  }
  return null;
}
