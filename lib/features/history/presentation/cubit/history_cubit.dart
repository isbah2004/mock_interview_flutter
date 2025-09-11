import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/models/unified_interview_session.dart';
import 'package:mock_interview/features/history/domain/usecases/get_history_usecase.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final GetHistoryUseCase _getHistoryUseCase;
  HistoryCubit({required GetHistoryUseCase getHistoryUseCase})
    : _getHistoryUseCase = getHistoryUseCase,
      super(HistoryInitial());

  Future<void> load(String userId, {int limit = 50}) async {
    if (isClosed) return;
    emit(HistoryLoading());
    final result = await _getHistoryUseCase(
      GetHistoryParams(userId: userId, limit: limit),
    );
    if (isClosed) return;
    result.fold(
      (f) => emit(HistoryError(_mapFailure(f))),
      (sessions) => emit(HistoryLoaded(sessions)),
    );
  }

  Future<void> refresh(String userId, {int limit = 50}) async {
    if (isClosed) return;
    final result = await _getHistoryUseCase(
      GetHistoryParams(userId: userId, limit: limit),
    );
    if (isClosed) return;
    result.fold(
      (f) => emit(HistoryError(_mapFailure(f))),
      (sessions) => emit(HistoryLoaded(sessions)),
    );
  }

  String _mapFailure(Failure f) {
    if (f is NetworkFailure) return 'No internet connection.';
    if (f is ServerFailure) return f.message;
    return 'Unexpected error.';
  }
}
