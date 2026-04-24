abstract class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value.trim())) {
      return 'Lütfen geçerli bir e-posta giriniz.';
    }
    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName boş olamaz.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Şifre boş olamaz.';
    }
    if (value.trim().length < 6) {
      return 'Şifre en az 6 karakter olmalı.';
    }
    return null;
  }

  static String? number(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Lütfen geçerli bir hedef sayı giriniz.';
    }
    if (int.tryParse(value.trim()) == null) {
      return 'Lütfen geçerli bir hedef sayı giriniz.';
    }
    return null;
  }
}
