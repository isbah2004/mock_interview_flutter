import 'dart:developer';

import 'package:appwrite/appwrite.dart';
import 'package:dio/dio.dart';
import 'package:mock_interview/core/constants/api_constants.dart';
import 'package:mock_interview/core/constants/app_secrets.dart';
import 'package:mock_interview/core/constants/database_constants.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/services/api_service.dart';
import 'package:mock_interview/features/mcqinterviews/data/models/start_interview_request.dart';
import 'package:mock_interview/features/mcqinterviews/data/models/submit_answer_request.dart';
import '../models/evaluation_result_model.dart';
import '../models/interview_session_model.dart';
import '../models/question_model.dart';

abstract class InterviewRemoteDataSource {
  Future<InterviewSessionModel> startInterview({
    required String userId,
    required String jobRole,
    required String difficultyLevel,
    required int numQuestions,
    required String category,
  });

  Future<EvaluationResultModel> submitAnswers({
    required String sessionId,
    required String userId,
    required List<String> answers,
    required String jobRole,
    required String difficultyLevel,
    required String category,
  });

  Future<Map<String, dynamic>> completeInterview({
    required String sessionId,
    required String userId,
    required int score,
    required int timeTaken,
    required int totalQuestions,
    required int correctAnswers,
  });

  Future<String> storeMcqEvaluation({
    required String sessionId,
    required int totalQuestions,
    required int correctAnswers,
    required double finalScore,
    int? timeTaken,
  });

  Future<void> storeInterviewSession(InterviewSessionModel session, String id);
  Future<void> storeQuestions(List<QuestionModel> questions);
  Future<List<InterviewSessionModel>> getUserSessions(String userId);
  Future<List<QuestionModel>> getSessionQuestions(String sessionId);
  Future<Map<String, dynamic>> getSessionStats(String sessionId);
  Future<void> deleteSession(String sessionId);
  Future<Map<String, dynamic>> getActiveSessions();
  Future<bool> checkHealth();
}

class InterviewRemoteDataSourceImpl implements InterviewRemoteDataSource {
  final ApiService _apiService;
  final Databases _databases;

  InterviewRemoteDataSourceImpl({
    required ApiService apiService,
    required Databases databases,
  }) : _apiService = apiService,
       _databases = databases;

  @override
  Future<InterviewSessionModel> startInterview({
    required String userId,
    required String jobRole,
    required String difficultyLevel,
    required int numQuestions,
    required String category,
  }) async {
    try {
      log('Start Interview called');

      StartInterviewRequest requestData = StartInterviewRequest(
        userId: userId,
        jobRole: jobRole,
        interviewType: 'mcq',
        difficultyLevel: difficultyLevel,
        numQuestions: numQuestions,
        category: category,
      );
      final response = await _apiService.dio.post(
        ApiConstants.startInterview,
        data: requestData.toJson(),
      );

      final sessionModel = InterviewSessionModel.fromAIResponse(response.data);

      return sessionModel;
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to start interview');
    } catch (e) {
      throw ServerFailure('Failed to start interview: $e');
    }
  }

