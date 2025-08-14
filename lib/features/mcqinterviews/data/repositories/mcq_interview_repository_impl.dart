import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/entities/evaluation_result.dart';
import 'package:mock_interview/features/mcqinterviews/data/models/interview_session_model.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/services/network_service.dart';
import 'package:mock_interview/features/mcqinterviews/data/models/question_model.dart';
import '../../domain/repositories/mcq_interview_repository.dart';
import '../datasources/mcq_interview_remote_datasource.dart';

class InterviewRepositoryImpl implements InterviewRepository {
  final InterviewRemoteDataSource remoteDataSource;
  final NetworkService networkService;

  InterviewRepositoryImpl({
    required this.remoteDataSource,
    required this.networkService,
  });

  @override
  Future<Either<Failure, InterviewSessionModel>> startInterview({
    required String userId,
    required String jobRole,
    required String difficultyLevel,
    required int numQuestions,
    required String category,
  }) async {
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final interview = await remoteDataSource.startInterview(
        userId: userId,
        jobRole: jobRole,
        difficultyLevel: difficultyLevel,
        numQuestions: numQuestions,
        category: category,
      );
      return Right(interview);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EvaluationResult>> submitAnswers({
    required String sessionId,
    required String userId,
    required List<String> answers,
    required String jobRole,
    required String difficultyLevel,
    required String category,
  }) async {
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final result = await remoteDataSource.submitAnswers(
        sessionId: sessionId,
        userId: userId,
        answers: answers,
        jobRole: jobRole,
        difficultyLevel: difficultyLevel,
        category: category,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSessionStats(
    String sessionId,
  ) async {
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final stats = await remoteDataSource.getSessionStats(sessionId);
      return Right(stats);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSession(String sessionId) async {
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      await remoteDataSource.deleteSession(sessionId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getActiveSessions() async {
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final sessions = await remoteDataSource.getActiveSessions();
      return Right(sessions);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkHealth() async {
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final isHealthy = await remoteDataSource.checkHealth();
      return Right(isHealthy);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> completeInterview({
    required String sessionId,
    required String userId,
    required int score,
    required int timeTaken,
    required int totalQuestions,
    required int correctAnswers,
  }) async {
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final result = await remoteDataSource.completeInterview(
        sessionId: sessionId,
        userId: userId,
        score: score,
        timeTaken: timeTaken,
        totalQuestions: totalQuestions,
        correctAnswers: correctAnswers,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<InterviewSessionModel>>> getUserSessions(
    String userId,
  ) async {
    try {
      final sessions = await remoteDataSource.getUserSessions(userId);
      return Right(sessions);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch user sessions: $e'));
    }
  }

  Future<Either<Failure, List<QuestionModel>>> getSessionQuestions(
    String sessionId,
  ) async {
    try {
      final questions = await remoteDataSource.getSessionQuestions(sessionId);
      return Right(questions);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch session questions: $e'));
    }
  }

  Future<Either<Failure, Unit>> storeInterviewSession(
    InterviewSessionModel session,
    String id,
  ) async {
    try {
      await remoteDataSource.storeInterviewSession(session, id);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to store interview session: $e'));
    }
  }

  Future<Either<Failure, Unit>> storeQuestions(
    List<QuestionModel> questions,
  ) async {
    try {
      await remoteDataSource.storeQuestions(questions);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to store questions: $e'));
    }
  }

  Failure _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure('Connection timed out');
      case DioExceptionType.badResponse:
        final message =
            e.response?.data?['error'] ??
            e.response?.data?['detail'] ??
            'Server error';
        return ServerFailure(message);
      case DioExceptionType.cancel:
        return const ServerFailure('Request cancelled');
      case DioExceptionType.connectionError:
        return const NetworkFailure('Connection error');
      default:
        return ServerFailure(e.message ?? 'Unknown error');
    }
  }
}
