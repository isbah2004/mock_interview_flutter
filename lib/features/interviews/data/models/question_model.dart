import 'package:mock_interview/core/entities/question.dart';
import 'package:mock_interview/core/extensions/enum_extensions.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super.question,
    required super.options,
    required super.correctAnswer,
    required super.explanation,
    required super.difficulty,
    required super.category,
    required super.topic,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as int,
      question: json['question'] as String,
      options: List<String>.from(json['options']),
      correctAnswer: json['correct_answer'] as String,
      explanation: json['explanation'] as String,
      difficulty: DifficultyLevelExtension.fromString(
        json['difficulty'] as String,
      ),
      category: QuestionCategoryExtension.fromString(
        json['category'] as String,
      ),
      topic: json['topic'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'difficulty': difficulty.name,
      'category': category.name,
      'topic': topic,
    };
  }
}
