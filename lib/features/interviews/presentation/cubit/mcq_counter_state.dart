import 'package:equatable/equatable.dart';

class McqCounterState extends Equatable {
  final int seconds;
  final bool isRunning;

  const McqCounterState({required this.seconds, this.isRunning = false});

  McqCounterState copyWith({int? seconds, bool? isRunning}) {
    return McqCounterState(
      seconds: seconds ?? this.seconds,
      isRunning: isRunning ?? this.isRunning,
    );
  }

  @override
  List<Object?> get props => [seconds, isRunning];
}
