

class SubmitAnswerRequest {
  final String userId;
  final String jobRole;
  final String interviewType;
  final String difficultyLevel;
  final int numQuestions;
  final String category;
  final List<String> answers;
  final String sessionId; // This is actually session_id in your API

  SubmitAnswerRequest({
    required this.userId,
    required this.jobRole,
    required this.interviewType,
    required this.difficultyLevel,
    required this.numQuestions,
    required this.category,
    required this.answers,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'job_role': jobRole,
      'interview_type': interviewType,
      'difficulty_level': difficultyLevel,
      'num_questions': numQuestions,
      'category': category,
      'answers': answers,
      'question_id': sessionId,
    };
  }
}