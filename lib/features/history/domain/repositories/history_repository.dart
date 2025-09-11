import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/models/unified_interview_session.dart';

abstract class HistoryRepository {
  Future<Either<Failure, List<UnifiedInterviewSession>>> getHistory(
    String userId, {
    int limit,
  });
}
