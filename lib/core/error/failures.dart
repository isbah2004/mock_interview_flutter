import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();

  @override
  List<Object> get props => [];
}

class AdFailure extends Failure {
  final String message;
  final int? code;

  const AdFailure({required this.message, this.code});

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'AdFailure(message: $message, code: $code)';
}

class AdNotLoadedFailure extends AdFailure {
  const AdNotLoadedFailure() : super(message: 'Ad is not loaded');
}

class AdLoadTimeoutFailure extends AdFailure {
  const AdLoadTimeoutFailure() : super(message: 'Ad load timeout');
}
