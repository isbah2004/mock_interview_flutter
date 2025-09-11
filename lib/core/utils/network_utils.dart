import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtils {
  static final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      // Check if we have any connection first
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return false;
      }

      // Test actual internet connectivity with a quick lookup
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get current connectivity type
  static Future<ConnectivityResult> getConnectivityType() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      return connectivityResults.first;
    } catch (e) {
      return ConnectivityResult.none;
    }
  }

  /// Stream of connectivity changes
  static Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}
