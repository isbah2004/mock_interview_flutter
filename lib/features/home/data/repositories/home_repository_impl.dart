import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/entities/user_stats.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';
import '../models/user_stats_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserStats>> getUserStats(String userId) async {
    try {
      final stats = await remoteDataSource.getUserStats(userId);
      return Right(stats);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to get user stats: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserStats(
    String userId,
    UserStats stats,
  ) async {
    try {
      final statsModel = UserStatsModel(
        totalInterviews: stats.totalInterviews,
        averageScore: stats.averageScore,
        voiceInterviews: stats.voiceInterviews,
        mcqInterviews: stats.mcqInterviews,
        improvementPercentage: stats.improvementPercentage,
        userId: stats.userId,
      );

      await remoteDataSource.updateUserStats(userId, statsModel);
      return const Right(null);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(
        ServerFailure('Failed to update user stats: ${e.toString()}'),
      );
    }
  }
}
