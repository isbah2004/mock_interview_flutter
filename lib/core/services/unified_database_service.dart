import 'package:appwrite/appwrite.dart';
// We'll use appwrite documents and IDs directly
import 'package:mock_interview/core/constants/database_constants.dart';
import 'package:mock_interview/core/models/unified_interview_session.dart';
import 'package:mock_interview/core/models/mcq_question_model.dart';
import 'package:mock_interview/core/models/voice_message_model.dart';
import 'package:mock_interview/core/models/voice_evaluation_model.dart';
import 'package:mock_interview/core/models/mcq_evaluation_model.dart';
import 'package:mock_interview/core/errors/failures.dart';

class UnifiedDatabaseService {
  final Databases _databases;

  UnifiedDatabaseService({required Databases databases})
    : _databases = databases;

  // ==================== INTERVIEW SESSIONS ====================

  /// Create a new interview session
  Future<UnifiedInterviewSession> createInterviewSession(
    UnifiedInterviewSession session,
  ) async {
    try {
      final document = await _databases.createDocument(
        databaseId: DatabaseConstants.databaseId,
        collectionId: DatabaseConstants.interviewSessionsCollection,
        documentId:
            session.sessionId.isNotEmpty ? session.sessionId : ID.unique(),
        data: session.toAppwrite(),
      );

      return UnifiedInterviewSession.fromAppwrite(document.data);
    } on AppwriteException catch (e) {
      throw ServerFailure('Failed to create interview session: ${e.message}');
    } catch (e) {
      throw ServerFailure('Failed to create interview session: $e');
    }
  }

  /// Update an existing interview session
  Future<UnifiedInterviewSession> updateInterviewSession(
    UnifiedInterviewSession session,
  ) async {
    try {
      final document = await _databases.updateDocument(
        databaseId: DatabaseConstants.databaseId,
        collectionId: DatabaseConstants.interviewSessionsCollection,
        documentId: session.sessionId,
        data: session.toAppwrite(),
      );

      return UnifiedInterviewSession.fromAppwrite(document.data);
    } on AppwriteException catch (e) {
      throw ServerFailure('Failed to update interview session: ${e.message}');
    } catch (e) {
      throw ServerFailure('Failed to update interview session: $e');
    }
  }

  /// Get interview session by ID
  Future<UnifiedInterviewSession> getInterviewSession(String sessionId) async {
    try {
      final document = await _databases.getDocument(
        databaseId: DatabaseConstants.databaseId,
        collectionId: DatabaseConstants.interviewSessionsCollection,
        documentId: sessionId,
      );

      return UnifiedInterviewSession.fromAppwrite(document.data);
    } on AppwriteException catch (e) {
      throw ServerFailure('Failed to get interview session: ${e.message}');
    } catch (e) {
      throw ServerFailure('Failed to get interview session: $e');
    }
  }

  /// Get user's interview sessions
  Future<List<UnifiedInterviewSession>> getUserInterviewSessions(
    String userId, {
    int limit = 20,
    String? orderBy,
  }) async {
    try {
      final queries = [Query.equal('userId', userId), Query.limit(limit)];

      if (orderBy != null) {
        queries.add(Query.orderDesc(orderBy));
      } else {
        queries.add(Query.orderDesc('startedAt'));
      }

      final response = await _databases.listDocuments(
        databaseId: DatabaseConstants.databaseId,
        collectionId: DatabaseConstants.interviewSessionsCollection,
        queries: queries,
      );

      return response.documents
          .map((doc) => UnifiedInterviewSession.fromAppwrite(doc.data))
          .toList();
    } on AppwriteException catch (e) {
      throw ServerFailure(
        'Failed to get user interview sessions: ${e.message}',
      );
    } catch (e) {
      throw ServerFailure('Failed to get user interview sessions: $e');
    }
  }

  // ==================== MCQ QUESTIONS ====================

