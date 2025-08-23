// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mock_interview/features/mcqinterviews/presentation/bloc/mcq_interview/mcq_interview_event.dart';
// import 'package:mock_interview/features/mcqinterviews/presentation/bloc/mcq_interview/mcq_interview_state.dart';
// import 'package:mock_interview/features/mcqinterviews/presentation/view/mcq_interview_view.dart';
// import '../bloc/mcq_interview/mcq_interview_bloc.dart';
// import '../bloc/mcq_setup/mcq_setup_bloc.dart';
// import '../bloc/mcq_setup/mcq_setup_event.dart';
// import '../bloc/mcq_setup/mcq_setup_state.dart';

// class McqInterviewSetupView extends StatelessWidget {
//   const McqInterviewSetupView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => McqSetupBloc(),
//       child: const _McqInterviewSetupContent(),
//     );
//   }
// }

// class _McqInterviewSetupContent extends StatefulWidget {
//   const _McqInterviewSetupContent();

//   @override
//   State<_McqInterviewSetupContent> createState() =>
//       _McqInterviewSetupContentState();
// }

// class _McqInterviewSetupContentState extends State<_McqInterviewSetupContent> {
//   final _formKey = GlobalKey<FormState>();
//   final _jobRoleController = TextEditingController();
//   final _userIdController = TextEditingController(text: 'user_123');

//   final List<String> _difficulties = ['easy', 'medium', 'hard'];
//   final List<String> _categories = ['general', 'technical', 'behavioral'];
//   final List<int> _questionCounts = [5, 10, 15, 20];