  @override
  Future<EvaluationResultModel> submitAnswers({
    required String sessionId,
    required String userId,
    required List<String> answers,
    required String jobRole,
    required String difficultyLevel,
    required String category,
  }) async {
    try {
      log('Submit Answers called');

      final requestData = SubmitAnswerRequest(
        userId: userId,
        jobRole: jobRole,
        interviewType: 'mcq',
        difficultyLevel: difficultyLevel.toLowerCase(),
        numQuestions: answers.length,
        category: category.toLowerCase(),
        answers: answers,
        sessionId: sessionId,
      );

      final response = await _apiService.dio.post(
        ApiConstants.submitResponse,
        data: requestData.toJson(),
      );

      // Convert API response to EvaluationResultModel
      final evaluationResult = EvaluationResultModel.fromJson(response.data);

      // 🆕 Store the evaluation in database
      final correctAnswers =
          evaluationResult.results.where((r) => r.isCorrect).length;
      await storeMcqEvaluation(
        sessionId: sessionId,
        totalQuestions: evaluationResult.totalQuestions,
        correctAnswers: correctAnswers,
        finalScore: evaluationResult.finalScore,
      );

      log('✓ MCQ evaluation stored successfully');

      return evaluationResult;
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to submit answers');
    } catch (e) {
      throw ServerFailure('Failed to submit answers: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> completeInterview({
    required String sessionId,
    required String userId,
    required int score,
    required int timeTaken,
    required int totalQuestions,
    required int correctAnswers,
  }) async {
    try {
      log('Complete Interview called');

      // Update session completion status in database
      final updateData = {
        'isCompleted': true,
        'completedAt': DateTime.now().toIso8601String(),
        'score': score.toDouble(),
        'percentage': ((correctAnswers / totalQuestions) * 100).toDouble(),
        'passed': ((correctAnswers / totalQuestions) * 100) >= 60.0,
        'timeTaken': timeTaken,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
      };

      await _databases.updateDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.sessionsCollection,
        documentId: sessionId,
        data: updateData,
      );

      log('✓ Interview completed and stored successfully');

      return {
        'sessionId': sessionId,
        'score': score,
        'percentage': ((correctAnswers / totalQuestions) * 100).toDouble(),
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'timeTaken': timeTaken,
        'passed': ((correctAnswers / totalQuestions) * 100) >= 60.0,
      };
    } on AppwriteException catch (e) {
      log('❌ AppwriteException completing interview: ${e.message}');
      throw ServerFailure('Failed to complete interview: ${e.message}');
    } catch (e) {
      log('❌ Unexpected error completing interview: $e');
      throw ServerFailure('Failed to complete interview: $e');
    }
  }

