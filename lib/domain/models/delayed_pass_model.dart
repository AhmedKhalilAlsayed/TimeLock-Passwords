const String passKey = 'passKey';
const String openDateTimeKey = 'openDateTimeKey';

class DelayedPassModel {
  String? pass;
  DateTime? openDateTime;

  DelayedPassModel(this.pass, this.openDateTime);

  DelayedPassModel.fromMap(Map<String, dynamic> map) {
    pass = map[passKey];
    openDateTime = DateTime.parse(map[openDateTimeKey]);
  }

  Map<String, dynamic> toMap() {
    return {passKey: pass, openDateTimeKey: openDateTime!.toIso8601String()};
  }
}
