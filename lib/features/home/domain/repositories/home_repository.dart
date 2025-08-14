import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';

abstract class HomeRepository {
  Future<Either<Failure, void>> getUserStats(String userId);
  Future<Either<Failure, void>> updateUserStats(String userId);
}
