import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/entities/user.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailParams {
  final String email;
  final String password;

  SignInWithEmailParams({required this.email, required this.password});
}

class SignInWithEmail implements UseCase<UserEntity, SignInWithEmailParams> {
  final AuthRepository authRepository;

  SignInWithEmail(this.authRepository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInWithEmailParams params) async {
    return await authRepository.signInWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}
