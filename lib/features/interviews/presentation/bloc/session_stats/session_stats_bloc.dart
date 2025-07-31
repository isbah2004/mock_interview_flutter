// import 'package:bloc/bloc.dart';
// import 'package:mock_interview/core/enums/question_category.dart';
// import '../../../domain/usecases/interview_usecases.dart';
// import '../../../../../core/entities/interview_session.dart';
// import 'session_stats_event.dart';
// import 'session_stats_state.dart';

// class SessionStatsBloc extends Bloc<SessionStatsEvent, SessionStatsState> {
//   final GetSessionStatsUseCase _getSessionStatsUseCase;
//   final GetUserSessionsUseCase _getUserSessionsUseCase;
//   final DeleteSessionUseCase _deleteSessionUseCase;
//   final SaveSessionToAppwriteUseCase _saveSessionToAppwriteUseCase;

//   SessionStatsBloc({
//     required GetSessionStatsUseCase getSessionStatsUseCase,
//     required GetUserSessionsUseCase getUserSessionsUseCase,
//     required DeleteSessionUseCase deleteSessionUseCase,
//     required SaveSessionToAppwriteUseCase saveSessionToAppwriteUseCase,
//   }) : _getSessionStatsUseCase = getSessionStatsUseCase,
//        _getUserSessionsUseCase = getUserSessionsUseCase,
//        _deleteSessionUseCase = deleteSessionUseCase,
//        _saveSessionToAppwriteUseCase = saveSessionToAppwriteUseCase,
//        super(const SessionStatsInitial()) {
//     on<GetSessionStatsEvent>(_onGetSessionStats);
//     on<GetUserSessionsEvent>(_onGetUserSessions);
//     on<DeleteSessionEvent>(_onDeleteSession);
//     on<SaveSessionToAppwriteEvent>(_onSaveSessionToAppwrite);
//     on<RefreshSessionStatsEvent>(_onRefreshSessionStats);
//     on<ClearSessionStatsEvent>(_onClearSessionStats);
//     on<LoadAllSessionsEvent>(_onLoadAllSessions);
//   }

//   Future<void> _onGetSessionStats(
//     GetSessionStatsEvent event,
//     Emitter<SessionStatsState> emit,
//   ) async {
//     emit(const SessionStatsLoading());

//     final result = await _getSessionStatsUseCase.call(event.sessionId);

//     result.fold((failure) => emit(SessionStatsError(failure.message)), (
//       sessionStats,
//     ) {
//       if (sessionStats != null) {
//         emit(SessionStatsLoaded(sessionStats: sessionStats));
//       } else {
//         emit(const SessionStatsEmpty());
//       }
//     });
//   }

//   Future<void> _onGetUserSessions(
//     GetUserSessionsEvent event,
//     Emitter<SessionStatsState> emit,
//   ) async {
//     emit(const SessionStatsLoading());

//     final result = await _getUserSessionsUseCase.call(event.userId);

//     result.fold((failure) => emit(SessionStatsError(failure.message)), (
//       sessions,
//     ) {
//       if (sessions.isNotEmpty) {
//         emit(UserSessionsLoaded(sessions: sessions));
//       } else {
//         emit(const SessionStatsEmpty());
//       }
//     });
//   }

//   Future<void> _onDeleteSession(
//     DeleteSessionEvent event,
//     Emitter<SessionStatsState> emit,
//   ) async {
//     emit(const SessionStatsLoading());

//     final result = await _deleteSessionUseCase.call(event.sessionId);

//     result.fold(
//       (failure) => emit(SessionStatsError(failure.message)),
//       (_) => emit(SessionDeleteSuccess(event.sessionId)),
//     );
//   }

//   Future<void> _onSaveSessionToAppwrite(
//     SaveSessionToAppwriteEvent event,
//     Emitter<SessionStatsState> emit,
//   ) async {
//     emit(const SessionStatsLoading());

//     // Create a basic InterviewSession for saving
//     final session = InterviewSession(
//       sessionId: event.sessionId,
//       userId: event.userId,
//       jobRole: 'Unknown', // Would be passed from event if needed
     
//       category: QuestionCategory.general, // Default or passed from event
//       createdAt: DateTime.now(),
//       isComplete: true, interviewType: event., difficultyLevel: null,
//     );

//     final result = await _saveSessionToAppwriteUseCase.call(session);

//     result.fold(
//       (failure) => emit(SessionStatsError(failure.message)),
//       (_) => emit(SessionSaveSuccess(event.sessionId)),
//     );
//   }

//   Future<void> _onRefreshSessionStats(
//     RefreshSessionStatsEvent event,
//     Emitter<SessionStatsState> emit,
//   ) async {
//     // If current state has session stats, refresh them
//     if (state is SessionStatsLoaded) {
//       final currentState = state as SessionStatsLoaded;
//       if (currentState.sessionStats != null) {
//         final sessionId = currentState.sessionStats!.sessionId;
//         add(GetSessionStatsEvent(sessionId: sessionId));
//       }
//     }
//     // If current state has user sessions, refresh them
//     else if (state is UserSessionsLoaded) {
//       final currentState = state as UserSessionsLoaded;
//       if (currentState.sessions.isNotEmpty) {
//         final userId = currentState.sessions.first.userId;
//         add(GetUserSessionsEvent(userId: userId));
//       }
//     }
//   }

//   void _onClearSessionStats(
//     ClearSessionStatsEvent event,
//     Emitter<SessionStatsState> emit,
//   ) {
//     emit(const SessionStatsInitial());
//   }

//   Future<void> _onLoadAllSessions(
//     LoadAllSessionsEvent event,
//     Emitter<SessionStatsState> emit,
//   ) async {
//     emit(const SessionStatsLoading());

//     // For now, we'll create some mock sessions since we don't have a user ID
//     // In a real app, you'd get the current user ID from authentication
//     const userId = 'current_user'; // This should come from auth service

//     // Create some mock sessions for demonstration
//     final mockSessions = [
//       InterviewSession(
//         sessionId: 'session_1',
//         userId: userId,
//         jobRole: 'Software Developer',
//         type: InterviewType.mcq,
//         difficulty: DifficultyLevel.medium,
//         category: QuestionCategory.technical,
//         createdAt: DateTime.now().subtract(const Duration(days: 2)),
//         isComplete: true,
//         score: 85.0,
//         duration: const Duration(minutes: 25),
//         feedback: 'Great performance! You showed strong technical knowledge.', interviewType: null, difficultyLevel: null,
//       ),
//       InterviewSession(
//         sessionId: 'session_2',
//         userId: userId,
//         jobRole: 'Data Scientist',
//         type: InterviewType.voice,
//         difficulty: DifficultyLevel.hard,
//         category: QuestionCategory.behavioral,
//         createdAt: DateTime.now().subtract(const Duration(days: 5)),
//         isComplete: true,
//         score: 72.0,
//         duration: const Duration(minutes: 35),
//         feedback:
//             'Good communication skills. Work on providing more specific examples.',
//       ),
//       InterviewSession(
//         sessionId: 'session_3',
//         userId: userId,
//         jobRole: 'Product Manager',
//         type: InterviewType.mcq,
//         difficulty: DifficultyLevel.easy,
//         category: QuestionCategory.general,
//         createdAt: DateTime.now().subtract(const Duration(days: 7)),
//         isComplete: true,
//         score: 90.0,
//         duration: const Duration(minutes: 20),
//         feedback: 'Excellent understanding of product management concepts.',
//       ),
//     ];

//     emit(SessionStatsLoaded(sessions: mockSessions));
//   }
// }
