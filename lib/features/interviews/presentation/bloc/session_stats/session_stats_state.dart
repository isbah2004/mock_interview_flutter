// import 'package:equatable/equatable.dart';
// import '../../../../../core/entities/interview_session.dart';
// import '../../../../../core/entities/session_stats.dart';

// abstract class SessionStatsState extends Equatable {
//   const SessionStatsState();

//   @override
//   List<Object?> get props => [];
// }

// class SessionStatsInitial extends SessionStatsState {
//   const SessionStatsInitial();
// }

// class SessionStatsLoading extends SessionStatsState {
//   const SessionStatsLoading();
// }

// class SessionStatsLoaded extends SessionStatsState {
//   final SessionStats? sessionStats;
//   final List<InterviewSession> sessions;

//   const SessionStatsLoaded({this.sessionStats, this.sessions = const []});

//   @override
//   List<Object?> get props => [sessionStats, sessions];
// }

// class UserSessionsLoaded extends SessionStatsState {
//   final List<InterviewSession> sessions;

//   const UserSessionsLoaded({required this.sessions});

//   @override
//   List<Object?> get props => [sessions];
// }

// class SessionStatsError extends SessionStatsState {
//   final String message;

//   const SessionStatsError(this.message);

//   @override
//   List<Object?> get props => [message];
// }

// class SessionDeleteSuccess extends SessionStatsState {
//   final String sessionId;

//   const SessionDeleteSuccess(this.sessionId);

//   @override
//   List<Object?> get props => [sessionId];
// }

// class SessionSaveSuccess extends SessionStatsState {
//   final String sessionId;

//   const SessionSaveSuccess(this.sessionId);

//   @override
//   List<Object?> get props => [sessionId];
// }

// class SessionStatsEmpty extends SessionStatsState {
//   const SessionStatsEmpty();
// }
