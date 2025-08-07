// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mock_interview/core/cubits/usercubit/user_cubit.dart';
// import 'package:mock_interview/core/cubits/usercubit/user_state.dart';
// import 'package:mock_interview/core/enums/difficulty_level.dart';
// import 'package:mock_interview/core/enums/question_category.dart';
// import 'package:mock_interview/core/extensions/enum_extensions.dart';
// import 'package:mock_interview/features/interviews/presentation/view/mcq_interview_view_new.dart';

// class InterviewConfigPage extends StatefulWidget {
//   const InterviewConfigPage({super.key});

//   @override
//   State<InterviewConfigPage> createState() => _InterviewConfigPageState();
// }

// class _InterviewConfigPageState extends State<InterviewConfigPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _jobRoleController = TextEditingController();

//   DifficultyLevel _selectedDifficulty = DifficultyLevel.medium;
//   int _selectedQuestions = 10;
//   QuestionCategory _selectedCategory = QuestionCategory.technical;
//   int _selectedTimePerQuestion = 30;

//   @override
//   void dispose() {
//     _jobRoleController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF9FAFB),
//       appBar: AppBar(
//         title: const Text(
//           'Interview Configuration',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: Theme.of(context).primaryColor,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Header
//               const Text(
//                 'Configure Your MCQ Interview',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF111827),
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Customize your interview settings to match your preparation level',
//                 style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 32),

//               // Job Role Input
//               _buildCard(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Job Role',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF374151),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     TextFormField(
//                       controller: _jobRoleController,
//                       decoration: InputDecoration(
//                         hintText: 'e.g., Software Engineer, Product Manager',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide(color: Colors.grey.shade300),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide(
//                             color: Theme.of(context).primaryColor,
//                           ),
//                         ),
//                         prefixIcon: const Icon(Icons.work_outline),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 16,
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter a job role';
//                         }
//                         return null;
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Difficulty Selection
//               _buildCard(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Difficulty Level',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF374151),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         _buildDifficultyChip(
//                           DifficultyLevel.easy,
//                           DifficultyLevel.easy.displayName,
//                           Colors.green,
//                         ),
//                         const SizedBox(width: 8),
//                         _buildDifficultyChip(
//                           DifficultyLevel.medium,
//                           DifficultyLevel.medium.displayName,
//                           Colors.orange,
//                         ),
//                         const SizedBox(width: 8),
//                         _buildDifficultyChip(
//                           DifficultyLevel.hard,
//                           DifficultyLevel.hard.displayName,
//                           Colors.red,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Number of Questions
//               _buildCard(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Number of Questions',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF374151),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Wrap(
//                       spacing: 8,
//                       children:
//                           [5, 10, 15, 20]
//                               .map((count) => _buildQuestionCountChip(count))
//                               .toList(),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Category Selection
//               _buildCard(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Interview Category',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF374151),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Wrap(
//                       spacing: 8,
//                       runSpacing: 8,
//                       children: [
//                         _buildCategoryChip(
//                           QuestionCategory.technical,
//                           QuestionCategory.technical.displayName,
//                         ),
//                         _buildCategoryChip(
//                           QuestionCategory.behavioral,
//                           QuestionCategory.behavioral.displayName,
//                         ),
//                         _buildCategoryChip(
//                           QuestionCategory.general,
//                           QuestionCategory.general.displayName,
//                         ),
//                         _buildCategoryChip(
//                           QuestionCategory.industrySpecific,
//                           QuestionCategory.industrySpecific.displayName,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Time per Question
//               _buildCard(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Time per Question',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF374151),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Wrap(
//                       spacing: 8,
//                       children:
//                           [
//                             15,
//                             30,
//                             45,
//                             60,
//                           ].map((seconds) => _buildTimeChip(seconds)).toList(),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 32),

//               // Start Interview Button
//               SizedBox(
//                 height: 56,
//                 child: ElevatedButton(
//                   onPressed: _startInterview,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Theme.of(context).primaryColor,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 2,
//                   ),
//                   child: const Text(
//                     'Start Interview',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCard({required Widget child}) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade200,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }

//   Widget _buildDifficultyChip(
//     DifficultyLevel value,
//     String label,
//     Color color,
//   ) {
//     final isSelected = _selectedDifficulty == value;
//     return GestureDetector(
//       onTap: () => setState(() => _selectedDifficulty = value),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: isSelected ? color : Colors.grey.shade300,
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             fontWeight: FontWeight.w500,
//             color: isSelected ? color : Colors.grey.shade700,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildQuestionCountChip(int count) {
//     final isSelected = _selectedQuestions == count;
//     return GestureDetector(
//       onTap: () => setState(() => _selectedQuestions = count),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color:
//               isSelected
//                   ? Theme.of(context).primaryColor.withOpacity(0.1)
//                   : Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color:
//                 isSelected
//                     ? Theme.of(context).primaryColor
//                     : Colors.grey.shade300,
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Text(
//           '$count Questions',
//           style: TextStyle(
//             fontWeight: FontWeight.w500,
//             color:
//                 isSelected
//                     ? Theme.of(context).primaryColor
//                     : Colors.grey.shade700,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryChip(QuestionCategory value, String label) {
//     final isSelected = _selectedCategory == value;
//     return GestureDetector(
//       onTap: () => setState(() => _selectedCategory = value),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color:
//               isSelected
//                   ? Theme.of(context).primaryColor.withOpacity(0.1)
//                   : Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color:
//                 isSelected
//                     ? Theme.of(context).primaryColor
//                     : Colors.grey.shade300,
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             fontWeight: FontWeight.w500,
//             color:
//                 isSelected
//                     ? Theme.of(context).primaryColor
//                     : Colors.grey.shade700,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTimeChip(int seconds) {
//     final isSelected = _selectedTimePerQuestion == seconds;
//     return GestureDetector(
//       onTap: () => setState(() => _selectedTimePerQuestion = seconds),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color:
//               isSelected
//                   ? Theme.of(context).primaryColor.withOpacity(0.1)
//                   : Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color:
//                 isSelected
//                     ? Theme.of(context).primaryColor
//                     : Colors.grey.shade300,
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Text(
//           '${seconds}s',
//           style: TextStyle(
//             fontWeight: FontWeight.w500,
//             color:
//                 isSelected
//                     ? Theme.of(context).primaryColor
//                     : Colors.grey.shade700,
//           ),
//         ),
//       ),
//     );
//   }

//   void _startInterview() {
//     if (_formKey.currentState!.validate()) {
//       // Check if user is logged in
//       final userState = context.read<UserCubit>().state;
//       if (userState is! UserAvailable) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Please login first to start the interview'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }

//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder:
//               (context) => MCQInterviewScreen(
//                 jobRole: _jobRoleController.text,
//                 difficulty: _selectedDifficulty,
//                 category: _selectedCategory,
//                 numberOfQuestions: _selectedQuestions,
//                 timePerQuestion: _selectedTimePerQuestion,
//               ),
//         ),
//       );
//     }
//   }
// }
