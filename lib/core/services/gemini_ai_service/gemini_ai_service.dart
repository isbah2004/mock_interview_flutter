import 'package:mock_interview/core/services/gemini_ai_service/mcq_generation_service.dart';
import 'package:mock_interview/core/services/gemini_ai_service/mcq_evaluation_service.dart';
import 'package:mock_interview/core/services/gemini_ai_service/voice_interview_service.dart';
import 'package:mock_interview/core/services/gemini_ai_service/mcq_session_manager.dart';
import 'package:mock_interview/core/services/gemini_ai_service/error_logger.dart';
import 'package:mock_interview/core/services/gemini_ai_service/monitoring_dashboard.dart';
import 'package:mock_interview/core/utils/app_logger.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_config.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_session.dart';
import 'package:mock_interview/core/models/mcq_question_model.dart';

class GeminiAiService {
  GeminiAiService();

  /// Get comprehensive error statistics across all Gemini AI services
  static Map<String, dynamic> getAllErrorStats() {
    final voiceStats = VoiceInterviewService.getErrorStats();
    final mcqGenStats = MCQGenerationService.getMcqErrorStats();
    final mcqEvalStats = MCQEvaluationService.getEvalErrorStats();

    final totalApiCalls =
        (voiceStats['totalApiCalls'] as int) +
        (mcqGenStats['totalApiCalls'] as int) +
        (mcqEvalStats['totalApiCalls'] as int);

    final total503Errors =
        (voiceStats['total503Errors'] as int) +
        (mcqGenStats['total503Errors'] as int) +
        (mcqEvalStats['total503Errors'] as int);

    final totalSuccessfulRetries =
        (voiceStats['successfulRetries'] as int) +
        (mcqGenStats['successfulRetries'] as int) +
        (mcqEvalStats['successfulRetries'] as int);

    return {
      'overall': {
        'totalApiCalls': totalApiCalls,
        'total503Errors': total503Errors,
        'successfulRetries': totalSuccessfulRetries,
        'errorRate503':
            totalApiCalls > 0 ? (total503Errors / totalApiCalls * 100) : 0.0,
        'retrySuccessRate':
            total503Errors > 0
                ? (totalSuccessfulRetries / total503Errors * 100)
                : 0.0,
      },
      'voiceInterview': voiceStats,
      'mcqGeneration': mcqGenStats,
      'mcqEvaluation': mcqEvalStats,
    };
  }

  /// Log consolidated error information for debugging
  static void logErrorStats() {
    final stats = getAllErrorStats();
    AppLogger.info('=== GEMINI AI SERVICE COMPREHENSIVE ERROR STATISTICS ===');
    AppLogger.info('Overall API Performance:');
    AppLogger.info('  Total API Calls: ${stats['overall']['totalApiCalls']}');
    AppLogger.info('  Total 503 Errors: ${stats['overall']['total503Errors']}');
    AppLogger.info(
      '  Successful Retries: ${stats['overall']['successfulRetries']}',
    );
    AppLogger.info(
      '  503 Error Rate: ${stats['overall']['errorRate503'].toStringAsFixed(2)}%',
    );
    AppLogger.info(
      '  Retry Success Rate: ${stats['overall']['retrySuccessRate'].toStringAsFixed(2)}%',
    );
    AppLogger.info('');
    AppLogger.info('Service Breakdown:');
    AppLogger.info(
      '  Voice Interview Service: ${stats['voiceInterview']['totalApiCalls']} calls, ${stats['voiceInterview']['total503Errors']} 503 errors',
    );
    AppLogger.info(
      '  MCQ Generation Service: ${stats['mcqGeneration']['totalApiCalls']} calls, ${stats['mcqGeneration']['total503Errors']} 503 errors',
    );
    AppLogger.info(
      '  MCQ Evaluation Service: ${stats['mcqEvaluation']['totalApiCalls']} calls, ${stats['mcqEvaluation']['total503Errors']} 503 errors',
    );
    AppLogger.info('=== END ERROR STATISTICS ===');

    // Automatically check and trigger alerts
    GeminiMonitoringDashboard.checkAndTriggerAlerts();
  }

  /// Display comprehensive health dashboard
  static void displayHealthDashboard() {
    GeminiMonitoringDashboard.displayHealthStatus();
  }

  /// Quick health check
  static Map<String, dynamic> getQuickHealthCheck() {
    return GeminiMonitoringDashboard.quickHealthCheck();
  }

  /// Generate comprehensive report for debugging
  static String generateHealthReport() {
    return GeminiMonitoringDashboard.generateComprehensiveReport();
  }

  /// Export all error logs for analysis
  static String exportAllErrorLogs() {
    return GeminiErrorLogger.exportErrorLog();
  }

