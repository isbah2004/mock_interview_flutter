// import 'package:equatable/equatable.dart';

// class VoiceQuestion extends Equatable {
//   final String id;
//   final String questionText;
//   final String category;
//   final int timeLimit; // in seconds
//   final int difficulty; // 1-5 scale

//   const VoiceQuestion({
//     required this.id,
//     required this.questionText,
//     required this.category,
//     this.timeLimit = 120, // 2 minutes default
//     this.difficulty = 3,
//   });

//   @override
//   List<Object?> get props => [
//     id,
//     questionText,
//     category,
//     timeLimit,
//     difficulty,
//   ];

//   VoiceQuestion copyWith({
//     String? id,
//     String? questionText,
//     String? category,
//     int? timeLimit,
//     int? difficulty,
//   }) {
//     return VoiceQuestion(
//       id: id ?? this.id,
//       questionText: questionText ?? this.questionText,
//       category: category ?? this.category,
//       timeLimit: timeLimit ?? this.timeLimit,
//       difficulty: difficulty ?? this.difficulty,
//     );
//   }
// }
