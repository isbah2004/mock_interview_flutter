import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_config.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_message.dart';

class InterviewSession {
  final InterviewConfig config;
  final List<InterviewMessage> messages;
  final int currentQuestionNumber;
  final InterviewStatus status;
  final bool isListening;
  final bool isSpeaking;
  final String currentUserResponse;

  const InterviewSession({
    required this.config,
    this.messages = const [],
    this.currentQuestionNumber = 0,
    this.status = InterviewStatus.notStarted,
    this.isListening = false,
    this.isSpeaking = false,
    this.currentUserResponse = '',
  });

  InterviewSession copyWith({
    InterviewConfig? config,
    List<InterviewMessage>? messages,
    int? currentQuestionNumber,
    InterviewStatus? status,
    bool? isListening,
    bool? isSpeaking,
    String? currentUserResponse,
  }) {
    return InterviewSession(
      config: config ?? this.config,
      messages: messages ?? this.messages,
      currentQuestionNumber:
          currentQuestionNumber ?? this.currentQuestionNumber,
      status: status ?? this.status,
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      currentUserResponse: currentUserResponse ?? this.currentUserResponse,
    );
  }

  bool get isCompleted => currentQuestionNumber >= config.numberOfQuestions;
  double get progress => currentQuestionNumber / config.numberOfQuestions;
}

enum InterviewStatus { notStarted, inProgress, completed, error }
