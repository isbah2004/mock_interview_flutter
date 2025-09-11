import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/services/unified_database_service.dart';
import 'package:mock_interview/core/services/network_service.dart';
import 'package:mock_interview/core/services/user_stats_service.dart';
import 'package:mock_interview/core/models/voice_message_model.dart';
import 'package:mock_interview/core/models/voice_evaluation_model.dart';
import 'package:mock_interview/core/models/unified_interview_session.dart';
import 'package:mock_interview/core/cubits/usercubit/user_cubit.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_session.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_message.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_config.dart';
import 'package:mock_interview/features/voiceinterviews/domain/usecases/start_interview_usecase.dart';
import 'package:mock_interview/features/voiceinterviews/domain/usecases/send_response_usecase.dart';
import 'package:mock_interview/features/voiceinterviews/domain/usecases/handle_speech_usecase.dart';
import 'package:mock_interview/features/voiceinterviews/data/models/voice_interview_evaluation_result.dart';
import 'package:mock_interview/core/constants/app_secrets.dart';
import 'package:mock_interview/core/utils/voice_cleaner.dart';
import 'package:mock_interview/features/voiceinterviews/utils/ai_response_cleaner.dart';
import 'voice_interview_event.dart';
import 'voice_interview_state.dart';
import 'package:mock_interview/core/utils/app_logger.dart';

