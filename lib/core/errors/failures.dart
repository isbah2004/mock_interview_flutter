import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class InvalidInputFailure extends Failure {
  const InvalidInputFailure(super.message);
}

// Ad-specific failures (moved here to consolidate failures)
class AdFailure extends Failure {
  final int? code;

  const AdFailure({required String message, this.code}) : super(message);

  @override
  List<Object> get props => [message, code ?? -1];

  @override
  String toString() => 'AdFailure(message: $message, code: $code)';
}

class AdNotLoadedFailure extends AdFailure {
  const AdNotLoadedFailure() : super(message: 'Ad is not loaded');
}

class AdLoadTimeoutFailure extends AdFailure {
  const AdLoadTimeoutFailure() : super(message: 'Ad load timeout');
}
