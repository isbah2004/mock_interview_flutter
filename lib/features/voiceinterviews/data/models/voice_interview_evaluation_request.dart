import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_message.dart';

class VoiceInterviewEvaluationRequest {
  final String sessionId;
  final String userId;
  final String jobRole;
  final String difficultyLevel;
  final String category;
  final List<InterviewMessage> messages;

  const VoiceInterviewEvaluationRequest({
    required this.sessionId,
    required this.userId,
    required this.jobRole,
    required this.difficultyLevel,
    required this.category,
    required this.messages,
  });

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'user_id': userId,
      'job_role': jobRole,
      'difficulty_level': difficultyLevel,
      'category': category,
      'interview_type': 'voice',
      'messages': messages
          .map(
            (msg) => {
              'type': msg.type.toString().split('.').last,
              'content': msg.content ?? '', // Handle null content
              'timestamp': msg.timestamp.toIso8601String(),
            },
          )
          .toList(),
    };
  }
}