class InterviewConfig {
  final String jobRole;
  final InterviewCategory category;
  final InterviewDifficulty difficulty;
  final int numberOfQuestions;

  const InterviewConfig({
    required this.jobRole,
    required this.category,
    required this.difficulty,
    required this.numberOfQuestions,
  });

  InterviewConfig copyWith({
    String? jobRole,
    InterviewCategory? category,
    InterviewDifficulty? difficulty,
    int? numberOfQuestions,
  }) {
    return InterviewConfig(
      jobRole: jobRole ?? this.jobRole,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      numberOfQuestions: numberOfQuestions ?? this.numberOfQuestions,
    );
  }
}

enum InterviewCategory {
  general('General'),
  behavioral('Behavioral'),
  technical('Technical'),
  industrySpecific('Industry Specific');

  const InterviewCategory(this.displayName);
  final String displayName;

  String get description {
    switch (this) {
      case InterviewCategory.general:
        return 'Basic questions about your background, experience, and motivations.';
      case InterviewCategory.behavioral:
        return 'Situation-based questions using the STAR method to assess soft skills.';
      case InterviewCategory.technical:
        return 'Role-specific technical questions to evaluate your expertise.';
      case InterviewCategory.industrySpecific:
        return 'Questions focused on industry knowledge and domain expertise.';
    }
  }
}

enum InterviewDifficulty {
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced');

  const InterviewDifficulty(this.displayName);
  final String displayName;

  String get description {
    switch (this) {
      case InterviewDifficulty.beginner:
        return 'Entry-level questions suitable for new graduates or career changers.';
      case InterviewDifficulty.intermediate:
        return 'Mid-level questions for professionals with 2-5 years of experience.';
      case InterviewDifficulty.advanced:
        return 'Senior-level questions for experienced professionals and leaders.';
    }
  }
}