  /// Store MCQ questions for a session
  Future<List<McqQuestionModel>> storeMcqQuestions(
    List<McqQuestionModel> questions,
  ) async {
    try {
      final List<McqQuestionModel> storedQuestions = [];

      for (final question in questions) {
        final document = await _databases.createDocument(
          databaseId: DatabaseConstants.databaseId,
          collectionId: DatabaseConstants.mcqQuestionsCollection,
          documentId: ID.unique(),
          data: question.toAppwrite(),
        );

        storedQuestions.add(McqQuestionModel.fromAppwrite(document.data));
      }

      return storedQuestions;
    } on AppwriteException catch (e) {
      throw ServerFailure('Failed to store MCQ questions: ${e.message}');
    } catch (e) {
      throw ServerFailure('Failed to store MCQ questions: $e');
    }
  }

  /// Get MCQ questions for a session
  Future<List<McqQuestionModel>> getMcqQuestions(String sessionId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: DatabaseConstants.databaseId,
        collectionId: DatabaseConstants.mcqQuestionsCollection,
        queries: [
          Query.equal('sessionId', sessionId),
          Query.orderAsc('questionNo'),
        ],
      );

      return response.documents
          .map((doc) => McqQuestionModel.fromAppwrite(doc.data))
          .toList();
    } on AppwriteException catch (e) {
      throw ServerFailure('Failed to get MCQ questions: ${e.message}');
    } catch (e) {
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
    try {
      final document = await _databases.updateDocument(
        databaseId: DatabaseConstants.databaseId,
        collectionId: DatabaseConstants.mcqQuestionsCollection,
        documentId: questionId,
        data: {
          'userAnswer': userAnswer,
          'isCorrect': isCorrect,
          'score': score,
        },
      );

      return McqQuestionModel.fromAppwrite(document.data);
    } on AppwriteException catch (e) {
      throw ServerFailure('Failed to update MCQ question answer: ${e.message}');
    } catch (e) {
      throw ServerFailure('Failed to update MCQ question answer: $e');
    }
  }

  // ==================== VOICE MESSAGES ====================

  /// Store voice message
  Future<VoiceMessageModel> storeVoiceMessage(VoiceMessageModel message) async {
    try {
      final document = await _databases.createDocument(
        databaseId: DatabaseConstants.databaseId,
        collectionId: DatabaseConstants.voiceMessagesCollection,
        documentId: ID.unique(),
        data: message.toAppwrite(),
      );

      return VoiceMessageModel.fromAppwrite(document.data);
    } on AppwriteException catch (e) {
      throw ServerFailure('Failed to store voice message: ${e.message}');
    } catch (e) {
      throw ServerFailure('Failed to store voice message: $e');
    }
  }

  /// Get voice messages for a session
  Future<List<VoiceMessageModel>> getVoiceMessages(String sessionId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: DatabaseConstants.databaseId,
        collectionId: DatabaseConstants.voiceMessagesCollection,
        queries: [
          Query.equal('sessionId', sessionId),
          Query.orderAsc('sequenceNumber'),
        ],
      );

      return response.documents
          .map((doc) => VoiceMessageModel.fromAppwrite(doc.data))
          .toList();
    } on AppwriteException catch (e) {
      throw ServerFailure('Failed to get voice messages: ${e.message}');
    } catch (e) {
      throw ServerFailure('Failed to get voice messages: $e');
    }
  }

  // ==================== VOICE EVALUATIONS ====================

  /// Store voice evaluation
  Future<VoiceEvaluationModel> storeVoiceEvaluation(
    VoiceEvaluationModel evaluation,
  ) async {
    try {
      final document = await _databases.createDocument(
        databaseId: DatabaseConstants.databaseId,
        collectionId: DatabaseConstants.voiceEvaluationsCollection,
        documentId: ID.unique(),
        data: evaluation.toAppwrite(),
      );

      return VoiceEvaluationModel.fromAppwrite(document.data);
    } on AppwriteException catch (e) {
      throw ServerFailure('Failed to store voice evaluation: ${e.message}');
    } catch (e) {
      throw ServerFailure('Failed to store voice evaluation: $e');
    }
  }

  /// Get voice evaluation for a session
  Future<VoiceEvaluationModel?> getVoiceEvaluation(String sessionId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: DatabaseConstants.databaseId,
        collectionId: DatabaseConstants.voiceEvaluationsCollection,
        queries: [Query.equal('sessionId', sessionId)],
      );

      if (response.documents.isEmpty) return null;

      return VoiceEvaluationModel.fromAppwrite(response.documents.first.data);
    } on AppwriteException catch (e) {
      throw ServerFailure('Failed to get voice evaluation: ${e.message}');
    } catch (e) {
      throw ServerFailure('Failed to get voice evaluation: $e');
    }
  }

  // ==================== MCQ EVALUATIONS ====================

  /// Store MCQ evaluation
  Future<McqEvaluationModel> storeMcqEvaluation(
    McqEvaluationModel evaluation,
  ) async {
    try {
      final document = await _databases.createDocument(
        databaseId: DatabaseConstants.databaseId,
        collectionId: DatabaseConstants.mcqEvaluationsCollection,
        documentId: ID.unique(),
        data: evaluation.toAppwrite(),
      );

      return McqEvaluationModel.fromAppwrite(document.data);
    } on AppwriteException catch (e) {
      throw ServerFailure('Failed to store MCQ evaluation: ${e.message}');
    } catch (e) {
      throw ServerFailure('Failed to store MCQ evaluation: $e');
    }
  }

  /// Get MCQ evaluation for a session
  Future<McqEvaluationModel?> getMcqEvaluation(String sessionId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: DatabaseConstants.databaseId,
        collectionId: DatabaseConstants.mcqEvaluationsCollection,
        queries: [Query.equal('sessionId', sessionId)],
      );

      if (response.documents.isEmpty) return null;

      return McqEvaluationModel.fromAppwrite(response.documents.first.data);
    } on AppwriteException catch (e) {
      throw ServerFailure('Failed to get MCQ evaluation: ${e.message}');
    } catch (e) {
      throw ServerFailure('Failed to get MCQ evaluation: $e');
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Delete interview session and all related data
  Future<void> deleteInterviewSession(String sessionId) async {
    try {
      // Delete related data first
      await _deleteRelatedData(sessionId);

      // Delete the session
      await _databases.deleteDocument(
        databaseId: DatabaseConstants.databaseId,
        collectionId: DatabaseConstants.interviewSessionsCollection,
        documentId: sessionId,
      );
    } on AppwriteException catch (e) {
      throw ServerFailure('Failed to delete interview session: ${e.message}');
    } catch (e) {
      throw ServerFailure('Failed to delete interview session: $e');
    }
  }

  Future<void> _deleteRelatedData(String sessionId) async {
    // Delete MCQ questions
    final mcqQuestions = await getMcqQuestions(sessionId);
    for (final question in mcqQuestions) {
      await _databases.deleteDocument(
        databaseId: DatabaseConstants.databaseId,
        collectionId: DatabaseConstants.mcqQuestionsCollection,
        documentId: question.questionId,
      );
    }

    // Delete voice messages
    final voiceMessages = await getVoiceMessages(sessionId);
    for (final message in voiceMessages) {
      await _databases.deleteDocument(
        databaseId: DatabaseConstants.databaseId,
        collectionId: DatabaseConstants.voiceMessagesCollection,
        documentId: message.messageId,
      );
    }

    // Delete evaluations
    final voiceEvaluation = await getVoiceEvaluation(sessionId);
    if (voiceEvaluation != null) {
      await _databases.deleteDocument(
        databaseId: DatabaseConstants.databaseId,
        collectionId: DatabaseConstants.voiceEvaluationsCollection,
        documentId: voiceEvaluation.evaluationId,
      );
    }

    final mcqEvaluation = await getMcqEvaluation(sessionId);
    if (mcqEvaluation != null) {
      await _databases.deleteDocument(
        databaseId: DatabaseConstants.databaseId,
        collectionId: DatabaseConstants.mcqEvaluationsCollection,
        documentId: mcqEvaluation.evaluationId,
      );
    }
  }
}