  @override
  Future<String> storeMcqEvaluation({
    required String sessionId,
    required int totalQuestions,
    required int correctAnswers,
    required double finalScore,
    int? timeTaken,
  }) async {
    try {
      log('Storing MCQ evaluation for session: $sessionId');

      final evaluationData = {
        'sessionId': sessionId,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'finalScore': finalScore,
        'timeTaken': timeTaken,
        'createdAt': DateTime.now().toIso8601String(),
      };

      final response = await _databases.createDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: DatabaseConstants.mcqEvaluationsCollection,
        documentId: ID.unique(),
        data: evaluationData,
      );

      log('✓ MCQ evaluation stored successfully: ${response.$id}');
      return response.$id;
    } on AppwriteException catch (e) {
      log('❌ AppwriteException storing MCQ evaluation: ${e.message}');
      throw ServerFailure('Failed to store MCQ evaluation: ${e.message}');
    } catch (e) {
      log('❌ Unexpected error storing MCQ evaluation: $e');
      throw ServerFailure('Failed to store MCQ evaluation: $e');
    }
  }

  @override
  Future<void> storeInterviewSession(
    InterviewSessionModel session,
    String id,
  ) async {
    try {
      log('Storing interview session: ${session.sessionId}');

      await _databases.createDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.sessionsCollection,
        documentId: session.sessionId,
        data: session.toAppwrite(id),
      );

      log('✓ Interview session stored successfully');
    } on AppwriteException catch (e) {
      if (e.code == 409) {
        // Document already exists, update it
        await _databases.updateDocument(
          databaseId: AppSecrets.databaseId,
          collectionId: AppSecrets.sessionsCollection,
          documentId: session.sessionId,
          data: session.toAppwrite(id),
        );
        log('✓ Interview session updated successfully');
      } else {
        log('❌ AppwriteException storing session: ${e.message}');
        throw ServerFailure('Failed to store interview session: ${e.message}');
      }
    } catch (e) {
      log('❌ Unexpected error storing session: $e');
      throw ServerFailure('Failed to store interview session: $e');
    }
  }

  @override
  Future<void> storeQuestions(List<QuestionModel> questions) async {
    try {
      log('Storing ${questions.length} questions');

      for (final question in questions) {
        try {
          await _databases.createDocument(
            databaseId: AppSecrets.databaseId,
            collectionId: AppSecrets.questionsCollection,
            documentId: ID.unique(),
            data: question.toAppwrite(),
          );
        } on AppwriteException catch (e) {
          if (e.code == 409) {
            // Document already exists, skip
            log('Question already exists, skipping: ${question.id}');
            continue;
          } else {
            log(
              '❌ AppwriteException storing question ${question.id}: ${e.message}',
            );
            continue;
          }
        }
      }

      log('✓ Questions stored successfully');
    } catch (e) {
      log('❌ Unexpected error storing questions: $e');
      throw ServerFailure('Failed to store questions: $e');
    }
  }

  Future<InterviewSessionModel?> getSessionById(String sessionId) async {
    try {
      log('Fetching session by ID: $sessionId');

      final response = await _databases.listDocuments(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.sessionsCollection,
        queries: [Query.equal('sessionId', sessionId)],
      );

      if (response.documents.isEmpty) {
        log('❌ Session not found: $sessionId');
        return null;
      }

      final session = InterviewSessionModel.fromAppwrite(
        response.documents.first.data,
      );
      log('✓ Found session: ${session.sessionId}');
      return session;
    } on AppwriteException catch (e) {
      log('❌ AppwriteException fetching session: ${e.message}');
      throw ServerFailure('Failed to fetch session: ${e.message}');
    } catch (e) {
      log('❌ Unexpected error fetching session: $e');
      throw ServerFailure('Failed to fetch session: $e');
    }
  }

  @override
  Future<List<InterviewSessionModel>> getUserSessions(String userId) async {
    try {
      log('Fetching sessions for user: $userId');

      final response = await _databases.listDocuments(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.sessionsCollection,
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('\$createdAt'),
        ],
      );

      final sessions =
          response.documents
              .map((doc) => InterviewSessionModel.fromAppwrite(doc.data))
              .toList();

      log('✓ Found ${sessions.length} sessions for user');
      return sessions;
    } on AppwriteException catch (e) {
      log('❌ AppwriteException fetching sessions: ${e.message}');
      throw ServerFailure('Failed to fetch user sessions: ${e.message}');
    } catch (e) {
      log('❌ Unexpected error fetching sessions: $e');
      throw ServerFailure('Failed to fetch user sessions: $e');
    }
  }

  @override
  Future<List<QuestionModel>> getSessionQuestions(String sessionId) async {
    try {
      log('Fetching questions for session: $sessionId');

      final response = await _databases.listDocuments(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.questionsCollection,
        queries: [
          Query.equal('sessionId', sessionId),
          Query.orderAsc('questionNo'),
        ],
      );

      final questions =
          response.documents
              .map((doc) => QuestionModel.fromAppwrite(doc.data))
              .toList();

      log('✓ Found ${questions.length} questions for session');
      return questions;
    } on AppwriteException catch (e) {
      log('❌ AppwriteException fetching questions: ${e.message}');
      throw ServerFailure('Failed to fetch session questions: ${e.message}');
    } catch (e) {
      log('❌ Unexpected error fetching questions: $e');
      throw ServerFailure('Failed to fetch session questions: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getSessionStats(String sessionId) async {
    try {
      log('Get Session Stats called');
      final response = await _apiService.dio.get(
        '${ApiConstants.sessionStats}/$sessionId',
      );
      return response.data;
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to retrieve stats');
    } catch (e) {
      throw ServerFailure('Failed to retrieve stats: $e');
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      await _apiService.dio.delete('${ApiConstants.deleteSession}/$sessionId');
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to delete session');
    } catch (e) {
      throw ServerFailure('Failed to delete session: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getActiveSessions() async {
    log('Get Active Sessions called');
    try {
      final response = await _apiService.dio.get(ApiConstants.activeSessions);
      return response.data;
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to retrieve active sessions');
    } catch (e) {
      throw ServerFailure('Failed to retrieve active sessions: $e');
    }
  }

  @override
  Future<bool> checkHealth() async {
    try {
      log('Health Check called');
      final response = await _apiService.dio.get(ApiConstants.healthCheck);
      return response.data['status'] == 'ok';
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Health check failed');
    } catch (e) {
      throw ServerFailure('Health check failed: $e');
    }
  }
}
