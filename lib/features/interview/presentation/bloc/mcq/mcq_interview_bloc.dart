import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../../domain/usecases/interview_usecases.dart';
import 'mcq_interview_event.dart';
import 'mcq_interview_state.dart';

class McqInterviewBloc extends Bloc<McqInterviewEvent, McqInterviewState> {
  final StartMcqInterviewUseCase _startMcqInterviewUseCase;
  final SubmitMcqAnswerUseCase _submitMcqAnswerUseCase;

  String? _currentSessionId;
  int _currentQuestionIndex = 0;
  int _totalQuestions = 0;
  int _correctAnswers = 0;

  McqInterviewBloc({
    required StartMcqInterviewUseCase startMcqInterviewUseCase,
    required SubmitMcqAnswerUseCase submitMcqAnswerUseCase,
  }) : _startMcqInterviewUseCase = startMcqInterviewUseCase,
       _submitMcqAnswerUseCase = submitMcqAnswerUseCase,
       super(McqInterviewInitial()) {
    on<StartMcqInterviewEvent>(_onStartMcqInterview);
    on<SubmitMcqAnswerEvent>(_onSubmitMcqAnswer);
    on<ProceedToNextQuestionEvent>(_onProceedToNextQuestion);
    on<CompleteInterviewEvent>(_onCompleteInterview);
    on<ResetInterviewEvent>(_onResetInterview);
  }

  Future<void> _onStartMcqInterview(
    StartMcqInterviewEvent event,
    Emitter<McqInterviewState> emit,
  ) async {
    emit(McqInterviewLoading());

    final params = StartMcqInterviewParams(
      userId: event.userId,
      jobRole: event.jobRole,
      difficultyLevel: event.difficultyLevel,
      category: event.category,
      numQuestions: event.numQuestions,
    );

    final result = await _startMcqInterviewUseCase.call(params);

    result.fold((failure) => emit(McqInterviewError(failure.message)), (
      question,
    ) {
      // Generate a session ID if not provided by the question
      _currentSessionId =
         
          'session_${DateTime.now().millisecondsSinceEpoch}';
      _currentQuestionIndex = 0;
      _totalQuestions = event.numQuestions;
      _correctAnswers = 0;

      emit(
        McqInterviewStarted(
          currentQuestion: question,
          sessionId: _currentSessionId!,
          currentQuestionIndex: _currentQuestionIndex,
          totalQuestions: _totalQuestions,
          correctAnswers: _correctAnswers,
        ),
      );
    });
  }

  Future<void> _onSubmitMcqAnswer(
    SubmitMcqAnswerEvent event,
    Emitter<McqInterviewState> emit,
  ) async {
    if (state is! McqInterviewStarted) return;

    final currentState = state as McqInterviewStarted;

    emit(
      McqInterviewAnswerSubmitting(
        currentQuestion: currentState.currentQuestion,
        sessionId: currentState.sessionId,
        currentQuestionIndex: currentState.currentQuestionIndex,
        totalQuestions: currentState.totalQuestions,
        correctAnswers: currentState.correctAnswers,
      ),
    );

    final params = SubmitMcqAnswerParams(
      sessionId: event.sessionId,
      answer: event.answer,
      userId: event.userId,
      jobRole: event.jobRole,
    );

    final result = await _submitMcqAnswerUseCase.call(params);

    result.fold((failure) => emit(McqInterviewError(failure.message)), (
      nextQuestion,
    ) {
      // Determine if the answer was correct based on score or feedback
      final score = nextQuestion.score ?? 0.0;
      final isCorrect = score > 50.0; // Assume >50% means correct
      final feedback =
          nextQuestion.feedback ??
          (isCorrect ? 'Correct answer!' : 'Incorrect answer.');

      if (isCorrect) {
        _correctAnswers++;
      }

      final isLastQuestion = _currentQuestionIndex + 1 >= _totalQuestions;

      emit(
        McqInterviewFeedback(
          currentQuestion: currentState.currentQuestion,
          nextQuestion: isLastQuestion ? null : nextQuestion,
          sessionId: currentState.sessionId,
          currentQuestionIndex: _currentQuestionIndex,
          totalQuestions: _totalQuestions,
          correctAnswers: _correctAnswers,
          feedback: feedback,
          score: score,
          isCorrect: isCorrect,
          isLastQuestion: isLastQuestion,
        ),
      );
    });
  }

  void _onProceedToNextQuestion(
    ProceedToNextQuestionEvent event,
    Emitter<McqInterviewState> emit,
  ) {
    if (state is! McqInterviewFeedback) return;

    final currentState = state as McqInterviewFeedback;

    if (currentState.isLastQuestion || currentState.nextQuestion == null) {
      add(const CompleteInterviewEvent());
      return;
    }

    _currentQuestionIndex++;

    emit(
      McqInterviewStarted(
        currentQuestion: currentState.nextQuestion!,
        sessionId: currentState.sessionId,
        currentQuestionIndex: _currentQuestionIndex,
        totalQuestions: _totalQuestions,
        correctAnswers: _correctAnswers,
      ),
    );
  }

  void _onCompleteInterview(
    CompleteInterviewEvent event,
    Emitter<McqInterviewState> emit,
  ) {
    if (state is! McqInterviewFeedback) return;

    final currentState = state as McqInterviewFeedback;
    final finalScore = (_correctAnswers / _totalQuestions * 100);

    emit(
      McqInterviewCompleted(
        sessionId: currentState.sessionId,
        totalQuestions: _totalQuestions,
        correctAnswers: _correctAnswers,
        finalScore: finalScore,
      ),
    );
  }

  void _onResetInterview(
    ResetInterviewEvent event,
    Emitter<McqInterviewState> emit,
  ) {
    _currentSessionId = null;
    _currentQuestionIndex = 0;
    _totalQuestions = 0;
    _correctAnswers = 0;
    emit(McqInterviewInitial());
  }
}
