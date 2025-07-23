import 'package:appwrite/appwrite.dart';
import '../models/session_model.dart';
import '../../../../core/constants/appwrite_constants.dart';
import '../../../../core/errors/failures.dart';

abstract class SessionRemoteDataSource {
  Future<List<SessionModel>> getUserSessions(String userId);
  Future<SessionModel> createSession({
    required String userId,
    required String type,
    String? jobRole,
    String? difficulty,
    String? category,
  });
  Future<SessionModel> updateSession(
    String sessionId,
    Map<String, dynamic> data,
  );
  Future<void> deleteSession(String sessionId);
  Future<List<SessionModel>> getSessionsByType({
    required String userId,
    required String type,
  });
  Future<List<SessionModel>> getSessionsInDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });
}

class SessionRemoteDataSourceImpl implements SessionRemoteDataSource {
  final Databases _databases;

  SessionRemoteDataSourceImpl({required Databases databases})
    : _databases = databases;

  @override
  Future<List<SessionModel>> getUserSessions(String userId) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.sessionsCollection,
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('\$createdAt'),
        ],
      );

      return result.documents
          .map((doc) => SessionModel.fromJson(doc.data))
          .toList();
    } on AppwriteException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to get user sessions');
    } catch (e) {
      throw ServerFailure('Unknown error occurred while getting user sessions');
    }
  }

  @override
  Future<SessionModel> createSession({
    required String userId,
    required String type,
    String? jobRole,
    String? difficulty,
    String? category,
  }) async {
    try {
      final result = await _databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.sessionsCollection,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'type': type,
          'jobRole': jobRole,
          'difficulty': difficulty,
          'category': category,
          'status': 'started',
          'isComplete': false,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      return SessionModel.fromJson(result.data);
    } on AppwriteException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to create session');
    } catch (e) {
      throw ServerFailure('Unknown error occurred while creating session');
    }
  }

  @override
  Future<SessionModel> updateSession(
    String sessionId,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.sessionsCollection,
        documentId: sessionId,
        data: data,
      );

      return SessionModel.fromJson(result.data);
    } on AppwriteException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to update session');
    } catch (e) {
      throw ServerFailure('Unknown error occurred while updating session');
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      await _databases.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.sessionsCollection,
        documentId: sessionId,
      );
    } on AppwriteException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to delete session');
    } catch (e) {
      throw ServerFailure('Unknown error occurred while deleting session');
    }
  }

  @override
  Future<List<SessionModel>> getSessionsByType({
    required String userId,
    required String type,
  }) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.sessionsCollection,
        queries: [
          Query.equal('userId', userId),
          Query.equal('type', type),
          Query.orderDesc('\$createdAt'),
        ],
      );

      return result.documents
          .map((doc) => SessionModel.fromJson(doc.data))
          .toList();
    } on AppwriteException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to get sessions by type');
    } catch (e) {
      throw ServerFailure(
        'Unknown error occurred while getting sessions by type',
      );
    }
  }

  @override
  Future<List<SessionModel>> getSessionsInDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.sessionsCollection,
        queries: [
          Query.equal('userId', userId),
          Query.greaterThanEqual('\$createdAt', startDate.toIso8601String()),
          Query.lessThanEqual('\$createdAt', endDate.toIso8601String()),
          Query.orderDesc('\$createdAt'),
        ],
      );

      return result.documents
          .map((doc) => SessionModel.fromJson(doc.data))
          .toList();
    } on AppwriteException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to get sessions in date range');
    } catch (e) {
      throw ServerFailure(
        'Unknown error occurred while getting sessions in date range',
      );
    }
  }
}
