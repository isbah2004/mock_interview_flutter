import 'package:mock_interview/core/services/openrouter_api_service.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_config.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_session.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_message.dart';
import 'package:mock_interview/core/services/gemini_ai_service/error_logger.dart';
import 'package:mock_interview/core/utils/app_logger.dart';

/// Service for conducting voice interviews using OpenRouter API
class VoiceInterviewService {
  List<Map<String, String>> _conversationHistory = [];

  // Retry configuration for 503 errors and network issues
  static const int maxRetries = 5; // Increased from 3 for network issues
  static const Duration baseDelay = Duration(
    seconds: 1,
  ); // Faster initial retry

  // Error tracking for monitoring
  static int _totalApiCalls = 0;
  static int _total503Errors = 0;
  static int _successfulRetries = 0;
  static final List<Map<String, dynamic>> _errorLog = [];

  /// Log error statistics for monitoring
  static void _logApiCallStats(
    String operation,
    bool success,
    int attempts,
    String? error,
  ) {
    _totalApiCalls++;

    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'operation': operation,
      'success': success,
      'attempts': attempts,
      'error': error,
    };

    _errorLog.add(logEntry);

    // Log current statistics
    AppLogger.info(
      'VoiceInterviewService: API Call Stats - Total: $_totalApiCalls, 503 Errors: $_total503Errors, Successful Retries: $_successfulRetries',
    );

    if (error?.contains('503') == true) {
      _total503Errors++;
      if (attempts > 1 && success) {
        _successfulRetries++;
      }
      AppLogger.info(
        'VoiceInterviewService: 503 Error Rate - ${(_total503Errors / _totalApiCalls * 100).toStringAsFixed(1)}%',
      );
      AppLogger.info(
        'VoiceInterviewService: 503 Retry Success Rate - ${_total503Errors > 0 ? (_successfulRetries / _total503Errors * 100).toStringAsFixed(1) : 0}%',
      );
    }

