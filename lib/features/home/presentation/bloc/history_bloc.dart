import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/session.dart';
import '../../domain/usecases/get_user_sessions.dart';
import '../../../../core/errors/failures.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetUserSessions _getUserSessions;

  HistoryBloc({required GetUserSessions getUserSessions})
    : _getUserSessions = getUserSessions,
      super(HistoryInitial()) {
    on<LoadUserSessions>(_onLoadUserSessions);
    on<RefreshUserSessions>(_onRefreshUserSessions);
  }

  Future<void> _onLoadUserSessions(
    LoadUserSessions event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());

    final result = await _getUserSessions(event.userId);

    result.fold(
      (failure) => emit(HistoryError(message: _mapFailureToMessage(failure))),
      (sessions) => emit(HistoryLoaded(sessions: sessions)),
    );
  }

  Future<void> _onRefreshUserSessions(
    RefreshUserSessions event,
    Emitter<HistoryState> emit,
  ) async {
    // Don't show loading state for refresh, just update data
    final result = await _getUserSessions(event.userId);

    result.fold(
      (failure) => emit(HistoryError(message: _mapFailureToMessage(failure))),
      (sessions) => emit(HistoryLoaded(sessions: sessions)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Failed to load interview history. Please try again.';
      case NetworkFailure:
        return 'No internet connection. Please check your network.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