  /// Get recent 503 errors across all services
  static List<Map<String, dynamic>> getRecent503Errors({int limit = 10}) {
    return GeminiErrorLogger.getRecent503Errors(limit: limit);
  }

  /// Clear all error logs (for testing purposes)
  static void clearAllErrorLogs() {
    GeminiErrorLogger.clearErrorLog();
  }

  Future<List<McqQuestionModel>> generateMcqQuestions({
    required String sessionId,
    required String category,
    required String difficulty,
    required int count,
    required String jobRole,
  }) async {
    try {
      AppLogger.info(
        'GeminiAiService: Starting MCQ generation - JobRole: $jobRole, Category: $category, Difficulty: $difficulty, Count: $count',
      );
      final result = await MCQGenerationService.generateMCQQuestions(
        sessionId: sessionId,
        jobRole: jobRole,
        difficultyLevel: difficulty,
        numQuestions: count,
        category: category,
      );
      AppLogger.info(
        'GeminiAiService: MCQ generation completed successfully - Generated: ${result.length} questions',
      );
      return result;
    } catch (e) {
      AppLogger.error('GeminiAiService: MCQ generation failed - Error: $e');
      AppLogger.error('GeminiAiService: Error type: ${e.runtimeType}');
      AppLogger.error(
        'GeminiAiService: Parameters - JobRole: $jobRole, Category: $category, Difficulty: $difficulty, Count: $count',
      );

      // Specific 503 error logging
      if (e.toString().contains('503')) {
        AppLogger.error(
          'GeminiAiService: 503 Service Unavailable during MCQ generation',
        );
        AppLogger.error(
          'GeminiAiService: This may indicate Gemini API is temporarily overloaded',
        );
        logErrorStats(); // Log current error statistics
      }

      rethrow;
    }
  }

  Future<List<McqQuestionModel>> generateTechnicalMcqQuestions({
    required String sessionId,
    required String jobRole,
    required String difficulty,
    required int count,
  }) async {
    try {
      AppLogger.info(
        'GeminiAiService: Starting Technical MCQ generation - JobRole: $jobRole, Difficulty: $difficulty, Count: $count',
      );
      final result = await MCQGenerationService.generateMCQQuestions(
        sessionId: sessionId,
        jobRole: jobRole,
        difficultyLevel: difficulty,
        numQuestions: count,
        category: 'Technical',
      );
      AppLogger.info(
        'GeminiAiService: Technical MCQ generation completed successfully - Generated: ${result.length} questions',
      );
      return result;
    } catch (e) {
      AppLogger.error(
        'GeminiAiService: Technical MCQ generation failed - Error: $e',
      );
      AppLogger.error('GeminiAiService: Error type: ${e.runtimeType}');
      AppLogger.error(
        'GeminiAiService: Parameters - JobRole: $jobRole, Difficulty: $difficulty, Count: $count',
      );

      // Specific 503 error logging
      if (e.toString().contains('503')) {
        AppLogger.error(
          'GeminiAiService: 503 Service Unavailable during Technical MCQ generation',
        );
        logErrorStats();
      }

      rethrow;
    }
  }

  Future<List<McqQuestionModel>> generateGeneralMcqQuestions({
    required String sessionId,
    required String difficulty,
    required int count,
  }) async {
    try {
      AppLogger.info(
        'GeminiAiService: Starting General MCQ generation - Difficulty: $difficulty, Count: $count',
      );
      final result = await MCQGenerationService.generateMCQQuestions(
        sessionId: sessionId,
        jobRole: 'General',
        difficultyLevel: difficulty,
        numQuestions: count,
        category: 'General',
      );
      AppLogger.info(
        'GeminiAiService: General MCQ generation completed successfully - Generated: ${result.length} questions',
      );
      return result;
    } catch (e) {
      AppLogger.error(
        'GeminiAiService: General MCQ generation failed - Error: $e',
      );
      AppLogger.error('GeminiAiService: Error type: ${e.runtimeType}');
      AppLogger.error(
        'GeminiAiService: Parameters - Difficulty: $difficulty, Count: $count',
      );

      // Specific 503 error logging
      if (e.toString().contains('503')) {
        AppLogger.error(
          'GeminiAiService: 503 Service Unavailable during General MCQ generation',
        );
        logErrorStats();
      }

      rethrow;
    }
  }

