import 'package:bloc/bloc.dart';
import '../../../../core/services/gemini_ai_service/gemini_ai_service.dart';
import '../../../../core/services/unified_database_service.dart';
import '../../../../core/services/user_stats_service.dart';
import '../../../../core/models/mcq_question_model.dart';
import '../../../../core/models/unified_interview_session.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/cubits/usercubit/user_cubit.dart';
import 'unified_mcq_interview_event.dart';
import 'unified_mcq_interview_state.dart';

class McqInterviewBloc
    extends Bloc<UnifiedMcqInterviewEvent, UnifiedMcqInterviewState> {
  final GeminiAiService _geminiAIService;
  final UnifiedDatabaseService _databaseService;
  final UserStatsService _userStatsService;
  final UserCubit _userCubit;

  String? _currentSessionId; // Track current session

  McqInterviewBloc({
    required GeminiAiService geminiAIService,
    required UnifiedDatabaseService databaseService,
    required UserStatsService userStatsService,
    required UserCubit userCubit,
  }) : _geminiAIService = geminiAIService,
       _databaseService = databaseService,
       _userStatsService = userStatsService,
       _userCubit = userCubit,
       super(const McqInterviewInitial()) {
    // Setup Event Handlers
    on<InitializeMcqInterview>(_onInitializeMcqInterview);
    on<StartJobTitleInput>(_onStartJobTitleInput);
    on<UpdateJobTitle>(_onUpdateJobTitle);
    on<GenerateMcqQuestions>(_onGenerateMcqQuestions);
    on<RetryGeneration>(_onRetryGeneration);

    // Interview Event Handlers
    on<StartMcqInterview>(_onStartMcqInterview);
    on<LoadQuestions>(_onLoadQuestions);

    // Navigation Event Handlers
    on<SelectOption>(_onSelectOption);
    on<NavigateToNext>(_onNavigateToNext);
    on<NavigateToPrevious>(_onNavigateToPrevious);
    on<UpdateAnswer>(_onUpdateAnswer);
    on<ClearSelection>(_onClearSelection);

    // Completion Event Handlers
    on<SubmitAnswers>(_onSubmitAnswers);
    on<CompleteInterview>(_onCompleteInterview);
    on<SaveInterviewResult>(_onSaveInterviewResult);

    // Reset Event Handlers
    on<ResetInterview>(_onResetInterview);
  }

  // Setup Event Handlers
  void _onInitializeMcqInterview(
    InitializeMcqInterview event,
    Emitter<UnifiedMcqInterviewState> emit,
  ) {
    emit(const McqInterviewInitial());
  }

  void _onStartJobTitleInput(
    StartJobTitleInput event,
    Emitter<UnifiedMcqInterviewState> emit,
  ) {
    emit(const JobTitleInputState());
  }

  void _onUpdateJobTitle(
    UpdateJobTitle event,
    Emitter<UnifiedMcqInterviewState> emit,
  ) {
    final isValid = event.jobTitle.trim().length >= 3;
    emit(JobTitleInputState(jobTitle: event.jobTitle, isValid: isValid));
  }

  Future<void> _onGenerateMcqQuestions(
    GenerateMcqQuestions event,
    Emitter<UnifiedMcqInterviewState> emit,
  ) async {
    try {
      emit(GeneratingQuestionsState(event.jobTitle));

      final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      _currentSessionId = sessionId; // Store for later use

      // Create UnifiedInterviewSession first
      final userId = _userCubit.currentUser?.id ?? 'anonymous_user';
      final session = UnifiedInterviewSession(
        sessionId: sessionId,
        userId: userId,
        jobRole: event.jobTitle,
        interviewType: 'mcq',
        difficulty: event.difficulty.toLowerCase(),
        category: event.category.toLowerCase(),
        totalQuestions: event.questionCount,
        timePerQuestion: 60,
        isCompleted: false,
        startedAt: DateTime.now(),
      );

      await _databaseService.createInterviewSession(session);

      final questions = await _geminiAIService.generateMcqQuestions(
        sessionId: sessionId,
        category: event.category.toLowerCase(),
        difficulty: event.difficulty.toLowerCase(),
        count: event.questionCount,
        jobRole: event.jobTitle,
      );

      if (questions.isNotEmpty) {
        // Store questions in database
        await _databaseService.storeMcqQuestions(questions);

        emit(
          QuestionsGeneratedState(
            jobTitle: event.jobTitle,
            questions: questions,
          ),
        );
      } else {
        emit(
          QuestionGenerationFailedState(
            jobTitle: event.jobTitle,
            error: 'No questions generated. Please try again.',
          ),
        );
      }
    } catch (e) {
      emit(
        QuestionGenerationFailedState(
          jobTitle: event.jobTitle,
          error: 'Failed to generate questions: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onRetryGeneration(
    RetryGeneration event,
    Emitter<UnifiedMcqInterviewState> emit,
  ) async {
    add(
      GenerateMcqQuestions(
        event.jobTitle,
        difficulty: event.difficulty,
        category: event.category,
        questionCount: event.questionCount,
      ),
    );
  }

  // Interview Event Handlers
  void _onStartMcqInterview(
    StartMcqInterview event,
    Emitter<UnifiedMcqInterviewState> emit,
  ) {
    if (event.questions.isNotEmpty) {
      final answers = List<String>.filled(event.questions.length, '');
      emit(
        McqInterviewInProgressState(
          jobTitle: event.questions.first.jobRole,
          questions: event.questions,
          currentQuestionIndex: 0,
          answers: answers,
          selectedOption: null,
          canNavigateNext: false,
          canNavigatePrevious: false,
          isLastQuestion: event.questions.length == 1,
        ),
      );
    }
  }

  void _onLoadQuestions(
    LoadQuestions event,
    Emitter<UnifiedMcqInterviewState> emit,
  ) {
    if (event.questions.isNotEmpty) {
      final answers = List<String>.filled(event.questions.length, '');
      emit(
        McqInterviewInProgressState(
          jobTitle: event.questions.first.jobRole,
          questions: event.questions,
          currentQuestionIndex: 0,
          answers: answers,
          selectedOption: null,
          canNavigateNext: false,
          canNavigatePrevious: false,
          isLastQuestion: event.questions.length == 1,
        ),
      );
    }
  }

  // Navigation Event Handlers
  void _onSelectOption(
    SelectOption event,
    Emitter<UnifiedMcqInterviewState> emit,
  ) {
    if (state is McqInterviewInProgressState) {
      final currentState = state as McqInterviewInProgressState;
      emit(
        currentState.copyWith(
          selectedOption: event.selectedOption,
          canNavigateNext: true,
        ),
      );
    }
  }

  void _onNavigateToNext(
    NavigateToNext event,
    Emitter<UnifiedMcqInterviewState> emit,
  ) {
    if (state is McqInterviewInProgressState) {
      final currentState = state as McqInterviewInProgressState;

      if (currentState.selectedOption != null &&
          currentState.currentQuestionIndex <
              currentState.questions.length - 1) {
        // Update current answer
        final updatedAnswers = List<String>.from(currentState.answers);
        updatedAnswers[currentState.currentQuestionIndex] =
            currentState.selectedOption!;

        final newIndex = currentState.currentQuestionIndex + 1;
        final nextAnswer = updatedAnswers[newIndex];
        final isLastQuestion = newIndex == currentState.questions.length - 1;

        emit(
          currentState.copyWith(
            currentQuestionIndex: newIndex,
            answers: updatedAnswers,
            selectedOption: nextAnswer.isNotEmpty ? nextAnswer : null,
            canNavigateNext: nextAnswer.isNotEmpty,
            canNavigatePrevious: true,
            isLastQuestion: isLastQuestion,
          ),
        );
      }
    }
  }

  void _onNavigateToPrevious(
    NavigateToPrevious event,
    Emitter<UnifiedMcqInterviewState> emit,
  ) {
    if (state is McqInterviewInProgressState) {
      final currentState = state as McqInterviewInProgressState;

      if (currentState.currentQuestionIndex > 0) {
        final newIndex = currentState.currentQuestionIndex - 1;
        final previousAnswer = currentState.answers[newIndex];

        emit(
          currentState.copyWith(
            currentQuestionIndex: newIndex,
            selectedOption: previousAnswer.isNotEmpty ? previousAnswer : null,
            canNavigateNext: previousAnswer.isNotEmpty,
            canNavigatePrevious: newIndex > 0,
            isLastQuestion: false,
          ),
        );
      }
    }
  }

  void _onUpdateAnswer(
    UpdateAnswer event,
    Emitter<UnifiedMcqInterviewState> emit,
  ) {
    if (state is McqInterviewInProgressState) {
      final currentState = state as McqInterviewInProgressState;
      final updatedAnswers = List<String>.from(currentState.answers);
      updatedAnswers[event.questionIndex] = event.answer;

      emit(currentState.copyWith(answers: updatedAnswers));
    }
  }

  void _onClearSelection(
    ClearSelection event,
    Emitter<UnifiedMcqInterviewState> emit,
  ) {
    if (state is McqInterviewInProgressState) {
      final currentState = state as McqInterviewInProgressState;
      emit(currentState.copyWith(clearSelection: true, canNavigateNext: false));
    }
  }

  // Completion Event Handlers
  Future<void> _onSubmitAnswers(
    SubmitAnswers event,
    Emitter<UnifiedMcqInterviewState> emit,
  ) async {
    if (state is McqInterviewInProgressState) {
      final currentState = state as McqInterviewInProgressState;

      // Update final answer if there's a selection
      final finalAnswers = List<String>.from(event.answers);
      if (currentState.selectedOption != null) {
        finalAnswers[currentState.currentQuestionIndex] =
            currentState.selectedOption!;
      }

      // Calculate score with enhanced details
      int correctCount = 0;
      final List<Map<String, dynamic>> questionResults = [];

      for (int i = 0; i < currentState.questions.length; i++) {
        final question = currentState.questions[i];
        final userAnswer = i < finalAnswers.length ? finalAnswers[i] : '';
        final isCorrect = userAnswer == question.correctAnswer;

        if (isCorrect) {
          correctCount++;
        }

        questionResults.add({
          'questionId': question.questionId,
          'question': question.question,
          'userAnswer': userAnswer,
          'correctAnswer': question.correctAnswer,
          'isCorrect': isCorrect,
          'topic': question.topic,
          'difficulty': question.difficulty,
          'explanation': question.explanation,
        });
      }

      final score = (correctCount / currentState.questions.length) * 100;
      final percentage = score;
      final passed = score >= 60.0;

      AppLogger.info('======= MCQ INTERVIEW COMPLETION STARTED =======');
      AppLogger.info('Session ID: $_currentSessionId');
      AppLogger.info('Job Title: ${currentState.jobTitle}');
      AppLogger.info(
        'Score: $correctCount / ${currentState.questions.length} = $score%',
      );
      AppLogger.info('Passed: $passed');
      AppLogger.info('Current User: ${_userCubit.currentUser?.id ?? "NULL"}');

      // Emit saving state first to show loading indicator
      emit(
        SavingInterviewResultState(
          jobTitle: currentState.jobTitle,
          questions: currentState.questions,
          answers: finalAnswers,
          score: score,
        ),
      );

      // Update session completion in database and user stats
      if (_currentSessionId != null) {
        final userId = _userCubit.currentUser?.id ?? 'anonymous_user';

        final updatedSession = UnifiedInterviewSession(
          sessionId: _currentSessionId!,
          userId: userId,
          jobRole: currentState.jobTitle,
          interviewType: 'mcq',
          difficulty: 'medium',
          category: 'general',
          totalQuestions: currentState.questions.length,
          timePerQuestion: 60,
          isCompleted: true,
          passed: passed,
          score: score,
          percentage: percentage,
          startedAt: DateTime.now().subtract(
            const Duration(minutes: 10),
          ), // Estimate
          completedAt: DateTime.now(),
          duration: 600, // 10 minutes estimate
        );

        try {
          await _databaseService.updateInterviewSession(updatedSession);
          AppLogger.info('MCQ: Session updated in database successfully');

          // Save individual question answers to database
          AppLogger.info('MCQ: Saving individual question answers to database');

          for (int i = 0; i < currentState.questions.length; i++) {
            final question = currentState.questions[i];
            final userAnswer = i < finalAnswers.length ? finalAnswers[i] : '';
            final isCorrect = userAnswer == question.correctAnswer;
            final questionScore = isCorrect ? 1.0 : 0.0;

            try {
              await _databaseService.updateMcqQuestionAnswer(
                question.questionId,
                userAnswer,
                isCorrect,
                questionScore,
              );
              AppLogger.info(
                'MCQ: Updated question ${i + 1} answer in database',
              );
            } catch (e) {
              AppLogger.error(
                'MCQ: Failed to update question ${i + 1} answer: $e',
              );
            }
          }
          AppLogger.info('MCQ: All question answers saved to database');

          // Enhanced MCQ evaluation is now handled by the modular AI service
          AppLogger.info('MCQ: Evaluation completed with score: $score%');

          // Update user statistics
          final currentUser = _userCubit.currentUser;
          if (currentUser != null) {
            try {
              AppLogger.debug(
                'MCQ: About to update user stats for user: ${currentUser.id}',
              );

              final updatedUser = await _userStatsService
                  .updateUserStatsAfterInterview(
                    currentUser: currentUser,
                    completedSession: updatedSession,
                  );
              _userCubit.updateUser(updatedUser);

              AppLogger.info('MCQ: User stats updated successfully');
            } catch (e) {
              AppLogger.error('Failed to update user stats: $e');
            }
          } else {
            AppLogger.warn('MCQ: No current user found, cannot update stats');
          }
        } catch (e) {
          AppLogger.error('MCQ: Failed to update session in database: $e');
        }
      } else {
        AppLogger.warn('MCQ: No session ID found, cannot update database');
      }

      emit(
        McqInterviewCompletedState(
          jobTitle: currentState.jobTitle,
          questions: currentState.questions,
          answers: finalAnswers,
          score: score,
          correctAnswers: correctCount,
          totalQuestions: currentState.questions.length,
        ),
      );
    }
  }

  void _onCompleteInterview(
    CompleteInterview event,
    Emitter<UnifiedMcqInterviewState> emit,
  ) {
    if (state is McqInterviewInProgressState) {
      final currentState = state as McqInterviewInProgressState;

      // Get current answers including the selected option
      final finalAnswers = List<String>.from(currentState.answers);
      if (currentState.selectedOption != null) {
        finalAnswers[currentState.currentQuestionIndex] =
            currentState.selectedOption!;
      }

      add(SubmitAnswers(finalAnswers));
    }
  }

  Future<void> _onSaveInterviewResult(
    SaveInterviewResult event,
    Emitter<UnifiedMcqInterviewState> emit,
  ) async {
    AppLogger.info('======= MCQ INTERVIEW COMPLETION STARTED =======');
    AppLogger.info('Event: ${event.runtimeType}');
    AppLogger.info('JobTitle: ${event.jobTitle}');
    AppLogger.info('Score: ${event.score} / ${event.questions.length}');
    AppLogger.info('Current Session ID: $_currentSessionId');
    AppLogger.info('Current User: ${_userCubit.currentUser?.id ?? "NULL"}');

    try {
      emit(
        SavingInterviewResultState(
          jobTitle: event.jobTitle,
          questions: event.questions,
          answers: event.answers,
          score: event.score,
        ),
      );

      // Update session completion in database
      if (_currentSessionId != null) {
        final userId = _userCubit.currentUser?.id ?? 'anonymous_user';
        final percentage = (event.score / event.questions.length) * 100;

        final updatedSession = UnifiedInterviewSession(
          sessionId: _currentSessionId!,
          userId: userId,
          jobRole: event.jobTitle,
          interviewType: 'mcq',
          difficulty: 'medium',
          category: 'general',
          totalQuestions: event.questions.length,
          timePerQuestion: 60,
          isCompleted: true,
          passed: percentage >= 60.0,
          score: percentage, // Use percentage as score (0-100)
          percentage: percentage,
          startedAt: DateTime.now().subtract(
            const Duration(minutes: 10),
          ), // Estimate
          completedAt: DateTime.now(),
          duration: 600, // 10 minutes estimate
        );

        await _databaseService.updateInterviewSession(updatedSession);

        // Update user statistics
        final currentUser = _userCubit.currentUser;
        if (currentUser != null) {
          try {
            AppLogger.info(
              'MCQ: About to update user stats for user: ${currentUser.id}',
            );
            AppLogger.info(
              'MCQ: Current stats - total: ${currentUser.totalInterviews}, mcq: ${currentUser.mcqInterviews}, avg: ${currentUser.averageScore}',
            );
            AppLogger.info(
              'MCQ: Completed session score: ${updatedSession.score}, type: ${updatedSession.interviewType}',
            );

            final updatedUser = await _userStatsService
                .updateUserStatsAfterInterview(
                  currentUser: currentUser,
                  completedSession: updatedSession,
                );
            _userCubit.updateUser(updatedUser);

            AppLogger.info('MCQ: User stats updated successfully');
            AppLogger.info(
              'MCQ: New stats - total: ${updatedUser.totalInterviews}, mcq: ${updatedUser.mcqInterviews}, avg: ${updatedUser.averageScore}',
            );
          } catch (e) {
            // Log error but don't fail the interview completion
            AppLogger.error('Failed to update user stats: $e');
          }
        } else {
          AppLogger.warn('MCQ: No current user found, cannot update stats');
        }
      }

      final interviewId = await _databaseService.saveMcqInterview(
        jobTitle: event.jobTitle,
        questions: event.questions,
        answers: event.answers,
        score: event.score,
      );

      emit(
        InterviewResultSavedState(interviewId: interviewId, score: event.score),
      );
    } catch (e) {
      emit(
        InterviewSaveFailedState(
          error: 'Failed to save interview: ${e.toString()}',
          jobTitle: event.jobTitle,
          questions: event.questions,
          answers: event.answers,
          score: event.score,
        ),
      );
    }
  }

  // Reset Event Handlers
  void _onResetInterview(
    ResetInterview event,
    Emitter<UnifiedMcqInterviewState> emit,
  ) {
    emit(const McqInterviewInitial());
  }

  // Helper getters
  bool get isLastQuestion {
    if (state is McqInterviewInProgressState) {
      final currentState = state as McqInterviewInProgressState;
      return currentState.currentQuestionIndex ==
          currentState.questions.length - 1;
    }
    return false;
  }

  List<String> get currentAnswers {
    if (state is McqInterviewInProgressState) {
      final currentState = state as McqInterviewInProgressState;
      // Update current answer if there's a selection
      if (currentState.selectedOption != null) {
        final updatedAnswers = List<String>.from(currentState.answers);
        updatedAnswers[currentState.currentQuestionIndex] =
            currentState.selectedOption!;
        return updatedAnswers;
      }
      return currentState.answers;
    }
    return [];
  }

  McqQuestionModel? get currentQuestion {
    if (state is McqInterviewInProgressState) {
      final currentState = state as McqInterviewInProgressState;
      return currentState.currentQuestion;
    }
    return null;
  }

  int get currentQuestionIndex {
    if (state is McqInterviewInProgressState) {
      final currentState = state as McqInterviewInProgressState;
      return currentState.currentQuestionIndex;
    }
    return 0;
  }

  String? get selectedOption {
    if (state is McqInterviewInProgressState) {
      final currentState = state as McqInterviewInProgressState;
      return currentState.selectedOption;
    }
    return null;
  }

  bool get canNavigateNext {
    if (state is McqInterviewInProgressState) {
      final currentState = state as McqInterviewInProgressState;
      return currentState.canNavigateNext;
    }
    return false;
  }

  bool get canNavigatePrevious {
    if (state is McqInterviewInProgressState) {
      final currentState = state as McqInterviewInProgressState;
      return currentState.canNavigatePrevious;
    }
    return false;
  }
}
