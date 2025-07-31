part of 'history_bloc.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object> get props => [];
}

class LoadUserSessions extends HistoryEvent {
  final String userId;

  const LoadUserSessions({required this.userId});

  @override
  List<Object> get props => [userId];
}

class RefreshUserSessions extends HistoryEvent {
  final String userId;

  const RefreshUserSessions({required this.userId});

  @override
  List<Object> get props => [userId];
}
