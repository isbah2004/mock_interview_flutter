import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/entities/user.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUser implements UseCase<UserEntity?, NoParams> {
  final AuthRepository authRepository;

  GetCurrentUser(this.authRepository);

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) async {
    return await authRepository.getCurrentUser();
  }
}
