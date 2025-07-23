// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mock_interview/core/usecases/usecase.dart';
// import 'package:mock_interview/features/interview/domain/usecases/create_interview.dart';
// import 'package:mock_interview/features/interview/domain/usecases/get_user_interviews.dart';
// import 'package:mock_interview/features/interview/domain/usecases/get_interview.dart';
// import 'package:mock_interview/features/interview/domain/usecases/start_interview.dart';
// import 'interview_state.dart';

// class InterviewCubit extends Cubit<InterviewState> {
//   final CreateInterview _createInterview;
//   final GetUserInterviews _getUserInterviews;
//   final GetInterview _getInterview;
//   final StartInterview _startInterview;

//   InterviewCubit({
//     required CreateInterview createInterview,
//     required GetUserInterviews getUserInterviews,
//     required GetInterview getInterview,
//     required StartInterview startInterview,
//   }) : _createInterview = createInterview,
//        _getUserInterviews = getUserInterviews,
//        _getInterview = getInterview,
//        _startInterview = startInterview,
//        super(const InterviewInitial());

//   Future<void> loadUserInterviews() async {
//     emit(const InterviewLoading());

//     final result = await _getUserInterviews(NoParams());

//     result.fold(
//       (failure) => emit(InterviewError(failure.message)),
//       (interviews) => emit(InterviewsLoaded(interviews)),
//     );
//   }

//   Future<void> createInterview({
//     required String title,
//     required String description,
//     required String category,
//     required String difficulty,
//     required int duration,
//   }) async {
//     emit(const InterviewLoading());

//     final result = await _createInterview(
//       CreateInterviewParams(
//         title: title,
//         description: description,
//         category: category,
//         difficulty: difficulty,
//         duration: duration,
//       ),
//     );

//     result.fold((failure) => emit(InterviewError(failure.message)), (
//       interview,
//     ) {
//       emit(InterviewCreated(interview));
//       // Reload interviews after creation
//       loadUserInterviews();
//     });
//   }

//   Future<void> startInterview(String interviewId) async {
//     emit(const InterviewLoading());

//     // First get the interview details
//     final interviewResult = await _getInterview(
//       GetInterviewParams(interviewId: interviewId),
//     );

//     interviewResult.fold((failure) => emit(InterviewError(failure.message)), (
//       interview,
//     ) async {
//       if (interview == null) {
//         emit(const InterviewError('Interview not found'));
//         return;
//       }

//       // Start the interview
//       final startResult = await _startInterview(
//         StartInterviewParams(interviewId: interviewId),
//       );

//       startResult.fold(
//         (failure) => emit(InterviewError(failure.message)),
//         (_) => emit(InterviewStarted(interview)),
//       );
//     });
//   }

//   void reset() {
//     emit(const InterviewInitial());
//   }
// }
