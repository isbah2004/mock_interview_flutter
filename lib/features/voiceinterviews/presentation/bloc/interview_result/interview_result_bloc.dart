import 'package:bloc/bloc.dart';
import 'package:mock_interview/features/voiceinterviews/domain/usecases/evaluate_voice_interview.dart';
import 'package:mock_interview/features/voiceinterviews/data/repositories/voice_interview_repository_impl.dart';
import 'package:mock_interview/features/voiceinterviews/data/datasources/voice_interview_remote_datasource.dart';
import 'package:mock_interview/core/services/network_service.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'interview_result_event.dart';
import 'interview_result_state.dart';

class InterviewResultBloc
    extends Bloc<InterviewResultEvent, InterviewResultState> {
  InterviewResultBloc() : super(InterviewResultInitial()) {
    on<StartEvaluation>(_onStartEvaluation);
    on<RetryEvaluation>(_onRetryEvaluation);
    on<StartScoreAnimation>(_onStartScoreAnimation);
  }

  Future<void> _onStartEvaluation(
    StartEvaluation event,
    Emitter<InterviewResultState> emit,
  ) async {
    await _performEvaluation(event.session, event.config, emit);
  }

  Future<void> _onRetryEvaluation(
    RetryEvaluation event,
    Emitter<InterviewResultState> emit,
  ) async {
    await _performEvaluation(event.session, event.config, emit);
  }

  void _onStartScoreAnimation(
    StartScoreAnimation event,
    Emitter<InterviewResultState> emit,
  ) {
    if (state is InterviewResultEvaluated) {
      final currentState = state as InterviewResultEvaluated;
      emit(currentState.copyWith(shouldAnimateScore: true));
    }
  }

  Future<void> _performEvaluation(
    dynamic session,
    dynamic config,
    Emitter<InterviewResultState> emit,
  ) async {
    emit(InterviewResultEvaluating());

    try {
      final networkService = NetworkInfoImpl(InternetConnection());
      final remoteDataSource = VoiceInterviewRemoteDataSourceImpl();
      final repository = VoiceInterviewRepositoryImpl(
        remoteDataSource: remoteDataSource,
        networkService: networkService,
      );
      final evaluateUseCase = EvaluateVoiceInterviewUseCase(repository);

      final result = await evaluateUseCase(
        EvaluateVoiceInterviewParams(session: session, config: config),
      );

      result.fold(
        (failure) => emit(InterviewResultError(failure.message)),
        (evaluationResult) =>
            emit(InterviewResultEvaluated(evaluationResult: evaluationResult)),
      );
    } catch (e) {
      emit(InterviewResultError('Failed to evaluate interview: $e'));
    }
  }
}
