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

    // Add new event handlers
    on<PlayTTS>(_onPlayTTS);
    on<PauseTTS>(_onPauseTTS);
    on<StopTTS>(_onStopTTS);
    on<ReplayTTS>(_onReplayTTS);
    on<EndInterview>(_onEndInterview);
    on<RetryCurrentQuestion>(_onRetryCurrentQuestion);
    on<UpdateTranscriptText>(_onUpdateTranscriptText);
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
        numberOfQuestions: event.config.numberOfQuestions,
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
        isCompleted: false,
        startedAt: DateTime.now(),
      );

      await _databaseService.createInterviewSession(unifiedSession);

      // Store the first AI message to the database
      final firstAiVoiceMessage = VoiceMessageModel(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: sessionId,
        messageType: AppSecrets.messageTypeAI,
        content: firstQuestion,
        timestamp: DateTime.now(),
        sequenceNumber: 0, // First message has sequence number 0
      );

      await _databaseService.storeVoiceMessage(firstAiVoiceMessage);

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

      // For the last question, keep the user's response text visible
      final shouldPreserveFinalText =
          updatedSession.currentQuestionNumber >
          updatedSession.config.numberOfQuestions;

      emit(
        VoiceInterviewReady(
          session: updatedSession,
          sessionId: currentState.sessionId,
          currentListeningText: shouldPreserveFinalText ? event.response : null,
          isListening: false,
          isSpeaking: false,
          isProcessing: false,
        ),
      ); // Check if interview should be completed automatically
      // Complete when we reach the specified number of questions (AFTER answering all questions)
      final hasReachedQuestionLimit =
          updatedSession.currentQuestionNumber >
          updatedSession.config.numberOfQuestions;

      AppLogger.info(
        'Voice Interview Completion Check: Questions=${updatedSession.currentQuestionNumber}/${updatedSession.config.numberOfQuestions}, '
        'HasReachedLimit=$hasReachedQuestionLimit',
      );

      // Check if this is the last question - if so, let the TTS complete before finishing
      if (hasReachedQuestionLimit) {
        AppLogger.info(
          'Voice Interview: All questions completed (${updatedSession.currentQuestionNumber - 1}/${updatedSession.config.numberOfQuestions})',
        );
        AppLogger.info(
          'Voice Interview: Starting final AI response TTS - will complete after speaking',
        );

        // Trigger text-to-speech for final AI response
        // The completion will be handled in the TTS completion callback
        add(SpeakResponse(aiResponse));
        return; // Don't complete yet, let TTS finish first
      }

      // Trigger text-to-speech for AI response (non-final questions)
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

        AppLogger.info(
          'Voice Interview: STT stopped. Current text: "${currentState.currentListeningText}"',
        );

        // If we have listening text, clean it and send as user response
        if (currentState.currentListeningText != null &&
            currentState.currentListeningText!.isNotEmpty) {
          // Clean the voice input
          final cleanedText = VoiceCleaner.cleanVoiceInput(
            currentState.currentListeningText!,
          );

          AppLogger.info('Voice Interview: Cleaned STT text: "$cleanedText"');

          // Validate the cleaned input
          if (VoiceCleaner.isValidInput(cleanedText)) {
            // First emit the state with the final listening text to show it
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

            // Small delay to ensure UI updates with the final text
            await Future.delayed(const Duration(milliseconds: 300));

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
        } else {
          // No text captured
          AppLogger.info(
            'Voice Interview: STT completed but no text was captured',
          );
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
        }
      } catch (e) {
        AppLogger.error(
          'Voice Interview: Error stopping listening: ${e.toString()}',
        );
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
              (evaluationResult['correctAnswers'] as List<dynamic>?)
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
                (evaluationResult['correctAnswers'] as List<dynamic>?)
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

          // Note: Conversation messages are already stored individually during the interview,
          // so no need to store them again here to avoid duplicates
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

        // Stop any ongoing TTS before completing the interview
        try {
          await _handleSpeechUseCase.stopSpeaking();
          AppLogger.info(
            'VoiceInterviewBloc: TTS stopped before interview completion',
          );
        } catch (e) {
          AppLogger.error(
            'VoiceInterviewBloc: Failed to stop TTS before completion: $e',
          );
          // Continue anyway - don't block completion due to TTS issues
        }

        // Emit completed state for navigation
        AppLogger.info(
          'VoiceInterviewBloc: ✅ Emitting VoiceInterviewCompleted state for navigation',
        );
        emit(
          VoiceInterviewCompleted(
            evaluation: evaluationResultObject,
            session: completedSession,
            sessionId: currentState.sessionId,
          ),
        );
        AppLogger.info(
          'VoiceInterviewBloc: ✅ VoiceInterviewCompleted state emitted successfully',
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

              // Check if this is the last question's response
              final isLastQuestion =
                  currentState.session.currentQuestionNumber >
                  currentState.session.config.numberOfQuestions;

              completionCalled = true;
              fallbackTimer.cancel();

              if (isLastQuestion) {
                AppLogger.info(
                  'Voice Interview: Last question TTS completed, adding delay before next step',
                );
                // Add extra delay for last question to let user process the final exchange
                Future.delayed(const Duration(milliseconds: 1500), () {
                  add(CompleteSpeaking());
                });
              } else {
                add(CompleteSpeaking());
              }
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

      // Check if this was the final question and complete the interview
      final hasReachedQuestionLimit =
          currentState.session.currentQuestionNumber >
          currentState.session.config.numberOfQuestions;

      if (hasReachedQuestionLimit) {
        AppLogger.info(
          'Voice Interview: Final AI response completed - triggering interview completion',
        );
        // Give a moment for the user to process the final response
        await Future.delayed(const Duration(milliseconds: 1000));
        add(CompleteInterview());
        return; // Don't emit ready state, go straight to completion
      }

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

  // Helper method to get current question
  String _getCurrentQuestion(InterviewSession session) {
    final aiMessages =
        session.messages
            .where((message) => message.type == MessageType.ai)
            .toList();

    if (aiMessages.isNotEmpty) {
      return aiMessages.last.content;
    }

    return 'Loading question...';
  }

  // TTS Control Handlers
  Future<void> _onPlayTTS(
    PlayTTS event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    if (state is VoiceInterviewReady) {
      final currentState = state as VoiceInterviewReady;

      try {
        if (currentState.isSpeakingPaused) {
          // Resume if paused
          AppLogger.info('VoiceInterviewBloc: Resuming TTS from Play button');
          await _handleSpeechUseCase.resumeSpeaking();
          emit(
            currentState.copyWith(isSpeaking: true, isSpeakingPaused: false),
          );
        } else {
          // If not currently speaking, try to replay the last question
          AppLogger.info(
            'VoiceInterviewBloc: Starting TTS from Play button (replay)',
          );
          final lastQuestion = _getCurrentQuestion(currentState.session);
          if (lastQuestion.isNotEmpty) {
            add(SpeakResponse(lastQuestion));
          }
        }
      } catch (e) {
        AppLogger.error('VoiceInterviewBloc: Error in PlayTTS: $e');
        emit(
          VoiceInterviewError(message: 'Failed to play TTS: ${e.toString()}'),
        );
      }
    }
  }

  Future<void> _onPauseTTS(
    PauseTTS event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    if (state is VoiceInterviewReady) {
      final currentState = state as VoiceInterviewReady;

      try {
        if (currentState.isSpeaking && !currentState.isSpeakingPaused) {
          AppLogger.info('VoiceInterviewBloc: Pausing TTS from Pause button');
          _ttsManuallyControlled = true; // Mark as manually controlled
          await _handleSpeechUseCase.pauseSpeaking();
          emit(currentState.copyWith(isSpeaking: true, isSpeakingPaused: true));
        }
      } catch (e) {
        AppLogger.error('VoiceInterviewBloc: Error in PauseTTS: $e');
        emit(
          VoiceInterviewError(message: 'Failed to pause TTS: ${e.toString()}'),
        );
      }
    }
  }

  Future<void> _onStopTTS(
    StopTTS event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    if (state is VoiceInterviewReady) {
      final currentState = state as VoiceInterviewReady;

      try {
        if (currentState.isSpeaking) {
          AppLogger.info('VoiceInterviewBloc: Stopping TTS from Stop button');
          _ttsManuallyControlled = true; // Mark as manually controlled
          await _handleSpeechUseCase.stopSpeaking();
          emit(
            currentState.copyWith(isSpeaking: false, isSpeakingPaused: false),
          );
        }
      } catch (e) {
        AppLogger.error('VoiceInterviewBloc: Error in StopTTS: $e');
        emit(
          VoiceInterviewError(message: 'Failed to stop TTS: ${e.toString()}'),
        );
      }
    }
  }

  Future<void> _onReplayTTS(
    ReplayTTS event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    if (state is VoiceInterviewReady) {
      final currentState = state as VoiceInterviewReady;

      try {
        AppLogger.info('VoiceInterviewBloc: Replaying TTS from Replay button');
        // Stop current TTS if playing
        if (currentState.isSpeaking) {
          await _handleSpeechUseCase.stopSpeaking();
        }

        // Get the current question and replay it
        final currentQuestion = _getCurrentQuestion(currentState.session);
        if (currentQuestion.isNotEmpty &&
            currentQuestion != 'Loading question...') {
          add(SpeakResponse(currentQuestion));
        } else {
          AppLogger.warn('VoiceInterviewBloc: No question available to replay');
          emit(VoiceInterviewError(message: 'No question available to replay'));
        }
      } catch (e) {
        AppLogger.error('VoiceInterviewBloc: Error in ReplayTTS: $e');
        emit(
          VoiceInterviewError(message: 'Failed to replay TTS: ${e.toString()}'),
        );
      }
    }
  }

  // Interview Control Handlers
  Future<void> _onEndInterview(
    EndInterview event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    if (state is VoiceInterviewReady) {
      add(CompleteInterview()); // Trigger the existing completion logic
    }
  }

  Future<void> _onRetryCurrentQuestion(
    RetryCurrentQuestion event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    if (state is VoiceInterviewError) {
      // Reset to ready state and replay the current question
      emit(VoiceInterviewLoading());
      // Add logic to retry the current question
      // For now, emit error asking user to restart
      emit(
        VoiceInterviewError(
          message: 'Please restart the interview to continue.',
        ),
      );
    }
  }

  Future<void> _onUpdateTranscriptText(
    UpdateTranscriptText event,
    Emitter<VoiceInterviewState> emit,
  ) async {
    if (state is VoiceInterviewReady) {
      final currentState = state as VoiceInterviewReady;
      emit(currentState.copyWith(currentListeningText: event.text));
    }
  }
}
