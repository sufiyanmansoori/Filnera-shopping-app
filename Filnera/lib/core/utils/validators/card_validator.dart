class CardValidator { static bool validate(String? value) => value != null && value.replaceAll(RegExp(r'\s+'), '').length >= 12; }
