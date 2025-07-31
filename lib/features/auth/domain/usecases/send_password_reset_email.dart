import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SendPasswordResetEmailParams {
  final String email;

  SendPasswordResetEmailParams({required this.email});
}

class SendPasswordResetEmail
    implements UseCase<void, SendPasswordResetEmailParams> {
  final AuthRepository authRepository;

  SendPasswordResetEmail(this.authRepository);

  @override
  Future<Either<Failure, void>> call(
    SendPasswordResetEmailParams params,
  ) async {
    return await authRepository.sendPasswordResetEmail(params.email);
  }
}
