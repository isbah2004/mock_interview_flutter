import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/services/network_service.dart';
import 'package:mock_interview/core/services/unified_database_service.dart';
import 'package:mock_interview/core/models/unified_interview_session.dart';
import 'package:mock_interview/core/models/voice_message_model.dart';
import 'package:mock_interview/core/models/voice_evaluation_model.dart';
import 'package:mock_interview/core/entities/evaluation_result.dart';
import '../../domain/repositories/voice_interview_repository.dart';
import '../../domain/entities/interview_session.dart';
import '../../domain/entities/interview_config.dart';
import '../../data/models/voice_interview_evaluation_result.dart';

/// Appwrite-powered Voice Interview Repository Implementation
class AppwriteVoiceInterviewRepositoryImpl implements VoiceInterviewRepository {
  final UnifiedDatabaseService databaseService;
  final NetworkService networkService;

  AppwriteVoiceInterviewRepositoryImpl({
    required this.databaseService,
    required this.networkService,
  });

  @override
  Future<Either<Failure, VoiceInterviewEvaluationResult>>
  evaluateVoiceInterview({
    required InterviewSession session,
    required InterviewConfig config,
  }) async {
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      // Create or get the unified session for voice interview
      final unifiedSession = await _getOrCreateUnifiedSession(session, config);

      // Store voice messages from the session
      await _storeVoiceMessages(unifiedSession.sessionId, session);

      // Create voice evaluation
      final evaluation = await _createVoiceEvaluation(
        unifiedSession,
        session,
        config,
      );

      // Update session to completed
      await _completeSession(unifiedSession, evaluation);

      // Create sample question results for compatibility
      final questionResults = <QuestionResult>[];
      for (int i = 0; i < config.numberOfQuestions; i++) {
        questionResults.add(
          QuestionResult(
            questionId: 'voice_q_${i + 1}',
            questionNumber: i + 1,
            question: 'Voice interview question ${i + 1}',
            userAnswer: 'Sample voice response ${i + 1}',
            correctAnswer: 'Sample expected response ${i + 1}',
            isCorrect: true, // Sample - would be evaluated by AI
            score: 1,
            explanation: 'Good response demonstrating relevant skills',
            topic: config.category.displayName,
            difficulty: config.difficulty.toString(),
          ),
        );
      }

      // Convert to legacy format using actual constructor parameters
      final result = VoiceInterviewEvaluationResult(
        sessionId: unifiedSession.sessionId,
        totalQuestions: config.numberOfQuestions,
        results: questionResults,
        finalScore: evaluation.finalScore,
        percentage: evaluation.percentage,
        passed: evaluation.passed,
        sessionComplete: evaluation.sessionComplete,
        completedAt: evaluation.completedAt,
        feedback: evaluation.feedback,
        aiCorrectAnswers: evaluation.aiCorrectAnswers,
        communicationScore: evaluation.communicationScore,
        contentScore: evaluation.contentScore,
        overallScore: evaluation.overallScore,
      );

      return Right(result);
    } catch (e) {
      return Left(
        ServerFailure('Failed to evaluate voice interview: ${e.toString()}'),
      );
    }
  }

  /// Get or create a unified session for the voice interview
  Future<UnifiedInterviewSession> _getOrCreateUnifiedSession(
    InterviewSession session,
    InterviewConfig config,
  ) async {
    // Generate a session ID based on timestamp
    final sessionId = 'voice_${DateTime.now().millisecondsSinceEpoch}';

    try {
      // Try to get existing session
      return await databaseService.getInterviewSession(sessionId);
    } catch (e) {
      // Create new session if it doesn't exist
      final unifiedSession = UnifiedInterviewSession(
        sessionId: sessionId,
        userId: 'sample_user', // This would come from auth in real usage
        jobRole: config.jobRole,
        interviewType: 'voice',
        difficulty: config.difficulty.toString(),
        category: config.category.displayName,
        totalQuestions: config.numberOfQuestions,
        timePerQuestion: 120, // 2 minutes per question for voice
        isCompleted: false,
        startedAt: DateTime.now(),
      );

      return await databaseService.createInterviewSession(unifiedSession);
    }
  }

  /// Store voice messages from the interview session
  Future<void> _storeVoiceMessages(
    String sessionId,
    InterviewSession session,
  ) async {
    // Store each message from the session
    for (int i = 0; i < session.messages.length; i++) {
      final message = session.messages[i];

      final voiceMessage = VoiceMessageModel(
        messageId: '',
        sessionId: sessionId,
        messageType: message.type.toString(),
        content: message.content,
        timestamp: DateTime.now().subtract(
          Duration(minutes: session.messages.length - i),
        ),
        sequenceNumber: i + 1,
      );

      await databaseService.storeVoiceMessage(voiceMessage);
    }
  }

  /// Create voice evaluation based on the session and config
  Future<VoiceEvaluationModel> _createVoiceEvaluation(
    UnifiedInterviewSession session,
    InterviewSession interviewSession,
    InterviewConfig config,
  ) async {
    // Sample evaluation scores - in a real implementation, this would come from AI analysis
    const overallScore = 85.0;
    const communicationScore = 88.0;
    const technicalScore = 82.0;

    final now = DateTime.now();
    final evaluation = VoiceEvaluationModel(
      evaluationId: '',
      sessionId: session.sessionId,
      feedback: _generateVoiceFeedback(overallScore),
      communicationScore: communicationScore,
      contentScore: technicalScore,
      overallScore: overallScore,
      aiCorrectAnswers: [],
      totalQuestions: config.numberOfQuestions,
      finalScore: overallScore,
      percentage: overallScore,
      passed: overallScore >= 60,
      sessionComplete: true,
      completedAt: now,
      createdAt: now,
    );

    return await databaseService.storeVoiceEvaluation(evaluation);
  }

  /// Complete the interview session
  Future<void> _completeSession(
    UnifiedInterviewSession session,
    VoiceEvaluationModel evaluation,
  ) async {
    final duration = DateTime.now().difference(session.startedAt).inSeconds;

    final updatedSession = UnifiedInterviewSession(
      sessionId: session.sessionId,
      userId: session.userId,
      jobRole: session.jobRole,
      interviewType: session.interviewType,
      difficulty: session.difficulty,
      category: session.category,
      totalQuestions: session.totalQuestions,
      timePerQuestion: session.timePerQuestion,
      isCompleted: true,
      passed: evaluation.passed,
      score: evaluation.finalScore,
      percentage: evaluation.percentage,
      startedAt: session.startedAt,
      completedAt: DateTime.now(),
      duration: duration,
    );

    await databaseService.updateInterviewSession(updatedSession);
  }

  /// Generate feedback based on overall score
  String _generateVoiceFeedback(double score) {
    if (score >= 85) {
      return 'Excellent performance! You demonstrated strong communication skills and technical knowledge.';
    } else if (score >= 70) {
      return 'Good performance! You showed solid skills with some areas for improvement.';
    } else if (score >= 60) {
      return 'Fair performance. Consider practicing more to improve your communication and technical skills.';
    } else {
      return 'Below expectations. Focus on improving your communication clarity and technical knowledge.';
    }
  }
}
