import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/home_repository.dart';

class GetUserStatsParams {
  final String userId;

  GetUserStatsParams({required this.userId});
}

class GetUserStats implements UseCase<void, GetUserStatsParams> {
  final HomeRepository homeRepository;

  GetUserStats(this.homeRepository);

  @override
  Future<Either<Failure, void>> call(GetUserStatsParams params) async {
    return await homeRepository.getUserStats(params.userId);
  }
}
