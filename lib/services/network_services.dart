import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  final Connectivity _connectivity = Connectivity();

  /// Checks if the device is connected to a network AND has actual internet reachability
  Future<bool> hasInternetConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();

    // Check if device is completely offline at network adapter level
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }

    // Verify actual internet reachability via DNS lookup
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
