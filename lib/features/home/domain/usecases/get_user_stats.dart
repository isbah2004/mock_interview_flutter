import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/home_repository.dart';
import '../../../../core/entities/user_stats.dart';

class GetUserStatsParams {
  final String userId;

  GetUserStatsParams({required this.userId});
}

class GetUserStats implements UseCase<UserStats, GetUserStatsParams> {
  final HomeRepository homeRepository;

  GetUserStats(this.homeRepository);

  @override
  Future<Either<Failure, UserStats>> call(GetUserStatsParams params) async {
    return await homeRepository.getUserStats(params.userId);
  }
}
