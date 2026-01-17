class AppValidators {
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) return 'Amount is required';
    final amount = double.tryParse(value);
    if (amount == null) return 'Please enter a valid number';
    if (amount <= 0) return 'Amount must be greater than 0';
    return null; // Means valid
  }

  static String? validateCategory(int? value) {
    if (value == null) {
      return 'Please select a category';
    }
    return null;
  }
}