//   @override
//   void dispose() {
//     _jobRoleController.dispose();
//     _userIdController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.surface,
//         title: Text(
//           'MCQ Interview Setup',
//           style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//             color: Theme.of(context).colorScheme.onSurface,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         surfaceTintColor: Colors.transparent,
//       ),
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       body: BlocListener<McqInterviewBloc, McqInterviewState>(
//         listener: (context, state) {
//           if (state is InterviewStarted) {
//             final currentSetupState = context.read<McqSetupBloc>().state;
//             String difficulty = 'easy';
//             String category = 'general';

//             if (currentSetupState is McqSetupConfiguring) {
//               difficulty = currentSetupState.selectedDifficulty;
//               category = currentSetupState.selectedCategory;
//             }

//             Navigator.of(context).pushReplacement(
//               MaterialPageRoute(
//                 builder:
//                     (context) => McqInterviewView(
//                       sessionId: state.sessionId,
//                       questions: state.questions,
//                       userId: _userIdController.text,
//                       jobRole: _jobRoleController.text.trim(),
//                       difficultyLevel: difficulty,
//                       category: category,
//                     ),
//               ),
//             );
//           } else if (state is InterviewError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Theme.of(context).colorScheme.error,
//               ),
//             );
//           }
//         },
//         child: BlocBuilder<McqSetupBloc, McqSetupState>(
//           builder: (context, setupState) {
//             return BlocBuilder<McqInterviewBloc, McqInterviewState>(
//               builder: (context, interviewState) {
//                 return SingleChildScrollView(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(20),
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                               colors: [
//                                 Theme.of(
//                                   context,
//                                 ).colorScheme.primary.withOpacity(0.1),
//                                 Theme.of(
//                                   context,
//                                 ).colorScheme.secondary.withOpacity(0.05),
//                               ],
//                             ),
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(
//                               color: Theme.of(
//                                 context,
//                               ).colorScheme.outline.withOpacity(0.2),
//                             ),
//                           ),
//                           child: Column(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color: Theme.of(
//                                     context,
//                                   ).colorScheme.primary.withOpacity(0.1),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Icon(
//                                   Icons.quiz_outlined,
//                                   size: 32,
//                                   color: Theme.of(context).colorScheme.primary,
//                                 ),
//                               ),
//                               const SizedBox(height: 12),
//                               Text(
//                                 'Setup Your MCQ Interview',
//                                 style: Theme.of(
//                                   context,
//                                 ).textTheme.headlineSmall?.copyWith(
//                                   color:
//                                       Theme.of(context).colorScheme.onSurface,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                               const SizedBox(height: 6),
//                               Text(
//                                 'Configure your preferences and get started',
//                                 style: Theme.of(
//                                   context,
//                                 ).textTheme.bodySmall?.copyWith(
//                                   color:
//                                       Theme.of(
//                                         context,
//                                       ).colorScheme.onSurfaceVariant,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 24),

//                         _buildSectionTitle('Job Role'),
//                         const SizedBox(height: 8),
//                         TextFormField(
//                           controller: _jobRoleController,
//                           decoration: InputDecoration(
//                             hintText:
//                                 'e.g., Flutter Developer, Software Engineer',
//                             hintStyle: TextStyle(
//                               color: Theme.of(
//                                 context,
//                               ).colorScheme.onSurfaceVariant.withOpacity(0.6),
//                             ),
//                             prefixIcon: Icon(
//                               Icons.work_outline,
//                               color: Theme.of(context).colorScheme.primary,
//                             ),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(
//                                 color: Theme.of(context).colorScheme.outline,
//                               ),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(
//                                 color: Theme.of(context).colorScheme.outline,
//                               ),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(
//                                 color: Theme.of(context).colorScheme.primary,
//                                 width: 2,
//                               ),
//                             ),
//                             filled: true,
//                             fillColor: Theme.of(context).colorScheme.surface,
//                           ),
//                           style: TextStyle(
//                             color: Theme.of(context).colorScheme.onSurface,
//                           ),
//                           onChanged: (value) {
//                             context.read<McqSetupBloc>().add(
//                               UpdateJobRole(value),
//                             );
//                           },
//                           validator: (value) {
//                             if (value == null || value.trim().isEmpty) {
//                               return 'Please enter a job role';
//                             }
//                             return null;
//                           },
//                         ),

//                         const SizedBox(height: 20),

//                         _buildSectionTitle('Difficulty Level'),
//                         const SizedBox(height: 8),
//                         Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(
//                               color: Theme.of(context).colorScheme.outline,
//                             ),
//                             borderRadius: BorderRadius.circular(12),
//                             color: Theme.of(context).colorScheme.surface,
//                           ),
//                           child: DropdownButtonFormField<String>(
//                             value:
//                                 setupState is McqSetupConfiguring
//                                     ? setupState.selectedDifficulty
//                                     : 'easy',
//                             decoration: InputDecoration(
//                               border: InputBorder.none,
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 12,
//                               ),
//                               prefixIcon: Icon(
//                                 Icons.trending_up,
//                                 color: Theme.of(context).colorScheme.primary,
//                               ),
//                             ),
//                             dropdownColor:
//                                 Theme.of(context).colorScheme.surface,
//                             style: TextStyle(
//                               color: Theme.of(context).colorScheme.onSurface,
//                             ),
//                             items:
//                                 _difficulties.map((difficulty) {
//                                   return DropdownMenuItem(
//                                     value: difficulty,
//                                     child: Text(difficulty.toUpperCase()),
//                                   );
//                                 }).toList(),
//                             onChanged: (value) {
//                               if (value != null) {
//                                 context.read<McqSetupBloc>().add(
//                                   UpdateDifficulty(value),
//                                 );
//                               }
//                             },
//                           ),
//                         ),

//                         const SizedBox(height: 20),

//                         _buildSectionTitle('Category'),
//                         const SizedBox(height: 8),
//                         Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(
//                               color: Theme.of(context).colorScheme.outline,
//                             ),
//                             borderRadius: BorderRadius.circular(12),
//                             color: Theme.of(context).colorScheme.surface,
//                           ),
//                           child: DropdownButtonFormField<String>(
//                             value:
//                                 setupState is McqSetupConfiguring
//                                     ? setupState.selectedCategory
//                                     : 'general',
//                             decoration: InputDecoration(
//                               border: InputBorder.none,
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 12,
//                               ),
//                               prefixIcon: Icon(
//                                 Icons.category_outlined,
//                                 color: Theme.of(context).colorScheme.primary,
//                               ),
//                             ),
//                             dropdownColor:
//                                 Theme.of(context).colorScheme.surface,
//                             style: TextStyle(
//                               color: Theme.of(context).colorScheme.onSurface,
//                             ),
//                             items:
//                                 _categories.map((category) {
//                                   return DropdownMenuItem(
//                                     value: category,
//                                     child: Text(category.toUpperCase()),
//                                   );
//                                 }).toList(),
//                             onChanged: (value) {
//                               if (value != null) {
//                                 context.read<McqSetupBloc>().add(
//                                   UpdateCategory(value),
//                                 );
//                               }
//                             },
//                           ),
//                         ),

//                         const SizedBox(height: 20),

//                         _buildSectionTitle('Number of Questions'),
//                         const SizedBox(height: 8),
//                         Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(
//                               color: Theme.of(context).colorScheme.outline,
//                             ),
//                             borderRadius: BorderRadius.circular(12),
//                             color: Theme.of(context).colorScheme.surface,
//                           ),
//                           child: DropdownButtonFormField<int>(
//                             value:
//                                 setupState is McqSetupConfiguring
//                                     ? setupState.selectedQuestions
//                                     : 5,
//                             decoration: InputDecoration(
//                               border: InputBorder.none,
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 12,
//                               ),
//                               prefixIcon: Icon(
//                                 Icons.quiz,
//                                 color: Theme.of(context).colorScheme.primary,
//                               ),
//                             ),
//                             dropdownColor:
//                                 Theme.of(context).colorScheme.surface,
//                             style: TextStyle(
//                               color: Theme.of(context).colorScheme.onSurface,
//                             ),
//                             items:
//                                 _questionCounts.map((count) {
//                                   return DropdownMenuItem(
//                                     value: count,
//                                     child: Text('$count Questions'),
//                                   );
//                                 }).toList(),
//                             onChanged: (value) {
//                               if (value != null) {
//                                 context.read<McqSetupBloc>().add(
//                                   UpdateQuestionCount(value),
//                                 );
//                               }
//                             },
//                           ),
//                         ),

//                         const SizedBox(height: 32),

//                         Container(
//                           height: 50,
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [
//                                 Theme.of(context).colorScheme.primary,
//                                 Theme.of(
//                                   context,
//                                 ).colorScheme.primary.withOpacity(0.8),
//                               ],
//                             ),
//                             borderRadius: BorderRadius.circular(16),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Theme.of(
//                                   context,
//                                 ).colorScheme.primary.withOpacity(0.3),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: ElevatedButton(
//                             onPressed:
//                                 interviewState is InterviewLoading
//                                     ? null
//                                     : _startInterview,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.transparent,
//                               foregroundColor:
//                                   Theme.of(context).colorScheme.onPrimary,
//                               shadowColor: Colors.transparent,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                             ),
//                             child:
//                                 interviewState is InterviewLoading
//                                     ? SizedBox(
//                                       height: 20,
//                                       width: 20,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                         valueColor:
//                                             AlwaysStoppedAnimation<Color>(
//                                               Theme.of(
//                                                 context,
//                                               ).colorScheme.onPrimary,
//                                             ),
//                                       ),
//                                     )
//                                     : Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         const Icon(Icons.play_arrow, size: 20),
//                                         const SizedBox(width: 8),
//                                         Text(
//                                           'Start MCQ Interview',
//                                           style: Theme.of(
//                                             context,
//                                           ).textTheme.labelLarge?.copyWith(
//                                             color:
//                                                 Theme.of(
//                                                   context,
//                                                 ).colorScheme.onPrimary,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                           ),
//                         ),

//                         const SizedBox(height: 20),

//                         Container(
//                           padding: const EdgeInsets.all(14),
//                           decoration: BoxDecoration(
//                             color: Theme.of(
//                               context,
//                             ).colorScheme.primaryContainer.withOpacity(0.3),
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: Theme.of(
//                                 context,
//                               ).colorScheme.primary.withOpacity(0.2),
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.info_outline,
//                                 color: Theme.of(context).colorScheme.primary,
//                                 size: 18,
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: Text(
//                                   'Ensure stable internet and a quiet environment for best results.',
//                                   style: Theme.of(
//                                     context,
//                                   ).textTheme.bodySmall?.copyWith(
//                                     color:
//                                         Theme.of(
//                                           context,
//                                         ).colorScheme.onSurfaceVariant,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: Theme.of(context).textTheme.labelLarge?.copyWith(
//         color: Theme.of(context).colorScheme.onSurface,
//         fontWeight: FontWeight.w600,
//       ),
//     );
//   }

//   void _startInterview() {
//     if (_formKey.currentState!.validate()) {
//       final setupState = context.read<McqSetupBloc>().state;
//       if (setupState is McqSetupConfiguring) {
//         context.read<McqInterviewBloc>().add(
//           StartInterviewEvent(
//             userId: _userIdController.text,
//             jobRole: _jobRoleController.text.trim(),
//             difficultyLevel: setupState.selectedDifficulty,
//             numQuestions: setupState.selectedQuestions,
//             category: setupState.selectedCategory,
//           ),
//         );
//       }
//     }
//   }
// }