  Future<List<McqQuestionModel>> generateBehavioralMcqQuestions({
    required String sessionId,
    required String difficulty,
    required int count,
  }) async {
    try {
      AppLogger.info(
        'GeminiAiService: Starting Behavioral MCQ generation - Difficulty: $difficulty, Count: $count',
      );
      final result = await MCQGenerationService.generateMCQQuestions(
        sessionId: sessionId,
        jobRole: 'Behavioral',
        difficultyLevel: difficulty,
        numQuestions: count,
        category: 'Behavioral',
      );
      AppLogger.info(
        'GeminiAiService: Behavioral MCQ generation completed successfully - Generated: ${result.length} questions',
      );
      return result;
    } catch (e) {
      AppLogger.error(
        'GeminiAiService: Behavioral MCQ generation failed - Error: $e',
      );
      AppLogger.error('GeminiAiService: Error type: ${e.runtimeType}');
      AppLogger.error(
        'GeminiAiService: Parameters - Difficulty: $difficulty, Count: $count',
      );

      // Specific 503 error logging
      if (e.toString().contains('503')) {
        AppLogger.error(
          'GeminiAiService: 503 Service Unavailable during Behavioral MCQ generation',
        );
        logErrorStats();
      }

      rethrow;
    }
  }

  Future<Map<String, dynamic>> evaluateMcqAnswers({
    required String sessionId,
    required List<McqQuestionModel> questions,
    required List<String> userAnswers,
    required String difficulty,
    required String category,
    required String jobRole,
  }) async {
    try {
      AppLogger.info(
        'GeminiAiService: Starting MCQ evaluation - SessionId: $sessionId, JobRole: $jobRole, Category: $category, Difficulty: $difficulty',
      );
      AppLogger.info(
        'GeminiAiService: Questions: ${questions.length}, UserAnswers: ${userAnswers.length}',
      );

      final result = await MCQEvaluationService.evaluateMCQInterview(
        sessionId: sessionId,
        jobRole: jobRole,
        difficultyLevel: difficulty,
        category: category,
        questions: questions,
        userAnswers: userAnswers,
      );
      AppLogger.info('GeminiAiService: MCQ evaluation completed successfully');
      return result;
    } catch (e) {
      AppLogger.error('GeminiAiService: MCQ evaluation failed - Error: $e');
      AppLogger.error('GeminiAiService: Error type: ${e.runtimeType}');
      AppLogger.error(
        'GeminiAiService: Parameters - SessionId: $sessionId, JobRole: $jobRole, Category: $category, Difficulty: $difficulty',
      );
      AppLogger.error(
        'GeminiAiService: Questions count: ${questions.length}, UserAnswers count: ${userAnswers.length}',
      );

      // Specific 503 error logging
      if (e.toString().contains('503')) {
        AppLogger.error(
          'GeminiAiService: 503 Service Unavailable during MCQ evaluation',
        );
        AppLogger.error(
          'GeminiAiService: Evaluation may have failed due to API overload',
        );
        logErrorStats();
      }

      rethrow;
    }
  }

  Future<Map<String, dynamic>> evaluateMcqPerformance({
    required String sessionId,
    required List<McqQuestionModel> questions,
    required List<String> userAnswers,
    required String category,
    required String difficulty,
    required String jobRole,
  }) async {
    try {
      AppLogger.info(
        'GeminiAiService: Starting MCQ performance evaluation - SessionId: $sessionId, JobRole: $jobRole, Category: $category, Difficulty: $difficulty',
      );
      AppLogger.info(
        'GeminiAiService: Questions: ${questions.length}, UserAnswers: ${userAnswers.length}',
      );

      final result = await MCQEvaluationService.evaluateMCQInterview(
        sessionId: sessionId,
        jobRole: jobRole,
        difficultyLevel: difficulty,
        category: category,
        questions: questions,
        userAnswers: userAnswers,
      );
      AppLogger.info(
        'GeminiAiService: MCQ performance evaluation completed successfully',
      );
      return result;
    } catch (e) {
      AppLogger.error(
        'GeminiAiService: MCQ performance evaluation failed - Error: $e',
      );
      AppLogger.error('GeminiAiService: Error type: ${e.runtimeType}');
      AppLogger.error(
        'GeminiAiService: Parameters - SessionId: $sessionId, JobRole: $jobRole, Category: $category, Difficulty: $difficulty',
      );
      AppLogger.error(
        'GeminiAiService: Questions count: ${questions.length}, UserAnswers count: ${userAnswers.length}',
      );

      // Specific 503 error logging
      if (e.toString().contains('503')) {
        AppLogger.error(
          'GeminiAiService: 503 Service Unavailable during MCQ performance evaluation',
        );
        logErrorStats();
      }

      rethrow;
    }
  }

  late final VoiceInterviewService _voiceInterviewService =
      VoiceInterviewService();
  late final MCQSessionManager _mcqSessionManager = MCQSessionManager();

