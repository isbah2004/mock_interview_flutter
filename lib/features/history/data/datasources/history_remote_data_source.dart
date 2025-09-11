import 'package:mock_interview/core/models/unified_interview_session.dart';
import 'package:mock_interview/core/services/unified_database_service.dart';
import 'package:mock_interview/core/errors/failures.dart';

/// Remote data source responsible solely for fetching interview sessions
/// for a user (history). Evaluation fetching is performed directly via
/// other services where needed; we keep this focused.
abstract class HistoryRemoteDataSource {
  Future<List<UnifiedInterviewSession>> getUserHistory({
    required String userId,
    int limit,
  });
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final UnifiedDatabaseService _databaseService;

  HistoryRemoteDataSourceImpl({required UnifiedDatabaseService databaseService})
    : _databaseService = databaseService;

  @override
  Future<List<UnifiedInterviewSession>> getUserHistory({
    required String userId,
    int limit = 50,
  }) async {
    try {
      return await _databaseService.getUserInterviewSessions(
        userId,
        limit: limit,
      );
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Failed to fetch history: $e');
    }
  }
}
