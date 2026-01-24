import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:timelockpassword/domain/domain_constants.dart';
import 'package:timelockpassword/network/network_interface.dart';
import 'package:timelockpassword/state_handler.dart';
import 'package:http/http.dart' as http;
import 'package:ntp/ntp.dart';
import 'package:opentelemetry/web_sdk.dart' as web_sdk;
import 'package:http_parser/http_parser.dart';

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
        .now(timeout: Duration(seconds: 60))
        .then((value) async {
          return StateHandler(NetworkErrorState.success, value);
        })
        .onError((e, s) {
          return StateHandler(NetworkErrorState.networkErrorGetTimeNTP, null);
        });

    return currentDateTimeHandler;
  }

  @override
  Future<StateHandler<NetworkErrorState, DateTime?>>
  getCurrentTimeByPerfomanceAPI() async {
    StateHandler<NetworkErrorState, DateTime?> currentDateTimeHandler =
        StateHandler(NetworkErrorState.networkErrorGetTimeAPI, null);
    if (kIsWeb) {
      try {
        currentDateTimeHandler.value = DateTime.fromMicrosecondsSinceEpoch(
          (web_sdk.WebTimeProvider().now.toInt() / 1000).toInt(),
        );
        currentDateTimeHandler.state = NetworkErrorState.success;
      } catch (e) {
        currentDateTimeHandler.state = NetworkErrorState.networkErrorGetTimeAPI;
        currentDateTimeHandler.value = null;
      }
    }

    return currentDateTimeHandler;
  }

  @override
  Future<StateHandler<NetworkErrorState, DateTime?>>
  getCurrentTimeFromDeployHTTP() async {
    StateHandler<NetworkErrorState, DateTime?> currentDateTimeHandler =
        StateHandler(NetworkErrorState.networkErrorGetTimeAPI, null);

    try {
      // Use the current URL to fetch the Date header from the server.
      // This avoids CORS issues and relies on the hosting server's time.
      final uri = Uri.base.replace(
        queryParameters: {
          ...Uri.base.queryParameters,
          '__t': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );
      final response = await http.get(uri);
      print(response.headers);
      if (response.headers.containsKey('date')) {
        currentDateTimeHandler.value = parseHttpDate(response.headers['date']!);
        currentDateTimeHandler.state = NetworkErrorState.success;
      } else if (kDebugMode) {
        // Local development servers often don't send the Date header.
        // Fallback to local time for testing purposes only.
        currentDateTimeHandler.value = DateTime.now().toUtc();
        currentDateTimeHandler.state = NetworkErrorState.success;
      } else {
        currentDateTimeHandler.state = NetworkErrorState.checkYourNetworkPlease;
      }
    } catch (e) {
      currentDateTimeHandler.state = NetworkErrorState.networkErrorGetTimeAPI;
    }

    return currentDateTimeHandler;
  }
}
