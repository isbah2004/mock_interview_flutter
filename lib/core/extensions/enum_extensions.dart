import 'package:mock_interview/core/enums/difficulty_level.dart';
import 'package:mock_interview/core/enums/question_category.dart';

/// Extension methods for DifficultyLevel enum
extension DifficultyLevelExtension on DifficultyLevel {
  /// Get the display name of the difficulty level
  String get displayName {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
    }
  }

  /// Get the difficulty level from a string
  static DifficultyLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'easy':
        return DifficultyLevel.easy;
      case 'medium':
        return DifficultyLevel.medium;
      case 'hard':
        return DifficultyLevel.hard;
      default:
        return DifficultyLevel.medium; // Default fallback
    }
  }
}

/// Extension methods for QuestionCategory enum
extension QuestionCategoryExtension on QuestionCategory {
  /// Get the display name of the question category
  String get displayName {
    switch (this) {
      case QuestionCategory.general:
        return 'General';
      case QuestionCategory.technical:
        return 'Technical';
      case QuestionCategory.behavioral:
        return 'Behavioral';
      case QuestionCategory.industrySpecific:
        return 'Industry Specific';
    }
  }

  /// Get the API value for the category
  String get apiValue {
    switch (this) {
      case QuestionCategory.general:
        return 'general';
      case QuestionCategory.technical:
        return 'technical';
      case QuestionCategory.behavioral:
        return 'behavioral';
      case QuestionCategory.industrySpecific:
        return 'industry_specific';
    }
  }

  /// Get the question category from a string
  static QuestionCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'general':
        return QuestionCategory.general;
      case 'technical':
        return QuestionCategory.technical;
      case 'behavioral':
        return QuestionCategory.behavioral;
      case 'industry_specific':
      case 'industryspecific':
        return QuestionCategory.industrySpecific;
      default:
        return QuestionCategory.general; // Default fallback
    }
  }
}
