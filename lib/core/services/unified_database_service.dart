import 'dart:developer' as dev;

import 'package:appwrite/appwrite.dart';
import 'package:mock_interview/core/constants/app_secrets.dart';
import 'package:mock_interview/core/models/unified_interview_session.dart';
import 'package:mock_interview/core/models/mcq_question_model.dart';
import 'package:mock_interview/core/models/voice_message_model.dart';
import 'package:mock_interview/core/models/voice_evaluation_model.dart';
import 'package:mock_interview/core/models/mcq_evaluation_model.dart';
import 'package:mock_interview/core/errors/failures.dart';

class UnifiedDatabaseService {
  static const _loggerName = 'UnifiedDatabaseService';
  final Databases _databases;

  UnifiedDatabaseService({required Databases databases})
    : _databases = databases {
    dev.log('UnifiedDatabaseService initialized', name: _loggerName);
  }

  Future<UnifiedInterviewSession> createInterviewSession(
    UnifiedInterviewSession session,
  ) async {
    dev.log(
      'createInterviewSession - start for sessionId: ${session.sessionId}',
      name: _loggerName,
    );
    try {
      final document = await _databases.createDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.interviewSessionsCollection,
        documentId:
            session.sessionId.isNotEmpty ? session.sessionId : ID.unique(),
        data: session.toAppwrite(),
      );

      dev.log(
        'createInterviewSession - success for sessionId: ${session.sessionId}',
        name: _loggerName,
      );
      return UnifiedInterviewSession.fromAppwrite(document.data);
    } on AppwriteException catch (e, st) {
      dev.log(
        'createInterviewSession - AppwriteException: ${e.message}',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to create interview session: ${e.message}');
    } catch (e, st) {
      dev.log(
        'createInterviewSession - Exception: $e',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to create interview session: $e');
    }
  }

  /// Update an existing interview session
  Future<UnifiedInterviewSession> updateInterviewSession(
    UnifiedInterviewSession session,
  ) async {
    dev.log(
      'updateInterviewSession - start for sessionId: ${session.sessionId}',
      name: _loggerName,
    );
    try {
      final document = await _databases.updateDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.interviewSessionsCollection,
        documentId: session.sessionId,
        data: session.toAppwrite(),
      );

      dev.log(
        'updateInterviewSession - success for sessionId: ${session.sessionId}',
        name: _loggerName,
      );
      return UnifiedInterviewSession.fromAppwrite(document.data);
    } on AppwriteException catch (e, st) {
      dev.log(
        'updateInterviewSession - AppwriteException: ${e.message}',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to update interview session: ${e.message}');
    } catch (e, st) {
      dev.log(
        'updateInterviewSession - Exception: $e',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to update interview session: $e');
    }
  }

  /// Get interview session by ID
  Future<UnifiedInterviewSession> getInterviewSession(String sessionId) async {
    dev.log(
      'getInterviewSession - start for sessionId: $sessionId',
      name: _loggerName,
    );
    try {
      final document = await _databases.getDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.interviewSessionsCollection,
        documentId: sessionId,
      );

      dev.log(
        'getInterviewSession - success for sessionId: $sessionId',
        name: _loggerName,
      );
      return UnifiedInterviewSession.fromAppwrite(document.data);
    } on AppwriteException catch (e, st) {
      dev.log(
        'getInterviewSession - AppwriteException: ${e.message}',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to get interview session: ${e.message}');
    } catch (e, st) {
      dev.log(
        'getInterviewSession - Exception: $e',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to get interview session: $e');
    }
  }

  /// Get user's interview sessions
  Future<List<UnifiedInterviewSession>> getUserInterviewSessions(
    String userId, {
    int limit = 20,
    String? orderBy,
  }) async {
    dev.log(
      'getUserInterviewSessions - start for userId: $userId, limit: $limit, orderBy: $orderBy',
      name: _loggerName,
    );
    try {
      final queries = [Query.equal('userId', userId), Query.limit(limit)];

      if (orderBy != null) {
        queries.add(Query.orderDesc(orderBy));
      } else {
        queries.add(Query.orderDesc('startedAt'));
      }

      final response = await _databases.listDocuments(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.interviewSessionsCollection,
        queries: queries,
      );

      dev.log(
        'getUserInterviewSessions - success for userId: $userId, found: ${response.documents.length}',
        name: _loggerName,
      );
      return response.documents
          .map((doc) => UnifiedInterviewSession.fromAppwrite(doc.data))
          .toList();
    } on AppwriteException catch (e, st) {
      dev.log(
        'getUserInterviewSessions - AppwriteException: ${e.message}',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure(
        'Failed to get user interview sessions: ${e.message}',
      );
    } catch (e, st) {
      dev.log(
        'getUserInterviewSessions - Exception: $e',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to get user interview sessions: $e');
    }
  }

  // ==================== MCQ QUESTIONS ====================

  /// Store MCQ questions for a session
  Future<List<McqQuestionModel>> storeMcqQuestions(
    List<McqQuestionModel> questions,
  ) async {
    dev.log(
      'storeMcqQuestions - start, count: ${questions.length}',
      name: _loggerName,
    );
    try {
      final List<McqQuestionModel> storedQuestions = [];

      for (final question in questions) {
        dev.log(
          'storeMcqQuestions - storing questionNo: ${question.questionNo} with ID: ${question.questionId}',
          name: _loggerName,
        );
        final document = await _databases.createDocument(
          databaseId: AppSecrets.databaseId,
          collectionId: AppSecrets.mcqQuestionsCollection,
          documentId: question.questionId, // Use the questionId from the model
          data: question.toAppwrite(),
        );

        storedQuestions.add(McqQuestionModel.fromAppwrite(document.data));
      }

      dev.log(
        'storeMcqQuestions - success, stored: ${storedQuestions.length}',
        name: _loggerName,
      );
      return storedQuestions;
    } on AppwriteException catch (e, st) {
      dev.log(
        'storeMcqQuestions - AppwriteException: ${e.message}',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to store MCQ questions: ${e.message}');
    } catch (e, st) {
      dev.log(
        'storeMcqQuestions - Exception: $e',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to store MCQ questions: $e');
    }
  }

  /// Get MCQ questions for a session
  Future<List<McqQuestionModel>> getMcqQuestions(String sessionId) async {
    dev.log(
      'getMcqQuestions - start for sessionId: $sessionId',
      name: _loggerName,
    );
    try {
      final response = await _databases.listDocuments(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.mcqQuestionsCollection,
        queries: [
          Query.equal('sessionId', sessionId),
          Query.orderAsc('questionNo'),
        ],
      );

      dev.log(
        'getMcqQuestions - success, found: ${response.documents.length}',
        name: _loggerName,
      );
      return response.documents
          .map((doc) => McqQuestionModel.fromAppwrite(doc.data))
          .toList();
    } on AppwriteException catch (e, st) {
      dev.log(
        'getMcqQuestions - AppwriteException: ${e.message}',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to get MCQ questions: ${e.message}');
    } catch (e, st) {
      dev.log(
        'getMcqQuestions - Exception: $e',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to get MCQ questions: $e');
    }
  }

  /// Update MCQ question with user answer
  Future<McqQuestionModel> updateMcqQuestionAnswer(
    String questionId,
    String userAnswer,
    bool isCorrect,
    double score,
  ) async {
    dev.log(
      'updateMcqQuestionAnswer - start for questionId: $questionId, userAnswer: $userAnswer, isCorrect: $isCorrect, score: $score',
      name: _loggerName,
    );
    try {
      final document = await _databases.updateDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.mcqQuestionsCollection,
        documentId: questionId,
        data: {
          'userAnswer': userAnswer,
          'isCorrect': isCorrect,
          'score': score,
        },
      );

      dev.log(
        'updateMcqQuestionAnswer - success for questionId: $questionId',
        name: _loggerName,
      );
      return McqQuestionModel.fromAppwrite(document.data);
    } on AppwriteException catch (e, st) {
      dev.log(
        'updateMcqQuestionAnswer - AppwriteException: ${e.message}',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to update MCQ question answer: ${e.message}');
    } catch (e, st) {
      dev.log(
        'updateMcqQuestionAnswer - Exception: $e',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to update MCQ question answer: $e');
    }
  }

  // ==================== VOICE MESSAGES ====================

  /// Store voice message
  Future<VoiceMessageModel> storeVoiceMessage(VoiceMessageModel message) async {
    dev.log(
      'storeVoiceMessage - start for messageId: ${message.messageId}, sessionId: ${message.sessionId}',
      name: _loggerName,
    );
    try {
      final document = await _databases.createDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.voiceMessagesCollection,
        documentId: ID.unique(),
        data: message.toAppwrite(),
      );

      dev.log(
        'storeVoiceMessage - success for messageId: ${message.messageId}',
        name: _loggerName,
      );
      return VoiceMessageModel.fromAppwrite(document.data);
    } on AppwriteException catch (e, st) {
      dev.log(
        'storeVoiceMessage - AppwriteException: ${e.message}',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to store voice message: ${e.message}');
    } catch (e, st) {
      dev.log(
        'storeVoiceMessage - Exception: $e',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to store voice message: $e');
    }
  }

  /// Get voice messages for a session
  Future<List<VoiceMessageModel>> getVoiceMessages(String sessionId) async {
    dev.log(
      'getVoiceMessages - start for sessionId: $sessionId',
      name: _loggerName,
    );
    try {
      final response = await _databases.listDocuments(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.voiceMessagesCollection,
        queries: [
          Query.equal('sessionId', sessionId),
          Query.orderAsc('sequenceNumber'),
        ],
      );

      dev.log(
        'getVoiceMessages - success, found: ${response.documents.length}',
        name: _loggerName,
      );
      return response.documents
          .map((doc) => VoiceMessageModel.fromAppwrite(doc.data))
          .toList();
    } on AppwriteException catch (e, st) {
      dev.log(
        'getVoiceMessages - AppwriteException: ${e.message}',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to get voice messages: ${e.message}');
    } catch (e, st) {
      dev.log(
        'getVoiceMessages - Exception: $e',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to get voice messages: $e');
    }
  }

  // ==================== VOICE EVALUATIONS ====================

  /// Store voice evaluation
  Future<VoiceEvaluationModel> storeVoiceEvaluation(
    VoiceEvaluationModel evaluation,
  ) async {
    dev.log(
      'storeVoiceEvaluation - start for evaluationId: ${evaluation.evaluationId}, sessionId: ${evaluation.sessionId}',
      name: _loggerName,
    );
    try {
      final document = await _databases.createDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.voiceEvaluationsCollection,
        documentId: ID.unique(),
        data: evaluation.toAppwrite(),
      );

      dev.log(
        'storeVoiceEvaluation - success for evaluationId: ${evaluation.evaluationId}',
        name: _loggerName,
      );
      return VoiceEvaluationModel.fromAppwrite(document.data);
    } on AppwriteException catch (e, st) {
      dev.log(
        'storeVoiceEvaluation - AppwriteException: ${e.message}',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to store voice evaluation: ${e.message}');
    } catch (e, st) {
      dev.log(
        'storeVoiceEvaluation - Exception: $e',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to store voice evaluation: $e');
    }
  }

  /// Get voice evaluation for a session
  Future<VoiceEvaluationModel?> getVoiceEvaluation(String sessionId) async {
    dev.log(
      'getVoiceEvaluation - start for sessionId: $sessionId',
      name: _loggerName,
    );
    try {
      final response = await _databases.listDocuments(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.voiceEvaluationsCollection,
        queries: [Query.equal('sessionId', sessionId)],
      );

      if (response.documents.isEmpty) {
        dev.log(
          'getVoiceEvaluation - none found for sessionId: $sessionId',
          name: _loggerName,
        );
        return null;
      }

      dev.log(
        'getVoiceEvaluation - found for sessionId: $sessionId',
        name: _loggerName,
      );
      return VoiceEvaluationModel.fromAppwrite(response.documents.first.data);
    } on AppwriteException catch (e, st) {
      dev.log(
        'getVoiceEvaluation - AppwriteException: ${e.message}',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to get voice evaluation: ${e.message}');
    } catch (e, st) {
      dev.log(
        'getVoiceEvaluation - Exception: $e',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to get voice evaluation: $e');
    }
  }

  // ==================== MCQ EVALUATIONS ====================

  /// Store MCQ evaluation
  Future<McqEvaluationModel> storeMcqEvaluation(
    McqEvaluationModel evaluation,
  ) async {
    dev.log(
      'storeMcqEvaluation - start for evaluationId: ${evaluation.evaluationId}, sessionId: ${evaluation.sessionId}',
      name: _loggerName,
    );
    try {
      final document = await _databases.createDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.mcqEvaluationsCollection,
        documentId: ID.unique(),
        data: evaluation.toAppwrite(),
      );

      dev.log(
        'storeMcqEvaluation - success for evaluationId: ${evaluation.evaluationId}',
        name: _loggerName,
      );
      return McqEvaluationModel.fromAppwrite(document.data);
    } on AppwriteException catch (e, st) {
      dev.log(
        'storeMcqEvaluation - AppwriteException: ${e.message}',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to store MCQ evaluation: ${e.message}');
    } catch (e, st) {
      dev.log(
        'storeMcqEvaluation - Exception: $e',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to store MCQ evaluation: $e');
    }
  }

  /// Get MCQ evaluation for a session
  Future<McqEvaluationModel?> getMcqEvaluation(String sessionId) async {
    dev.log(
      'getMcqEvaluation - start for sessionId: $sessionId',
      name: _loggerName,
    );
    try {
      final response = await _databases.listDocuments(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.mcqEvaluationsCollection,
        queries: [Query.equal('sessionId', sessionId)],
      );

      if (response.documents.isEmpty) {
        dev.log(
          'getMcqEvaluation - none found for sessionId: $sessionId',
          name: _loggerName,
        );
        return null;
      }

      dev.log(
        'getMcqEvaluation - found for sessionId: $sessionId',
        name: _loggerName,
      );
      return McqEvaluationModel.fromAppwrite(response.documents.first.data);
    } on AppwriteException catch (e, st) {
      dev.log(
        'getMcqEvaluation - AppwriteException: ${e.message}',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to get MCQ evaluation: ${e.message}');
    } catch (e, st) {
      dev.log(
        'getMcqEvaluation - Exception: $e',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to get MCQ evaluation: $e');
    }
  }

  /// Store enhanced MCQ evaluation with detailed analysis
  Future<String> storeEnhancedMCQEvaluation(
    Map<String, dynamic> evaluationData,
  ) async {
    dev.log(
      'storeEnhancedMCQEvaluation - start for sessionId: ${evaluationData['sessionId']}',
      name: _loggerName,
    );
    try {
      final document = await _databases.createDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.mcqEvaluationsCollection,
        documentId: ID.unique(),
        data: evaluationData,
      );

      dev.log(
        'storeEnhancedMCQEvaluation - success for sessionId: ${evaluationData['sessionId']}',
        name: _loggerName,
      );
      return document.$id;
    } on AppwriteException catch (e, st) {
      dev.log(
        'storeEnhancedMCQEvaluation - AppwriteException: ${e.message}',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure(
        'Failed to store enhanced MCQ evaluation: ${e.message}',
      );
    } catch (e, st) {
      dev.log(
        'storeEnhancedMCQEvaluation - Exception: $e',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to store enhanced MCQ evaluation: $e');
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Delete interview session and all related data
  Future<void> deleteInterviewSession(String sessionId) async {
    dev.log(
      'deleteInterviewSession - start for sessionId: $sessionId',
      name: _loggerName,
    );
    try {
      // Delete related data first
      await _deleteRelatedData(sessionId);

      // Delete the session
      await _databases.deleteDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.interviewSessionsCollection,
        documentId: sessionId,
      );

      dev.log(
        'deleteInterviewSession - success for sessionId: $sessionId',
        name: _loggerName,
      );
    } on AppwriteException catch (e, st) {
      dev.log(
        'deleteInterviewSession - AppwriteException: ${e.message}',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to delete interview session: ${e.message}');
    } catch (e, st) {
      dev.log(
        'deleteInterviewSession - Exception: $e',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to delete interview session: $e');
    }
  }

  Future<void> _deleteRelatedData(String sessionId) async {
    dev.log(
      '_deleteRelatedData - start for sessionId: $sessionId',
      name: _loggerName,
    );
    // Delete MCQ questions
    final mcqQuestions = await getMcqQuestions(sessionId);
    dev.log(
      '_deleteRelatedData - mcqQuestions count: ${mcqQuestions.length}',
      name: _loggerName,
    );
    for (final question in mcqQuestions) {
      dev.log(
        'Deleting MCQ question id: ${question.questionId}',
        name: _loggerName,
      );
      await _databases.deleteDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.mcqQuestionsCollection,
        documentId: question.questionId,
      );
      dev.log(
        'Deleted MCQ question id: ${question.questionId}',
        name: _loggerName,
      );
    }

    // Delete voice messages
    final voiceMessages = await getVoiceMessages(sessionId);
    dev.log(
      '_deleteRelatedData - voiceMessages count: ${voiceMessages.length}',
      name: _loggerName,
    );
    for (final message in voiceMessages) {
      dev.log(
        'Deleting voice message id: ${message.messageId}',
        name: _loggerName,
      );
      await _databases.deleteDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.voiceMessagesCollection,
        documentId: message.messageId,
      );
      dev.log(
        'Deleted voice message id: ${message.messageId}',
        name: _loggerName,
      );
    }

    // Delete evaluations
    final voiceEvaluation = await getVoiceEvaluation(sessionId);
    if (voiceEvaluation != null) {
      dev.log(
        'Deleting voice evaluation id: ${voiceEvaluation.evaluationId}',
        name: _loggerName,
      );
      await _databases.deleteDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.voiceEvaluationsCollection,
        documentId: voiceEvaluation.evaluationId,
      );
      dev.log(
        'Deleted voice evaluation id: ${voiceEvaluation.evaluationId}',
        name: _loggerName,
      );
    } else {
      dev.log(
        'No voice evaluation to delete for sessionId: $sessionId',
        name: _loggerName,
      );
    }

    final mcqEvaluation = await getMcqEvaluation(sessionId);
    if (mcqEvaluation != null) {
      dev.log(
        'Deleting mcq evaluation id: ${mcqEvaluation.evaluationId}',
        name: _loggerName,
      );
      await _databases.deleteDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.mcqEvaluationsCollection,
        documentId: mcqEvaluation.evaluationId,
      );
      dev.log(
        'Deleted mcq evaluation id: ${mcqEvaluation.evaluationId}',
        name: _loggerName,
      );
    } else {
      dev.log(
        'No mcq evaluation to delete for sessionId: $sessionId',
        name: _loggerName,
      );
    }

    dev.log(
      '_deleteRelatedData - completed for sessionId: $sessionId',
      name: _loggerName,
    );
  }

  // ==================== VOICE INTERVIEW SESSION METHODS ====================

  /// Save voice interview session (alias for createInterviewSession for voice interviews)
  Future<UnifiedInterviewSession> saveVoiceInterviewSession(
    UnifiedInterviewSession session,
  ) async {
    dev.log(
      'saveVoiceInterviewSession - start for sessionId: ${session.sessionId}',
      name: _loggerName,
    );

    try {
      // Check if session already exists
      final existingSession = await getInterviewSession(session.sessionId);

      if (existingSession.sessionId.isNotEmpty) {
        // Update existing session
        return await updateInterviewSession(session);
      } else {
        // Create new session
        return await createInterviewSession(session);
      }
    } catch (e, st) {
      dev.log(
        'saveVoiceInterviewSession - Exception: $e',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to save voice interview session: $e');
    }
  }

  /// Get voice interview session (alias for getInterviewSession for voice interviews)
  Future<UnifiedInterviewSession?> getVoiceInterviewSession(
    String sessionId,
  ) async {
    dev.log(
      'getVoiceInterviewSession - start for sessionId: $sessionId',
      name: _loggerName,
    );

    try {
      final session = await getInterviewSession(sessionId);

      if (session.interviewType == 'voice') {
        dev.log(
          'getVoiceInterviewSession - success for sessionId: $sessionId',
          name: _loggerName,
        );
        return session;
      } else {
        dev.log(
          'getVoiceInterviewSession - session not found or not voice type for sessionId: $sessionId',
          name: _loggerName,
        );
        return null;
      }
    } catch (e, st) {
      dev.log(
        'getVoiceInterviewSession - Exception: $e',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      return null; // Return null instead of throwing for voice interview specific method
    }
  }

  /// Save voice evaluation (alias for storeVoiceEvaluation)
  Future<VoiceEvaluationModel> saveVoiceEvaluation(
    VoiceEvaluationModel evaluation,
  ) async {
    dev.log(
      'saveVoiceEvaluation - delegating to storeVoiceEvaluation for sessionId: ${evaluation.sessionId}',
      name: _loggerName,
    );

    return await storeVoiceEvaluation(evaluation);
  }

  /// Get all voice interview sessions for a user
  Future<List<UnifiedInterviewSession>> getVoiceInterviewsForUser(
    String userId,
  ) async {
    dev.log(
      'getVoiceInterviewsForUser - start for userId: $userId',
      name: _loggerName,
    );

    try {
      final response = await _databases.listDocuments(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.interviewSessionsCollection,
        queries: [
          Query.equal('userId', userId),
          Query.equal('interviewType', 'voice'),
          Query.orderDesc('\$createdAt'),
        ],
      );

      final sessions =
          response.documents
              .map((doc) => UnifiedInterviewSession.fromAppwrite(doc.data))
              .toList();

      dev.log(
        'getVoiceInterviewsForUser - success, found: ${sessions.length} sessions for userId: $userId',
        name: _loggerName,
      );
      return sessions;
    } on AppwriteException catch (e, st) {
      dev.log(
        'getVoiceInterviewsForUser - AppwriteException: ${e.message}',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure(
        'Failed to get voice interviews for user: ${e.message}',
      );
    } catch (e, st) {
      dev.log(
        'getVoiceInterviewsForUser - Exception: $e',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to get voice interviews for user: $e');
    }
  }

  /// Save MCQ interview results
  Future<String> saveMcqInterview({
    required String jobTitle,
    required List<McqQuestionModel> questions,
    required List<String> answers,
    required double score,
  }) async {
    dev.log(
      'saveMcqInterview - start for jobTitle: $jobTitle',
      name: _loggerName,
    );
    try {
      // Generate session ID
      final sessionId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create interview session
      final session = UnifiedInterviewSession(
        sessionId: sessionId,
        userId: '', // Will be set by Appwrite
        interviewType: 'mcq',
        jobRole: jobTitle,
        difficulty: 'medium',
        category: 'general',
        isCompleted: true,
        startedAt: DateTime.now(),
        completedAt: DateTime.now(),
        score: score,
        totalQuestions: questions.length,
        duration: 0, // MCQ doesn't track duration
      );

      // Save the session first
      await createInterviewSession(session);

      // Store questions with answers
      final questionsWithAnswers = <McqQuestionModel>[];
      for (int i = 0; i < questions.length; i++) {
        final question = questions[i];
        final userAnswer = i < answers.length ? answers[i] : '';
        final isCorrect = userAnswer == question.correctAnswer;

        questionsWithAnswers.add(
          question.copyWith(
            sessionId: sessionId,
            userAnswer: userAnswer,
            isCorrect: isCorrect,
            score: isCorrect ? 1.0 : 0.0,
          ),
        );
      }

      await storeMcqQuestions(questionsWithAnswers);

      // Create and store evaluation
      final evaluation = McqEvaluationModel(
        evaluationId: '${sessionId}_eval',
        sessionId: sessionId,
        finalScore: score,
        totalQuestions: questions.length,
        correctAnswers: _calculateCorrectAnswers(questions, answers),
        timeTaken: 0, // MCQ doesn't track time
        createdAt: DateTime.now(),
      );

      await storeMcqEvaluation(evaluation);

      dev.log(
        'saveMcqInterview - success for sessionId: $sessionId',
        name: _loggerName,
      );

      return sessionId;
    } on AppwriteException catch (e, st) {
      dev.log(
        'saveMcqInterview - AppwriteException: ${e.message}',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to save MCQ interview: ${e.message}');
    } catch (e, st) {
      dev.log(
        'saveMcqInterview - Exception: $e',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      throw ServerFailure('Failed to save MCQ interview: $e');
    }
  }

  int _calculateCorrectAnswers(
    List<McqQuestionModel> questions,
    List<String> answers,
  ) {
    int correct = 0;
    for (int i = 0; i < questions.length && i < answers.length; i++) {
      if (answers[i] == questions[i].correctAnswer) {
        correct++;
      }
    }
    return correct;
  }
}
