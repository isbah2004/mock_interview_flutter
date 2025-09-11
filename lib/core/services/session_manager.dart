

import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'appwrite_service.dart';
import '../constants/app_secrets.dart';

class SessionManager {
  static Databases get _databases => AppwriteService.databases;

  /// Create a new interview session
  static Future<Map<String, dynamic>> createSession({
    required String userId,
    required String jobRole,
    required String type, // 'mcq' or 'voice'
    required String difficulty,
    required String category,
  }) async {
    try {
      final response = await _databases.createDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.interviewSessionsCollection,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'jobRole': jobRole,
          'type': type,
          'difficulty': difficulty,
          'category': category,
          'status': 'started',
          'score': null,
          'isComplete': false,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to create session: $e');
    }
  }

  /// Complete a session with score and duration
  static Future<Map<String, dynamic>> completeSession({
    required String sessionId,
    required double score,
    required Duration duration,
    int? questionsAnswered,
  }) async {
    try {
      final response = await _databases.updateDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.interviewSessionsCollection,
        documentId: sessionId,
        data: {
          'score': score,
          'isComplete': true,
          'status': 'completed',
          'sessionDuration': duration.inSeconds,
          'questionsAnswered': questionsAnswered,
          'completedAt': DateTime.now().toIso8601String(),
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to complete session: $e');
    }
  }

  /// Get all sessions for a user
  static Future<List<Map<String, dynamic>>> getUserSessions(
    String userId,
  ) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.interviewSessionsCollection,
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('\$createdAt'),
        ],
      );

      return response.documents
          .map((doc) => {...doc.data, 'id': doc.$id})
          .toList();
    } catch (e) {
      throw Exception('Failed to get user sessions: $e');
    }
  }

  /// Get sessions by type (voice or mcq)
  static Future<List<Map<String, dynamic>>> getSessionsByType({
    required String userId,
    required String type,
  }) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.interviewSessionsCollection,
        queries: [
          Query.equal('userId', userId),
          Query.equal('type', type),
          Query.orderDesc('\$createdAt'),
        ],
      );

      return response.documents
          .map((doc) => {...doc.data, 'id': doc.$id})
          .toList();
    } catch (e) {
      throw Exception('Failed to get sessions by type: $e');
    }
  }

  /// Get recent sessions (last 30 days)
  static Future<List<Map<String, dynamic>>> getRecentSessions({
    required String userId,
    int days = 30,
  }) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final response = await _databases.listDocuments(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.interviewSessionsCollection,
        queries: [
          Query.equal('userId', userId),
          Query.greaterThanEqual('\$createdAt', startDate.toIso8601String()),
          Query.orderDesc('\$createdAt'),
        ],
      );

      return response.documents
          .map((doc) => {...doc.data, 'id': doc.$id})
          .toList();
    } catch (e) {
      throw Exception('Failed to get recent sessions: $e');
    }
  }

  /// Get session statistics for a user
  static Future<Map<String, dynamic>> getSessionStats(String userId) async {
    try {
      final sessions = await getUserSessions(userId);

      int totalSessions = sessions.length;
      int voiceSessions = 0;
      int mcqSessions = 0;
      double totalScore = 0.0;
      int completedSessions = 0;

      for (var session in sessions) {
        if (session['type'] == 'voice') {
          voiceSessions++;
        } else if (session['type'] == 'mcq') {
          mcqSessions++;
        }

        if (session['isComplete'] == true && session['score'] != null) {
          totalScore += (session['score'] as num).toDouble();
          completedSessions++;
        }
      }

      double averageScore =
          completedSessions > 0 ? totalScore / completedSessions : 0.0;

      return {
        'totalSessions': totalSessions,
        'voiceSessions': voiceSessions,
        'mcqSessions': mcqSessions,
        'completedSessions': completedSessions,
        'averageScore': averageScore,
        'totalScore': totalScore,
      };
    } catch (e) {
      throw Exception('Failed to get session stats: $e');
    }
  }

  /// Delete a session
  static Future<void> deleteSession(String sessionId) async {
    try {
      await _databases.deleteDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.interviewSessionsCollection,
        documentId: sessionId,
      );
    } catch (e) {
      throw Exception('Failed to delete session: $e');
    }
  }

  /// Convert session data to display format
  static Map<String, dynamic> sessionToDisplayFormat(
    Map<String, dynamic> session,
  ) {
    return {
      'id': session['id'],
      'type': session['type'] == 'voice' ? 'Voice Interview' : 'MCQ Interview',
      'jobRole': session['jobRole'] ?? 'General',
      'category': session['category'] ?? 'Technical',
      'difficulty': session['difficulty'] ?? 'Medium',
      'date': _formatDate(
        DateTime.parse(
          session['\$createdAt'] ?? DateTime.now().toIso8601String(),
        ),
      ),
      'duration': _formatDuration(session['sessionDuration']),
      'score': session['score']?.round() ?? 0,
      'status': session['status'] ?? 'unknown',
      'isComplete': session['isComplete'] ?? false,
      'icon': session['type'] == 'voice' ? Icons.mic : Icons.book,
    };
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String _formatDuration(int? durationInSeconds) {
    if (durationInSeconds == null) return '-- min';
    final minutes = (durationInSeconds / 60).round();
    return '$minutes min';
  }
}
