import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/features/mcqinterviews/data/models/evaluation_result_model.dart';
import 'package:mock_interview/features/mcqinterviews/domain/usecases/complete_interview_usecase.dart';
import 'package:mock_interview/features/mcqinterviews/domain/usecases/start_interview_usecase.dart';
import 'package:mock_interview/features/mcqinterviews/domain/usecases/submit_answers_usecase.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/bloc/mcq/mcq_interview_event.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/bloc/mcq/mcq_interview_state.dart';

class McqInterviewBloc extends Bloc<McqInterviewEvent, McqInterviewState> {
  final StartInterviewUseCase _startInterviewUseCase;
  final SubmitAnswersUseCase _submitAnswersUseCase;
  final CompleteInterviewUseCase _completeInterviewUseCase;

  McqInterviewBloc({
    required StartInterviewUseCase startInterviewUseCase,
    required SubmitAnswersUseCase submitAnswersUseCase,
    required CompleteInterviewUseCase completeInterviewUseCase,
  }) : _startInterviewUseCase = startInterviewUseCase,
       _submitAnswersUseCase = submitAnswersUseCase,
       _completeInterviewUseCase = completeInterviewUseCase,
       super(InterviewInitial()) {
    on<StartInterviewEvent>(_onStartInterview);
    on<LoadQuestionsEvent>(_onLoadQuestions);
    on<SubmitAnswersEvent>(_onSubmitAnswers);
    on<CompleteInterviewEvent>(_onCompleteInterview);
  }

  Future<void> _onStartInterview(
    StartInterviewEvent event,
    Emitter<McqInterviewState> emit,
  ) async {
    try {
      emit(InterviewLoading());

      // if (_startInterviewUseCase != null) {
      final result = await _startInterviewUseCase(
        StartInterviewParams(
          userId: event.userId,
          jobRole: event.jobRole,
          difficultyLevel: event.difficultyLevel,
          numQuestions: event.numQuestions,
          category: event.category,
        ),
      );

      result.fold(
        (failure) => emit(InterviewError(failure.message)),
        (interviewSession) => emit(
          InterviewStarted(
            sessionId: interviewSession.sessionId,
            questions: interviewSession.questions ?? [],
          ),
        ),
      );
      // } else {
      //   // Fallback to mock implementation
      //   await Future.delayed(const Duration(seconds: 2));
      //   const sessionId = 'mock_session_123';
      //   final questions = _generateMockQuestions();

      //   emit(InterviewStarted(sessionId: sessionId, questions: questions));
      // }
    } catch (e) {
      emit(InterviewError('Failed to start interview: $e'));
    }
  }

  Future<void> _onLoadQuestions(
    LoadQuestionsEvent event,
    Emitter<McqInterviewState> emit,
  ) async {
    try {
      emit(InterviewLoading());

      // Mock implementation
      await Future.delayed(const Duration(seconds: 1));
      final questions = _generateMockQuestions();

      emit(
        InterviewInProgress(
          sessionId: event.sessionId,
          questions: questions,
          currentQuestionIndex: 0,
          answers: [],
        ),
      );
    } catch (e) {
      emit(InterviewError('Failed to load questions: $e'));
    }
  }

  Future<void> _onSubmitAnswers(
    SubmitAnswersEvent event,
    Emitter<McqInterviewState> emit,
  ) async {
    try {
      emit(InterviewLoading());

      // if (_submitAnswersUseCase != null) {
      final result = await _submitAnswersUseCase(
        SubmitAnswersParams(
          sessionId: event.sessionId,
          userId: event.userId,
          answers: event.answers,
          jobRole: event.jobRole,
          difficultyLevel: event.difficultyLevel,
          category: event.category,
        ),
      );

      result.fold(
        (failure) => emit(InterviewError(failure.message)),
        (evaluationResult) => emit(
          InterviewCompleted(
            evaluationResult: evaluationResult as EvaluationResultModel,
          ),
        ),
      );
      // } else {
      //   // Fallback to mock implementation
      //   await Future.delayed(const Duration(seconds: 2));

      //   final correctAnswers = (event.answers.length * 0.7).round();
      //   final percentage = (correctAnswers / event.answers.length) * 100;

      //   emit(
      //     InterviewCompleted(
      //       sessionId: event.sessionId,
      //       finalScore: correctAnswers.toDouble(),
      //       percentage: percentage,
      //       passed: percentage >= 60,
      //       totalQuestions: event.answers.length,
      //       correctAnswers: correctAnswers,
      //       results: _generateMockResults(event.answers.length),
      //     ),
      //   );
      // }
    } catch (e) {
      emit(InterviewError('Failed to submit answers: $e'));
    }
  }

