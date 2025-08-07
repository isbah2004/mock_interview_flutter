// lib/features/interview/domain/entities/question.dart
import 'package:equatable/equatable.dart';
import 'package:mock_interview/core/enums/difficulty_level.dart';
import 'package:mock_interview/core/enums/question_category.dart';

class Question extends Equatable {
  final int id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final DifficultyLevel difficulty;
  final QuestionCategory category;
  final String topic;

  const Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.difficulty,
    required this.category,
    required this.topic,
  });

  @override
  List<Object> get props => [
    id,
    question,
    options,
    correctAnswer,
    explanation,
    difficulty,
    category,
    topic,
  ];
}
