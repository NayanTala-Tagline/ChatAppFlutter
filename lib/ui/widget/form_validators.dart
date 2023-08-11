class FormValidators {
  static String? validateEmail(String text) {
    var regex =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
    return RegExp(regex).hasMatch(text) ? null : '';
  }

  static String? validateName(String text) {
    return text.isNotEmpty ? null : '';
  }

  static String? validatePassword(String text) {
    return text.isNotEmpty ? null : '';
  }

  static String? validateNewPassword(String text) {
    final start = r'^';
    final oneNumber = r'(?=.*[0-9])';
    final oneSymbol = r'''(?=.*[\-/:;\(\)$&@".,\?!'\[\]{}#%\^\*+=_|~<>€£¥])''';
    final oneLowercase = r'(?=.*[a-z])';
    final oneUppercase = r'(?=.*[A-Z])';
    final min8Chars = r'.{8,}';
    final end = r'$';
    final regex =
        '$start$oneNumber$oneSymbol$oneLowercase$oneUppercase$min8Chars$end';

    final numbeRegex = '$oneNumber';
    return RegExp(numbeRegex).hasMatch(text) ? null : '';
  }

  /// Validates a string to see if it matches the password reset validation code pattern.
  ///
  /// returns success if the string is 6 numberical digits in length
  static String? validatePasswordResetCode(String text) {
    var regex = r'^[0-9]{4,4}$';
    return RegExp(regex).hasMatch(text) ? null : '';
  }

  static String? confirmPassword(String text) {
    var regex = r'^[0-9]{8,8}$';
    return RegExp(regex).hasMatch(text) ? null : '';
  }
}