    // Keep only last 50 entries to prevent memory issues
    if (_errorLog.length > 50) {
      _errorLog.removeAt(0);
    }
  }

  /// Get error statistics for debugging
  static Map<String, dynamic> getErrorStats() {
    return {
      'totalApiCalls': _totalApiCalls,
      'total503Errors': _total503Errors,
      'successfulRetries': _successfulRetries,
      'errorRate503':
          _totalApiCalls > 0 ? (_total503Errors / _totalApiCalls * 100) : 0.0,
      'retrySuccessRate':
          _total503Errors > 0
              ? (_successfulRetries / _total503Errors * 100)
              : 0.0,
      'recentErrors': _errorLog.take(10).toList(),
    };
  }

  /// Retry mechanism with exponential backoff for API calls
  Future<T> _retryApiCall<T>(
    Future<T> Function() apiCall,
    String operation,
  ) async {
    int attempt = 0;
    String? lastError;

    while (attempt < maxRetries) {
      try {
        AppLogger.info(
          'VoiceInterviewService: Attempting $operation (attempt ${attempt + 1}/$maxRetries)',
        );
        final result = await apiCall();

        // Log successful API call
        _logApiCallStats(operation, true, attempt + 1, lastError);

        if (attempt > 0) {
          AppLogger.info(
            'VoiceInterviewService: $operation succeeded on attempt ${attempt + 1}',
          );
        }
        return result;
      } catch (e) {
        attempt++;
        lastError = e.toString();

        // Log all errors with full context
        AppLogger.error(
          'VoiceInterviewService: $operation failed on attempt $attempt/$maxRetries - Error: $e',
        );
        AppLogger.error('VoiceInterviewService: Error type: ${e.runtimeType}');
        AppLogger.error(
          'VoiceInterviewService: Error toString: ${e.toString()}',
        );

        // Log error with comprehensive context
        GeminiErrorLogger.logError(
          service: 'VoiceInterviewService',
          operation: operation,
          error: e.toString(),
          context: {
            'attempt': attempt,
            'maxRetries': maxRetries,
            'operation': operation,
          },
          stackTrace: e is Error ? e.stackTrace?.toString() : null,
        );

        // Log error with comprehensive context
        GeminiErrorLogger.logError(
          service: 'VoiceInterviewService',
          operation: operation,
          error: e.toString(),
          context: {
            'attempt': attempt,
            'maxRetries': maxRetries,
            'operation': operation,
          },
          stackTrace: e is Error ? e.stackTrace?.toString() : null,
        );

        // Check if it's a retryable error (503, network errors, connection issues)
        final errorString = e.toString().toLowerCase();
        final isRetryableError =
            errorString.contains('503') ||
            errorString.contains('service unavailable') ||
            errorString.contains('temporarily unavailable') ||
            errorString.contains('connection reset by peer') ||
            errorString.contains('socketexception') ||
            errorString.contains('connection failed') ||
            errorString.contains('connection timed out') ||
            errorString.contains('network error') ||
            errorString.contains('errno = 104');

        if (isRetryableError && attempt < maxRetries) {
          final delay = Duration(
            seconds: baseDelay.inSeconds * (1 << (attempt - 1)),
          );
          AppLogger.warn(
            'VoiceInterviewService: Retryable error detected on attempt $attempt/$maxRetries for $operation',
          );
          AppLogger.warn(
            'VoiceInterviewService: Error type: ${errorString.contains('503') ? '503 Service Unavailable' : 'Network/Connection Error'}',
          );
          AppLogger.warn(
            'VoiceInterviewService: Implementing exponential backoff - waiting ${delay.inSeconds} seconds before retry...',
          );
          AppLogger.debug(
            'VoiceInterviewService: Retry strategy: ${delay.inSeconds}s delay (base: ${baseDelay.inSeconds}s, multiplier: ${1 << (attempt - 1)})',
          );

          await Future.delayed(delay);
          continue;
        }

        // Log final failure details
        if (attempt >= maxRetries) {
          AppLogger.error(
            'VoiceInterviewService: All retry attempts exhausted for $operation',
          );
          if (isRetryableError) {
            AppLogger.error(
              'VoiceInterviewService: Retryable errors persisted through all $maxRetries attempts - API/Network may be experiencing extended issues',
            );
          }

          // Log failed API call
          _logApiCallStats(operation, false, attempt, lastError);
        } else if (!isRetryableError) {
          AppLogger.error(
            'VoiceInterviewService: Non-retryable error encountered - will not retry: $e',
          );

          // Log failed API call for non-retryable errors
          _logApiCallStats(operation, false, attempt, lastError);
        }

        // If it's not a retryable error or we've exhausted retries, rethrow
        rethrow;
      }
    }

    throw Exception('Max retries exceeded for $operation');
  }

  /// Initialize voice interview with configuration
  Future<void> initialize(InterviewConfig config) async {
    try {
      AppLogger.info(
        'VoiceInterviewService: Initializing with config - Job: ${config.jobRole}, Category: ${config.category}, Difficulty: ${config.difficulty}',
      );

      // Initialize conversation history with system prompt
      final systemPrompt = _buildSystemPrompt(config);
      _conversationHistory = [
        {'role': 'system', 'content': systemPrompt},
      ];

      AppLogger.info(
        'VoiceInterviewService: Successfully initialized conversation with system prompt',
      );
    } catch (e) {
      AppLogger.error(
        'VoiceInterviewService: Failed to initialize - Error: $e',
      );
      AppLogger.error('VoiceInterviewService: Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  /// Send message and get AI response
  Future<String> sendMessage(String message) async {
    return await _retryApiCall(() async {
      try {
        AppLogger.debug(
          'VoiceInterviewService: Sending message - Length: ${message.length} chars',
        );

        // Check if user wants to skip the question
        String processedMessage = _processUserMessage(message);

        if (processedMessage != message) {
          AppLogger.info(
            'VoiceInterviewService: Skip request detected and processed',
          );
        }

        // Add user message to conversation history
        _conversationHistory.add({'role': 'user', 'content': processedMessage});

        // Create prompt with conversation history
        final prompt = _buildConversationPrompt();

        final responseText = await OpenRouterApiService.generateText(
          prompt: prompt,
          temperature: 0.7,
          maxTokens: 4000,
        );

        // Add AI response to conversation history
        _conversationHistory.add({
          'role': 'assistant',
          'content': responseText,
        });

        AppLogger.debug(
          'VoiceInterviewService: Received response - Length: ${responseText.length} chars',
        );
        return responseText;
      } catch (e) {
        AppLogger.error(
          'VoiceInterviewService: sendMessage failed - Error: $e',
        );
        AppLogger.error('VoiceInterviewService: Error type: ${e.runtimeType}');
        AppLogger.debug(
          'VoiceInterviewService: Message that caused error: "${message.substring(0, message.length > 100 ? 100 : message.length)}${message.length > 100 ? '...' : ''}"',
        );

        // Specific error handling for different error types
        if (e.toString().contains('503')) {
          AppLogger.warn(
            'VoiceInterviewService: 503 Service Unavailable - Will retry with backoff',
          );
          rethrow; // Let the retry mechanism handle it
        } else if (e.toString().toLowerCase().contains(
              'connection reset by peer',
            ) ||
            e.toString().toLowerCase().contains('socketexception') ||
            e.toString().toLowerCase().contains('errno = 104')) {
          AppLogger.warn(
            'VoiceInterviewService: Network connection error - Will retry with backoff',
          );
          rethrow; // Let the retry mechanism handle it
        } else if (e.toString().contains('429')) {
          AppLogger.warn(
            'VoiceInterviewService: 429 Rate Limit Exceeded - Too many requests',
          );
          throw Exception(
            'Rate limit exceeded (429): Please wait before sending another message.',
          );
        } else if (e.toString().contains('401')) {
          AppLogger.error(
            'VoiceInterviewService: 401 Unauthorized - Invalid API key',
          );
          throw Exception('Authentication failed (401): Invalid API key.');
        } else if (e.toString().contains('400')) {
          AppLogger.error(
            'VoiceInterviewService: 400 Bad Request - Invalid request format',
          );
          throw Exception(
            'Bad request (400): Invalid message format or content.',
          );
        } else if (e.toString().contains('timeout')) {
          AppLogger.warn('VoiceInterviewService: Request timeout');
          throw Exception(
            'Request timeout: The AI service took too long to respond.',
          );
        } else {
          AppLogger.error('VoiceInterviewService: Unknown error occurred');
          throw Exception('AI Service Error: $e');
        }
      }
    }, 'sendMessage');
  }

  /// Process user message to detect skip requests and handle them appropriately
  String _processUserMessage(String message) {
    final lowerMessage = message.toLowerCase().trim();

    // List of phrases that indicate user wants to skip
    final skipPhrases = [
      'skip',
      'skip this',
      'skip this question',
      'skip question',
      'next question',
      'move to next',
      'move to the next',
      'pass',
      'pass this',
      'pass this question',
      'i don\'t want to answer',
      'don\'t want to answer',
      'i don\'t know',
      'no answer',
      'i\'d rather not answer',
      'rather not answer',
      'can we skip this',
      'let\'s skip this',
      'next',
      'move on',
      'i prefer not to answer',
      'prefer not to answer',
      'i\'ll skip this',
      'i\'ll pass',
      'no comment',
    ];

    // Check if the message matches any skip phrases
    bool isSkipRequest = skipPhrases.any(
      (phrase) =>
          lowerMessage == phrase ||
          lowerMessage.startsWith('$phrase ') ||
          lowerMessage.endsWith(' $phrase') ||
          lowerMessage.contains(' $phrase '),
    );

    if (isSkipRequest) {
      AppLogger.info(
        'VoiceInterviewService: User requested to skip question - Original: "$message"',
      );
      return 'I would prefer to skip this question and move to the next one.';
    }

    return message;
  }

  /// Build conversation prompt from history
  String _buildConversationPrompt() {
    final buffer = StringBuffer();

    for (final message in _conversationHistory) {
      final role = message['role']!;
      final content = message['content']!;

      if (role == 'system') {
        buffer.writeln('System: $content');
      } else if (role == 'user') {
        buffer.writeln('Human: $content');
      } else if (role == 'assistant') {
        buffer.writeln('Assistant: $content');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Evaluate completed voice interview
  Future<Map<String, dynamic>> evaluateInterview(
    InterviewSession session,
    InterviewConfig config,
  ) async {
    return await _retryApiCall(() async {
      try {
        AppLogger.info('VoiceInterviewService: Starting interview evaluation');
        AppLogger.info(
          'VoiceInterviewService: Session status: ${session.status}',
        );
        AppLogger.info(
          'VoiceInterviewService: Message count: ${session.messages.length}',
        );
        AppLogger.info(
          'VoiceInterviewService: Current question: ${session.currentQuestionNumber}',
        );
        AppLogger.info(
          'VoiceInterviewService: Config - Job: ${config.jobRole}, Category: ${config.category}',
        );

        // Create evaluation request using OpenRouter API
        final evaluationPrompt = _buildEvaluationPrompt(session, config);
        AppLogger.debug(
          'VoiceInterviewService: Generated evaluation prompt - Length: ${evaluationPrompt.length} chars',
        );

        AppLogger.info(
          'VoiceInterviewService: Sending evaluation request to OpenRouter API',
        );
        final responseText = await OpenRouterApiService.generateText(
          prompt: evaluationPrompt,
          temperature: 0.3, // Lower temperature for more consistent evaluation
          maxTokens: 4000,
        );

        AppLogger.debug(
          'VoiceInterviewService: Received evaluation response - Length: ${responseText.length} chars',
        );

        // Debug logging - log the actual response
        AppLogger.info(
          'VoiceInterviewService: OpenRouter AI Evaluation Response:',
        );
        AppLogger.debug('=' * 50);
        AppLogger.debug(responseText);
        AppLogger.debug('=' * 50);

        if (responseText.isEmpty) {
          AppLogger.error(
            'VoiceInterviewService: ERROR - Empty response from Gemini AI',
          );
          throw Exception('Empty response from Gemini AI');
        }

        try {
          AppLogger.debug('VoiceInterviewService: Parsing evaluation response');
          final result = _parseEvaluationResponse(
            responseText,
            session,
            config,
          );
          AppLogger.info(
            'VoiceInterviewService: Successfully parsed evaluation result',
          );
          return result;
        } catch (parseError) {
          AppLogger.error(
            'VoiceInterviewService: Failed to parse AI response: $parseError',
          );
          AppLogger.warn(
            'VoiceInterviewService: Using fallback evaluation result',
          );
          return _createFallbackEvaluationResult(session, config);
        }
      } catch (e) {
        AppLogger.error(
          'VoiceInterviewService: evaluateInterview failed - Error: $e',
        );
        AppLogger.error('VoiceInterviewService: Error type: ${e.runtimeType}');
        AppLogger.debug(
          'VoiceInterviewService: Session details - Status: ${session.status}, Messages: ${session.messages.length}, Question: ${session.currentQuestionNumber}',
        );

        // Specific error handling for different error types
        if (e.toString().contains('503')) {
          AppLogger.warn(
            'VoiceInterviewService: 503 Service Unavailable during evaluation - Will retry with backoff',
          );
          rethrow; // Let the retry mechanism handle it
        } else if (e.toString().contains('429')) {
          AppLogger.warn(
            'VoiceInterviewService: 429 Rate Limit Exceeded during evaluation',
          );
          throw Exception(
            'Rate limit exceeded (429): Please wait before requesting evaluation.',
          );
        } else if (e.toString().contains('401')) {
          AppLogger.error(
            'VoiceInterviewService: 401 Unauthorized during evaluation - Invalid API key',
          );
          throw Exception(
            'Authentication failed (401): Invalid API key for evaluation.',
          );
        } else if (e.toString().contains('400')) {
          AppLogger.error(
            'VoiceInterviewService: 400 Bad Request during evaluation - Invalid prompt',
          );
          throw Exception(
            'Bad request (400): Invalid evaluation prompt format.',
          );
        } else if (e.toString().contains('timeout')) {
          AppLogger.warn(
            'VoiceInterviewService: Request timeout during evaluation - Will use fallback',
          );
          return _createFallbackEvaluationResult(session, config);
        } else {
          AppLogger.error(
            'VoiceInterviewService: Unknown error during evaluation',
          );
          throw Exception('AI Evaluation Error: $e');
        }
      }
    }, 'evaluateInterview');
  }

  /// Build system prompt for voice interview
  String _buildSystemPrompt(InterviewConfig config) {
    String categoryInstructions = _getCategoryInstructions(config);
    String difficultyInstructions = _getDifficultyInstructions(config);

    return 'You are a professional job interviewer conducting a mock interview for a ${config.jobRole} position. '
        '$categoryInstructions'
        '$difficultyInstructions'
        'You will ask exactly ${config.numberOfQuestions} questions, one at a time. '
        'FEEDBACK GUIDELINES: After each answer from the candidate, provide constructive feedback following this structure: '
        '1. ACKNOWLEDGE: Start with positive acknowledgment (e.g., "Thank you for that response" or "I appreciate your perspective") '
        '2. EVALUATE: Provide specific feedback on their answer: '
        '   - If the answer is strong: Highlight what they did well, mention specific strengths, and encourage them '
        '   - If the answer needs improvement: Constructively point out areas for enhancement without being harsh '
        '   - If the answer is incomplete: Suggest what additional points could strengthen their response '
        '3. GUIDE: Offer a brief tip or insight that could help them in similar future questions '
        '4. TRANSITION: Smoothly move to the next question with appropriate question numbering '
        'EXAMPLE FEEDBACK STYLES: '
        '- For good answers: "Excellent! Your specific example about [detail] demonstrates strong [skill]. This shows great [quality]. Moving to question 2..." '
        '- For weak answers: "I understand your point about [acknowledgment]. To strengthen this, consider mentioning [suggestion]. For future interviews, try to include [tip]. Let\'s continue with question 2..." '
        '- For incomplete answers: "That\'s a good start with [what they mentioned]. Adding examples about [specific area] would make your response more compelling. Now for question 2..." '
        'Keep feedback concise (2-3 sentences) and suitable for voice interaction. Be encouraging while being honest about areas for improvement. '
        'IMPORTANT SKIP HANDLING: If a candidate says they want to skip a question, prefer not to answer, '
        'or express reluctance to respond, DO NOT repeat the question or insist. Instead, respond with: '
        '"That\'s perfectly fine. Let\'s move on to the next question." Then immediately proceed to the next question. '
        'Do not provide feedback on skipped questions. Simply acknowledge and move forward. '
        'IMPORTANT: After the candidate answers the FINAL (${config.numberOfQuestions}th) question, '
        'provide detailed feedback on their final answer using the same feedback structure, then give brief overall interview feedback highlighting: '
        '- Their strongest responses and skills demonstrated '
        '- Key areas for improvement across all answers '
        '- One specific tip for future interviews '
        'End with "This concludes our interview. Thank you for your time and best of luck!" '
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

  /// Build evaluation prompt for voice interview
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

    final questions =
        session.messages.where((msg) => msg.type == MessageType.ai).toList();
    final answers =
        session.messages.where((msg) => msg.type == MessageType.user).toList();

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

  /// Parse evaluation response from Gemini AI
  Map<String, dynamic> _parseEvaluationResponse(
    String responseText,
    InterviewSession session,
    InterviewConfig config,
  ) {
    AppLogger.debug('Parsing evaluation response...');

    // Extract scores using more flexible regex patterns
    final communicationMatch = RegExp(
      r'COMMUNICATION_SCORE:\s*([0-9.]+)',
      caseSensitive: false,
    ).firstMatch(responseText);
    final contentMatch = RegExp(
      r'CONTENT_SCORE:\s*([0-9.]+)',
      caseSensitive: false,
    ).firstMatch(responseText);
    final overallMatch = RegExp(
      r'OVERALL_SCORE:\s*([0-9.]+)',
      caseSensitive: false,
    ).firstMatch(responseText);

    // Parse scores (out of 10)
    final communicationScore =
        double.tryParse(communicationMatch?.group(1) ?? '0') ?? 0.0;
    final contentScore = double.tryParse(contentMatch?.group(1) ?? '0') ?? 0.0;
    final overallScore = double.tryParse(overallMatch?.group(1) ?? '0') ?? 0.0;

    // Extract detailed feedback
    final feedbackMatch = RegExp(
      r'DETAILED_FEEDBACK:\s*(.*?)(?=CORRECT_ANSWERS:|$)',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(responseText);
    String feedback = feedbackMatch?.group(1)?.trim() ?? '';

    // Fallback to regular FEEDBACK if DETAILED_FEEDBACK not found
    if (feedback.isEmpty) {
      final fallbackMatch = RegExp(
        r'FEEDBACK:\s*(.*?)(?=CORRECT_ANSWERS:|$)',
        dotAll: true,
        caseSensitive: false,
      ).firstMatch(responseText);
      feedback = fallbackMatch?.group(1)?.trim() ?? 'No feedback available.';
    }

    // Extract correct answers using updated pattern
    final correctAnswers = <String>[];
    final questionCount =
        session.messages.where((msg) => msg.type == MessageType.ai).length;

    for (int i = 1; i <= questionCount; i++) {
      final answerPattern = RegExp(
        r'IDEAL_ANSWER_$i:\s*(.*?)(?=QUESTION_|IDEAL_ANSWER_|$)',
        dotAll: true,
        caseSensitive: false,
      );
      final match = answerPattern.firstMatch(responseText);
      correctAnswers.add(
        match?.group(1)?.trim() ?? 'No ideal answer provided.',
      );
    }

    // Ensure we have answers for all questions
    while (correctAnswers.length < questionCount) {
      correctAnswers.add('No ideal answer provided.');
    }

    AppLogger.info(
      'Parsed scores - Communication: $communicationScore, Content: $contentScore, Overall: $overallScore',
    );
    AppLogger.info('Feedback length: ${feedback.length}');
    AppLogger.info('Correct answers count: ${correctAnswers.length}');

    // Convert scores to percentage for consistency (multiply by 10)
    final percentageScore = overallScore * 10;

    return {
      'communicationScore': communicationScore,
      'contentScore': contentScore,
      'overallScore': overallScore,
      'percentageScore': percentageScore,
      'feedback': feedback,
      'correctAnswers': correctAnswers,
      'evaluationDate': DateTime.now().toIso8601String(),
    };
  }

  /// Create fallback evaluation result if parsing fails
  Map<String, dynamic> _createFallbackEvaluationResult(
    InterviewSession session,
    InterviewConfig config,
  ) {
    final questionCount =
        session.messages.where((msg) => msg.type == MessageType.ai).length;
    final answeredCount =
        session.messages
            .where(
              (msg) =>
                  msg.type == MessageType.user && msg.content.trim().isNotEmpty,
            )
            .length;

    // Conservative fallback scoring based on participation
    double participationScore =
        questionCount > 0
            ? (answeredCount / questionCount) * 30.0
            : 0.0; // Max 30% for participation

    final fallbackAnswers = List.generate(
      questionCount,
      (index) => 'Please review standard practices for this question.',
    );

    AppLogger.info(
      'VoiceInterviewService: Fallback evaluation - $answeredCount/$questionCount questions answered, score: $participationScore%',
    );

    return {
      'communicationScore': participationScore * 0.1, // 0-3 points
      'contentScore': participationScore * 0.1, // 0-3 points
      'overallScore': participationScore * 0.1, // 0-3 points
      'percentageScore': participationScore, // 0-30%
      'feedback':
          answeredCount == 0
              ? 'No responses were provided during the interview. Please try again and answer the questions.'
              : 'Interview completed with limited responses ($answeredCount/$questionCount questions answered). Please review your answers and continue practicing.',
      'correctAnswers': fallbackAnswers,
      'evaluationDate': DateTime.now().toIso8601String(),
    };
  }
}
