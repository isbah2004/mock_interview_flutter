import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/enums/difficulty_level.dart';
import 'package:mock_interview/core/enums/interview_type.dart';
import 'package:mock_interview/core/enums/question_category.dart';
import 'package:mock_interview/core/errors/failures.dart';
import '../../../../core/entities/question.dart';
import '../repositories/interview_repository.dart';

class StartVoiceInterviewUseCase {
  final InterviewRepository repository;

  StartVoiceInterviewUseCase(this.repository);

  Stream<Either<Failure, Question>> call(StartVoiceInterviewParams params) {
    return repository.startVoiceInterview(
      userId: params.userId,
      jobRole: params.jobRole,
      difficultyLevel: params.difficultyLevel,
      category: params.category, interviewType: params.interviewType,
      
    );
  }
}

class StartVoiceInterviewParams {
  final String userId;
  final String jobRole;
  final DifficultyLevel difficultyLevel;
  final QuestionCategory category;
  final InterviewType interviewType;

  StartVoiceInterviewParams( {required this.interviewType,
    required this.userId,
    required this.jobRole,
    required this.difficultyLevel,
    required this.category,
  });
}
