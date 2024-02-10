// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:connectivity/connectivity.dart';

class Internet {
  static bool isOnline = false;

  static init() async {
    // Check at init  time
    var result = await Connectivity().checkConnectivity();
    check(result);

    // Add listener
    Connectivity().onConnectivityChanged.listen(check);
  }

  static check(ConnectivityResult result) async {
    if (result == ConnectivityResult.none)
      isOnline = false;
    else
      isOnline = true;
  }
}
