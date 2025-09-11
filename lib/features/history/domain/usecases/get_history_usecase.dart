import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/models/unified_interview_session.dart';
import 'package:mock_interview/core/usecases/usecase.dart';
import 'package:mock_interview/features/history/domain/repositories/history_repository.dart';

class GetHistoryUseCase
    implements UseCase<List<UnifiedInterviewSession>, GetHistoryParams> {
  final HistoryRepository repository;
  GetHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<UnifiedInterviewSession>>> call(
    GetHistoryParams params,
  ) async {
    return repository.getHistory(params.userId, limit: params.limit);
  }
}

class GetHistoryParams {
  final String userId;
  final int limit;
  const GetHistoryParams({required this.userId, this.limit = 50});
}
