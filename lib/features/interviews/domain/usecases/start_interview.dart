import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/entities/interview.dart';
import 'package:mock_interview/core/enums/difficulty_level.dart';
import 'package:mock_interview/core/enums/question_category.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/usecases/usecase.dart';
import 'package:mock_interview/features/interviews/domain/repositories/interview_repository.dart';

class StartInterview implements UseCase<Interview,StartInterviewParams >{
  final InterviewRepository interviewRepository;

  StartInterview(this.interviewRepository);

  @override
  Future<Either<Failure, Interview>> call(StartInterviewParams params) async {
    return await interviewRepository.startInterview(
      userId: params.userId,
      jobRole: params.jobRole,
      difficultyLevel: params.difficultyLevel,
      category: params.category,
      numQuestions: params.numQuestions,
    );
  }
}



class StartInterviewParams  {
  final String userId, jobRole;
  final DifficultyLevel difficultyLevel;
  final QuestionCategory category;
  final int numQuestions;
  StartInterviewParams({
    required this.userId,
    required this.jobRole,
    required this.difficultyLevel,
    required this.category,
    required this.numQuestions,
  });
}