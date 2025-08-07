import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'mcq_counter_state.dart';

class McqCounterCubit extends Cubit<McqCounterState> {
  static const int maxSeconds = 30;
  Timer? _timer;

  McqCounterCubit() : super(const McqCounterState(seconds: 0));

  void start() {
    if (state.isRunning) return;
    emit(state.copyWith(isRunning: true));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.seconds < maxSeconds) {
        emit(state.copyWith(seconds: state.seconds + 1));
      } else {
        stop();
      }
    });
  }

  void stop() {
    _timer?.cancel();
    emit(state.copyWith(isRunning: false));
  }

  void reset() {
    _timer?.cancel();
    emit(const McqCounterState(seconds: 0, isRunning: false));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
