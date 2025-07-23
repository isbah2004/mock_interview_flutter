import 'package:bloc/bloc.dart';
import '../../domain/usecases/get_user_stats.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetUserStats getUserStats;

  HomeBloc({required this.getUserStats}) : super(const HomeInitial()) {
    on<HomeLoadRequested>(_onHomeLoadRequested);
    on<HomeRefreshRequested>(_onHomeRefreshRequested);
  }

  Future<void> _onHomeLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    final result = await getUserStats(GetUserStatsParams(userId: event.userId));

    result.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (userStats) => emit(HomeLoaded(userStats: userStats)),
    );
  }

  Future<void> _onHomeRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    // Don't show loading for refresh
    final result = await getUserStats(GetUserStatsParams(userId: event.userId));

    result.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (userStats) => emit(HomeLoaded(userStats: userStats)),
    );
  }
}
