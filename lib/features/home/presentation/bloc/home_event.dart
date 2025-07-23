import 'package:equatable/equatable.dart';
import '../../../../core/entities/user_stats.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeLoadRequested extends HomeEvent {
  final String userId;

  const HomeLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class HomeRefreshRequested extends HomeEvent {
  final String userId;

  const HomeRefreshRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class HomeUpdateStatsRequested extends HomeEvent {
  final String userId;
  final UserStats stats;

  const HomeUpdateStatsRequested({required this.userId, required this.stats});

  @override
  List<Object?> get props => [userId, stats];
}
