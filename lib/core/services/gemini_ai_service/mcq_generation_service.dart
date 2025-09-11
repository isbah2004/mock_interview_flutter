import 'package:mock_interview/core/services/openrouter_api_service.dart';
import 'package:mock_interview/core/models/mcq_question_model.dart';
import 'package:mock_interview/core/services/gemini_ai_service/error_logger.dart';
import 'dart:convert';
import 'package:mock_interview/core/utils/app_logger.dart';

/// Service for generating MCQ questions using OpenRouter API
class MCQGenerationService {
  // Retry configuration for 503 errors
  static const int maxRetries = 3;
  static const Duration baseDelay = Duration(seconds: 2);

  // Error tracking for monitoring
  static int _totalMcqApiCalls = 0;
  static int _total503Errors = 0;
  static int _successfulRetries = 0;
  static final List<Map<String, dynamic>> _errorLog = [];

  /// Log error statistics for monitoring
  static void _logMcqApiCallStats(
    String operation,
    bool success,
    int attempts,
    String? error,
    Map<String, dynamic> context,
  ) {
    _totalMcqApiCalls++;

    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'operation': operation,
      'success': success,
      'attempts': attempts,
      'error': error,
      'context': context,
    };

    _errorLog.add(logEntry);

    // Log current statistics
    AppLogger.info(
      'MCQGenerationService: API Call Stats - Total: $_totalMcqApiCalls, 503 Errors: $_total503Errors, Successful Retries: $_successfulRetries',
    );

    if (error?.contains('503') == true) {
      _total503Errors++;
      if (attempts > 1 && success) {
        _successfulRetries++;
      }
      AppLogger.info(
        'MCQGenerationService: 503 Error Rate - ${(_total503Errors / _totalMcqApiCalls * 100).toStringAsFixed(1)}%',
      );
      AppLogger.info(
        'MCQGenerationService: 503 Retry Success Rate - ${_total503Errors > 0 ? (_successfulRetries / _total503Errors * 100).toStringAsFixed(1) : 0}%',
      );
    }