  Future<void> _onCompleteInterview(
    CompleteInterviewEvent event,
    Emitter<McqInterviewState> emit,
  ) async {
    try {
      emit(InterviewLoading());

      // if (_completeInterviewUseCase != null) {
      final result = await _completeInterviewUseCase(
        CompleteInterviewParams(
          sessionId: event.sessionId,
          userId: event.userId,
          score: event.score,
          timeTaken: event.timeTaken,
          totalQuestions: event.totalQuestions,
          correctAnswers: event.correctAnswers,
        ),
      );

      result.fold((failure) => emit(InterviewError(failure.message)), (
        completionResult,
      ) {
        // Create mock EvaluationResultModel from completion result
        final percentage = (event.correctAnswers / event.totalQuestions) * 100;
        final mockEvaluationResult = EvaluationResultModel(
          sessionId: event.sessionId,
          totalQuestions: event.totalQuestions,
          results: _generateMockQuestionResults(event.totalQuestions),
          finalScore: event.score.toDouble(),
          percentage: percentage,
          passed: percentage >= 60,
          sessionComplete: true,
          completedAt: DateTime.now(),
        );

        emit(InterviewCompleted(evaluationResult: mockEvaluationResult));
      });
      // } else {
      //   // Fallback to mock implementation
      //   await Future.delayed(const Duration(seconds: 1));

      //   emit(
      //     InterviewCompleted(
      //       sessionId: event.sessionId,
      //       finalScore: event.score.toDouble(),
      //       percentage: (event.correctAnswers / event.totalQuestions) * 100,
      //       passed: (event.correctAnswers / event.totalQuestions) * 100 >= 60,
      //       totalQuestions: event.totalQuestions,
      //       correctAnswers: event.correctAnswers,
      //       results: _generateMockResults(event.totalQuestions),
      //     ),
      //   );
      // }
    } catch (e) {
      emit(InterviewError('Failed to complete interview: $e'));
    }
  }

  List<Map<String, dynamic>> _generateMockQuestions() {
    return [
      {
        'id': '1',
        'question': 'What is the primary purpose of Flutter?',
        'options': [
          'Web development only',
          'Cross-platform mobile development',
          'Backend development',
          'Database management',
        ],
        'correctAnswer': 1,
      },
      {
        'id': '2',
        'question':
            'Which programming language is used for Flutter development?',
        'options': ['Java', 'Kotlin', 'Dart', 'Swift'],
        'correctAnswer': 2,
      },
      {
        'id': '3',
        'question': 'What is a StatefulWidget in Flutter?',
        'options': [
          'A widget that never changes',
          'A widget that can change its state',
          'A widget for navigation',
          'A widget for styling',
        ],
        'correctAnswer': 1,
      },
      {
        'id': '4',
        'question': 'What is the purpose of pubspec.yaml file?',
        'options': [
          'Store user data',
          'Define app dependencies and metadata',
          'Handle navigation',
          'Manage state',
        ],
        'correctAnswer': 1,
      },
      {
        'id': '5',
        'question':
            'Which method is called when a StatefulWidget is first created?',
        'options': ['build()', 'initState()', 'dispose()', 'setState()'],
        'correctAnswer': 1,
      },
    ];
  }

  List<QuestionResultModel> _generateMockQuestionResults(int totalQuestions) {
    return List.generate(
      totalQuestions,
      (index) => QuestionResultModel(
        questionId: '${index + 1}',
        questionNumber: index + 1,
        question: 'Mock question ${index + 1}',
        userAnswer: 'Mock user answer ${index + 1}',
        correctAnswer: 'Mock correct answer ${index + 1}',
        isCorrect: index % 3 != 0, // Mock: 2/3 correct
        score: index % 3 != 0 ? 100 : 0,
        explanation: 'Mock explanation for question ${index + 1}',
        topic: 'Mock Topic',
        difficulty: 'easy',
      ),
    );
  }
}
