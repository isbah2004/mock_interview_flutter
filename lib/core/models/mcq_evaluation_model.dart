import 'package:equatable/equatable.dart';

class McqEvaluationModel extends Equatable {
  final String evaluationId;
  final String sessionId;
  final int totalQuestions;
  final int correctAnswers;
  final double finalScore;
  final int? timeTaken; // in seconds
  final DateTime createdAt;

  const McqEvaluationModel({
    required this.evaluationId,
    required this.sessionId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.finalScore,
    this.timeTaken,
    required this.createdAt,
  });

  factory McqEvaluationModel.fromAppwrite(Map<String, dynamic> document) {
    return McqEvaluationModel(
      evaluationId: document['\$id'] ?? '',
      sessionId: document['sessionId'] ?? '',
      totalQuestions: document['totalQuestions'] ?? 0,
      correctAnswers: document['correctAnswers'] ?? 0,
      finalScore: document['finalScore']?.toDouble() ?? 0.0,
      timeTaken: document['timeTaken'],
      createdAt: DateTime.parse(document['createdAt']),
    );
  }

  Map<String, dynamic> toAppwrite() {
    return {
      'sessionId': sessionId,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'finalScore': finalScore,
      'timeTaken': timeTaken,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory McqEvaluationModel.create({
    required String sessionId,
    required int totalQuestions,
    required int correctAnswers,
    required double finalScore,
    int? timeTaken,
  }) {
    return McqEvaluationModel(
      evaluationId: '', // Will be set by Appwrite
      sessionId: sessionId,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      finalScore: finalScore,
      timeTaken: timeTaken,
      createdAt: DateTime.now(),
    );
  }

  double get percentage =>
      totalQuestions > 0 ? (finalScore / totalQuestions) * 100 : 0.0;
  bool get passed => percentage >= 60.0;

  McqEvaluationModel copyWith({
    String? evaluationId,
    String? sessionId,
    int? totalQuestions,
    int? correctAnswers,
    double? finalScore,
    int? timeTaken,
    DateTime? createdAt,
  }) {
    return McqEvaluationModel(
      evaluationId: evaluationId ?? this.evaluationId,
      sessionId: sessionId ?? this.sessionId,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      finalScore: finalScore ?? this.finalScore,
      timeTaken: timeTaken ?? this.timeTaken,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    evaluationId,
    sessionId,
    totalQuestions,
    correctAnswers,
    finalScore,
    timeTaken,
    createdAt,
  ];
}
