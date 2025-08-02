import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileParams {
  final String name;


  UpdateProfileParams({required this.name});
}

class UpdateProfile implements UseCase<void, UpdateProfileParams> {
  final AuthRepository authRepository;

  UpdateProfile(this.authRepository);

  @override
  Future<Either<Failure, void>> call(UpdateProfileParams params) async {
    return await authRepository.updateProfile(
      name: params.name,
     
    );
  }
}
