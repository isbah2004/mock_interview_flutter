import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/entities/user.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmailParams {
  final String email;
  final String password;
  final String name;

  SignUpWithEmailParams({
    required this.email,
    required this.password,
    required this.name,
  });
}

class SignUpWithEmail implements UseCase<UserEntity, SignUpWithEmailParams> {
  final AuthRepository authRepository;

  SignUpWithEmail(this.authRepository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpWithEmailParams params) async {
    return await authRepository.signUpWithEmail(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }
}
