import 'package:connectivity/connectivity.dart';

class Network {
  static Future<bool> isInternetAvailable() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    }

    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    return false;
  }
}
