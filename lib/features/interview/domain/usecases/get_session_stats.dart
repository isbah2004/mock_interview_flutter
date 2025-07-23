import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import '../../../../core/entities/session_stats.dart';
import '../repositories/interview_repository.dart';

class GetSessionStatsUseCase {
  final InterviewRepository repository;

  GetSessionStatsUseCase(this.repository);

  Future<Either<Failure, SessionStats?>> call(String sessionId) async {
    return await repository.getSessionStats(sessionId);
  }
}

class GetSessionStatsParams extends Equatable {
  final String sessionId;

  const GetSessionStatsParams({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}
