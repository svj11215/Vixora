/// Form validation helper methods used across the application.
class Validators {
  Validators._();

  /// Validates that a visitor name is at least 2 characters.
  static String? validateVisitorName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Visitor name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Validates that a phone number has at least 10 digits.
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10) {
      return 'Phone number must have at least 10 digits';
    }
    return null;
  }

  /// Validates that a purpose has been selected from the dropdown.
  static String? validatePurpose(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a purpose';
    }
    return null;
  }

  /// Validates that a resident code is exactly 4 numeric digits.
  static String? validateResidentCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Resident code is required';
    }
    if (!RegExp(r'^\d{4}$').hasMatch(value.trim())) {
      return 'Code must be exactly 4 digits';
    }
    return null;
  }

  /// Validates that a name for profile update is not empty.
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name cannot be empty';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Validates that a flat number is in a valid format (e.g., A-102).
  static String? validateFlatNo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Flat number is required';
    }
    return null;
  }
}
