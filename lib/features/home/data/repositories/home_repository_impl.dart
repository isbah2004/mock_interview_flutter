import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';


class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> getUserStats(String userId) async {
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
    
  ) async {
    try {
   

      await remoteDataSource.updateUserStats(userId);
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
