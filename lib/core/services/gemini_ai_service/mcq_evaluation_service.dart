import 'package:mock_interview/core/services/openrouter_api_service.dart';
import 'package:mock_interview/core/models/mcq_question_model.dart';
import 'package:mock_interview/core/services/gemini_ai_service/error_logger.dart';
import 'dart:convert';
import 'package:mock_interview/core/utils/app_logger.dart';

/// Service for evaluating MCQ interviews using OpenRouter API
class MCQEvaluationService {
  // Retry configuration for 503 errors
  static const int maxRetries = 3;
  static const Duration baseDelay = Duration(seconds: 2);

  // Error tracking for monitoring
  static int _totalEvalApiCalls = 0;
  static int _total503Errors = 0;
  static int _successfulRetries = 0;
  static final List<Map<String, dynamic>> _errorLog = [];

  /// Log error statistics for monitoring
  static void _logEvalApiCallStats(
    String operation,
    bool success,
    int attempts,
    String? error,
    Map<String, dynamic> context,
  ) {
    _totalEvalApiCalls++;

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
      'MCQEvaluationService: API Call Stats - Total: $_totalEvalApiCalls, 503 Errors: $_total503Errors, Successful Retries: $_successfulRetries',
    );

    if (error?.contains('503') == true) {
      _total503Errors++;
      if (attempts > 1 && success) {
        _successfulRetries++;
      }
      AppLogger.info(
        'MCQEvaluationService: 503 Error Rate - ${(_total503Errors / _totalEvalApiCalls * 100).toStringAsFixed(1)}%',
      );
      AppLogger.info(
        'MCQEvaluationService: 503 Retry Success Rate - ${_total503Errors > 0 ? (_successfulRetries / _total503Errors * 100).toStringAsFixed(1) : 0}%',
      );
    }

