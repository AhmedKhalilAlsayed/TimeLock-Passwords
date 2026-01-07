import 'dart:convert';

import 'package:TimeLockPassword/domain/domain_constants.dart';
import 'package:TimeLockPassword/domain/domain_interface.dart';
import 'package:TimeLockPassword/domain/models/delayed_pass_model.dart';
import 'package:TimeLockPassword/domain/models/password.dart';
import 'package:TimeLockPassword/network/network_impl.dart';
import 'package:TimeLockPassword/network/network_interface.dart';
import 'package:TimeLockPassword/state_handler.dart';
import 'package:encrypt/encrypt.dart';

enum DomainErrorStates {
  success,
  failed,
  pleaseMakeYourLengthAtLeast8,
  youDidNotSelectCharType,
  pleaseWaitTheOpeningDateTime,
  checkYourNetwork,
  yourDeviceClockNotSyncedWithNetwork,
}

class DomainImpl extends DomainInterface {
  final Key _key = Key.fromUtf8(DomainConstants.key);

  @override
  StateHandler<DomainErrorStates, String> generatePass({
    required bool isContainNumbers,
    required bool isContainSmallChars,
    required bool isContainCapitalChars,
    required bool isContainSigns,
    required int length,
  }) {
    StateHandler<PasswordErrorStates, String> passHandler = Password.generate(
      isContainCapitalChars: isContainCapitalChars,
      isContainNumbers: isContainNumbers,
      isContainSigns: isContainSigns,
      isContainSmallChars: isContainSmallChars,
      length: length,
    );

    switch (passHandler.state) {
      case PasswordErrorStates.success:
        return StateHandler(DomainErrorStates.success, passHandler.value);
      case PasswordErrorStates.shortLengthError:
        return StateHandler(
          DomainErrorStates.pleaseMakeYourLengthAtLeast8,
          null,
        );
      case PasswordErrorStates.noTypeSelectedError:
        return StateHandler(DomainErrorStates.youDidNotSelectCharType, null);
    }
  }

  @override
  StateHandler<DomainErrorStates, Encrypted> generateHashWithPassAndTime(
    String pass,
    DateTime openDateTime,
  ) {
    // Generate a new IV for each encryption
    final iv = IV.fromSecureRandom(16);
    final delayedPassModel = DelayedPassModel(pass, openDateTime);

    final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
    final str = jsonEncode(delayedPassModel.toMap());

    // Encrypt the data
    final encryptedContent = encrypter.encrypt(str, iv: iv);

    // Combine IV + ciphertext and return it as a single Encrypted object
    final combined = Encrypted.fromBase64(
      base64.encode(iv.bytes + encryptedContent.bytes),
    );

    return StateHandler(DomainErrorStates.success, combined);
  }

  @override
  Future<StateHandler<DomainErrorStates, String>> getPassFromHash(
    Encrypted hash,
  ) async {
    try {
      // The hash must contain a 16-byte IV and at least one 16-byte block of data.
      if (hash.bytes.length < 32) {
        return StateHandler(DomainErrorStates.failed, "Invalid hash format");
      }

      // Extract IV (first 16 bytes) and the actual encrypted content
      final iv = IV(hash.bytes.sublist(0, 16));
      final encryptedContent = Encrypted(hash.bytes.sublist(16));

      final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));

      // Decrypt using the extracted IV
      final decrypted = encrypter.decrypt(encryptedContent, iv: iv);

      final delayedPassModel = DelayedPassModel.fromMap(jsonDecode(decrypted));

      final networkInterface = NetworkInterface.impl();
      var currentDateTimeHandler = StateHandler<DomainErrorStates, DateTime?>(
        DomainErrorStates.failed,
        null,
      );

      // TODO v+: validate the device's time

      // Try fetching time from NTP first
      final ntpResultHandler = await networkInterface.getCurrentTimeByNTP();
      if (ntpResultHandler.state == NetworkErrorState.success) {
        currentDateTimeHandler.state = DomainErrorStates.success;
        currentDateTimeHandler.value = ntpResultHandler.value;
      } else {
        // Fallback to API if NTP fails or is out of sync
        final apiResultHandler = await networkInterface.getCurrentTimeByAPI();
        if (apiResultHandler.state == NetworkErrorState.success) {
          currentDateTimeHandler.state = DomainErrorStates.success;
          currentDateTimeHandler.value = apiResultHandler.value;
        } else if (apiResultHandler.state != NetworkErrorState.success) {
          currentDateTimeHandler.state = DomainErrorStates.checkYourNetwork;
        } else {
          currentDateTimeHandler.state =
              DomainErrorStates.yourDeviceClockNotSyncedWithNetwork;
        }
      }

      // Check openTime with current time
      if (currentDateTimeHandler.state == DomainErrorStates.success) {
        if (currentDateTimeHandler.value!.isAfter(
          delayedPassModel.openDateTime!,
        )) {
          return StateHandler(
            DomainErrorStates.success,
            delayedPassModel.pass!,
          );
        } else {
          return StateHandler(
            DomainErrorStates.pleaseWaitTheOpeningDateTime,
            delayedPassModel.openDateTime!.toString(),
          );
        }
      } else {
        return StateHandler(currentDateTimeHandler.state, null);
      }
    } catch (e) {
      // Catch any error during decryption or parsing
      return StateHandler(DomainErrorStates.failed, "Invalid hash format");
    }
  }

  // bool validateAPICurrentTimeIsSyncedWithLocal(DateTime datetime) {
  //   return true;
  //   final now = DateTime.now().subtract(DateTime.now().timeZoneOffset);
  //   return (datetime.difference(now)).inHours.abs() <= 1;
  // }
  //
  // bool validateNTPCurrentTimeIsSyncedWithLocal(DateTime datetime) {
  //   return true;
  //   final now = DateTime.now();
  //   return (datetime.difference(now)).inHours.abs() <= 1;
  // }
}
