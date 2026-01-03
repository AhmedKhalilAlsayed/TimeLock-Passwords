import 'dart:convert';

import 'package:delay_pass/domain/domain_constants.dart';
import 'package:delay_pass/network/network_interface.dart';
import 'package:delay_pass/state_handler.dart';
import 'package:http/http.dart' as http;
import 'package:ntp/ntp.dart';

enum NetworkErrorState {
  success,
  checkYourNetworkPlease,
  networkErrorGetTimeAPI,
  networkErrorGetTimeNTP,
}

class NetworkImpl extends NetworkInterface {
  @override
  Future<StateHandler<NetworkErrorState, DateTime?>>
  getCurrentTimeByAPI() async {
    StateHandler<NetworkErrorState, DateTime?> currentTimeHandler =
        StateHandler(NetworkErrorState.networkErrorGetTimeAPI, null);

    await http
        .get(
          Uri.https(DomainConstants.rapidApiHost, "ip"),
          headers: {
            'x-rapidapi-key': DomainConstants.rapidApiKey,
            'x-rapidapi-host': DomainConstants.rapidApiHost,
          },
        )
        .then((v) {
          currentTimeHandler.state = NetworkErrorState.success;
          currentTimeHandler.value = DateTime.parse(
            jsonDecode(v.body)['datetime'],
          );
        })
        .catchError((e) {
          currentTimeHandler.state = NetworkErrorState.networkErrorGetTimeAPI;
        });

    return currentTimeHandler;
  }

  @override
  Future<StateHandler<NetworkErrorState, DateTime>>
  getCurrentTimeByNTP() async {
    StateHandler<NetworkErrorState, DateTime> currentDateTimeHandler = await NTP
        .now(timeout: Duration(seconds: 3))
        .then((value) async {
          return StateHandler(NetworkErrorState.success, value);
        })
        .onError((e, s) {
          return StateHandler(NetworkErrorState.networkErrorGetTimeNTP, null);
        });

    return currentDateTimeHandler;
  }
}