    // Keep only last 50 entries to prevent memory issues
    if (_errorLog.length > 50) {
      _errorLog.removeAt(0);
    }
  }

  /// Get error statistics for debugging
  static Map<String, dynamic> getEvalErrorStats() {
    return {
      'totalApiCalls': _totalEvalApiCalls,
      'total503Errors': _total503Errors,
      'successfulRetries': _successfulRetries,
      'errorRate503':
          _totalEvalApiCalls > 0
              ? (_total503Errors / _totalEvalApiCalls * 100)
              : 0.0,
      'retrySuccessRate':
          _total503Errors > 0
              ? (_successfulRetries / _total503Errors * 100)
              : 0.0,
      'recentErrors': _errorLog.take(10).toList(),
    };
  }

  /// Retry mechanism with exponential backoff for API calls
  static Future<T> _retryEvalApiCall<T>(
    Future<T> Function() apiCall,
    String operation,
    Map<String, dynamic> context,
  ) async {
    int attempt = 0;
    String? lastError;

    while (attempt < maxRetries) {
      try {
        AppLogger.info(
          'MCQEvaluationService: Attempting $operation (attempt ${attempt + 1}/$maxRetries)',
        );
        AppLogger.debug('MCQEvaluationService: Context - $context');
        final result = await apiCall();

        // Log successful API call
        _logEvalApiCallStats(operation, true, attempt + 1, lastError, context);

        if (attempt > 0) {
          AppLogger.info(
            'MCQEvaluationService: $operation succeeded on attempt ${attempt + 1}',
          );
        }
        return result;
      } catch (e) {
        attempt++;
        lastError = e.toString();

        // Log all errors with full context
        AppLogger.error(
          'MCQEvaluationService: $operation failed on attempt $attempt/$maxRetries - Error: $e',
        );
        AppLogger.error('MCQEvaluationService: Error type: ${e.runtimeType}');
        AppLogger.error(
          'MCQEvaluationService: Error toString: ${e.toString()}',
        );
        AppLogger.debug('MCQEvaluationService: Context - $context');

        // Log error with comprehensive context
        GeminiErrorLogger.logError(
          service: 'MCQEvaluationService',
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
            'MCQEvaluationService: 503 Service Unavailable detected on attempt $attempt/$maxRetries for $operation',
          );
          AppLogger.warn(
            'MCQEvaluationService: This indicates Gemini API is temporarily overloaded or under maintenance',
          );
          AppLogger.warn(
            'MCQEvaluationService: Implementing exponential backoff - waiting ${delay.inSeconds} seconds before retry...',
          );
          AppLogger.debug(
            'MCQEvaluationService: Retry strategy: ${delay.inSeconds}s delay (base: ${baseDelay.inSeconds}s, multiplier: ${1 << (attempt - 1)})',
          );

          await Future.delayed(delay);
          continue;
        }

        // Log final failure details
        if (attempt >= maxRetries) {
          AppLogger.error(
            'MCQEvaluationService: All retry attempts exhausted for $operation',
          );
          if (is503Error) {
            AppLogger.error(
              'MCQEvaluationService: 503 errors persisted through all $maxRetries attempts - API may be experiencing extended downtime',
            );
          }

          // Log failed API call
          _logEvalApiCallStats(operation, false, attempt, lastError, context);
        } else if (!is503Error) {
          AppLogger.error(
            'MCQEvaluationService: Non-503 error encountered - will not retry: $e',
          );

          // Log failed API call for non-503 errors
          _logEvalApiCallStats(operation, false, attempt, lastError, context);
        }

        // If it's not a 503 error or we've exhausted retries, rethrow
        rethrow;
      }
    }

    throw Exception('Max retries exceeded for $operation');
  }

  /// Evaluate MCQ interview using Gemini AI for detailed analysis
  static Future<Map<String, dynamic>> evaluateMCQInterview({
    required String sessionId,
    required String jobRole,
    required String difficultyLevel,
    required String category,
    required List<McqQuestionModel> questions,
    required List<String> userAnswers,
  }) async {
    final context = {
      'sessionId': sessionId,
      'jobRole': jobRole,
      'difficultyLevel': difficultyLevel,
      'category': category,
      'questionsCount': questions.length,
      'userAnswersCount': userAnswers.length,
    };

    return await _retryEvalApiCall(
      () async {
        try {
          AppLogger.info('=== MCQ EVALUATION WITH GEMINI AI ===');
          AppLogger.info('MCQEvaluationService: Session: $sessionId');
          AppLogger.info('MCQEvaluationService: Job Role: $jobRole');
          AppLogger.info(
            'MCQEvaluationService: Questions: ${questions.length}',
          );
          AppLogger.info(
            'MCQEvaluationService: User Answers: ${userAnswers.length}',
          );

          final evaluationPrompt = _buildMCQEvaluationPrompt(
            sessionId: sessionId,
            jobRole: jobRole,
            difficultyLevel: difficultyLevel,
            category: category,
            questions: questions,
            userAnswers: userAnswers,
          );

          AppLogger.info(
            'MCQEvaluationService: Sending evaluation request to OpenRouter API',
          );
          final responseText = await OpenRouterApiService.generateText(
            prompt: evaluationPrompt,
            temperature:
                0.3, // Lower temperature for more consistent evaluation
            maxTokens: 8000,
          );

          AppLogger.info('=== OPENROUTER MCQ EVALUATION RESPONSE ===');
          AppLogger.debug(responseText);
          AppLogger.info('=== END RESPONSE ===');

          if (responseText.isEmpty) {
            AppLogger.error(
              'MCQEvaluationService: ERROR - Empty response from OpenRouter API',
            );
            throw Exception(
              'Empty response from OpenRouter API for MCQ evaluation',
            );
          }

          try {
            AppLogger.debug(
              'MCQEvaluationService: Parsing evaluation response',
            );
            return _parseMCQEvaluationResponse(
              responseText,
              questions,
              userAnswers,
              jobRole,
              difficultyLevel,
              category,
            );
          } catch (parseError) {
            AppLogger.error(
              'MCQEvaluationService: Failed to parse MCQ AI response, using fallback: $parseError',
            );
            return _createFallbackMCQEvaluationResult(
              questions,
              userAnswers,
              jobRole,
              difficultyLevel,
              category,
            );
          }
        } catch (e) {
          AppLogger.error(
            'MCQEvaluationService: MCQ AI Evaluation Error Details: $e',
          );
          AppLogger.error('MCQEvaluationService: Error type: ${e.runtimeType}');
          AppLogger.debug('MCQEvaluationService: Context - $context');

          // Specific error handling for different error types
          if (e.toString().contains('503')) {
            AppLogger.warn(
              'MCQEvaluationService: 503 Service Unavailable during MCQ evaluation - Will retry with backoff',
            );
            rethrow; // Let the retry mechanism handle it
          } else if (e.toString().contains('429')) {
            AppLogger.warn(
              'MCQEvaluationService: 429 Rate Limit Exceeded during MCQ evaluation',
            );
            throw Exception(
              'Rate limit exceeded (429): Please wait before requesting evaluation.',
            );
          } else if (e.toString().contains('401')) {
            AppLogger.error(
              'MCQEvaluationService: 401 Unauthorized during MCQ evaluation - Invalid API key',
            );
            throw Exception(
              'Authentication failed (401): Invalid API key for evaluation.',
            );
          } else if (e.toString().contains('400')) {
            AppLogger.error(
              'MCQEvaluationService: 400 Bad Request during MCQ evaluation - Invalid prompt',
            );
            throw Exception(
              'Bad request (400): Invalid evaluation prompt format.',
            );
          } else if (e.toString().contains('timeout')) {
            AppLogger.warn(
              'MCQEvaluationService: Request timeout during MCQ evaluation - Will use fallback',
            );
            return _createFallbackMCQEvaluationResult(
              questions,
              userAnswers,
              jobRole,
              difficultyLevel,
              category,
            );
          } else {
            AppLogger.error(
              'MCQEvaluationService: Unknown error during MCQ evaluation',
            );
            throw Exception('MCQ Evaluation Error: $e');
          }
        }
      },
      'evaluateMCQInterview',
      context,
    );
  }

  /// Build prompt for MCQ evaluation using Gemini AI
  static String _buildMCQEvaluationPrompt({
    required String sessionId,
    required String jobRole,
    required String difficultyLevel,
    required String category,
    required List<McqQuestionModel> questions,
    required List<String> userAnswers,
  }) {
    final prompt = StringBuffer();

    prompt.writeln('MCQ INTERVIEW EVALUATION REQUEST');
    prompt.writeln('=================================');
    prompt.writeln('Session ID: $sessionId');
    prompt.writeln('Job Role: $jobRole');
    prompt.writeln('Difficulty: $difficultyLevel');
    prompt.writeln('Category: $category');
    prompt.writeln('Total Questions: ${questions.length}');
    prompt.writeln('');

    prompt.writeln('QUESTIONS AND ANSWERS:');
    prompt.writeln('=====================');

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final userAnswer = i < userAnswers.length ? userAnswers[i] : 'No Answer';
      final isCorrect = userAnswer == question.correctAnswer;

      prompt.writeln('');
      prompt.writeln('Question ${i + 1}:');
      prompt.writeln('Q: ${question.question}');
      prompt.writeln('Options: ${question.options.join(', ')}');
      prompt.writeln('Correct Answer: ${question.correctAnswer}');
      prompt.writeln('User Answer: $userAnswer');
      prompt.writeln('Result: ${isCorrect ? 'CORRECT' : 'INCORRECT'}');
      if (question.explanation.isNotEmpty) {
        prompt.writeln('Explanation: ${question.explanation}');
      }
      prompt.writeln('Topic: ${question.topic}');
      prompt.writeln('Difficulty: ${question.difficulty}');
    }

    prompt.writeln('');
    prompt.writeln('EVALUATION INSTRUCTIONS:');
    prompt.writeln('========================');
    prompt.writeln(
      'You are an expert HR professional and technical interviewer evaluating this MCQ interview performance.',
    );
    prompt.writeln(
      'Please provide a comprehensive evaluation with the following EXACT JSON structure:',
    );
    prompt.writeln('');
    prompt.writeln('{');
    prompt.writeln('  "totalQuestions": ${questions.length},');
    prompt.writeln('  "correctAnswers": [calculate from above],');
    prompt.writeln('  "incorrectAnswers": [calculate from above],');
    prompt.writeln('  "score": [percentage out of 100],');
    prompt.writeln('  "percentage": [same as score],');
    prompt.writeln('  "passed": [true if score >= 60, false otherwise],');
    prompt.writeln(
      '  "performanceLevel": "[Excellent|Good|Average|Below Average|Poor]",',
    );
    prompt.writeln(
      '  "overallFeedback": "[Comprehensive feedback about performance]",',
    );
    prompt.writeln(
      '  "strengths": ["[strength 1]", "[strength 2]", "[strength 3]"],',
    );
    prompt.writeln(
      '  "areasForImprovement": ["[improvement 1]", "[improvement 2]", "[improvement 3]"],',
    );
    prompt.writeln('  "topicAnalysis": {');
    prompt.writeln(
      '    "[topic1]": {"correct": X, "total": Y, "percentage": Z},',
    );
    prompt.writeln(
      '    "[topic2]": {"correct": X, "total": Y, "percentage": Z}',
    );
    prompt.writeln('  },');
    prompt.writeln(
      '  "recommendations": ["[recommendation 1]", "[recommendation 2]", "[recommendation 3]"],',
    );
    prompt.writeln(
      '  "nextSteps": "[Specific advice for career development in $jobRole]"',
    );
    prompt.writeln('}');
    prompt.writeln('');
    prompt.writeln('IMPORTANT REQUIREMENTS:');
    prompt.writeln(
      '- Provide ONLY valid JSON without any markdown formatting or code blocks',
    );
    prompt.writeln(
      '- Calculate scores accurately based on correct/incorrect answers',
    );
    prompt.writeln(
      '- Provide constructive, specific feedback relevant to $jobRole',
    );
    prompt.writeln(
      '- Include topic-wise analysis based on the question topics',
    );
    prompt.writeln('- Suggest concrete steps for improvement');
    prompt.writeln('- Be professional yet encouraging in tone');

    return prompt.toString();
  }

  /// Parse MCQ evaluation response from Gemini AI
  static Map<String, dynamic> _parseMCQEvaluationResponse(
    String responseText,
    List<McqQuestionModel> questions,
    List<String> userAnswers,
    String jobRole,
    String difficultyLevel,
    String category,
  ) {
    try {
      // Clean the response text - remove markdown formatting if present
      String cleanedResponse =
          responseText.replaceAll('```json', '').replaceAll('```', '').trim();

      // Try to find JSON content if wrapped in other text
      int jsonStart = cleanedResponse.indexOf('{');
      int jsonEnd = cleanedResponse.lastIndexOf('}');

      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        cleanedResponse = cleanedResponse.substring(jsonStart, jsonEnd + 1);
      }

      final Map<String, dynamic> parsed = json.decode(cleanedResponse);

      // Validate required fields and add missing ones
      final result = <String, dynamic>{
        'sessionId': questions.isNotEmpty ? questions.first.sessionId : '',
        'totalQuestions': parsed['totalQuestions'] ?? questions.length,
        'correctAnswers':
            parsed['correctAnswers'] ??
            _calculateCorrectAnswers(questions, userAnswers),
        'incorrectAnswers':
            parsed['incorrectAnswers'] ??
            (questions.length -
                _calculateCorrectAnswers(questions, userAnswers)),
        'score': parsed['score'] ?? _calculateScore(questions, userAnswers),
        'percentage':
            parsed['percentage'] ?? _calculateScore(questions, userAnswers),
        'passed':
            parsed['passed'] ?? (_calculateScore(questions, userAnswers) >= 60),
        'performanceLevel':
            parsed['performanceLevel'] ??
            _getPerformanceLevel(_calculateScore(questions, userAnswers)),
        'overallFeedback':
            parsed['overallFeedback'] ?? 'Good attempt at the MCQ interview.',
        'strengths':
            parsed['strengths'] ??
            ['Completed all questions', 'Showed engagement'],
        'areasForImprovement':
            parsed['areasForImprovement'] ??
            ['Review incorrect answers', 'Study core concepts'],
        'topicAnalysis':
            parsed['topicAnalysis'] ??
            _generateTopicAnalysis(questions, userAnswers),
        'recommendations':
            parsed['recommendations'] ??
            ['Practice more questions', 'Review fundamentals'],
        'nextSteps':
            parsed['nextSteps'] ??
            'Continue studying and practicing for $jobRole interviews.',
        'evaluatedAt': DateTime.now().toIso8601String(),
        'evaluationType': 'mcq',
        'jobRole': jobRole,
        'difficulty': difficultyLevel,
        'category': category,
      };

      AppLogger.info('=== MCQ EVALUATION PARSED SUCCESSFULLY ===');
      AppLogger.info('Score: ${result['score']}%');
      AppLogger.info(
        'Correct: ${result['correctAnswers']}/${result['totalQuestions']}',
      );
      AppLogger.info('Performance: ${result['performanceLevel']}');

      return result;
    } catch (e) {
      AppLogger.error('Error parsing MCQ evaluation response: $e');
      throw Exception('Failed to parse MCQ evaluation response: $e');
    }
  }

  /// Create fallback MCQ evaluation result
  static Map<String, dynamic> _createFallbackMCQEvaluationResult(
    List<McqQuestionModel> questions,
    List<String> userAnswers,
    String jobRole,
    String difficultyLevel,
    String category,
  ) {
    final correctAnswers = _calculateCorrectAnswers(questions, userAnswers);
    final score = _calculateScore(questions, userAnswers);

    return {
      'sessionId': questions.isNotEmpty ? questions.first.sessionId : '',
      'totalQuestions': questions.length,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': questions.length - correctAnswers,
      'score': score,
      'percentage': score,
      'passed': score >= 60,
      'performanceLevel': _getPerformanceLevel(score),
      'overallFeedback':
          'You completed the MCQ interview. ${score >= 60 ? 'Good performance!' : 'Consider reviewing the topics covered.'}',
      'strengths':
          score >= 80
              ? [
                'Excellent understanding',
                'Strong performance',
                'Well prepared',
              ]
              : score >= 60
              ? [
                'Good effort',
                'Basic understanding demonstrated',
                'Completed all questions',
              ]
              : ['Attempted all questions', 'Shows interest in learning'],
      'areasForImprovement':
          score < 60
              ? [
                'Review fundamental concepts',
                'Practice more questions',
                'Study core topics',
              ]
              : score < 80
              ? [
                'Deepen understanding',
                'Review missed topics',
                'Practice advanced concepts',
              ]
              : ['Minor gaps to address', 'Continue building expertise'],
      'topicAnalysis': _generateTopicAnalysis(questions, userAnswers),
      'recommendations': [
        'Review questions you got wrong',
        'Study $jobRole fundamentals',
        'Practice similar questions',
      ],
      'nextSteps':
          score >= 80
              ? 'Excellent work! You\'re ready for more advanced $jobRole challenges.'
              : score >= 60
              ? 'Good foundation. Focus on strengthening weaker areas for $jobRole success.'
              : 'Invest time in learning $jobRole fundamentals before attempting advanced topics.',
      'evaluatedAt': DateTime.now().toIso8601String(),
      'evaluationType': 'mcq',
      'jobRole': jobRole,
      'difficulty': difficultyLevel,
      'category': category,
    };
  }

  /// Calculate correct answers count
  static int _calculateCorrectAnswers(
    List<McqQuestionModel> questions,
    List<String> userAnswers,
  ) {
    int correct = 0;
    for (int i = 0; i < questions.length && i < userAnswers.length; i++) {
      if (questions[i].correctAnswer == userAnswers[i]) {
        correct++;
      }
    }
    return correct;
  }

  /// Calculate score percentage
  static double _calculateScore(
    List<McqQuestionModel> questions,
    List<String> userAnswers,
  ) {
    if (questions.isEmpty) return 0.0;
    final correct = _calculateCorrectAnswers(questions, userAnswers);
    return (correct / questions.length) * 100;
  }

  /// Get performance level based on score
  static String _getPerformanceLevel(double score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Good';
    if (score >= 60) return 'Average';
    if (score >= 40) return 'Below Average';
    return 'Poor';
  }

  /// Generate topic-wise analysis
  static Map<String, dynamic> _generateTopicAnalysis(
    List<McqQuestionModel> questions,
    List<String> userAnswers,
  ) {
    final Map<String, Map<String, int>> topicStats = {};

    for (int i = 0; i < questions.length; i++) {
      final topic =
          questions[i].topic.isNotEmpty ? questions[i].topic : 'General';
      final isCorrect =
          i < userAnswers.length &&
          questions[i].correctAnswer == userAnswers[i];

      topicStats[topic] ??= {'correct': 0, 'total': 0};
      topicStats[topic]!['total'] = topicStats[topic]!['total']! + 1;
      if (isCorrect) {
        topicStats[topic]!['correct'] = topicStats[topic]!['correct']! + 1;
      }
    }

    // Convert to percentage format
    final Map<String, dynamic> result = {};
    topicStats.forEach((topic, stats) {
      final percentage =
          stats['total']! > 0
              ? (stats['correct']! / stats['total']!) * 100
              : 0.0;
      result[topic] = {
        'correct': stats['correct'],
        'total': stats['total'],
        'percentage': percentage.round(),
      };
    });

    return result;
  }
}
