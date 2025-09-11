import 'package:appwrite/appwrite.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mock_interview/core/constants/app_secrets.dart';
import 'package:mock_interview/core/entities/user.dart';
import 'package:mock_interview/core/enums/auth_provider.dart';
import 'package:mock_interview/core/models/unified_interview_session.dart';
import 'dart:developer' as dev;

/// Service to handle user statistics updates after interviews
class UserStatsService {
  final Databases _databases;
  final GetStorage _storage;
  static const String _loggerName = 'UserStatsService';

  UserStatsService({required Databases databases, required GetStorage storage})
    : _databases = databases,
      _storage = storage;

  /// Update user statistics after completing an interview
  Future<UserEntity> updateUserStatsAfterInterview({
    required UserEntity currentUser,
    required UnifiedInterviewSession completedSession,
  }) async {
    dev.log(
      'updateUserStatsAfterInterview - start for user: ${currentUser.id}',
      name: _loggerName,
    );

    dev.log(
      'Current user stats - total: ${currentUser.totalInterviews}, voice: ${currentUser.voiceInterviews}, mcq: ${currentUser.mcqInterviews}, avg: ${currentUser.averageScore}',
      name: _loggerName,
    );

    dev.log(
      'Completed session - type: ${completedSession.interviewType}, score: ${completedSession.score}',
      name: _loggerName,
    );

    try {
      // Calculate new statistics
      final newTotalInterviews = currentUser.totalInterviews + 1;

      int newVoiceInterviews = currentUser.voiceInterviews;
      int newMcqInterviews = currentUser.mcqInterviews;

      if (completedSession.interviewType == 'voice') {
        newVoiceInterviews++;
      } else if (completedSession.interviewType == 'mcq') {
        newMcqInterviews++;
      }

      // Calculate new average score
      final currentTotalScore =
          currentUser.averageScore * currentUser.totalInterviews;
      final newScore = completedSession.score ?? 0.0;
      final newAverageScore =
          (currentTotalScore + newScore) / newTotalInterviews;

      dev.log(
        'Calculated new stats - total: $newTotalInterviews, voice: $newVoiceInterviews, mcq: $newMcqInterviews, avg: $newAverageScore',
        name: _loggerName,
      );

      // Create updated user entity
      final updatedUser = currentUser.copyWith(
        totalInterviews: newTotalInterviews,
        voiceInterviews: newVoiceInterviews,
        mcqInterviews: newMcqInterviews,
        averageScore: newAverageScore,
        updatedAt: DateTime.now(),
      );

      dev.log(
        'About to update Appwrite document with ID: ${currentUser.id}',
        name: _loggerName,
      );

      // Update in Appwrite
      await _databases.updateDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.usersCollection,
        documentId: currentUser.id,
        data: {
          'totalInterviews': newTotalInterviews,
          'voiceInterviews': newVoiceInterviews,
          'mcqInterviews': newMcqInterviews,
          'averageScore': newAverageScore,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      dev.log(
        'updateUserStatsAfterInterview - Appwrite update successful',
        name: _loggerName,
      );

      // Update in GetStorage as well - store complete user data
      try {
        await _storeCompleteUserData(updatedUser);

        dev.log(
          'updateUserStatsAfterInterview - GetStorage update successful',
          name: _loggerName,
        );
      } catch (storageError) {
        dev.log(
          'updateUserStatsAfterInterview - GetStorage update failed: $storageError',
          name: _loggerName,
          error: storageError,
        );
      }

      dev.log(
        'updateUserStatsAfterInterview - success: total=$newTotalInterviews, voice=$newVoiceInterviews, mcq=$newMcqInterviews, avg=${newAverageScore.toStringAsFixed(1)}',
        name: _loggerName,
      );

      return updatedUser;
    } catch (e, st) {
      dev.log(
        'updateUserStatsAfterInterview - error: $e',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Get current user statistics from database
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    dev.log('getUserStats - start for user: $userId', name: _loggerName);

    try {
      final document = await _databases.getDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.usersCollection,
        documentId: userId,
      );

      final stats = {
        'totalInterviews': document.data['totalInterviews'] ?? 0,
        'voiceInterviews': document.data['voiceInterviews'] ?? 0,
        'mcqInterviews': document.data['mcqInterviews'] ?? 0,
        'averageScore': (document.data['averageScore'] ?? 0.0).toDouble(),
      };

      dev.log('getUserStats - success: $stats', name: _loggerName);
      return stats;
    } catch (e, st) {
      dev.log(
        'getUserStats - error: $e',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Calculate performance growth over time
  Future<double> calculateGrowthPercentage(String userId) async {
    dev.log(
      'calculateGrowthPercentage - start for user: $userId',
      name: _loggerName,
    );

    try {
      // Get recent sessions to calculate growth
      final recentSessions = await _databases.listDocuments(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.interviewSessionsCollection,
        queries: [
          Query.equal('userId', userId),
          Query.equal('isCompleted', true),
          Query.orderDesc('completedAt'),
          Query.limit(10), // Last 10 sessions
        ],
      );

      if (recentSessions.documents.length < 2) {
        return 0.0; // Not enough data for growth calculation
      }

      final sessions = recentSessions.documents;

      // Calculate average of first half vs second half
      final halfPoint = sessions.length ~/ 2;
      final recentHalf = sessions.take(halfPoint);
      final olderHalf = sessions.skip(halfPoint);

      final recentAvg =
          recentHalf
              .map((doc) => (doc.data['percentage'] ?? 0.0).toDouble())
              .reduce((a, b) => a + b) /
          recentHalf.length;

      final olderAvg =
          olderHalf
              .map((doc) => (doc.data['percentage'] ?? 0.0).toDouble())
              .reduce((a, b) => a + b) /
          olderHalf.length;

      final growthPercentage =
          olderAvg > 0 ? ((recentAvg - olderAvg) / olderAvg) * 100 : 0.0;

      dev.log(
        'calculateGrowthPercentage - success: ${growthPercentage.toStringAsFixed(1)}%',
        name: _loggerName,
      );

      return growthPercentage;
    } catch (e, st) {
      dev.log(
        'calculateGrowthPercentage - error: $e',
        name: _loggerName,
        error: e,
        stackTrace: st,
      );
      return 0.0; // Return 0 on error
    }
  }

  /// Store complete user data in local storage (public method)
  Future<void> storeUserData(UserEntity user) async {
    await _storeCompleteUserData(user);
  }

  /// Store complete user data in local storage
  Future<void> _storeCompleteUserData(UserEntity user) async {
    try {
      final userDataMap = {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'photoUrl': user.photoUrl,
        'provider': user.provider.name,
        'totalInterviews': user.totalInterviews,
        'voiceInterviews': user.voiceInterviews,
        'mcqInterviews': user.mcqInterviews,
        'averageScore': user.averageScore,
        'createdAt': user.createdAt.toIso8601String(),
        'updatedAt': user.updatedAt.toIso8601String(),
        'lastStatsUpdate': DateTime.now().toIso8601String(),
      };

      await _storage.write('complete_user_data', userDataMap);

      dev.log('_storeCompleteUserData - success', name: _loggerName);
    } catch (storageError) {
      dev.log(
        '_storeCompleteUserData - failed: $storageError',
        name: _loggerName,
        error: storageError,
      );
    }
  }

  /// Load complete user data from local storage
  Future<Map<String, dynamic>?> getStoredUserData() async {
    try {
      final userData = _storage.read('complete_user_data');
      if (userData != null) {
        dev.log('getStoredUserData - found cached data', name: _loggerName);
        return Map<String, dynamic>.from(userData);
      }

      dev.log('getStoredUserData - no cached data found', name: _loggerName);
      return null;
    } catch (e) {
      dev.log('getStoredUserData - error: $e', name: _loggerName, error: e);
      return null;
    }
  }

  /// Sync user data from Appwrite and update local storage
  Future<UserEntity?> syncUserDataFromServer(String userId) async {
    try {
      dev.log(
        'syncUserDataFromServer - fetching for user: $userId',
        name: _loggerName,
      );

      final document = await _databases.getDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.usersCollection,
        documentId: userId,
      );

      final userData = document.data;
      final syncedUser = UserEntity(
        id: userId,
        name: userData['name'] ?? '',
        email: userData['email'] ?? '',
        photoUrl: userData['photoUrl'],
        provider: AuthType.email, // Default, can be enhanced
        totalInterviews: userData['totalInterviews'] ?? 0,
        voiceInterviews: userData['voiceInterviews'] ?? 0,
        mcqInterviews: userData['mcqInterviews'] ?? 0,
        averageScore: (userData['averageScore'] ?? 0.0).toDouble(),
        createdAt: DateTime.parse(
          userData['createdAt'] ?? DateTime.now().toIso8601String(),
        ),
        updatedAt: DateTime.parse(
          userData['updatedAt'] ?? DateTime.now().toIso8601String(),
        ),
      );

      // Store in local storage
      await _storeCompleteUserData(syncedUser);

      dev.log('syncUserDataFromServer - success', name: _loggerName);

      return syncedUser;
    } catch (e) {
      dev.log(
        'syncUserDataFromServer - error: $e',
        name: _loggerName,
        error: e,
      );
      return null;
    }
  }
}
