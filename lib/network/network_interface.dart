import 'package:timelockpassword/network/network_impl.dart';
import 'package:timelockpassword/state_handler.dart';

abstract class NetworkInterface {
  static final NetworkInterface _networkInterface = NetworkImpl();

  static NetworkInterface impl() {
    return _networkInterface;
  }

  Future<StateHandler<NetworkErrorState, DateTime>> getCurrentTimeByNTP();

  Future<StateHandler<NetworkErrorState, DateTime?>> getCurrentTimeByAPI();
}
