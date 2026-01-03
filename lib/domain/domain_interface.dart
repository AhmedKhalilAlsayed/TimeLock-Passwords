import 'package:delay_pass/domain/domain_impl.dart';
import 'package:delay_pass/state_handler.dart';
import 'package:encrypt/encrypt.dart';

/// interface
abstract class DomainInterface {
  static final DomainInterface _domainInterface = DomainImpl();

  static DomainInterface impl() {
    return _domainInterface;
  }

  StateHandler<DomainErrorStates, String> generatePass({
    required bool isContainNumbers,
    required bool isContainSmallChars,
    required bool isContainCapitalChars,
    required bool isContainSigns,
    required int length,
  });

  StateHandler<DomainErrorStates, Encrypted> generateHashWithPassAndTime(
    String pass,
    DateTime openDateTime,
  );

  Future<StateHandler<DomainErrorStates, String>> getPassFromHash(
    Encrypted hash,
  );
}
