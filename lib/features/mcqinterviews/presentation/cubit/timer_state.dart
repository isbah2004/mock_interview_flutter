import 'package:equatable/equatable.dart';

class TimerState extends Equatable {
  final int timeRemaining;
  final bool isRunning;
  final bool isFinished;

  const TimerState({
    required this.timeRemaining,
    required this.isRunning,
    required this.isFinished,
  });

  @override
  List<Object> get props => [timeRemaining, isRunning, isFinished];

  TimerState copyWith({
    int? timeRemaining,
    bool? isRunning,
    bool? isFinished,
  }) {
    return TimerState(
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isRunning: isRunning ?? this.isRunning,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}