import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/entities/user_stats.dart';

abstract class HomeRepository {
  Future<Either<Failure, UserStats>> getUserStats(String userId);
  Future<Either<Failure, void>> updateUserStats(String userId, UserStats stats);
}