  Future<void> initializeVoiceInterview(InterviewConfig config) async {
    try {
      AppLogger.info(
        'GeminiAiService: Initializing voice interview - Job: ${config.jobRole}, Category: ${config.category}, Difficulty: ${config.difficulty}',
      );
      await _voiceInterviewService.initialize(config);
      AppLogger.info(
        'GeminiAiService: Voice interview initialization successful',
      );
    } catch (e) {
      AppLogger.error(
        'GeminiAiService: Voice interview initialization failed - Error: $e',
      );
      AppLogger.error('GeminiAiService: Error type: ${e.runtimeType}');

      // Specific 503 error logging
      if (e.toString().contains('503')) {
        AppLogger.error(
          'GeminiAiService: 503 Service Unavailable during voice interview initialization',
        );
        AppLogger.error(
          'GeminiAiService: This may indicate Gemini API is temporarily overloaded',
        );
        logErrorStats(); // Log current comprehensive error statistics
      }

      rethrow;
    }
  }

  Future<String> sendVoiceMessage(String message) async {
    try {
      AppLogger.info(
        'GeminiAiService: Sending voice message - Length: ${message.length} chars',
      );
      final response = await _voiceInterviewService.sendMessage(message);
      AppLogger.info(
        'GeminiAiService: Voice message sent successfully - Response length: ${response.length} chars',
      );
      return response;
    } catch (e) {
      AppLogger.error('GeminiAiService: Send voice message failed - Error: $e');
      AppLogger.error('GeminiAiService: Error type: ${e.runtimeType}');

      // Specific 503 error logging
      if (e.toString().contains('503')) {
        AppLogger.error(
          'GeminiAiService: 503 Service Unavailable during voice message send',
        );
        AppLogger.error(
          'GeminiAiService: Message causing 503: "${message.substring(0, message.length > 50 ? 50 : message.length)}${message.length > 50 ? '...' : ''}"',
        );
        logErrorStats(); // Log current comprehensive error statistics
      }

      rethrow;
    }
  }

  Future<Map<String, dynamic>> evaluateVoiceInterview(
    InterviewSession session,
    InterviewConfig config,
  ) async {
    try {
      AppLogger.info('GeminiAiService: Starting voice interview evaluation');
      AppLogger.info(
        'GeminiAiService: Session details - Messages: ${session.messages.length}, Status: ${session.status}',
      );
      final result = await _voiceInterviewService.evaluateInterview(
        session,
        config,
      );
      AppLogger.info(
        'GeminiAiService: Voice interview evaluation completed successfully',
      );
      return result;
    } catch (e) {
      AppLogger.error(
        'GeminiAiService: Voice interview evaluation failed - Error: $e',
      );
      AppLogger.error('GeminiAiService: Error type: ${e.runtimeType}');
      AppLogger.error(
        'GeminiAiService: Session context - Job: ${config.jobRole}, Category: ${config.category}, Messages: ${session.messages.length}',
      );

      // Specific 503 error logging
      if (e.toString().contains('503')) {
        AppLogger.error(
          'GeminiAiService: 503 Service Unavailable during voice interview evaluation',
        );
        AppLogger.error(
          'GeminiAiService: Evaluation may have failed due to API overload',
        );
        logErrorStats(); // Log current comprehensive error statistics
      }

      rethrow;
    }
  }

  // MCQ Session Management Methods
  Future<Map<String, dynamic>> startMcqSession({
    required String category,
    required String difficulty,
    required int questionCount,
    String? jobRole,
  }) async {
    final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    return {
      'sessionId': sessionId,
      'category': category,
      'difficulty': difficulty,
      'questionCount': questionCount,
      'jobRole': jobRole ?? 'General',
      'status': 'started',
    };
  }

  Future<Map<String, dynamic>> submitMcqAnswer({
    required String sessionId,
    required int questionIndex,
    required String answer,
  }) async {
    return {
      'sessionId': sessionId,
      'questionIndex': questionIndex,
      'answer': answer,
      'status': 'submitted',
    };
  }

  Future<Map<String, dynamic>> completeMcqSession({
    required String sessionId,
  }) async {
    return {'sessionId': sessionId, 'status': 'completed'};
  }

  Map<String, dynamic>? getMcqSession(String sessionId) {
    final sessionData = _mcqSessionManager.getSession(sessionId);
    if (sessionData == null) return null;

    return {
      'sessionId': sessionData.sessionId,
      'jobRole': sessionData.jobRole,
      'difficulty': sessionData.difficulty,
      'category': sessionData.category,
      'numQuestions': sessionData.numQuestions,
      'questions': sessionData.questions.map((q) => q.toAppwrite()).toList(),
      'createdAt': sessionData.createdAt.toIso8601String(),
      'lastActivity': sessionData.lastActivity.toIso8601String(),
      'isComplete': sessionData.isComplete,
    };
  }

  void clearMcqSession(String sessionId) {
    _mcqSessionManager.clearAllSessions();
  }

  List<String> getSupportedCategories() {
    return ['Technical', 'General', 'Behavioral'];
  }

  List<String> getSupportedDifficulties() {
    return ['Beginner', 'Intermediate', 'Advanced'];
  }
}
