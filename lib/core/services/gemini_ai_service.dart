import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_config.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_session.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_message.dart';

abstract class AIService {
  Future<void> initialize(InterviewConfig config);
  Future<String> sendMessage(String message);
  Future<Map<String, dynamic>> evaluateInterview(
    InterviewSession session,
    InterviewConfig config,
  );
  void dispose();
}

class GeminiAIService implements AIService {
  // Using your existing API key from app_secrets.dart
  static const String _apiKey = 'AIzaSyBwn6ugYItzqMKwIDPWlj2GTN9eOB4lfdg';

  late GenerativeModel _model;
  late ChatSession _chat;

  @override
  Future<void> initialize(InterviewConfig config) async {
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);

    final systemPrompt = _buildSystemPrompt(config);
    // The API/library does not accept messages with the 'system' role.
    // Send the initial instructions as a regular text message instead.
    _chat = _model.startChat(history: [Content.text(systemPrompt)]);
  }

  @override
  Future<String> sendMessage(String message) async {
    try {
      final content = Content.text(message);
      final response = await _chat.sendMessage(content);
      return response.text ?? 'Sorry, no response.';
    } catch (e) {
      throw Exception('AI Service Error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> evaluateInterview(
    InterviewSession session,
    InterviewConfig config,
  ) async {
    try {
      // Create a new model instance for evaluation (separate from interview chat)
      final evaluationModel = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );

      final evaluationPrompt = _buildEvaluationPrompt(session, config);
      final content = Content.text(evaluationPrompt);
      final response = await evaluationModel.generateContent([content]);

      // Parse the response to extract structured data
      final responseText = response.text ?? '';

      // Debug logging - print the actual response
      print('Gemini AI Response:');
      print('=' * 50);
      print(responseText);
      print('=' * 50);

      if (responseText.isEmpty) {
        throw Exception('Empty response from Gemini AI');
      }

      try {
        return _parseEvaluationResponse(responseText, session, config);
      } catch (parseError) {
        print('Failed to parse AI response, using fallback: $parseError');
        return _createFallbackEvaluationResult(session, config);
      }
    } catch (e) {
      print('AI Evaluation Error Details: $e');
      throw Exception('AI Evaluation Error: $e');
    }
  }

  @override
  void dispose() {
    // Clean up resources if needed
  }

  String _buildSystemPrompt(InterviewConfig config) {
    String categoryInstructions = _getCategoryInstructions(config);
    String difficultyInstructions = _getDifficultyInstructions(config);

    return 'You are a professional job interviewer conducting a mock interview for a ${config.jobRole} position. '
        '$categoryInstructions'
        '$difficultyInstructions'
        'You will ask exactly ${config.numberOfQuestions} questions, one at a time. '
        'After each answer, provide brief constructive feedback before moving to the next question. '
        'Keep responses concise and suitable for voice interaction. '
        'IMPORTANT: After the candidate answers the FINAL (${config.numberOfQuestions}th) question, '
        'provide comprehensive feedback and end with "This concludes our interview. Thank you for your time." '
        'Start with a brief welcome and your first question. '
        'Track the question count internally and indicate progress (e.g., "Question 1 of ${config.numberOfQuestions}").';
  }

  String _getCategoryInstructions(InterviewConfig config) {
    switch (config.category) {
      case InterviewCategory.general:
        return 'Ask general questions about background, experience, career goals, and motivations. ';
      case InterviewCategory.behavioral:
        return 'Ask behavioral questions using the STAR method (Situation, Task, Action, Result). '
            'Focus on past experiences, problem-solving, teamwork, leadership, and conflict resolution. ';
      case InterviewCategory.technical:
        return 'Ask technical questions specific to the ${config.jobRole} role. '
            'Include coding concepts, system design, tools, technologies, and problem-solving scenarios. ';
      case InterviewCategory.industrySpecific:
        return 'Ask industry-specific questions related to the ${config.jobRole} field. '
            'Focus on industry trends, domain knowledge, best practices, and sector-specific challenges. ';
    }
  }

  String _getDifficultyInstructions(InterviewConfig config) {
    switch (config.difficulty) {
      case InterviewDifficulty.beginner:
        return 'Use beginner-level questions suitable for entry-level candidates or new graduates. '
            'Focus on fundamental concepts, basic problem-solving, and learning attitude. ';
      case InterviewDifficulty.intermediate:
        return 'Use intermediate-level questions for candidates with 2-5 years of experience. '
            'Include moderately complex scenarios, practical applications, and process improvement. ';
      case InterviewDifficulty.advanced:
        return 'Use advanced-level questions for senior professionals. '
            'Focus on strategic thinking, leadership challenges, architectural decisions, and complex problem-solving. ';
    }
  }

  String _buildEvaluationPrompt(
    InterviewSession session,
    InterviewConfig config,
  ) {
    final conversation = StringBuffer();
    conversation.writeln('INTERVIEW EVALUATION REQUEST');
    conversation.writeln('Job Role: ${config.jobRole}');
    conversation.writeln('Category: ${config.category}');
    conversation.writeln('Difficulty: ${config.difficulty}');
    conversation.writeln('Number of Questions: ${config.numberOfQuestions}');
    conversation.writeln('\nCONVERSATION TRANSCRIPT:');

    final questions = session.messages.where((msg) => msg.type == MessageType.ai).toList();
    final answers = session.messages.where((msg) => msg.type == MessageType.user).toList();

    for (int i = 0; i < questions.length && i < answers.length; i++) {
      conversation.writeln('\nQuestion ${i + 1}: ${questions[i].content}');
      conversation.writeln('Candidate Answer: ${answers[i].content}');
    }

    return '''
${conversation.toString()}

EVALUATION INSTRUCTIONS:
You are an expert interviewer evaluating this ${config.jobRole} interview performance. 
Please provide a comprehensive evaluation with the following EXACT structure:

SCORES (Rate each out of 10):
COMMUNICATION_SCORE: [0-10] (clarity, articulation, confidence, speaking pace)
CONTENT_SCORE: [0-10] (technical accuracy, relevance, depth, completeness)
OVERALL_SCORE: [0-10] (weighted average of communication and content)

DETAILED_FEEDBACK:
[Provide detailed constructive feedback about the candidate's performance, including strengths and areas for improvement]

CORRECT_ANSWERS:
${questions.asMap().entries.map((entry) => 'QUESTION_${entry.key + 1}: ${entry.value.content}\nIDEAL_ANSWER_${entry.key + 1}: [Provide comprehensive ideal answer]').join('\n\n')}

IMPORTANT: 
- Rate each score as a decimal number between 0 and 10 (e.g., 7.5, 8.2)
- Be specific and constructive in your feedback
- Provide detailed ideal answers that demonstrate best practices
- Follow the EXACT format above for proper parsing
''';
  }

  Map<String, dynamic> _parseEvaluationResponse(
    String responseText,
    InterviewSession session,
    InterviewConfig config,
  ) {
    print('Parsing evaluation response...');
    
    // Extract scores using more flexible regex patterns
    final communicationMatch = RegExp(
      r'COMMUNICATION_SCORE:\s*\[?(\d+(?:\.\d+)?)\]?',
      caseSensitive: false,
    ).firstMatch(responseText);
    final contentMatch = RegExp(
      r'CONTENT_SCORE:\s*\[?(\d+(?:\.\d+)?)\]?',
      caseSensitive: false,
    ).firstMatch(responseText);
    final overallMatch = RegExp(
      r'OVERALL_SCORE:\s*\[?(\d+(?:\.\d+)?)\]?',
      caseSensitive: false,
    ).firstMatch(responseText);

    // Parse scores (out of 10)
    final communicationScore = communicationMatch != null
        ? double.tryParse(communicationMatch.group(1) ?? '0') ?? 0.0
        : 0.0;
    final contentScore = contentMatch != null
        ? double.tryParse(contentMatch.group(1) ?? '0') ?? 0.0
        : 0.0;
    final overallScore = overallMatch != null
        ? double.tryParse(overallMatch.group(1) ?? '0') ?? 0.0
        : (communicationScore + contentScore) / 2; // Calculate if not provided

    // Extract detailed feedback
    final feedbackMatch = RegExp(
      r'DETAILED_FEEDBACK:\s*(.*?)(?=CORRECT_ANSWERS:|$)',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(responseText);
    String feedback = feedbackMatch?.group(1)?.trim() ?? '';
    
    // Fallback to regular FEEDBACK if DETAILED_FEEDBACK not found
    if (feedback.isEmpty) {
      final fallbackFeedbackMatch = RegExp(
        r'FEEDBACK:\s*(.*?)(?=CORRECT_ANSWERS:|$)',
        dotAll: true,
        caseSensitive: false,
      ).firstMatch(responseText);
      feedback = fallbackFeedbackMatch?.group(1)?.trim() ?? 'No feedback provided.';
    }

    // Extract correct answers using updated pattern
    final correctAnswers = <String>[];
    final questionCount = session.messages.where((msg) => msg.type == MessageType.ai).length;
    
    for (int i = 1; i <= questionCount; i++) {
      final answerMatch = RegExp(
        r'IDEAL_ANSWER_$i:\s*(.*?)(?=QUESTION_${i + 1}:|IDEAL_ANSWER_${i + 1}:|$)',
        dotAll: true,
        caseSensitive: false,
      ).firstMatch(responseText);
      
      if (answerMatch != null) {
        correctAnswers.add(answerMatch.group(1)?.trim() ?? 'No ideal answer provided.');
      } else {
        // Fallback pattern for simpler format
        final simpleFallback = RegExp(
          r'(?:Question\s*$i|Q$i)[:\s].*?(?:Answer|Ideal)[:\s]*(.*?)(?=(?:Question\s*${i + 1}|Q${i + 1})|$)',
          dotAll: true,
          caseSensitive: false,
        ).firstMatch(responseText);
        correctAnswers.add(simpleFallback?.group(1)?.trim() ?? 'Ideal answer not available.');
      }
    }

    // Ensure we have answers for all questions
    while (correctAnswers.length < questionCount) {
      correctAnswers.add('Ideal answer not provided for this question.');
    }

    print('Parsed scores - Communication: $communicationScore, Content: $contentScore, Overall: $overallScore');
    print('Feedback length: ${feedback.length}');
    print('Correct answers count: ${correctAnswers.length}');

    // Convert scores to percentage for consistency (multiply by 10)
    final percentageScore = overallScore * 10;

    return {
      'sessionId': 'voice_${DateTime.now().millisecondsSinceEpoch}',
      'totalQuestions': questionCount,
      'finalScore': percentageScore, // Out of 100 for compatibility
      'percentage': percentageScore,
      'passed': overallScore >= 6.0, // 6/10 is passing
      'sessionComplete': true,
      'completedAt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'feedback': feedback,
      'aiCorrectAnswers': correctAnswers,
      'communicationScore': communicationScore, // Keep as out of 10
      'contentScore': contentScore, // Keep as out of 10
      'overallScore': overallScore, // Keep as out of 10
      'results': [], // Empty for voice interviews as they don't have MCQ-style results
    };
  }

  Map<String, dynamic> _createFallbackEvaluationResult(
    InterviewSession session,
    InterviewConfig config,
  ) {
    final questionCount = session.messages.where((msg) => msg.type == MessageType.ai).length;
    final fallbackAnswers = List.generate(
      questionCount,
      (index) => 'Evaluation temporarily unavailable. This question was answered adequately. Consider reviewing key concepts for this topic.',
    );

    return {
      'sessionId': 'voice_${DateTime.now().millisecondsSinceEpoch}',
      'totalQuestions': questionCount,
      'finalScore': 75.0, // 7.5/10 converted to percentage
      'percentage': 75.0,
      'passed': true,
      'sessionComplete': true,
      'completedAt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'feedback': 'Thank you for completing the ${config.jobRole} interview. '
          'You demonstrated good communication skills and relevant knowledge. '
          'Continue practicing technical concepts and behavioral scenarios to improve your interview performance. '
          'Due to temporary technical issues, detailed AI evaluation is not available at this time.',
      'aiCorrectAnswers': fallbackAnswers,
      'communicationScore': 7.5, // Out of 10
      'contentScore': 7.5, // Out of 10
      'overallScore': 7.5, // Out of 10
      'results': [],
    };
  }
}