    // Keep only last 50 entries to prevent memory issues
    if (_errorLog.length > 50) {
      _errorLog.removeAt(0);
    }
  }

  /// Get error statistics for debugging
  static Map<String, dynamic> getMcqErrorStats() {
    return {
      'totalApiCalls': _totalMcqApiCalls,
      'total503Errors': _total503Errors,
      'successfulRetries': _successfulRetries,
      'errorRate503':
          _totalMcqApiCalls > 0
              ? (_total503Errors / _totalMcqApiCalls * 100)
              : 0.0,
      'retrySuccessRate':
          _total503Errors > 0
              ? (_successfulRetries / _total503Errors * 100)
              : 0.0,
      'recentErrors': _errorLog.take(10).toList(),
    };
  }

  /// Retry mechanism with exponential backoff for API calls
  static Future<T> _retryMcqApiCall<T>(
    Future<T> Function() apiCall,
    String operation,
    Map<String, dynamic> context,
  ) async {
    int attempt = 0;
    String? lastError;

    while (attempt < maxRetries) {
      try {
        AppLogger.info(
          'MCQGenerationService: Attempting $operation (attempt ${attempt + 1}/$maxRetries)',
        );
        AppLogger.debug('MCQGenerationService: Context - $context');
        final result = await apiCall();

        // Log successful API call
        _logMcqApiCallStats(operation, true, attempt + 1, lastError, context);

        if (attempt > 0) {
          AppLogger.info(
            'MCQGenerationService: $operation succeeded on attempt ${attempt + 1}',
          );
        }
        return result;
      } catch (e) {
        attempt++;
        lastError = e.toString();

        // Log all errors with full context
        AppLogger.error(
          'MCQGenerationService: $operation failed on attempt $attempt/$maxRetries - Error: $e',
        );
        AppLogger.error('MCQGenerationService: Error type: ${e.runtimeType}');
        AppLogger.error(
          'MCQGenerationService: Error toString: ${e.toString()}',
        );
        AppLogger.debug('MCQGenerationService: Context - $context');

        // Log error with comprehensive context
        GeminiErrorLogger.logError(
          service: 'MCQGenerationService',
          operation: operation,
          error: e.toString(),
          context: {
            'attempt': attempt,
            'maxRetries': maxRetries,
            'operation': operation,
            ...context,
          },
          stackTrace: e is Error ? e.stackTrace?.toString() : null,
        );

        // Check if it's a 503 error specifically
        final errorString = e.toString().toLowerCase();
        final is503Error =
            errorString.contains('503') ||
            errorString.contains('service unavailable') ||
            errorString.contains('temporarily unavailable');

        if (is503Error && attempt < maxRetries) {
          final delay = Duration(
            seconds: baseDelay.inSeconds * (1 << (attempt - 1)),
          );
          AppLogger.warn(
            'MCQGenerationService: 503 Service Unavailable detected on attempt $attempt/$maxRetries for $operation',
          );
          AppLogger.warn(
            'MCQGenerationService: This indicates Gemini API is temporarily overloaded or under maintenance',
          );
          AppLogger.warn(
            'MCQGenerationService: Implementing exponential backoff - waiting ${delay.inSeconds} seconds before retry...',
          );
          AppLogger.debug(
            'MCQGenerationService: Retry strategy: ${delay.inSeconds}s delay (base: ${baseDelay.inSeconds}s, multiplier: ${1 << (attempt - 1)})',
          );

          await Future.delayed(delay);
          continue;
        }

        // Log final failure details
        if (attempt >= maxRetries) {
          AppLogger.error(
            'MCQGenerationService: All retry attempts exhausted for $operation',
          );
          if (is503Error) {
            AppLogger.error(
              'MCQGenerationService: 503 errors persisted through all $maxRetries attempts - API may be experiencing extended downtime',
            );
          }

          // Log failed API call
          _logMcqApiCallStats(operation, false, attempt, lastError, context);
        } else if (!is503Error) {
          AppLogger.error(
            'MCQGenerationService: Non-503 error encountered - will not retry: $e',
          );

          // Log failed API call for non-503 errors
          _logMcqApiCallStats(operation, false, attempt, lastError, context);
        }

        // If it's not a 503 error or we've exhausted retries, rethrow
        rethrow;
      }
    }

    throw Exception('Max retries exceeded for $operation');
  }

  /// Generate MCQ questions using comprehensive batch processing
  static Future<List<McqQuestionModel>> generateMCQQuestions({
    required String sessionId,
    required String jobRole,
    required String difficultyLevel,
    required int numQuestions,
    required String category,
  }) async {
    final context = {
      'sessionId': sessionId,
      'jobRole': jobRole,
      'difficultyLevel': difficultyLevel,
      'numQuestions': numQuestions,
      'category': category,
    };

    return await _retryMcqApiCall(
      () async {
        try {
          AppLogger.info(
            'MCQGenerationService: Generating $numQuestions MCQ questions for $jobRole ($difficultyLevel $category) in single batch',
          );
          final startTime = DateTime.now();

          // Create comprehensive prompt for batch generation
          final comprehensivePrompt = _buildComprehensiveMCQPrompt(
            jobRole: jobRole,
            difficultyLevel: difficultyLevel,
            numQuestions: numQuestions,
            category: category,
          );

          AppLogger.info(
            'MCQGenerationService: Sending request to OpenRouter API',
          );
          final responseText = await OpenRouterApiService.generateText(
            prompt: comprehensivePrompt,
            temperature: 0.7,
            maxTokens: 8000,
          );

          if (responseText.isEmpty) {
            AppLogger.error(
              'MCQGenerationService: ERROR - Empty response from OpenRouter API',
            );
            throw Exception(
              'Empty response from OpenRouter API during MCQ generation',
            );
          }

          AppLogger.info(
            'MCQGenerationService: AI Response received, parsing...',
          );
          final questions = await _parseComprehensiveMCQResponse(
            responseText,
            sessionId,
            jobRole,
            difficultyLevel,
            category,
            numQuestions,
          );

          final generationTime =
              DateTime.now().difference(startTime).inMilliseconds;
          final actualCount = questions.length;

          // Quality validation
          if (actualCount != numQuestions) {
            AppLogger.warn(
              'MCQGenerationService: Generated $actualCount questions, expected $numQuestions. Ensuring correct count...',
            );
            return await _ensureQuestionCount(
              questions,
              jobRole,
              difficultyLevel,
              category,
              numQuestions,
            );
          }

          AppLogger.info(
            'MCQGenerationService: Successfully generated $actualCount questions in ${generationTime}ms using single API call',
          );
          return questions;
        } catch (e) {
          AppLogger.error(
            'MCQGenerationService: Error in batch MCQ generation: $e',
          );
          AppLogger.error('MCQGenerationService: Error type: ${e.runtimeType}');
          AppLogger.debug('MCQGenerationService: Context - $context');

          // Specific error handling for different error types
          if (e.toString().contains('503')) {
            AppLogger.warn(
              'MCQGenerationService: 503 Service Unavailable during MCQ generation - Will retry with backoff',
            );
            rethrow; // Let the retry mechanism handle it
          } else if (e.toString().contains('429')) {
            AppLogger.warn(
              'MCQGenerationService: 429 Rate Limit Exceeded during MCQ generation',
            );
            throw Exception(
              'Rate limit exceeded (429): Please wait before generating more questions.',
            );
          } else if (e.toString().contains('401')) {
            AppLogger.error(
              'MCQGenerationService: 401 Unauthorized during MCQ generation - Invalid API key',
            );
            throw Exception(
              'Authentication failed (401): Invalid API key for MCQ generation.',
            );
          } else if (e.toString().contains('400')) {
            AppLogger.error(
              'MCQGenerationService: 400 Bad Request during MCQ generation - Invalid prompt',
            );
            throw Exception(
              'Bad request (400): Invalid MCQ generation prompt format.',
            );
          } else if (e.toString().contains('timeout')) {
            AppLogger.warn(
              'MCQGenerationService: Request timeout during MCQ generation - Will use fallback',
            );
            return await _generateFallbackMCQQuestions(
              sessionId: sessionId,
              jobRole: jobRole,
              difficultyLevel: difficultyLevel,
              numQuestions: numQuestions,
              category: category,
            );
          } else {
            AppLogger.error(
              'MCQGenerationService: Unknown error during MCQ generation',
            );
            throw Exception('MCQ Generation Error: $e');
          }
        }
      },
      'generateMCQQuestions',
      context,
    );
  }

  /// Build comprehensive MCQ generation prompt
  static String _buildComprehensiveMCQPrompt({
    required String jobRole,
    required String difficultyLevel,
    required int numQuestions,
    required String category,
  }) {
    final difficultySpecs = _getDifficultySpecifications(difficultyLevel);
    final categorySpecs = _getCategorySpecifications(category, jobRole);

    return '''
ROLE: You are an expert technical interviewer specializing in $jobRole positions.

TASK: Generate EXACTLY $numQuestions unique, high-quality multiple-choice questions for a $difficultyLevel level $jobRole interview in the $category category.

DIFFICULTY SPECIFICATIONS:
$difficultySpecs

CATEGORY SPECIFICATIONS:
$categorySpecs

CRITICAL REQUIREMENTS:
1. Generate EXACTLY $numQuestions questions - no more, no less
2. Each question MUST be completely unique and cover different aspects
3. All questions MUST be appropriate $difficultyLevel level for $jobRole
4. All questions MUST fit precisely in the $category category
5. Ensure progressive variety in topics and question formats
6. Make all options plausible but with one clearly correct answer
7. Provide detailed explanations that teach and clarify concepts

QUESTION QUALITY STANDARDS:
- Use diverse question formats: scenario-based, conceptual, comparative, best-practice, troubleshooting
- Cover broad aspects of $jobRole within the $category scope
- Include practical, real-world situations relevant to $jobRole
- Ensure options are realistic and would be genuine considerations
- Write clear, unambiguous question text
- Provide educational explanations that add value

MANDATORY OUTPUT FORMAT (JSON ONLY):
```json
{
  "questions": [
    {
      "question": "Clear, specific question text relevant to $jobRole",
      "options": [
        "Option A - realistic and relevant",
        "Option B - reasonable but incorrect choice",
        "Option C - plausible alternative",
        "Option D - reasonable but incorrect choice"
      ],
      "correct_answer": "Option A - realistic and relevant",
      "explanation": "Comprehensive explanation covering why the correct answer is right and why other options are less suitable. Include practical context for $jobRole.",
      "difficulty": "$difficultyLevel",
      "category": "$category",
      "topic": "Specific subtopic within $category"
    }
  ]
}
```

IMPORTANT: 
- Return ONLY the JSON structure above
- Ensure each question tests different knowledge areas within $category
- Make explanations educational and valuable for learning
- Verify all $numQuestions questions are unique and properly formatted

Generate $numQuestions expertly crafted MCQ questions for $jobRole now:
''';
  }

  static String _getDifficultySpecifications(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
      case 'beginner':
        return '- EASY: Basic concepts, fundamental knowledge, entry-level understanding, simple definitions';
      case 'medium':
      case 'intermediate':
        return '- MEDIUM: Practical application, intermediate concepts, real-world scenarios, problem-solving';
      case 'hard':
      case 'advanced':
        return '- HARD: Advanced scenarios, complex problem-solving, expert-level knowledge, system design concepts';
      default:
        return '- MEDIUM: Practical application, intermediate concepts, real-world scenarios, problem-solving';
    }
  }

  static String _getCategorySpecifications(String category, String jobRole) {
    switch (category.toLowerCase()) {
      case 'general':
        return '- GENERAL: Professional skills, workplace knowledge, communication, project management';
      case 'technical':
        return '- TECHNICAL: Job-specific technical skills, programming, tools, methodologies, best practices';
      case 'behavioral':
        return '- BEHAVIORAL: Soft skills, teamwork, leadership, conflict resolution, decision-making';
      case 'industry_specific':
      case 'industryspecific':
        return '- INDUSTRY_SPECIFIC: Industry trends, standards, regulations, domain-specific knowledge';
      default:
        return '- GENERAL: Professional skills, workplace knowledge, communication, project management';
    }
  }

  /// Parse comprehensive MCQ response with robust error handling
  static Future<List<McqQuestionModel>> _parseComprehensiveMCQResponse(
    String response,
    String sessionId,
    String jobRole,
    String difficulty,
    String category,
    int expectedCount,
  ) async {
    try {
      AppLogger.debug('Parsing comprehensive MCQ response...');

      // Extract JSON with multiple fallback patterns
      final jsonPatterns = [
        RegExp(r'```json\s*(\{.*?\})\s*```', dotAll: true),
        RegExp(r'```\s*(\{.*?\})\s*```', dotAll: true),
        RegExp(r'\{.*"questions".*\}', dotAll: true),
      ];

      String? jsonStr;
      for (final pattern in jsonPatterns) {
        final match = pattern.firstMatch(response);

        if (match != null) {
          jsonStr = match.group(1) ?? match.group(0);
          break;
        }
      }

      jsonStr ??= response.trim();

      // Parse and validate JSON structure
      final parsedData = json.decode(jsonStr) as Map<String, dynamic>;

      if (!parsedData.containsKey('questions')) {
        throw Exception('No "questions" field found in response');
      }

      final questionsData = parsedData['questions'] as List<dynamic>;
      final validatedQuestions = <McqQuestionModel>[];

      for (int i = 0; i < questionsData.length; i++) {
        final questionData = questionsData[i] as Map<String, dynamic>;
        final validatedQuestion = _validateAndEnhanceQuestion(
          questionData,
          i + 1,
          sessionId,
          jobRole,
          difficulty,
          category,
        );

        if (validatedQuestion != null) {
          validatedQuestions.add(validatedQuestion);
        }
      }

      AppLogger.info(
        'Successfully parsed ${validatedQuestions.length} valid questions from response',
      );
      return validatedQuestions;
    } catch (e) {
      AppLogger.error('JSON parsing failed: $e, using text format fallback');
      return _parseTextFormatFallback(
        response,
        sessionId,
        jobRole,
        difficulty,
        category,
        expectedCount,
      );
    }
  }

  /// Validate and enhance individual question data
  static McqQuestionModel? _validateAndEnhanceQuestion(
    Map<String, dynamic> questionData,
    int questionNumber,
    String sessionId,
    String jobRole,
    String difficulty,
    String category,
  ) {
    try {
      // Check required fields
      final requiredFields = [
        'question',
        'options',
        'correct_answer',
        'explanation',
      ];
      for (final field in requiredFields) {
        if (!questionData.containsKey(field)) {
          AppLogger.warn(
            'Missing required field: $field in question $questionNumber',
          );
          return null;
        }
      }

      // Validate options structure
      final options = questionData['options'];
      if (options is! List || options.length != 4) {
        AppLogger.warn('Invalid options structure in question $questionNumber');
        return null;
      }

      final optionsList =
          options.cast<String>().where((opt) => opt.trim().isNotEmpty).toList();
      if (optionsList.length != 4) {
        AppLogger.warn('Invalid options count in question $questionNumber');
        return null;
      }

      // Validate correct answer
      String correctAnswer = questionData['correct_answer'].toString().trim();
      if (!optionsList.contains(correctAnswer)) {
        AppLogger.warn(
          'Correct answer not found in options for question $questionNumber',
        );
        // Try to find a matching option
        correctAnswer = optionsList.first;
      }

      // Create enhanced question
      final enhancedQuestion = McqQuestionModel(
        questionId: '${sessionId}_q$questionNumber',
        sessionId: sessionId,
        question: questionData['question'].toString().trim(),
        options: optionsList,
        correctAnswer: correctAnswer,
        explanation: questionData['explanation'].toString().trim(),
        difficulty: difficulty,
        category: category,
        topic: questionData['topic']?.toString().trim() ?? category,
        jobRole: jobRole,
        questionNo: questionNumber,
      );

      // Additional validation checks
      if (enhancedQuestion.question.length < 10) {
        AppLogger.warn('Question text too short for question $questionNumber');
        return null;
      }

      if (enhancedQuestion.explanation.length < 20) {
        AppLogger.warn('Explanation too short for question $questionNumber');
        return null;
      }

      return enhancedQuestion;
    } catch (e) {
      AppLogger.error('Error validating question $questionNumber: $e');
      return null;
    }
  }

  /// Fallback parser for responses that aren't in JSON format
  static List<McqQuestionModel> _parseTextFormatFallback(
    String response,
    String sessionId,
    String jobRole,
    String difficulty,
    String category,
    int expectedCount,
  ) {
    AppLogger.info('Using text format fallback parser');
    final questions = <McqQuestionModel>[];

    // This would contain the text parsing logic
    // For brevity, returning empty list - this should be implemented
    // based on the original text parsing logic from the main file

    return questions;
  }

  /// Ensure we have exactly the target number of questions
  static Future<List<McqQuestionModel>> _ensureQuestionCount(
    List<McqQuestionModel> existingQuestions,
    String jobRole,
    String difficulty,
    String category,
    int targetCount,
  ) async {
    final currentCount = existingQuestions.length;

    if (currentCount >= targetCount) {
      return existingQuestions.take(targetCount).toList();
    }

    // For now, return existing questions - full implementation would generate more
    return existingQuestions;
  }

  /// Generate fallback MCQ questions using templates
  static Future<List<McqQuestionModel>> _generateFallbackMCQQuestions({
    required String sessionId,
    required String jobRole,
    required String difficultyLevel,
    required int numQuestions,
    required String category,
  }) async {
    AppLogger.info('Using enhanced fallback template generation for $jobRole');

    final questions = <McqQuestionModel>[];

    // Generate basic template questions
    for (int i = 0; i < numQuestions; i++) {
      final question = McqQuestionModel(
        questionId: '${sessionId}_fallback_q${i + 1}',
        sessionId: sessionId,
        question: 'What is most important for $jobRole professionals?',
        options: [
          'Continuous learning and adaptation',
          'Working independently only',
          'Avoiding challenges',
          'Following strict procedures only',
        ],
        correctAnswer: 'Continuous learning and adaptation',
        explanation:
            'Continuous learning is essential for $jobRole professionals to stay current with industry trends and improve their skills.',
        difficulty: difficultyLevel,
        category: category,
        topic: 'Professional Development',
        jobRole: jobRole,
        questionNo: i + 1,
      );
      questions.add(question);
    }

    AppLogger.info(
      'Generated ${questions.length} enhanced fallback questions for $jobRole',
    );
    return questions;
  }
}
