// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mock_interview/core/di/injection_container.dart';
// import 'package:mock_interview/features/interviews/presentation/bloc/mcq/mcq_interview_bloc.dart';
// import 'package:mock_interview/features/interviews/presentation/pages/interview_config_page.dart';

// class MCQInterviewDemo extends StatelessWidget {
//   const MCQInterviewDemo({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'MCQ Interview Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: BlocProvider(
//         create: (context) => serviceLocator<InterviewBloc>(),
//         child: const InterviewConfigPage(),
//       ),
//     );
//   }
// }

// // You can use this in your main.dart or as a separate demo screen
// class MCQInterviewDemoScreen extends StatelessWidget {
//   const MCQInterviewDemoScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('MCQ Interview System'),
//         backgroundColor: Theme.of(context).primaryColor,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.quiz, size: 64, color: Theme.of(context).primaryColor),
//             const SizedBox(height: 24),
//             const Text(
//               'MCQ Interview System',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Practice with customizable MCQ interviews',
//               style: TextStyle(fontSize: 16, color: Colors.grey),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 32),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder:
//                         (context) => BlocProvider(
//                           create: (context) => serviceLocator<InterviewBloc>(),
//                           child: const InterviewConfigPage(),
//                         ),
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 32,
//                   vertical: 16,
//                 ),
//                 backgroundColor: Theme.of(context).primaryColor,
//               ),
//               child: const Text(
//                 'Start MCQ Interview',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
