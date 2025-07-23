import 'package:appwrite/appwrite.dart';
import 'package:mock_interview/core/constants/appwrite_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/entities/interview_session.dart';

abstract class InterviewLocalDataSource {
  Future<void> saveSession(InterviewSession session);
  Future<List<InterviewSession>> getUserSessions(String userId);
  Future<void> updateSession(InterviewSession session);
  Future<void> deleteSession(String sessionId);
}

class InterviewLocalDataSourceImpl implements InterviewLocalDataSource {
  final Databases databases;


  InterviewLocalDataSourceImpl({required this.databases});

  @override
  Future<void> saveSession(InterviewSession session) async {
    try {
      await databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.sessionsCollection,
        documentId: session.sessionId,
        data: _sessionToMap(session),
      );
    } on AppwriteException catch (e) {
      throw CacheException(e.message ?? 'Failed to save session');
    }
  }

  @override
  Future<List<InterviewSession>> getUserSessions(String userId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.sessionsCollection,
        queries: [
          Query.equal('user_id', userId),
          Query.orderDesc('created_at'),
        ],
      );

      return response.documents.map((doc) => _mapToSession(doc.data)).toList();
    } on AppwriteException catch (e) {
      throw CacheException(e.message ?? 'Failed to fetch sessions');
    }
  }

  @override
  Future<void> updateSession(InterviewSession session) async {
    try {
      await databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.sessionsCollection,
        documentId: session.sessionId,
        data: _sessionToMap(session),
      );
    } on AppwriteException catch (e) {
      throw CacheException(e.message ?? 'Failed to update session');
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      await databases.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.sessionsCollection,
        documentId: sessionId,
      );
    } on AppwriteException catch (e) {
      throw CacheException(e.message ?? 'Failed to delete session');
    }
  }

  Map<String, dynamic> _sessionToMap(InterviewSession session) {
    return {
      'user_id': session.userId,
      'job_role': session.jobRole,
      'interview_type': session.interviewType.name,
      'difficulty_level': session.difficultyLevel.name,
      'category': session.category.name,
      'num_questions': session.numQuestions,
      'created_at': session.createdAt.toIso8601String(),
      'is_complete': session.isComplete,
    };
  }

  InterviewSession _mapToSession(Map<String, dynamic> data) {
    return InterviewSession(
      sessionId: data['\$id'],
      userId: data['user_id'],
      jobRole: data['job_role'],
      type: InterviewType.values.firstWhere(
        (e) => e.name == data['interview_type'],
      ),
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == data['difficulty_level'],
      ),
      category: QuestionCategory.values.firstWhere(
        (e) => e.name == data['category'],
      ),
      numQuestions: data['num_questions'],
      createdAt: DateTime.parse(data['created_at']),
      isComplete: data['is_complete'] ?? false,
    );
  }
}
