// lib/data/models/question_model.dart
import 'dart:convert';

import 'package:mock_interview/core/entities/question.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
     super.sessionId,
    required super.questionNumber,
    required super.questionText,
    required super.options,
    required super.correctAnswer,
    super.userAnswer,
    super.isCorrect,
    super.score,
    required super.explanation,
    required super.difficulty,
    required super.category,
    required super.topic,
    required super.jobRole,
  });

  factory QuestionModel.fromEntity(Question entity) {
    return QuestionModel(
      id: entity.id,
      sessionId: entity.sessionId,
      questionNumber: entity.questionNumber,
      questionText: entity.questionText,
      options: entity.options,
      correctAnswer: entity.correctAnswer,
      userAnswer: entity.userAnswer,
      isCorrect: entity.isCorrect,
      score: entity.score,
      explanation: entity.explanation,
      difficulty: entity.difficulty,
      category: entity.category,
      topic: entity.topic,
      jobRole: entity.jobRole,
    );
  }

  Question toEntity() {
    return Question(
      id: id,
      sessionId: sessionId,
      questionNumber: questionNumber,
      questionText: questionText,
      options: options,
      correctAnswer: correctAnswer,
      userAnswer: userAnswer,
      isCorrect: isCorrect,
      score: score,
      explanation: explanation,
      difficulty: difficulty,
      category: category,
      topic: topic,
      jobRole: jobRole,
    );
  }

  factory QuestionModel.fromAIResponse(Map<String, dynamic> json) {
    return QuestionModel(
      id:  json['question_id'] ?? '',
      questionNumber: json['question_number'] ?? 0,
      questionText: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correct_answer'] ?? '',
      explanation: json['explanation'] ?? '',
      difficulty: json['difficulty'] ,
      category: json['category'],
      topic: json['topic'] ?? '',
      jobRole: json['job_role'] ?? '',
    );
  }

  Map<String, dynamic> toAIResponse() {
    return {
      'id': id,
      'question_number': questionNumber,
      'question': questionText,
      'options': options,
      'correct_answer': correctAnswer,
      'user_answer': userAnswer,
      'is_correct': isCorrect,
      'score': score,
      'explanation': explanation,
      'difficulty': difficulty,
      'category': category,
      'topic': topic,
      'job_role': jobRole,
    };
  }
  factory QuestionModel.fromAppwrite(Map<String, dynamic> document) {
    return QuestionModel(
      id: document['\$id'] ?? '',
      sessionId: document['sessionId'] ?? '',
      questionNumber: document['questionNo'] ?? 0,
      questionText: document['question'] ?? '',
      options: _parseOptions(document['options']),
      correctAnswer: document['correctAnswer'] ?? '',
      userAnswer: document['userAnswer'],
      isCorrect: document['isCorrect'],
      score: document['score']?.toDouble(),
      explanation: document['explanation'] ?? '',
      difficulty: document['difficulty'],
      category: document['category'],
      topic: document['topic'] ?? '',
      jobRole: document['jobRole'] ?? '',
    );
  }

  Map<String, dynamic> toAppwrite() {
    return {
      'sessionId': sessionId,
      'questionNo': questionNumber,
      'question': questionText,
      'options': jsonEncode(options),
      'correctAnswer': correctAnswer,
      'userAnswer': userAnswer,
      'score': score ?? 0.0,
      'isCorrect': isCorrect ?? false,
      'explanation': explanation,
      'difficulty': difficulty,
      'category': category,
      'topic': topic,
      'jobRole': jobRole,
    };
  }

  static List<String> _parseOptions(dynamic value) {
    if (value == null) return [];
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        return List<String>.from(decoded);
      } catch (e) {
        return [];
      }
    }
    if (value is List) {
      return List<String>.from(value);
    }
    return [];
  }

 
}