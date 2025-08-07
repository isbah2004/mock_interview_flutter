// lib/features/interview/presentation/bloc/interview_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/features/interviews/domain/usecases/start_interview.dart';
import 'package:mock_interview/features/interviews/domain/usecases/submit_answers.dart';
import 'package:mock_interview/features/interviews/presentation/bloc/mcq/mcq_interview_event.dart';
import 'package:mock_interview/features/interviews/presentation/bloc/mcq/mcq_interview_state.dart';

class InterviewBloc extends Bloc<InterviewEvent, InterviewState> {
  final StartInterview startInterviewUseCase;
  final SubmitAnswers submitAnswersUseCase;

  InterviewBloc({
    required this.startInterviewUseCase,
    required this.submitAnswersUseCase,
  }) : super(InterviewInitial()) {
    on<StartInterviewEvent>(_onStartInterview);
    on<SelectAnswerEvent>(_onSelectAnswer);
    on<NextQuestionEvent>(_onNextQuestion);
    on<PreviousQuestionEvent>(_onPreviousQuestion);
    on<GoToQuestionEvent>(_onGoToQuestion);
    on<SubmitInterviewEvent>(_onSubmitInterview);
    on<ResetInterviewEvent>(_onResetInterview);
  }

  Future<void> _onStartInterview(
    StartInterviewEvent event,
    Emitter<InterviewState> emit,
  ) async {
    emit(InterviewLoading());

    final result = await startInterviewUseCase(StartInterviewParams(
      userId: event.userId,
      jobRole: event.jobRole,
      difficultyLevel: event.difficultyLevel,
      numQuestions: event.numQuestions,
      category: event.category,
    ));

    result.fold(
      (failure) => emit(InterviewError(message: _mapFailureToMessage(failure))),
      (interview) => emit(InterviewStarted(
        interview: interview,
        userAnswers: List.filled(interview.questions.length, ''),
        currentQuestionIndex: 0,
      )),
    );
  }

  void _onSelectAnswer(
    SelectAnswerEvent event,
    Emitter<InterviewState> emit,
  ) {
    if (state is InterviewStarted) {
      final currentState = state as InterviewStarted;
      final updatedAnswers = List<String>.from(currentState.userAnswers);
      updatedAnswers[event.questionIndex] = event.answer;

      emit(currentState.copyWith(userAnswers: updatedAnswers));
    }
  }

  void _onNextQuestion(
    NextQuestionEvent event,
    Emitter<InterviewState> emit,
  ) {
    if (state is InterviewStarted) {
      final currentState = state as InterviewStarted;
      if (currentState.currentQuestionIndex < currentState.interview.questions.length - 1) {
        emit(currentState.copyWith(
          currentQuestionIndex: currentState.currentQuestionIndex + 1,
        ));
      }
    }
  }

  void _onPreviousQuestion(
    PreviousQuestionEvent event,
    Emitter<InterviewState> emit,
  ) {
    if (state is InterviewStarted) {
      final currentState = state as InterviewStarted;
      if (currentState.currentQuestionIndex > 0) {
        emit(currentState.copyWith(
          currentQuestionIndex: currentState.currentQuestionIndex - 1,
        ));
      }
    }
  }

  void _onGoToQuestion(
    GoToQuestionEvent event,
    Emitter<InterviewState> emit,
  ) {
    if (state is InterviewStarted) {
      final currentState = state as InterviewStarted;
      if (event.questionIndex >= 0 &&
          event.questionIndex < currentState.interview.questions.length) {
        emit(currentState.copyWith(currentQuestionIndex: event.questionIndex));
      }
    }
  }

  Future<void> _onSubmitInterview(
    SubmitInterviewEvent event,
    Emitter<InterviewState> emit,
  ) async {
    emit(InterviewLoading());

    final result = await submitAnswersUseCase(SubmitAnswersParams(
      sessionId: event.sessionId,
      userId: event.userId,
      answers: event.answers,
    ));

    result.fold(
      (failure) => emit(InterviewError(message: _mapFailureToMessage(failure))),
      (evaluationResult) => emit(InterviewCompleted(evaluationResult: evaluationResult)),
    );
  }

  void _onResetInterview(
    ResetInterviewEvent event,
    Emitter<InterviewState> emit,
  ) {
    emit(InterviewInitial());
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'No internet connection. Please check your network.';
    } else if (failure is CacheFailure) {
      return 'Cache error occurred.';
    } else {
      return 'An unexpected error occurred.';
    }
  }
}