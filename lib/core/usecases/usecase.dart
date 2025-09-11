import 'package:fpdart/fpdart.dart';
import '../errors/failures.dart';

/// Generic use case contract
abstract class UseCase<R, P> {
  Future<Either<Failure, R>> call(P params);
}

class NoParams {}
