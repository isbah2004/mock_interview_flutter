import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/entities/interview_session.dart';
import 'package:mock_interview/core/entities/question.dart';
import 'package:mock_interview/core/entities/session_stats.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/services/network_service.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/interview_repository.dart';
import '../datasources/interview_remote_datasource.dart';
import '../datasources/interview_local_datasource.dart';
import '../models/interview_request_model.dart';

class InterviewRepositoryImpl implements InterviewRepository {
  final InterviewRemoteDataSource remoteDataSource;
  final InterviewLocalDataSource localDataSource;
  final NetworkService networkService;

  InterviewRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkService,
  });

  @override
  Future<Either<Failure, Question>> startMcqInterview({
    required String userId,
    required String jobRole,
    required DifficultyLevel difficultyLevel,
    required QuestionCategory category,
    required int numQuestions,
  }) async {
    // Check network connectivity first
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final request = InterviewRequestModel.fromMcqParams(
        userId: userId,
        jobRole: jobRole,
        difficultyLevel: difficultyLevel,
        category: category,
        numQuestions: numQuestions,
      );

      final response = await remoteDataSource.startMcqInterview(request);

      // Save session to local storage - we'll use questionId as sessionId for now
      final session = InterviewSession(
        sessionId:
            response.questionId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        jobRole: jobRole,
        type: InterviewType.mcq,
        difficulty: difficultyLevel,
        category: category,
        numQuestions: numQuestions,
        createdAt: DateTime.now(),
        isComplete: false,
      );

      await localDataSource.saveSession(session);

      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Failed to start MCQ interview: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Question>> submitMcqAnswer({
    required String sessionId,
    required String answer,
    required String userId,
    required String jobRole,
  }) async {
    // Check network connectivity first
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final request = InterviewRequestModel.fromMcqParams(
        userId: userId,
        jobRole: jobRole,
        difficultyLevel:
            DifficultyLevel.medium, // Default - this should come from session
        category:
            QuestionCategory.general, // Default - this should come from session
        numQuestions: 1, // Not used for submit
        answer: answer,
        questionId: sessionId, // Using sessionId as questionId
      );

      final response = await remoteDataSource.submitMcqAnswer(request);
      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Failed to submit MCQ answer: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<Either<Failure, Question>> startVoiceInterview({
    required String userId,
    required String jobRole,
    required DifficultyLevel difficultyLevel,
    required QuestionCategory category,
  }) async* {
    // Check network connectivity first
    if (!await networkService.isConnected) {
      yield const Left(NetworkFailure('No internet connection'));
      return;
    }

    try {
      final request = InterviewRequestModel.fromVoiceParams(
        userId: userId,
        jobRole: jobRole,
        difficultyLevel: difficultyLevel,
        category: category,
      );

      final responseStream = remoteDataSource.startVoiceInterview(request);

      await for (final response in responseStream) {
        // Save session to local storage on first response
        if (response.questionId != null && response.questionId!.isNotEmpty) {
          final session = InterviewSession(
            sessionId: response.questionId!,
            userId: userId,
            jobRole: jobRole,
            type: InterviewType.voice,
            difficulty: difficultyLevel,
            category: category,
            numQuestions:
                null, // Voice interviews don't have fixed question count
            createdAt: DateTime.now(),
            isComplete: false,
          );

          await localDataSource.saveSession(session);
        }

        yield Right(response.toEntity());
      }
    } on ServerException catch (e) {
      yield Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      yield Left(NetworkFailure(e.message));
    } catch (e) {
      yield Left(
        ServerFailure('Failed to start voice interview: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> submitVoiceAnswer({
    required String sessionId,
    required String answer,
    required String userId,
    required String jobRole,
  }) async {
    // Check network connectivity first
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final request = InterviewRequestModel.fromVoiceParams(
        userId: userId,
        jobRole: jobRole,
        difficultyLevel:
            DifficultyLevel.medium, // Default - this should come from session
        category:
            QuestionCategory.general, // Default - this should come from session
        answer: answer,
        questionId: sessionId, // Using sessionId as questionId
      );

      await remoteDataSource.submitVoiceAnswer(request);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Failed to submit voice answer: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> endVoiceInterview(String sessionId) async {
    // Check network connectivity first
    if (!await networkService.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.endVoiceInterview(sessionId);

      // Update local session to mark as complete
      final sessions = await localDataSource.getUserSessions(
        '',
      ); // We'll need to get user ID somehow
      final session = sessions.firstWhere((s) => s.sessionId == sessionId);
      final updatedSession = InterviewSession(
        sessionId: session.sessionId,
        userId: session.userId,
        jobRole: session.jobRole,
        type: session.type,
        difficulty: session.difficulty,
        category: session.category,
        numQuestions: session.numQuestions,
        createdAt: session.createdAt,
        isComplete: true,
      );

      await localDataSource.updateSession(updatedSession);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Failed to end voice interview: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, SessionStats>> getSessionStats(
    String sessionId,
  ) async {
    try {
      // Try to get from remote first if connected
      if (await networkService.isConnected) {
        try {
          final stats = await remoteDataSource.getSessionStats(sessionId);
          return Right(stats.toEntity());
        } on ServerException catch (e) {
          return Left(ServerFailure(e.message));
        } on NetworkException catch (e) {
          return Left(NetworkFailure(e.message));
        }
      } else {
        // Return network failure if not connected and no local cache
        return const Left(
          NetworkFailure('No internet connection and no cached data'),
        );
      }
    } catch (e) {
      return Left(
        ServerFailure('Failed to get session stats: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteSession(String sessionId) async {
    try {
      // Delete from remote if connected
      if (await networkService.isConnected) {
        try {
          await remoteDataSource.deleteSession(sessionId);
        } on ServerException catch (e) {
          return Left(ServerFailure(e.message));
        } on NetworkException catch (e) {
          return Left(NetworkFailure(e.message));
        }
      }

      // Always delete from local storage
      await localDataSource.deleteSession(sessionId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete session: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSessionToAppwrite(
    InterviewSession session,
  ) async {
    try {
      await localDataSource.saveSession(session);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(
        CacheFailure('Failed to save session to Appwrite: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<InterviewSession>>> getUserSessions(
    String userId,
  ) async {
    try {
      // Try to get from local storage first
      final localSessions = await localDataSource.getUserSessions(userId);

      if (localSessions.isNotEmpty) {
        return Right(localSessions);
      }

      // If no local sessions and no network, return empty list
      if (!await networkService.isConnected) {
        return const Right([]);
      }

      // If we had remote data source method for getting user sessions, we'd call it here
      // For now, return the local sessions (which might be empty)
      return Right(localSessions);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Failed to get user sessions: ${e.toString()}'),
      );
    }
  }
}
