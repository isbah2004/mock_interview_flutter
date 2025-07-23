
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract class NetworkService {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkService {
  final InternetConnection connectivityChecker;

  NetworkInfoImpl(this.connectivityChecker);

  @override
  Future<bool> get isConnected async => await connectivityChecker.hasInternetAccess;
}