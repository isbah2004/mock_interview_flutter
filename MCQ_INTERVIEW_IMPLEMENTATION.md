# MCQ Interview System - Clean Architecture Implementation

This is a complete implementation of the MCQ Interview System following Clean Architecture principles, SOLID design patterns, and using BLoC for state management.

## 🏗️ Architecture Overview

The implementation follows Clean Architecture with these layers:

```
lib/features/interviews/
├── domain/
│   ├── entities/
│   │   ├── interview.dart
│   │   ├── question.dart
│   │   └── evaluation_result.dart
│   ├── repositories/
│   │   └── interview_repository.dart
│   └── usecases/
│       ├── start_interview.dart
│       ├── submit_answers.dart
│       ├── get_session_stats.dart
│       └── delete_session.dart
├── data/
│   ├── models/
│   │   ├── interview_model.dart
│   │   ├── question_model.dart
│   │   └── evaluation_result_model.dart
│   ├── datasources/
│   │   └── interview_remote_datasource.dart
│   └── repositories/
│       └── interview_repository_impl.dart
└── presentation/
    ├── bloc/
    │   └── mcq/
    │       ├── mcq_interview_bloc.dart
    │       ├── mcq_interview_event.dart
    │       └── mcq_interview_state.dart
    ├── pages/
    │   └── interview_config_page.dart
    ├── view/
    │   ├── mcq_interview_view_new.dart
    │   └── mcq_result_view.dart
    └── widgets/
        ├── question_card.dart
        └── progress_indicator.dart
```

## 🚀 Features Implemented

### ✅ Interview Configuration

- Job role input
- Difficulty level selection (Easy, Medium, Hard)
- Number of questions (5, 10, 15, 20)
- Category selection (Technical, Behavioral, General, Industry Specific)
- Time per question (15s, 30s, 45s, 60s)

### ✅ Interview Experience

- Real-time progress tracking
- Timer countdown per question
- Question navigation (Previous/Next)
- Answer selection with visual feedback
- Auto-submit on timeout
- Exit confirmation dialog

### ✅ Results & Analytics

- Comprehensive score display
- Percentage calculation
- Pass/Fail status
- Question-by-question review
- Detailed explanations
- Performance statistics

### ✅ Clean Architecture Components

- **Entities**: Core business objects (Interview, Question, EvaluationResult)
- **Use Cases**: Business logic (StartInterview, SubmitAnswers)
- **Repository Pattern**: Data abstraction layer
- **BLoC Pattern**: State management
- **Dependency Injection**: Using GetIt service locator

## 📱 Presentation Layer Components

### 1. Interview Configuration Page

```dart
InterviewConfigPage()
```

- Beautiful UI with cards and chips
- Form validation
- User authentication check
- Customizable interview settings

### 2. MCQ Interview Screen

```dart
MCQInterviewScreen()
```

- Timer-based questions
- Progress indicator
- Question card with options
- Navigation controls
- Real-time state management

### 3. Results Screen

```dart
InterviewResultScreen()
```

- Animated score display
- Detailed question review
- Performance analytics
- Action buttons (Try Again, Home)

### 4. Reusable Widgets

#### Question Card

```dart
QuestionCard(
  question: question,
  selectedAnswer: selectedAnswer,
  onAnswerSelected: (answer) => {...},
  questionNumber: 1,
  totalQuestions: 10,
)
```

#### Progress Indicator

```dart
InterviewProgressIndicator(
  current: 5,
  total: 10,
  progress: 0.5,
  timeRemaining: Duration(seconds: 30),
)
```

## 🔧 Usage Instructions

### 1. Add to your main.dart

```dart
import 'package:mock_interview/features/interviews/presentation/mcq_interview_demo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies(); // Initialize dependency injection
  runApp(const MCQInterviewDemo());
}
```

### 2. Or integrate into existing app

```dart
// Navigate to interview configuration
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BlocProvider(
      create: (context) => serviceLocator<InterviewBloc>(),
      child: const InterviewConfigPage(),
    ),
  ),
);
```

### 3. Customize the experience

```dart
MCQInterviewScreen(
  jobRole: 'Software Engineer',
  difficulty: 'medium',
  category: 'technical',
  numberOfQuestions: 10,
  timePerQuestion: 30,
)
```

## 🛠️ Dependencies Required

The following dependencies are already included in the project:

- `flutter_bloc` - State management
- `equatable` - Value equality
- `get_it` - Dependency injection
- `dio` - HTTP requests
- `supabase_flutter` - Backend integration

## 🎯 API Integration

The system integrates with the MCQ Interview API endpoints:

- `POST /api/v1/start_interview` - Start new interview session
- `POST /api/v1/submit_answer` - Submit answers and get evaluation
- `GET /api/v1/session_stats/{session_id}` - Get session statistics
- `DELETE /api/v1/session/{session_id}` - Delete session

## 🎨 UI/UX Features

### Design System

- Modern card-based layout
- Consistent color scheme
- Responsive design
- Smooth animations
- Material Design 3 principles

### User Experience

- Intuitive navigation
- Clear progress indication
- Immediate feedback
- Error handling
- Loading states

### Accessibility

- Screen reader support
- High contrast colors
- Touch-friendly targets
- Keyboard navigation

## 🔄 State Management

The BLoC pattern manages these states:

```dart
abstract class InterviewState {
  InterviewInitial()     // Initial state
  InterviewLoading()     // Loading interview
  InterviewStarted()     // Active interview
  InterviewCompleted()   // Results available
  InterviewError()       // Error occurred
}
```

### Events handled:

- `StartInterviewEvent` - Begin interview
- `SelectAnswerEvent` - Answer selection
- `NextQuestionEvent` - Navigate forward
- `PreviousQuestionEvent` - Navigate backward
- `SubmitInterviewEvent` - Submit final answers

## 🧪 Testing Support

The clean architecture enables easy testing:

```dart
// Unit test use cases
testWidgets('should start interview successfully', (tester) async {
  // Given
  final useCase = MockStartInterview();
  final bloc = InterviewBloc(startInterviewUseCase: useCase, ...);

  // When
  bloc.add(StartInterviewEvent(...));

  // Then
  expect(bloc.state, isA<InterviewStarted>());
});
```

## 📊 Performance Considerations

- Lazy loading of questions
- Memory-efficient state management
- Optimized rebuild cycles
- Image caching for media questions
- Background processing for API calls

## 🔐 Security Features

- User authentication checks
- Session validation
- Input sanitization
- Secure API communication
- Data encryption in transit

## 🚀 Future Enhancements

### Ready for extension:

- Voice-based interviews
- Image/video questions
- Real-time collaboration
- Advanced analytics
- Machine learning insights
- Offline capability
- Multi-language support

## 📝 Code Quality

The implementation follows:

- SOLID principles
- Clean Architecture
- DRY (Don't Repeat Yourself)
- KISS (Keep It Simple, Stupid)
- Comprehensive error handling
- Proper separation of concerns

## 🎉 Getting Started

1. Ensure all dependencies are installed
2. Initialize dependency injection in your app
3. Add the demo screen to your navigation
4. Configure API endpoints
5. Start interviewing!

```dart
// Quick start example
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => serviceLocator<InterviewBloc>(),
        child: const InterviewConfigPage(),
      ),
    );
  }
}
```

The MCQ Interview System is now ready for production use with a clean, maintainable, and scalable architecture! 🎯
