class ValidatorUtils {
  /// Validasi Email Format
  static bool isValidEmail(String email) {
    if (email.trim().isEmpty) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  /// Cek aturan password (harus 8 char, ada huruf besar/kecil, angka, simbol)
  /// Mengembalikan Map berisi status untuk setiap aturan agar bisa dipakai UI Indicator
  static Map<String, bool> getPasswordRuleStatus(String password) {
    return {
      'minLength': password.length >= 8,
      'hasUppercase': password.contains(RegExp(r'[A-Z]')),
      'hasLowercase': password.contains(RegExp(r'[a-z]')),
      'hasNumber': password.contains(RegExp(r'[0-9]')),
      'hasSymbol': password.contains(RegExp(r'[^a-zA-Z0-9]')),
    };
  }

  /// Validasi Password Sederhana (Return true jika semua syarat terpenuhi)
  static bool isValidPassword(String password) {
    final rules = getPasswordRuleStatus(password);
    return !rules.containsValue(false);
  }

  /// Pesan error standar untuk password
  static const String passwordRequirementMsg =
      "Password harus memiliki minimal 8 karakter, huruf besar, huruf kecil, angka, dan simbol.";
}
