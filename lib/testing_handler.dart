import 'package:flutter/foundation.dart';

/// Test every function or scenario through it
class TestHandler {
  static int counter = 0;

  static void runScenario(Function scenarioFn) {
    if (kDebugMode) {
      scenarioFn();
    }
  }

  static void prnt(dynamic d) {
    if (kDebugMode) {
      print(
        "TESTp$counter:${StackTrace.current.toString().split('\n')[1]}",
      );
      print(d);
      counter++;
    }
  }
}
