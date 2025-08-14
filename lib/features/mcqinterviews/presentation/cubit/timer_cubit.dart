import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/cubit/timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
  Timer? _timer;

  TimerCubit()
    : super(
        const TimerState(timeRemaining: 0, isRunning: false, isFinished: false),
      );

  void startTimer([int? duration]) {
    final timeInSeconds = duration ?? 1800; // Default 30 minutes

    if (state.isRunning) return;

    emit(
      TimerState(
        timeRemaining: timeInSeconds,
        isRunning: true,
        isFinished: false,
      ),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemaining > 0) {
        emit(state.copyWith(timeRemaining: state.timeRemaining - 1));
      } else {
        stopTimer();
        emit(state.copyWith(isFinished: true));
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    emit(state.copyWith(isRunning: false));
  }

  void stopTimer() {
    _timer?.cancel();
    emit(state.copyWith(isRunning: false));
  }

  void resetTimer() {
    _timer?.cancel();
    emit(
      const TimerState(timeRemaining: 0, isRunning: false, isFinished: false),
    );
  }

  String get formattedTime {
    final minutes = state.timeRemaining ~/ 60;
    final seconds = state.timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
