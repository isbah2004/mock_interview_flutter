import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/services/network_service.dart';
import '../../domain/entities/interview_session.dart';
import '../../domain/entities/interview_config.dart';
import '../../domain/repositories/voice_interview_repository.dart';
import '../datasources/voice_interview_remote_datasource.dart';
import '../models/voice_interview_evaluation_result.dart';

class VoiceInterviewRepositoryImpl implements VoiceInterviewRepository {
  final VoiceInterviewRemoteDataSource remoteDataSource;
  final NetworkService networkService;

  VoiceInterviewRepositoryImpl({
    required this.remoteDataSource,
    required this.networkService,
  });

  @override
  Future<Either<Failure, VoiceInterviewEvaluationResult>>
  evaluateVoiceInterview({
    required InterviewSession session,
    required InterviewConfig config,
  }) async {
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final result = await remoteDataSource.evaluateVoiceInterview(
        session,
        config,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
