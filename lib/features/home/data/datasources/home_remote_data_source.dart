import 'package:appwrite/appwrite.dart';
import 'package:mock_interview/core/constants/appwrite_constants.dart';
import 'package:mock_interview/core/errors/failures.dart';
import '../models/user_stats_model.dart';

abstract class HomeRemoteDataSource {
  Future<UserStatsModel> getUserStats(String userId);
  Future<void> updateUserStats(String userId, UserStatsModel stats);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Databases _databases;

  HomeRemoteDataSourceImpl({required Databases databases})
    : _databases = databases;

  @override
  Future<UserStatsModel> getUserStats(String userId) async {
    try {
      // Get interview sessions for this user to calculate stats
      final sessions = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.sessionsCollection,
        queries: [Query.equal('userId', userId)],
      );

      // Calculate stats from sessions
      int totalInterviews = sessions.documents.length;
      int voiceInterviews = 0;
      int mcqInterviews = 0;
      double totalScore = 0.0;

      for (var session in sessions.documents) {
        final sessionData = session.data;
        if (sessionData['type'] == 'voice') {
          voiceInterviews++;
        } else if (sessionData['type'] == 'mcq') {
          mcqInterviews++;
        }

        if (sessionData['score'] != null) {
          totalScore += (sessionData['score'] as num).toDouble();
        }
      }

      double averageScore =
          totalInterviews > 0 ? totalScore / totalInterviews : 0.0;

      // Create UserStatsModel from data
      return UserStatsModel(
        totalInterviews: totalInterviews,
        averageScore: averageScore,
        voiceInterviews: voiceInterviews,
        mcqInterviews: mcqInterviews,
        improvementPercentage: _calculateImprovement(sessions.documents),
        userId: userId,
      );
    } on AppwriteException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to get user stats');
    } catch (e) {
      throw ServerFailure('Unknown error occurred while getting user stats');
    }
  }

  @override
  Future<void> updateUserStats(String userId, UserStatsModel stats) async {
    try {
      await _databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: userId,
        data: {
          'totalInterviews': stats.totalInterviews,
          'averageScore': stats.averageScore,
          'voiceInterviews': stats.voiceInterviews,
          'mcqInterviews': stats.mcqInterviews,
        },
      );
    } on AppwriteException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to update user stats');
    } catch (e) {
      throw ServerFailure('Unknown error occurred while updating user stats');
    }
  }

  double _calculateImprovement(List sessions) {
    if (sessions.length < 2) return 0.0;

    // Sort sessions by date
    sessions.sort((a, b) {
      final dateA = DateTime.parse(a.data['\$createdAt']);
      final dateB = DateTime.parse(b.data['\$createdAt']);
      return dateA.compareTo(dateB);
    });

    // Get last month's sessions
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, now.day);

    final recentSessions =
        sessions.where((session) {
          final sessionDate = DateTime.parse(session.data['\$createdAt']);
          return sessionDate.isAfter(lastMonth);
        }).toList();

    final olderSessions =
        sessions.where((session) {
          final sessionDate = DateTime.parse(session.data['\$createdAt']);
          return sessionDate.isBefore(lastMonth);
        }).toList();

    if (recentSessions.isEmpty || olderSessions.isEmpty) return 0.0;

    // Calculate average scores
    double recentAverage =
        recentSessions.fold(0.0, (sum, session) {
          return sum + (session.data['score'] ?? 0.0);
        }) /
        recentSessions.length;

    double olderAverage =
        olderSessions.fold(0.0, (sum, session) {
          return sum + (session.data['score'] ?? 0.0);
        }) /
        olderSessions.length;

    if (olderAverage == 0) return 0.0;

    return ((recentAverage - olderAverage) / olderAverage) * 100;
  }
}
