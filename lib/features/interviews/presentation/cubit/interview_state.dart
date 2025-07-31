// import 'package:equatable/equatable.dart';
// import 'package:mock_interview/core/entities/interview_entity.dart';

// abstract class InterviewState extends Equatable {
//   const InterviewState();

//   @override
//   List<Object?> get props => [];
// }

// class InterviewInitial extends InterviewState {
//   const InterviewInitial();
// }

// class InterviewLoading extends InterviewState {
//   const InterviewLoading();
// }

// class InterviewsLoaded extends InterviewState {
//   final List<InterviewEntity> interviews;

//   const InterviewsLoaded(this.interviews);

//   @override
//   List<Object?> get props => [interviews];
// }

// class InterviewCreated extends InterviewState {
//   final InterviewEntity interview;

//   const InterviewCreated(this.interview);

//   @override
//   List<Object?> get props => [interview];
// }

// class InterviewStarted extends InterviewState {
//   final InterviewEntity interview;

//   const InterviewStarted(this.interview);

//   @override
//   List<Object?> get props => [interview];
// }

// class InterviewError extends InterviewState {
//   final String message;

//   const InterviewError(this.message);

//   @override
//   List<Object?> get props => [message];
// }
