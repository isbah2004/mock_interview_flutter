import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'appwrite_service.dart';
import '../constants/appwrite_constants.dart';
import 'session_manager.dart';

class ProfileManager {
  static Databases get _databases => AppwriteService.databases;
  static Storage get _storage => AppwriteService.storage;

  /// Get user profile data
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final userDoc = await _databases.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: userId,
      );

      // Get session statistics
      final sessionStats = await SessionManager.getSessionStats(userId);

      return {...userDoc.data, 'id': userDoc.$id, 'stats': sessionStats};
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Update user profile information
  static Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;

      updateData['updatedAt'] = DateTime.now().toIso8601String();

      final response = await _databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: userId,
        data: updateData,
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Upload profile image
  static Future<String> uploadProfileImage({
    required String userId,
    required String filePath,
  }) async {
    try {
      // Upload file to storage
      final file = await _storage.createFile(
        bucketId: AppwriteConstants.profileImagesBucket,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: filePath),
      );

      // Get file URL
      final fileUrl = _storage.getFileView(
        bucketId: AppwriteConstants.profileImagesBucket,
        fileId: file.$id,
      );

      // Update user profile with new photo URL
      await updateProfile(userId: userId, photoUrl: fileUrl.toString());

      return fileUrl.toString();
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Get user achievements based on session data
  static Future<List<Map<String, dynamic>>> getUserAchievements(
    String userId,
  ) async {
    try {
      final sessionStats = await SessionManager.getSessionStats(userId);
      final sessions = await SessionManager.getUserSessions(userId);

      List<Map<String, dynamic>> achievements = [];

      // First Interview Achievement
      if (sessionStats['totalSessions'] >= 1) {
        achievements.add({
          'title': 'First Steps',
          'description': 'Completed your first interview',
          'icon': Icons.star,
          'earned': true,
          'date': sessions.isNotEmpty ? sessions.last['\$createdAt'] : null,
        });
      }

      // Score Achievements
      if (sessionStats['averageScore'] >= 90) {
        achievements.add({
          'title': 'Excellence',
          'description': 'Achieved 90%+ average score',
          'icon': Icons.emoji_events,
          'earned': true,
          'date': DateTime.now().toIso8601String(),
        });
      } else if (sessionStats['averageScore'] >= 80) {
        achievements.add({
          'title': 'High Performer',
          'description': 'Achieved 80%+ average score',
          'icon': Icons.trending_up,
          'earned': true,
          'date': DateTime.now().toIso8601String(),
        });
      }

      // Volume Achievements
      if (sessionStats['totalSessions'] >= 10) {
        achievements.add({
          'title': 'Dedicated Learner',
          'description': 'Completed 10+ interviews',
          'icon': Icons.school,
          'earned': true,
          'date': DateTime.now().toIso8601String(),
        });
      } else if (sessionStats['totalSessions'] >= 5) {
        achievements.add({
          'title': 'Getting Started',
          'description': 'Completed 5+ interviews',
          'icon': Icons.timeline,
          'earned': true,
          'date': DateTime.now().toIso8601String(),
        });
      }

      // Consistency Achievement
      final recentSessions = await SessionManager.getRecentSessions(
        userId: userId,
        days: 7,
      );
      if (recentSessions.length >= 3) {
        achievements.add({
          'title': 'Consistent Performer',
          'description': 'Completed 3+ interviews this week',
          'icon': Icons.calendar_today,
          'earned': true,
          'date': DateTime.now().toIso8601String(),
        });
      }

      return achievements;
    } catch (e) {
      throw Exception('Failed to get user achievements: $e');
    }
  }

  /// Get user performance insights
  static Future<Map<String, dynamic>> getPerformanceInsights(
    String userId,
  ) async {
    try {
      final sessions = await SessionManager.getUserSessions(userId);
      final recentSessions = await SessionManager.getRecentSessions(
        userId: userId,
        days: 30,
      );

      // Calculate improvement rate
      double improvementRate = 0.0;
      if (sessions.length >= 2) {
        final firstHalf = sessions.skip(sessions.length ~/ 2).toList();
        final secondHalf = sessions.take(sessions.length ~/ 2).toList();

        double firstAvg =
            firstHalf
                .where((s) => s['score'] != null)
                .map((s) => s['score'] as double)
                .fold(0.0, (a, b) => a + b) /
            firstHalf.length;

        double secondAvg =
            secondHalf
                .where((s) => s['score'] != null)
                .map((s) => s['score'] as double)
                .fold(0.0, (a, b) => a + b) /
            secondHalf.length;

        if (firstAvg > 0) {
          improvementRate = ((secondAvg - firstAvg) / firstAvg) * 100;
        }
      }

      // Calculate current streak
      int currentStreak = 0;
      DateTime? lastSessionDate;

      for (var session in sessions) {
        DateTime sessionDate = DateTime.parse(session['\$createdAt']);
        if (lastSessionDate == null) {
          lastSessionDate = sessionDate;
          currentStreak = 1;
        } else {
          Duration diff = lastSessionDate.difference(sessionDate);
          if (diff.inDays <= 1) {
            currentStreak++;
            lastSessionDate = sessionDate;
          } else {
            break;
          }
        }
      }

      // Get strongest and weakest areas
      Map<String, List<double>> categoryScores = {};
      for (var session in sessions) {
        if (session['score'] != null && session['category'] != null) {
          String category = session['category'];
          if (!categoryScores.containsKey(category)) {
            categoryScores[category] = [];
          }
          categoryScores[category]!.add(session['score'].toDouble());
        }
      }

      String? strongestArea;
      String? weakestArea;
      double highestAvg = 0;
      double lowestAvg = 100;

      categoryScores.forEach((category, scores) {
        double avg = scores.fold(0.0, (a, b) => a + b) / scores.length;
        if (avg > highestAvg) {
          highestAvg = avg;
          strongestArea = category;
        }
        if (avg < lowestAvg) {
          lowestAvg = avg;
          weakestArea = category;
        }
      });

      return {
        'improvementRate': improvementRate.toStringAsFixed(1),
        'currentStreak': currentStreak,
        'recentSessionsCount': recentSessions.length,
        'strongestArea': strongestArea ?? 'N/A',
        'weakestArea': weakestArea ?? 'N/A',
        'averageSessionDuration': _calculateAverageSessionDuration(sessions),
        'nextMilestone': _getNextMilestone(sessions.length),
        'progressToMilestone': _getProgressToMilestone(sessions.length),
      };
    } catch (e) {
      throw Exception('Failed to get performance insights: $e');
    }
  }

  static String _calculateAverageSessionDuration(
    List<Map<String, dynamic>> sessions,
  ) {
    if (sessions.isEmpty) return '0 min';

    double totalDuration = 0;
    int validSessions = 0;

    for (var session in sessions) {
      if (session['sessionDuration'] != null) {
        totalDuration += session['sessionDuration'];
        validSessions++;
      }
    }

    if (validSessions == 0) return '0 min';

    double avgMinutes = (totalDuration / validSessions) / 60;
    return '${avgMinutes.round()} min';
  }

  static String _getNextMilestone(int sessionCount) {
    if (sessionCount < 5) return '5 interviews';
    if (sessionCount < 10) return '10 interviews';
    if (sessionCount < 25) return '25 interviews';
    if (sessionCount < 50) return '50 interviews';
    if (sessionCount < 100) return '100 interviews';
    return '${((sessionCount ~/ 100) + 1) * 100} interviews';
  }

  static double _getProgressToMilestone(int sessionCount) {
    if (sessionCount < 5) return sessionCount / 5;
    if (sessionCount < 10) return (sessionCount - 5) / 5;
    if (sessionCount < 25) return (sessionCount - 10) / 15;
    if (sessionCount < 50) return (sessionCount - 25) / 25;
    if (sessionCount < 100) return (sessionCount - 50) / 50;

    int nextHundred = ((sessionCount ~/ 100) + 1) * 100;
    int currentHundred = (sessionCount ~/ 100) * 100;
    return (sessionCount - currentHundred) / (nextHundred - currentHundred);
  }

  /// Update user preferences
  static Future<void> updatePreferences({
    required String userId,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      await _databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: userId,
        data: {
          'preferences': preferences,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to update preferences: $e');
    }
  }
}
