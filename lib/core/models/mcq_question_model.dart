import 'package:equatable/equatable.dart';
import 'dart:convert';

class McqQuestionModel extends Equatable {
  final String questionId;
  final String sessionId;
  final int questionNo;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? userAnswer;
  final bool? isCorrect;
  final double? score;
  final String explanation;
  final String difficulty;
  final String category;
  final String topic;
  final String jobRole;

  const McqQuestionModel({
    required this.questionId,
    required this.sessionId,
    required this.questionNo,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.userAnswer,
    this.isCorrect,
    this.score,
    required this.explanation,
    required this.difficulty,
    required this.category,
    required this.topic,
    required this.jobRole,
  });

  factory McqQuestionModel.fromAppwrite(Map<String, dynamic> document) {
    return McqQuestionModel(
      questionId: document['\$id'] ?? '',
      sessionId: document['sessionId'] ?? '',
      questionNo: document['questionNo'] ?? 0,
      question: document['question'] ?? '',
      options: _parseOptions(document['options']),
      correctAnswer: document['correctAnswer'] ?? '',
      userAnswer: document['userAnswer'],
      isCorrect: document['isCorrect'],
      score: document['score']?.toDouble(),
      explanation: document['explanation'] ?? '',
      difficulty: document['difficulty'] ?? '',
      category: document['category'] ?? '',
      topic: document['topic'] ?? '',
      jobRole: document['jobRole'] ?? '',
    );
  }

  Map<String, dynamic> toAppwrite() {
    return {
      'sessionId': sessionId,
      'questionNo': questionNo,
      'question': question,
      'options': jsonEncode(options),
      'correctAnswer': correctAnswer,
      'userAnswer': userAnswer,
      'isCorrect': isCorrect,
      'score': score,
      'explanation': explanation,
      'difficulty': difficulty,
      'category': category,
      'topic': topic,
      'jobRole': jobRole,
    };
  }

  static List<String> _parseOptions(dynamic optionsData) {
    if (optionsData == null) return [];

    if (optionsData is String) {
      try {
        final List<dynamic> decoded = jsonDecode(optionsData);
        return decoded.cast<String>();
      } catch (e) {
        return [];
      }
    }

    if (optionsData is List) {
      return optionsData.cast<String>();
    }

    return [];
  }

  McqQuestionModel copyWith({
    String? questionId,
    String? sessionId,
    int? questionNo,
    String? question,
    List<String>? options,
    String? correctAnswer,
    String? userAnswer,
    bool? isCorrect,
    double? score,
    String? explanation,
    String? difficulty,
    String? category,
    String? topic,
    String? jobRole,
  }) {
    return McqQuestionModel(
      questionId: questionId ?? this.questionId,
      sessionId: sessionId ?? this.sessionId,
      questionNo: questionNo ?? this.questionNo,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      score: score ?? this.score,
      explanation: explanation ?? this.explanation,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      topic: topic ?? this.topic,
      jobRole: jobRole ?? this.jobRole,
    );
  }

  @override
  List<Object?> get props => [
    questionId,
    sessionId,
    questionNo,
    question,
    options,
    correctAnswer,
    userAnswer,
    isCorrect,
    score,
    explanation,
    difficulty,
    category,
    topic,
    jobRole,
  ];
}
