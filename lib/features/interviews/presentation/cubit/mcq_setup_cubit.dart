import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/enums/difficulty_level.dart';
import 'package:mock_interview/core/enums/question_category.dart';
import 'mcq_setup_state.dart';

class MCQSetupCubit extends Cubit<MCQSetupState> {
  MCQSetupCubit() : super(const MCQSetupInitial());

  void updateDifficulty(String difficulty) {
    if (state is MCQSetupInitial) {
      final currentState = state as MCQSetupInitial;
      emit(
        MCQSetupUpdated(
          difficulty: difficulty,
          questions: currentState.questions,
          category: currentState.category,
          timeLimit: currentState.timeLimit,
          jobRole: currentState.jobRole,
        ),
      );
    } else if (state is MCQSetupUpdated) {
      final currentState = state as MCQSetupUpdated;
      emit(currentState.copyWith(difficulty: difficulty));
    }
  }

  void updateQuestions(String questions) {
    if (state is MCQSetupInitial) {
      final currentState = state as MCQSetupInitial;
      emit(
        MCQSetupUpdated(
          difficulty: currentState.difficulty,
          questions: questions,
          category: currentState.category,
          timeLimit: currentState.timeLimit,
          jobRole: currentState.jobRole,
        ),
      );
    } else if (state is MCQSetupUpdated) {
      final currentState = state as MCQSetupUpdated;
      emit(currentState.copyWith(questions: questions));
    }
  }

  void updateCategory(String category) {
    if (state is MCQSetupInitial) {
      final currentState = state as MCQSetupInitial;
      emit(
        MCQSetupUpdated(
          difficulty: currentState.difficulty,
          questions: currentState.questions,
          category: category,
          timeLimit: currentState.timeLimit,
          jobRole: currentState.jobRole,
        ),
      );
    } else if (state is MCQSetupUpdated) {
      final currentState = state as MCQSetupUpdated;
      emit(currentState.copyWith(category: category));
    }
  }

  void updateTimeLimit(String timeLimit) {
    if (state is MCQSetupInitial) {
      final currentState = state as MCQSetupInitial;
      emit(
        MCQSetupUpdated(
          difficulty: currentState.difficulty,
          questions: currentState.questions,
          category: currentState.category,
          timeLimit: timeLimit,
          jobRole: currentState.jobRole,
        ),
      );
    } else if (state is MCQSetupUpdated) {
      final currentState = state as MCQSetupUpdated;
      emit(currentState.copyWith(timeLimit: timeLimit));
    }
  }

  void updateJobRole(String jobRole) {
    if (state is MCQSetupInitial) {
      final currentState = state as MCQSetupInitial;
      emit(
        MCQSetupUpdated(
          difficulty: currentState.difficulty,
          questions: currentState.questions,
          category: currentState.category,
          timeLimit: currentState.timeLimit,
          jobRole: jobRole,
        ),
      );
    } else if (state is MCQSetupUpdated) {
      final currentState = state as MCQSetupUpdated;
      emit(currentState.copyWith(jobRole: jobRole));
    }
  }

  String calculateDuration(String questions, String timeLimit) {
    int questionCount = int.parse(questions.split(' ')[0]);
    int timePerQuestion = int.parse(timeLimit.split(' ')[0]);
    int totalMinutes = (questionCount * timePerQuestion / 60).ceil();
    return '$totalMinutes-${totalMinutes + 2} minutes';
  }

  // Get current values
  String get currentDifficulty {
    if (state is MCQSetupInitial) {
      return (state as MCQSetupInitial).difficulty;
    } else if (state is MCQSetupUpdated) {
      return (state as MCQSetupUpdated).difficulty;
    }
    return 'Medium';
  }

  String get currentQuestions {
    if (state is MCQSetupInitial) {
      return (state as MCQSetupInitial).questions;
    } else if (state is MCQSetupUpdated) {
      return (state as MCQSetupUpdated).questions;
    }
    return '10 Questions';
  }

  String get currentCategory {
    if (state is MCQSetupInitial) {
      return (state as MCQSetupInitial).category;
    } else if (state is MCQSetupUpdated) {
      return (state as MCQSetupUpdated).category;
    }
    return 'General';
  }

  String get currentTimeLimit {
    if (state is MCQSetupInitial) {
      return (state as MCQSetupInitial).timeLimit;
    } else if (state is MCQSetupUpdated) {
      return (state as MCQSetupUpdated).timeLimit;
    }
    return '30 seconds';
  }

  String get currentJobRole {
    if (state is MCQSetupInitial) {
      return (state as MCQSetupInitial).jobRole;
    } else if (state is MCQSetupUpdated) {
      return (state as MCQSetupUpdated).jobRole;
    }
    return '';
  }

  // Helper methods for enum conversion
  DifficultyLevel getDifficultyEnum() {
    switch (currentDifficulty.toLowerCase()) {
      case 'easy':
        return DifficultyLevel.easy;
      case 'hard':
        return DifficultyLevel.hard;
      default:
        return DifficultyLevel.medium;
    }
  }

  QuestionCategory getCategoryEnum() {
    switch (currentCategory.toLowerCase()) {
      case 'technical':
        return QuestionCategory.technical;
      case 'behavioral':
        return QuestionCategory.behavioral;
      case 'industry specific':
        return QuestionCategory.industrySpecific;
      default:
        return QuestionCategory.general;
    }
  }

  int getNumberOfQuestions() {
    return int.parse(currentQuestions.split(' ')[0]);
  }

  int getTimePerQuestion() {
    return int.parse(currentTimeLimit.split(' ')[0]);
  }
}
