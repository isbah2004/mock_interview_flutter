import 'package:equatable/equatable.dart';

abstract class SessionStatsEvent extends Equatable {
  const SessionStatsEvent();

  @override
  List<Object?> get props => [];
}

class GetSessionStatsEvent extends SessionStatsEvent {
  final String sessionId;

  const GetSessionStatsEvent({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class GetUserSessionsEvent extends SessionStatsEvent {
  final String userId;

  const GetUserSessionsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class DeleteSessionEvent extends SessionStatsEvent {
  final String sessionId;

  const DeleteSessionEvent({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class SaveSessionToAppwriteEvent extends SessionStatsEvent {
  final String sessionId;
  final String userId;

  const SaveSessionToAppwriteEvent({
    required this.sessionId,
    required this.userId,
  });

  @override
  List<Object?> get props => [sessionId, userId];
}

class RefreshSessionStatsEvent extends SessionStatsEvent {
  const RefreshSessionStatsEvent();
}

class ClearSessionStatsEvent extends SessionStatsEvent {
  const ClearSessionStatsEvent();
}

class LoadAllSessionsEvent extends SessionStatsEvent {
  const LoadAllSessionsEvent();
}
