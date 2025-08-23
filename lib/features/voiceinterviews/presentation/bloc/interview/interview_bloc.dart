import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:mock_interview/features/voiceinterviews/domain/usecases/handle_speech_usecase.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_config.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_message.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_session.dart';
import 'package:mock_interview/features/voiceinterviews/domain/usecases/send_response_usecase.dart';
import 'package:mock_interview/features/voiceinterviews/domain/usecases/start_interview_usecase.dart';
import 'package:mock_interview/features/voiceinterviews/utils/ai_response_cleaner.dart';

import 'interview_event.dart';
import 'interview_state.dart';

class InterviewBloc extends Bloc<InterviewEvent, InterviewState> {
  final StartInterviewUseCase _startInterviewUseCase;
  final SendResponseUseCase _sendResponseUseCase;
  final HandleSpeechUseCase _handleSpeechUseCase;

  InterviewSession _session = const InterviewSession(
    config: InterviewConfig(
      jobRole: '',
      category: InterviewCategory.general,
      difficulty: InterviewDifficulty.intermediate,
      numberOfQuestions: 5,
    ),
  );

  InterviewBloc(
    this._startInterviewUseCase,
    this._sendResponseUseCase,
    this._handleSpeechUseCase,
  ) : super(InterviewInitial()) {
    on<InitializeInterview>(_onInitializeInterview);
    on<SendUserResponse>(_onSendUserResponse);
    on<StartListening>(_onStartListening);
    on<StopListening>(_onStopListening);
    on<UpdateListeningText>(_onUpdateListeningText);
    on<SpeakResponse>(_onSpeakResponse);
    on<CompleteSpeaking>(_onCompleteSpeaking);
  }

  Future<void> _onInitializeInterview(
    InitializeInterview event,
    Emitter<InterviewState> emit,
  ) async {
    try {
      emit(InterviewLoading());

      _session = InterviewSession(config: event.config);

      final aiResponse = await _startInterviewUseCase(event.config);

      // Clean the AI response to remove formatting artifacts
      final cleanedAiResponse = AIResponseCleaner.cleanAIResponse(aiResponse);

      final message = InterviewMessage(
        content: cleanedAiResponse,
        type: MessageType.ai,
        timestamp: DateTime.now(),
      );

      _session = _session.copyWith(
        messages: [..._session.messages, message],
        status: InterviewStatus.inProgress,
        currentQuestionNumber: 1,
      );

      emit(InterviewInProgress(_session));
      add(SpeakResponse(cleanedAiResponse));
    } catch (e) {
      emit(InterviewError(e.toString()));
    }
  }

  Future<void> _onSendUserResponse(
    SendUserResponse event,
    Emitter<InterviewState> emit,
  ) async {
    try {
      final userMessage = InterviewMessage(
        content: event.response,
        type: MessageType.user,
        timestamp: DateTime.now(),
      );

      _session = _session.copyWith(
        messages: [..._session.messages, userMessage],
      );

      emit(InterviewInProgress(_session));

      final aiResponse = await _sendResponseUseCase(event.response);

      // Clean the AI response to remove formatting artifacts
      final cleanedAiResponse = AIResponseCleaner.cleanAIResponse(aiResponse);

      final aiMessage = InterviewMessage(
        content: cleanedAiResponse,
        type: MessageType.ai,
        timestamp: DateTime.now(),
      );

      // Check if this is a new question
      int questionNumber = _session.currentQuestionNumber;
      if (cleanedAiResponse.toLowerCase().contains('question') &&
          cleanedAiResponse.contains('${questionNumber + 1}')) {
        questionNumber++;
        debugPrint('DEBUG: Detected new question $questionNumber');
      }

      // Check if interview should be completed based on AI response content
      bool isInterviewComplete =
          cleanedAiResponse.toLowerCase().contains('this concludes') ||
          cleanedAiResponse.toLowerCase().contains('thank you for your time') ||
          cleanedAiResponse.toLowerCase().contains('interview completed') ||
          cleanedAiResponse.toLowerCase().contains('end of interview');

      debugPrint(
        'DEBUG: AI Response: ${aiResponse.substring(0, aiResponse.length > 100 ? 100 : aiResponse.length)}...',
      );
      debugPrint(
        'DEBUG: Question number: $questionNumber, Max questions: ${_session.config.numberOfQuestions}',
      );
      debugPrint('DEBUG: Is interview complete: $isInterviewComplete');

      final status =
          isInterviewComplete
              ? InterviewStatus.completed
              : InterviewStatus.inProgress;

      _session = _session.copyWith(
        messages: [..._session.messages, aiMessage],
        currentQuestionNumber: questionNumber,
        status: status,
      );

      emit(InterviewInProgress(_session));
      add(SpeakResponse(cleanedAiResponse));
    } catch (e) {
      emit(InterviewError(e.toString()));
    }
  }

  void _onStartListening(StartListening event, Emitter<InterviewState> emit) {
    _session = _session.copyWith(isListening: true);
    emit(InterviewInProgress(_session));

    _handleSpeechUseCase.startListening(
      onResult: (text) => add(UpdateListeningText(text)),
      onComplete: () => add(StopListening()),
    );
  }

  void _onStopListening(StopListening event, Emitter<InterviewState> emit) {
    _handleSpeechUseCase.stopListening();

    if (_session.currentUserResponse.isNotEmpty) {
      add(SendUserResponse(_session.currentUserResponse));
    }

    _session = _session.copyWith(isListening: false, currentUserResponse: '');

    emit(InterviewInProgress(_session));
  }

  void _onUpdateListeningText(
    UpdateListeningText event,
    Emitter<InterviewState> emit,
  ) {
    _session = _session.copyWith(currentUserResponse: event.text);
    emit(InterviewInProgress(_session));
  }

  void _onSpeakResponse(SpeakResponse event, Emitter<InterviewState> emit) {
    _session = _session.copyWith(isSpeaking: true);
    emit(InterviewInProgress(_session));

    _handleSpeechUseCase.speak(
      event.text,
      onComplete: () => add(CompleteSpeaking()),
    );
  }

  void _onCompleteSpeaking(
    CompleteSpeaking event,
    Emitter<InterviewState> emit,
  ) {
    _session = _session.copyWith(isSpeaking: false);
    emit(InterviewInProgress(_session));

    // Start listening after speaking unless interview is explicitly completed
    // This ensures we listen for the answer to the final question
    if (_session.status != InterviewStatus.completed) {
      add(StartListening());
    }
  }
}
