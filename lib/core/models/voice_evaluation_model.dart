import 'package:equatable/equatable.dart';
import 'dart:convert';

class VoiceEvaluationModel extends Equatable {
  final String evaluationId;
  final String sessionId;
  final String feedback;
  final double communicationScore;
  final double contentScore;
  final double overallScore;
  final List<String> aiCorrectAnswers;
  final int totalQuestions;
  final double finalScore;
  final double percentage;
  final bool passed;
  final bool sessionComplete;
  final DateTime completedAt;
  final DateTime createdAt;

  const VoiceEvaluationModel({
    required this.evaluationId,
    required this.sessionId,
    required this.feedback,
    required this.communicationScore,
    required this.contentScore,
    required this.overallScore,
    required this.aiCorrectAnswers,
    required this.totalQuestions,
    required this.finalScore,
    required this.percentage,
    required this.passed,
    required this.sessionComplete,
    required this.completedAt,
    required this.createdAt,
  });

  factory VoiceEvaluationModel.fromAppwrite(Map<String, dynamic> document) {
    return VoiceEvaluationModel(
      evaluationId: document['\$id'] ?? '',
      sessionId: document['sessionId'] ?? '',
      feedback: document['feedback'] ?? '',
      communicationScore: document['communicationScore']?.toDouble() ?? 0.0,
      contentScore: document['contentScore']?.toDouble() ?? 0.0,
      overallScore: document['overallScore']?.toDouble() ?? 0.0,
      aiCorrectAnswers: _parseStringList(document['aiCorrectAnswers']),
      totalQuestions: document['totalQuestions'] ?? 0,
      finalScore: document['finalScore']?.toDouble() ?? 0.0,
      percentage: document['percentage']?.toDouble() ?? 0.0,
      passed: document['passed'] ?? false,
      sessionComplete: document['sessionComplete'] ?? false,
      completedAt: DateTime.parse(document['completedAt']),
      createdAt: DateTime.parse(document['createdAt']),
    );
  }

  Map<String, dynamic> toAppwrite() {
    return {
      'sessionId': sessionId,
      'feedback': feedback,
      'communicationScore': communicationScore,
      'contentScore': contentScore,
      'overallScore': overallScore,
      'aiCorrectAnswers': jsonEncode(aiCorrectAnswers),
      'totalQuestions': totalQuestions,
      'finalScore': finalScore,
      'percentage': percentage,
      'passed': passed,
      'sessionComplete': sessionComplete,
      'completedAt': completedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static List<String> _parseStringList(dynamic data) {
    if (data == null) return [];

    if (data is String) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        return decoded.cast<String>();
      } catch (e) {
        return [];
      }
    }

    if (data is List) {
      return data.cast<String>();
    }

    return [];
  }

  factory VoiceEvaluationModel.fromVoiceInterviewEvaluationResult({
    required String sessionId,
    required String feedback,
    required double communicationScore,
    required double contentScore,
    required double overallScore,
    required List<String> aiCorrectAnswers,
    required int totalQuestions,
    required double finalScore,
    required double percentage,
    required bool passed,
    required bool sessionComplete,
    required DateTime completedAt,
  }) {
    return VoiceEvaluationModel(
      evaluationId: '', // Will be set by Appwrite
      sessionId: sessionId,
      feedback: feedback,
      communicationScore: communicationScore,
      contentScore: contentScore,
      overallScore: overallScore,
      aiCorrectAnswers: aiCorrectAnswers,
      totalQuestions: totalQuestions,
      finalScore: finalScore,
      percentage: percentage,
      passed: passed,
      sessionComplete: sessionComplete,
      completedAt: completedAt,
      createdAt: DateTime.now(),
    );
  }

  VoiceEvaluationModel copyWith({
    String? evaluationId,
    String? sessionId,
    String? feedback,
    double? communicationScore,
    double? contentScore,
    double? overallScore,
    List<String>? aiCorrectAnswers,
    int? totalQuestions,
    double? finalScore,
    double? percentage,
    bool? passed,
    bool? sessionComplete,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return VoiceEvaluationModel(
      evaluationId: evaluationId ?? this.evaluationId,
      sessionId: sessionId ?? this.sessionId,
      feedback: feedback ?? this.feedback,
      communicationScore: communicationScore ?? this.communicationScore,
      contentScore: contentScore ?? this.contentScore,
      overallScore: overallScore ?? this.overallScore,
      aiCorrectAnswers: aiCorrectAnswers ?? this.aiCorrectAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      finalScore: finalScore ?? this.finalScore,
      percentage: percentage ?? this.percentage,
      passed: passed ?? this.passed,
      sessionComplete: sessionComplete ?? this.sessionComplete,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    evaluationId,
    sessionId,
    feedback,
    communicationScore,
    contentScore,
    overallScore,
    aiCorrectAnswers,
    totalQuestions,
    finalScore,
    percentage,
    passed,
    sessionComplete,
    completedAt,
    createdAt,
  ];
}
