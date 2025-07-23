import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../../domain/usecases/interview_usecases.dart';
import 'voice_interview_event.dart';
import 'voice_interview_state.dart';

class VoiceInterviewBloc
    extends Bloc<VoiceInterviewEvent, VoiceInterviewState> {
  final StartVoiceInterviewUseCase _startVoiceInterviewUseCase;
  final SubmitVoiceAnswerUseCase _submitVoiceAnswerUseCase;
  final EndVoiceInterviewUseCase _endVoiceInterviewUseCase;

  String? _currentSessionId;
  StreamSubscription? _questionStreamSubscription;

  VoiceInterviewBloc({
    required StartVoiceInterviewUseCase startVoiceInterviewUseCase,
    required SubmitVoiceAnswerUseCase submitVoiceAnswerUseCase,
    required EndVoiceInterviewUseCase endVoiceInterviewUseCase,
  }) : _startVoiceInterviewUseCase = startVoiceInterviewUseCase,
       _submitVoiceAnswerUseCase = submitVoiceAnswerUseCase,
       _endVoiceInterviewUseCase = endVoiceInterviewUseCase,
       super(VoiceInterviewInitial()) {
    on<StartVoiceInterviewEvent>(_onStartVoiceInterview);
    on<SubmitVoiceAnswerEvent>(_onSubmitVoiceAnswer);
    on<EndVoiceInterviewEvent>(_onEndVoiceInterview);
    on<StartRecordingEvent>(_onStartRecording);
    on<StopRecordingEvent>(_onStopRecording);
    on<ResetVoiceInterviewEvent>(_onResetVoiceInterview);
  }

  @override
  Future<void> close() {
    _questionStreamSubscription?.cancel();
    return super.close();
  }

  Future<void> _onStartVoiceInterview(
    StartVoiceInterviewEvent event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    emit(VoiceInterviewLoading());

    final params = StartVoiceInterviewParams(
      userId: event.userId,
      jobRole: event.jobRole,
      difficultyLevel: event.difficultyLevel,
      category: event.category,
    );

    final questionStream = _startVoiceInterviewUseCase.call(params);

    _questionStreamSubscription = questionStream.listen(
      (result) {
        result.fold((failure) => emit(VoiceInterviewError(failure.message)), (
          question,
        ) {
          // Generate session ID from question or timestamp
          _currentSessionId =
              'voice_session_${DateTime.now().millisecondsSinceEpoch}';

          emit(
            VoiceInterviewQuestionReceived(
              question: question,
              sessionId: _currentSessionId!,
            ),
          );

          // Automatically transition to started state for listening
          emit(
            VoiceInterviewStarted(
              currentQuestion: question,
              sessionId: _currentSessionId!,
              isListening: true,
              isRecording: false,
            ),
          );
        });
      },
      onError: (error) {
        emit(VoiceInterviewError('Stream error: $error'));
      },
    );
  }

  Future<void> _onSubmitVoiceAnswer(
    SubmitVoiceAnswerEvent event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    if (state is! VoiceInterviewStarted) return;

    final currentState = state as VoiceInterviewStarted;

    emit(
      VoiceInterviewAnswerSubmitting(
        currentQuestion: currentState.currentQuestion,
        sessionId: currentState.sessionId,
        answer: event.answer,
      ),
    );

    final params = SubmitVoiceAnswerParams(
      sessionId: event.sessionId,
      answer: event.answer,
      userId: event.userId,
      jobRole: event.jobRole,
    );

    final result = await _submitVoiceAnswerUseCase.call(params);

    result.fold((failure) => emit(VoiceInterviewError(failure.message)), (_) {
      // After submitting, wait for the next question from the stream
      // or transition back to listening state
      emit(
        VoiceInterviewStarted(
          currentQuestion: currentState.currentQuestion,
          sessionId: currentState.sessionId,
          isListening: true,
          isRecording: false,
        ),
      );
    });
  }

  Future<void> _onEndVoiceInterview(
    EndVoiceInterviewEvent event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    final result = await _endVoiceInterviewUseCase.call(event.sessionId);

    result.fold((failure) => emit(VoiceInterviewError(failure.message)), (_) {
      _questionStreamSubscription?.cancel();
      emit(
        VoiceInterviewCompleted(
          sessionId: event.sessionId,
          score: 85.0, // This should come from the actual result
          totalQuestions: 5, // This should come from the actual result
          feedback:
              'Interview completed successfully!', // This should come from the actual result
        ),
      );
    });
  }

  void _onStartRecording(
    StartRecordingEvent event,
    Emitter<VoiceInterviewState> emit,
  ) {
    if (state is VoiceInterviewStarted) {
      final currentState = state as VoiceInterviewStarted;
      emit(currentState.copyWith(isRecording: true));
    }
  }

  void _onStopRecording(
    StopRecordingEvent event,
    Emitter<VoiceInterviewState> emit,
  ) {
    if (state is VoiceInterviewStarted) {
      final currentState = state as VoiceInterviewStarted;
      emit(currentState.copyWith(isRecording: false));
    }
  }

  void _onResetVoiceInterview(
    ResetVoiceInterviewEvent event,
    Emitter<VoiceInterviewState> emit,
  ) {
    _questionStreamSubscription?.cancel();
    _currentSessionId = null;
    emit(VoiceInterviewInitial());
  }
}