class VoiceInterviewBloc
    extends Bloc<VoiceInterviewEvent, VoiceInterviewState> {
  final UnifiedDatabaseService _databaseService;
  final NetworkService _networkService;
  final StartInterviewUseCase _startInterviewUseCase;
  final SendResponseUseCase _sendResponseUseCase;
  final HandleSpeechUseCase _handleSpeechUseCase;
  final UserCubit _userCubit;
  final UserStatsService _userStatsService;

  // Track TTS state to prevent force completion when manually stopped
  bool _ttsManuallyControlled = false;

  VoiceInterviewBloc({
    required UnifiedDatabaseService databaseService,
    required NetworkService networkService,
    required StartInterviewUseCase startInterviewUseCase,
    required SendResponseUseCase sendResponseUseCase,
    required HandleSpeechUseCase handleSpeechUseCase,
    required UserCubit userCubit,
    required UserStatsService userStatsService,
  }) : _databaseService = databaseService,
       _networkService = networkService,
       _startInterviewUseCase = startInterviewUseCase,
       _sendResponseUseCase = sendResponseUseCase,
       _handleSpeechUseCase = handleSpeechUseCase,
       _userCubit = userCubit,
       _userStatsService = userStatsService,
       super(VoiceInterviewInitial()) {
    // Register event handlers for existing events
    on<InitializeInterview>(_onInitializeInterview);
    on<StartInterviewSetup>(_onStartInterviewSetup);
    on<SendUserResponse>(_onSendUserResponse);
    on<StartListening>(_onStartListening);
    on<StopListening>(_onStopListening);
    on<UpdateListeningText>(_onUpdateListeningText);
    on<SpeakResponse>(_onSpeakResponse);
    on<CompleteSpeaking>(_onCompleteSpeaking);
    on<PauseSpeaking>(_onPauseSpeaking);
    on<ResumeSpeaking>(_onResumeSpeaking);
    on<StopSpeaking>(_onStopSpeaking);
    on<CompleteInterview>(_onCompleteInterview);
    on<ResetInterviewState>(_onResetInterviewState);
    on<StartEvaluation>(_onStartEvaluation);
    on<RetryEvaluation>(_onRetryEvaluation);
  }

  Future<void> _onInitializeInterview(
    InitializeInterview event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    try {
      emit(VoiceInterviewLoading());

      if (!await _networkService.isConnected) {
        emit(VoiceInterviewError(message: 'No internet connection'));
        return;
      }

      // Start the interview using the use case to get the first question
      final firstQuestion = await _startInterviewUseCase.call(event.config);

      // Create the first AI message
      final aiMessage = InterviewMessage(
        content: firstQuestion,
        type: MessageType.ai,
        timestamp: DateTime.now(),
      );

      // Create interview session with the first message and set status to inProgress
      final session = InterviewSession(
        config: event.config,
        messages: [aiMessage],
        status: InterviewStatus.inProgress,
        currentQuestionNumber: 1,
      );

      final sessionId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create UnifiedInterviewSession in database
      final userId = _userCubit.currentUser?.id ?? 'anonymous_user';
      final unifiedSession = UnifiedInterviewSession(
        sessionId: sessionId,
        userId: userId,
        jobRole: event.config.jobRole,
        interviewType: 'voice',
        difficulty: _mapDifficultyToAppwrite(event.config.difficulty),
        category: _mapCategoryToAppwrite(event.config.category),
        totalQuestions: event.config.numberOfQuestions,
        timePerQuestion: 120, // 2 minutes per voice question
        isCompleted: false,
        startedAt: DateTime.now(),
      );

      await _databaseService.createInterviewSession(unifiedSession);

      emit(
        VoiceInterviewReady(
          session: session,
          sessionId: sessionId,
          isListening: false,
          isSpeaking: false,
          isProcessing: false,
        ),
      );

      // Trigger text-to-speech for the first question
      add(SpeakResponse(firstQuestion));
    } catch (e) {
      emit(
        VoiceInterviewError(
          message: 'Failed to initialize interview: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onStartInterviewSetup(
    StartInterviewSetup event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    try {
      emit(VoiceInterviewSetupConfiguring(event.config, true));

      if (!await _networkService.isConnected) {
        emit(VoiceInterviewError(message: 'No internet connection'));
        return;
      }

      // Emit setup ready state to navigate to interview view
      emit(VoiceInterviewSetupReady(event.config));
    } catch (e) {
      emit(
        VoiceInterviewError(
          message: 'Failed to setup interview: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onSendUserResponse(
    SendUserResponse event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! VoiceInterviewReady) {
        emit(
          VoiceInterviewError(message: 'Invalid state for sending response'),
        );
        return;
      }

      emit(
        VoiceInterviewReady(
          session: currentState.session,
          sessionId: currentState.sessionId,
          isListening: false,
          isSpeaking: false,
          isProcessing: true,
        ),
      );

      if (!await _networkService.isConnected) {
        emit(VoiceInterviewError(message: 'No internet connection'));
        return;
      }

      // Create user message
      final userMessage = InterviewMessage(
        content: event.response,
        type: MessageType.user,
        timestamp: DateTime.now(),
      );

      // Get AI response using the send response use case
      final aiResponse = await _sendResponseUseCase.call(event.response);

      // Create AI message
      final aiMessage = InterviewMessage(
        content: aiResponse,
        type: MessageType.ai,
        timestamp: DateTime.now(),
      );

      // Update session with both messages
      final updatedMessages = [
        ...currentState.session.messages,
        userMessage,
        aiMessage,
      ];

      final updatedSession = currentState.session.copyWith(
        messages: updatedMessages,
        currentQuestionNumber: currentState.session.currentQuestionNumber + 1,
      );

      // Store messages to database
      final userVoiceMessage = VoiceMessageModel(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: currentState.sessionId,
        messageType: AppSecrets.messageTypeUser,
        content: event.response,
        timestamp: DateTime.now(),
        sequenceNumber: updatedMessages.length - 2,
      );

      final aiVoiceMessage = VoiceMessageModel(
        messageId: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        sessionId: currentState.sessionId,
        messageType: AppSecrets.messageTypeAI,
        content: aiResponse,
        timestamp: DateTime.now(),
        sequenceNumber: updatedMessages.length - 1,
      );

      await _databaseService.storeVoiceMessage(userVoiceMessage);
      await _databaseService.storeVoiceMessage(aiVoiceMessage);

      emit(
        VoiceInterviewReady(
          session: updatedSession,
          sessionId: currentState.sessionId,
          isListening: false,
          isSpeaking: false,
          isProcessing: false,
        ),
      );

      // Check if interview should be completed automatically
      // Complete when we reach the specified number of questions
      final hasReachedQuestionLimit =
          updatedSession.currentQuestionNumber >=
          updatedSession.config.numberOfQuestions;

      AppLogger.info(
        'Voice Interview Completion Check: Questions=${updatedSession.currentQuestionNumber}/${updatedSession.config.numberOfQuestions}, '
        'HasReachedLimit=$hasReachedQuestionLimit',
      );

      // Complete interview immediately when question limit is reached
      if (hasReachedQuestionLimit) {
        AppLogger.info(
          'Voice Interview: Completing interview - Question limit reached (${updatedSession.currentQuestionNumber}/${updatedSession.config.numberOfQuestions})',
        );
        // Complete the interview when question limit is reached
        add(CompleteInterview());
        return;
      }

      // Trigger text-to-speech for AI response
      add(SpeakResponse(aiResponse));
    } catch (e) {
      emit(
        VoiceInterviewError(
          message: 'Failed to send response: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onStartListening(
    StartListening event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    final currentState = state;
    if (currentState is VoiceInterviewReady) {
      try {
        emit(
          VoiceInterviewReady(
            session: currentState.session,
            sessionId: currentState.sessionId,
            isListening: true,
            isSpeaking: false,
            isProcessing: false,
          ),
        );

        // Start listening using the speech service
        await _handleSpeechUseCase.startListening(
          onResult: (String text) {
            add(UpdateListeningText(text));
          },
          onComplete: () {
            add(StopListening());
          },
        );
      } catch (e) {
        emit(
          VoiceInterviewError(
            message: 'Failed to start listening: ${e.toString()}',
          ),
        );
      }
    }
  }

  Future<void> _onStopListening(
    StopListening event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    final currentState = state;
    if (currentState is VoiceInterviewReady) {
      try {
        // Stop listening using the speech service
        _handleSpeechUseCase.stopListening();

        // If we have listening text, clean it and send as user response
        if (currentState.currentListeningText != null &&
            currentState.currentListeningText!.isNotEmpty) {
          // Clean the voice input
          final cleanedText = VoiceCleaner.cleanVoiceInput(
            currentState.currentListeningText!,
          );

          // Validate the cleaned input
          if (VoiceCleaner.isValidInput(cleanedText)) {
            add(SendUserResponse(cleanedText));
          } else {
            // If cleaned input is invalid, show error
            emit(
              VoiceInterviewError(
                message:
                    'Could not understand your response. Please try speaking again.',
              ),
            );
            return;
          }
        }

        emit(
          VoiceInterviewReady(
            session: currentState.session,
            sessionId: currentState.sessionId,
            currentListeningText: null,
            isListening: false,
            isSpeaking: false,
            isProcessing: false,
          ),
        );
      } catch (e) {
        emit(
          VoiceInterviewError(
            message: 'Failed to stop listening: ${e.toString()}',
          ),
        );
      }
    }
  }

  Future<void> _onCompleteInterview(
    CompleteInterview event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is VoiceInterviewReady) {
        // Update UnifiedInterviewSession in database to completed status
        final userId = _userCubit.currentUser?.id ?? 'anonymous_user';
        final session = currentState.session;

        // Emit evaluating state first
        emit(
          VoiceInterviewEvaluating(
            session: session,
            sessionId: currentState.sessionId,
          ),
        );

        AppLogger.info('VoiceInterviewBloc: Starting interview evaluation...');

        // Declare evaluation result variable
        Map<String, dynamic> evaluationResult;

        // Safety check: ensure we have messages to evaluate
        if (session.messages.isEmpty) {
          AppLogger.info(
            'VoiceInterviewBloc: No messages to evaluate, using default scores',
          );
          evaluationResult = _calculatePerformanceBasedEvaluation(session);
        } else {
          AppLogger.info(
            'VoiceInterviewBloc: Found ${session.messages.length} messages to evaluate',
          );

          // Evaluate the interview using Gemini AI
          try {
            // Add timeout to prevent getting stuck
            evaluationResult = await _sendResponseUseCase
                .evaluateInterview(session, session.config)
                .timeout(
                  const Duration(minutes: 2), // 2-minute timeout
                  onTimeout: () {
                    AppLogger.warn(
                      'VoiceInterviewBloc: Evaluation timeout, using fallback',
                    );
                    return _calculatePerformanceBasedEvaluation(session);
                  },
                );
            AppLogger.info(
              'VoiceInterviewBloc: AI evaluation completed successfully',
            );
          } catch (e) {
            AppLogger.error(
              'VoiceInterviewBloc: AI evaluation failed, using performance-based fallback: $e',
            );
            evaluationResult = _calculatePerformanceBasedEvaluation(session);
          }
        }

        // Extract scores from evaluation
        final overallScore =
            (evaluationResult['overallScore'] as double? ?? 0.0);
        final percentageScore =
            (evaluationResult['percentageScore'] as double? ?? 0.0);
        final communicationScore =
            (evaluationResult['communicationScore'] as double? ?? 0.0);
        final contentScore =
            (evaluationResult['contentScore'] as double? ?? 0.0);

        AppLogger.info(
          'VoiceInterviewBloc: Evaluation scores - Overall: $overallScore, Percentage: $percentageScore, Communication: $communicationScore, Content: $contentScore',
        );
        AppLogger.info(
          'VoiceInterviewBloc: Updating interview session to completed...',
        );

        final updatedSession = UnifiedInterviewSession(
          sessionId: currentState.sessionId,
          userId: userId,
          jobRole: session.config.jobRole,
          interviewType: 'voice',
          difficulty: _mapDifficultyToAppwrite(session.config.difficulty),
          category: _mapCategoryToAppwrite(session.config.category),
          totalQuestions: session.config.numberOfQuestions,
          timePerQuestion: 120,
          isCompleted: true,
          passed: percentageScore >= 60.0,
          score: overallScore,
          percentage: percentageScore,
          startedAt: DateTime.now().subtract(
            const Duration(minutes: 5),
          ), // Estimate
          completedAt: DateTime.now(),
          duration: 300, // 5 minutes estimate
        );

        try {
          await _databaseService.updateInterviewSession(updatedSession);
          AppLogger.info(
            'VoiceInterviewBloc: Interview session updated successfully',
          );
        } catch (e) {
          AppLogger.error(
            'VoiceInterviewBloc: Failed to update interview session: $e',
          );
          // Don't fail the entire flow for session update issues, but log it
        }

        // Update user stats
        if (_userCubit.currentUser != null) {
          try {
            AppLogger.info(
              'Voice: About to update user stats for user: ${_userCubit.currentUser!.id}',
            );
            AppLogger.info(
              'Voice: Current stats - total: ${_userCubit.currentUser!.totalInterviews}, voice: ${_userCubit.currentUser!.voiceInterviews}, avg: ${_userCubit.currentUser!.averageScore}',
            );
            AppLogger.info(
              'Voice: Completed session score: ${updatedSession.score}, type: ${updatedSession.interviewType}',
            );

            final updatedUser = await _userStatsService
                .updateUserStatsAfterInterview(
                  currentUser: _userCubit.currentUser!,
                  completedSession: updatedSession,
                );

            // Update UserCubit with new stats
            _userCubit.updateUser(updatedUser);

            AppLogger.info('Voice: User stats updated successfully');
            AppLogger.info(
              'Voice: New stats - total: ${updatedUser.totalInterviews}, voice: ${updatedUser.voiceInterviews}, avg: ${updatedUser.averageScore}',
            );
          } catch (e) {
            // Log error but don't fail the interview completion
            AppLogger.error(
              'Failed to update user stats in voice interview: $e',
            );
          }
        } else {
          AppLogger.warn('Voice: No current user found, cannot update stats');
        }

        // Update session to completed status
        final completedSession = currentState.session.copyWith(
          status: InterviewStatus.completed,
        );

        // Create the evaluation result object
        final evaluationResultObject = VoiceInterviewEvaluationResult(
          sessionId: updatedSession.sessionId,
          totalQuestions: session.config.numberOfQuestions,
          results: [], // Voice interviews don't have MCQ-style question results
          finalScore: percentageScore,
          percentage: percentageScore,
          passed: percentageScore >= 60.0,
          sessionComplete: true,
          completedAt: DateTime.now(),
          feedback:
              evaluationResult['feedback'] as String? ??
              'No feedback available',
          aiCorrectAnswers:
              (evaluationResult['aiCorrectAnswers'] as List<dynamic>?)
                  ?.cast<String>() ??
              [],
          communicationScore: communicationScore,
          contentScore: contentScore,
          overallScore: overallScore,
        );

        // Save evaluation to database
        VoiceEvaluationModel? savedEvaluation;
        try {
          AppLogger.info(
            'VoiceInterviewBloc: Attempting to save evaluation for sessionId: ${updatedSession.sessionId}',
          );

          final voiceEvaluation = VoiceEvaluationModel(
            evaluationId:
                'eval_${updatedSession.sessionId}_${DateTime.now().millisecondsSinceEpoch}',
            sessionId: updatedSession.sessionId,
            feedback:
                evaluationResult['feedback'] as String? ??
                'No feedback available',
            communicationScore: communicationScore,
            contentScore: contentScore,
            overallScore: overallScore,
            aiCorrectAnswers:
                (evaluationResult['aiCorrectAnswers'] as List<dynamic>?)
                    ?.cast<String>() ??
                [],
            totalQuestions: session.config.numberOfQuestions,
            finalScore: percentageScore,
            percentage: percentageScore,
            passed: percentageScore >= 60.0,
            sessionComplete: true,
            completedAt: DateTime.now(),
            // Note: conversation messages are stored separately in voice_messages collection
            conversationMessages: [], // Empty for now, stored separately
          );

          savedEvaluation = await _databaseService.storeVoiceEvaluation(
            voiceEvaluation,
          );
          AppLogger.info(
            'VoiceInterviewBloc: Evaluation saved to database successfully with ID: ${savedEvaluation.evaluationId}',
          );

          // Store conversation messages separately
          try {
            AppLogger.info(
              'VoiceInterviewBloc: Storing conversation messages...',
            );
            for (int i = 0; i < session.messages.length; i++) {
              final message = session.messages[i];
              final voiceMessage = VoiceMessageModel(
                messageId: '',
                sessionId: updatedSession.sessionId,
                messageType: message.type.toString().split('.').last,
                content: message.content,
                timestamp: message.timestamp,
                sequenceNumber: i + 1,
              );
              await _databaseService.storeVoiceMessage(voiceMessage);
            }
            AppLogger.info(
              'VoiceInterviewBloc: All conversation messages stored successfully',
            );
          } catch (e) {
            AppLogger.error(
              'VoiceInterviewBloc: Failed to store conversation messages: $e',
            );
            // Don't fail the entire flow for message storage issues
          }
        } catch (e, stackTrace) {
          AppLogger.error(
            'VoiceInterviewBloc: Failed to save evaluation to database: $e',
          );
          AppLogger.error('Stack trace: $stackTrace');

          // Don't continue with the flow if database save fails
          // This ensures we know when evaluations aren't being stored
          emit(
            VoiceInterviewError(
              message:
                  'Failed to save interview evaluation: ${e.toString()}. Please try again.',
            ),
          );
          return;
        }

        // Emit evaluated state for navigation
        emit(
          VoiceInterviewEvaluated(
            session: completedSession,
            result: evaluationResultObject,
            sessionId: currentState.sessionId,
          ),
        );
      }
    } catch (e) {
      emit(
        VoiceInterviewError(
          message: 'Failed to finish interview: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onResetInterviewState(
    ResetInterviewState event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    emit(VoiceInterviewInitial());
  }

  Future<void> _onUpdateListeningText(
    UpdateListeningText event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    final currentState = state;
    if (currentState is VoiceInterviewReady) {
      emit(
        VoiceInterviewReady(
          session: currentState.session,
          sessionId: currentState.sessionId,
          currentListeningText: event.text,
          isListening: currentState.isListening,
          isSpeaking: currentState.isSpeaking,
          isProcessing: currentState.isProcessing,
        ),
      );
    }
  }

  Future<void> _onSpeakResponse(
    SpeakResponse event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    final currentState = state;
    if (currentState is VoiceInterviewReady) {
      // Reset TTS control flag when starting new TTS
      _ttsManuallyControlled = false;

      emit(
        VoiceInterviewReady(
          session: currentState.session,
          sessionId: currentState.sessionId,
          currentListeningText: currentState.currentListeningText,
          isListening: false,
          isSpeaking: true,
          isProcessing: false,
        ),
      );

      try {
        // Clean the response to remove markdown formatting for TTS
        final cleanedResponse = AIResponseCleaner.cleanAIResponse(
          event.response,
        );

        AppLogger.info(
          'VoiceInterviewBloc: Starting TTS for: ${cleanedResponse.substring(0, cleanedResponse.length > 50 ? 50 : cleanedResponse.length)}...',
        );

        // Add a timeout to prevent hanging TTS
        bool completionCalled = false;

        // Set up fallback timer (30 seconds max for TTS)
        final fallbackTimer = Timer(const Duration(seconds: 30), () {
          if (!completionCalled && !_ttsManuallyControlled) {
            AppLogger.warn(
              'VoiceInterviewBloc: TTS timeout reached, forcing completion',
            );
            completionCalled = true;
            add(CompleteSpeaking());
          } else if (_ttsManuallyControlled) {
            AppLogger.info(
              'VoiceInterviewBloc: TTS timeout reached but TTS is manually controlled, not forcing completion',
            );
          }
        });

        // Speak the cleaned response using the speech service
        await _handleSpeechUseCase.speak(
          cleanedResponse,
          onComplete: () {
            if (!completionCalled) {
              AppLogger.info('VoiceInterviewBloc: TTS completed normally');
              completionCalled = true;
              fallbackTimer.cancel();
              add(CompleteSpeaking());
            }
          },
        );

        // If speak method completes but callback wasn't called, trigger completion
        await Future.delayed(const Duration(seconds: 10));
        if (!completionCalled && !_ttsManuallyControlled) {
          AppLogger.warn(
            'VoiceInterviewBloc: TTS method completed but callback not called, forcing completion',
          );
          completionCalled = true;
          fallbackTimer.cancel();
          add(CompleteSpeaking());
        } else if (_ttsManuallyControlled) {
          AppLogger.info(
            'VoiceInterviewBloc: TTS method completed but TTS is manually controlled, not forcing completion',
          );
        }
      } catch (e) {
        AppLogger.error('VoiceInterviewBloc: TTS error: $e');
        emit(
          VoiceInterviewError(
            message: 'Failed to speak response: ${e.toString()}',
          ),
        );
      }
    }
  }

  Future<void> _onCompleteSpeaking(
    CompleteSpeaking event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    final currentState = state;
    if (currentState is VoiceInterviewReady) {
      AppLogger.info(
        'VoiceInterviewBloc: Completing speaking, setting isSpeaking to false',
      );
      _ttsManuallyControlled = false; // Reset flag when completing
      emit(
        currentState.copyWith(
          isListening: false,
          isSpeaking: false,
          isSpeakingPaused: false, // Reset pause state when completing
          isProcessing: false,
        ),
      );
    }
  }

  Future<void> _onPauseSpeaking(
    PauseSpeaking event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    final currentState = state;
    if (currentState is VoiceInterviewReady && currentState.isSpeaking) {
      AppLogger.info('VoiceInterviewBloc: Pausing TTS');
      _ttsManuallyControlled = true; // Mark as manually controlled
      await _handleSpeechUseCase.pauseSpeaking();
      emit(
        currentState.copyWith(
          isSpeaking: false, // Not actively speaking when paused
          isSpeakingPaused: true,
        ),
      );
    }
  }

  Future<void> _onResumeSpeaking(
    ResumeSpeaking event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    final currentState = state;
    if (currentState is VoiceInterviewReady && currentState.isSpeakingPaused) {
      AppLogger.info('VoiceInterviewBloc: Resuming TTS');
      await _handleSpeechUseCase.resumeSpeaking();
      emit(
        currentState.copyWith(
          isSpeaking: true, // Now actively speaking again
          isSpeakingPaused: false,
        ),
      );
    }
  }

  Future<void> _onStopSpeaking(
    StopSpeaking event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    final currentState = state;
    if (currentState is VoiceInterviewReady && currentState.isSpeaking) {
      AppLogger.info('VoiceInterviewBloc: Stopping TTS');
      _ttsManuallyControlled = true; // Mark as manually controlled
      await _handleSpeechUseCase.stopSpeaking();
      emit(
        VoiceInterviewReady(
          session: currentState.session,
          sessionId: currentState.sessionId,
          currentListeningText: currentState.currentListeningText,
          isListening: false,
          isSpeaking: false,
          isProcessing: false,
        ),
      );
    }
  }

  /// Calculate performance-based evaluation when AI evaluation fails
  Map<String, dynamic> _calculatePerformanceBasedEvaluation(
    InterviewSession session,
  ) {
    // Count answered vs total questions
    int totalQuestions = session.config.numberOfQuestions;
    int answeredQuestions =
        session.messages
            .where(
              (msg) =>
                  msg.type == MessageType.user && msg.content.trim().isNotEmpty,
            )
            .length;

    // Calculate percentage based on answered questions
    double answerPercentage =
        totalQuestions > 0 ? (answeredQuestions / totalQuestions) * 100 : 0.0;

    // Conservative scoring: only give points for actually answered questions
    double baseScore = answerPercentage * 0.6; // Max 60% for just answering

    // Add bonus for content quality (simple heuristics)
    double contentBonus = 0.0;
    for (var message in session.messages.where(
      (msg) => msg.type == MessageType.user,
    )) {
      String content = message.content.trim();
      if (content.isNotEmpty) {
        // Basic content quality scoring
        if (content.length > 50) {
          contentBonus += 5; // Detailed answers
        }
        if (content.split(' ').length > 10) {
          contentBonus += 3; // Longer responses
        }
        if (content.contains(RegExp(r'[.!?]'))) {
          contentBonus += 2; // Complete sentences
        }
      }
    }

    // Cap the bonus and calculate final scores
    contentBonus = contentBonus.clamp(0.0, 40.0); // Max 40% bonus
    double finalScore = (baseScore + contentBonus).clamp(0.0, 100.0);

    AppLogger.info(
      'Performance-based evaluation: Answered $answeredQuestions/$totalQuestions questions',
    );
    AppLogger.info(
      'Base score: $baseScore%, Content bonus: $contentBonus%, Final: $finalScore%',
    );

    return {
      'overallScore': finalScore,
      'percentageScore': finalScore,
      'communicationScore':
          finalScore * 0.8, // Slightly lower for communication
      'contentScore': finalScore * 1.2, // Slightly higher for content
      'feedback':
          'Performance evaluated based on answered questions ($answeredQuestions/$totalQuestions) and response quality.',
      'strengths':
          answeredQuestions > totalQuestions * 0.7
              ? ['Good response rate', 'Engaged with most questions']
              : ['Participated in interview'],
      'improvements':
          answeredQuestions < totalQuestions * 0.5
              ? [
                'Try to answer more questions',
                'Provide more detailed responses',
              ]
              : ['Consider adding more detail to responses'],
    };
  }

  /// Maps voice interview difficulty enum to Appwrite expected values
  String _mapDifficultyToAppwrite(InterviewDifficulty difficulty) {
    switch (difficulty) {
      case InterviewDifficulty.beginner:
        return 'easy';
      case InterviewDifficulty.intermediate:
        return 'medium';
      case InterviewDifficulty.advanced:
        return 'hard';
    }
  }

  String _mapCategoryToAppwrite(InterviewCategory category) {
    switch (category) {
      case InterviewCategory.general:
        return 'general';
      case InterviewCategory.behavioral:
        return 'behavioral';
      case InterviewCategory.technical:
        return 'technical';
      case InterviewCategory.industrySpecific:
        return 'industrySpecific';
    }
  }

  /// Handle evaluation request for completed interviews from history
  Future<void> _onStartEvaluation(
    StartEvaluation event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    try {
      // Check if evaluation already exists in database
      final sessionId =
          'session_${event.session.messages.hashCode}'; // Generate session ID from messages
      final existingEvaluation = await _databaseService.getVoiceEvaluation(
        sessionId,
      );

      if (existingEvaluation != null) {
        // Convert to evaluation result and emit
        final evaluationResult = VoiceInterviewEvaluationResult(
          sessionId: existingEvaluation.sessionId,
          totalQuestions: existingEvaluation.totalQuestions,
          results: [],
          finalScore: existingEvaluation.finalScore,
          percentage: existingEvaluation.percentage,
          passed: existingEvaluation.passed,
          sessionComplete: existingEvaluation.sessionComplete,
          completedAt: existingEvaluation.completedAt,
          feedback: existingEvaluation.feedback,
          aiCorrectAnswers: existingEvaluation.aiCorrectAnswers,
          communicationScore: existingEvaluation.communicationScore,
          contentScore: existingEvaluation.contentScore,
          overallScore: existingEvaluation.overallScore,
        );

        emit(
          VoiceInterviewEvaluated(
            session: event.session,
            result: evaluationResult,
            sessionId: existingEvaluation.sessionId,
          ),
        );
        return;
      }

      // If no evaluation exists, show error
      emit(
        VoiceInterviewEvaluationError(
          message:
              'No evaluation data found for this interview. This interview may not have been properly completed.',
          session: event.session,
          sessionId: sessionId,
        ),
      );
    } catch (e) {
      emit(
        VoiceInterviewEvaluationError(
          message: 'Failed to load evaluation: ${e.toString()}',
          session: event.session,
          sessionId: 'session_${event.session.messages.hashCode}',
        ),
      );
    }
  }

  /// Handle retry evaluation request
  Future<void> _onRetryEvaluation(
    RetryEvaluation event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    final sessionId = 'session_${event.session.messages.hashCode}';

    // For retry, we can try to re-evaluate using the session data
    emit(
      VoiceInterviewEvaluating(session: event.session, sessionId: sessionId),
    );

    try {
      // Re-run the evaluation logic from _onCompleteInterview
      // For now, just redirect to the error state suggesting to restart
      emit(
        VoiceInterviewEvaluationError(
          message: 'Please restart the interview to get a fresh evaluation.',
          session: event.session,
          sessionId: sessionId,
        ),
      );
    } catch (e) {
      emit(
        VoiceInterviewEvaluationError(
          message: 'Failed to retry evaluation: ${e.toString()}',
          session: event.session,
          sessionId: sessionId,
        ),
      );
    }
  }
}
