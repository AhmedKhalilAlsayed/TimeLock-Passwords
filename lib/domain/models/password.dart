import 'dart:math';

import 'package:timelockpassword/state_handler.dart';

enum PasswordErrorStates { success, shortLengthError, noTypeSelectedError }

class Password {
  static const String smallChars = "qwertyuiopasdfghjklzxcvbnm";
  static const String capitalChars = "QWERTYUIOPASDFGHJKLZXCVBNM";
  static const String numbers = "0123456789";
  static const String signs = "!@#\$%^&&*()_++/*-+";

  static StateHandler<PasswordErrorStates, String> generate({
    bool isContainNumbers = true,
    bool isContainSmallChars = true,
    bool isContainCapitalChars = true,
    bool isContainSigns = true,
    int length = 8,
  }) {
    PasswordErrorStates? errorState;
    String allChars = "";
    String pass = "";
    Random random = Random();

    // safe entering of there is unwanted values
    if (length < 8) {
      errorState = PasswordErrorStates.shortLengthError;
      return StateHandler(errorState, null);
    }
    if (!isContainNumbers &&
        !isContainSmallChars &&
        !isContainCapitalChars &&
        !isContainSigns) {
      errorState = PasswordErrorStates.noTypeSelectedError;
      return StateHandler(errorState, null);
    }
    // get the needed chars
    if (isContainSigns) allChars += signs;
    if (isContainNumbers) allChars += numbers;
    if (isContainCapitalChars) allChars += capitalChars;
    if (isContainSmallChars) allChars += smallChars;
    // generate the pass
    for (int i = 0; i < length; i++) {
      pass += allChars[random.nextInt(allChars.length)];
    }
    errorState = PasswordErrorStates.success;
    return StateHandler(errorState, pass);
  }
}
