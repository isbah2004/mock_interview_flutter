import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/bloc/mcq_interview_event.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/bloc/mcq_interview_state.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/view/mcq_interview_view.dart';
import '../bloc/mcq_interview_bloc.dart';

class InterviewSetupPage extends StatefulWidget {
  const InterviewSetupPage({super.key});

  @override
  State<InterviewSetupPage> createState() => _InterviewSetupPageState();
}

class _InterviewSetupPageState extends State<InterviewSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _jobRoleController = TextEditingController();
  final _userIdController = TextEditingController(
    text: 'user_123',
  ); // Mock user ID

  String _selectedDifficulty = 'easy';
  String _selectedCategory = 'general';
  int _selectedQuestions = 5;

  final List<String> _difficulties = ['easy', 'medium', 'hard'];
  final List<String> _categories = ['general', 'technical', 'behavioral'];
  final List<int> _questionCounts = [5, 10, 15, 20];

  @override
  void dispose() {
    _jobRoleController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Interview Setup',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 1,
        shadowColor: Colors.grey.withOpacity(0.2),
      ),
      backgroundColor: Colors.white,
      body: BlocListener<McqInterviewBloc, McqInterviewState>(
        listener: (context, state) {
          if (state is InterviewStarted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder:
                    (context) => McqInterviewPage(
                      sessionId: state.sessionId,
                      questions: state.questions,
                    ),
              ),
            );
          } else if (state is InterviewError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<McqInterviewBloc, McqInterviewState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.quiz_outlined,
                            size: 48,
                            color: Colors.black,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Setup Your Interview',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Configure your interview preferences and get started',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Job Role Input
                    _buildSectionTitle('Job Role'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _jobRoleController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Flutter Developer, Software Engineer',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: Icon(
                          Icons.work_outline,
                          color: Colors.grey.shade600,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: const TextStyle(color: Colors.black),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a job role';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Difficulty Level
                    _buildSectionTitle('Difficulty Level'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedDifficulty,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          prefixIcon: Icon(
                            Icons.trending_up,
                            color: Colors.grey,
                          ),
                        ),
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Colors.black),
                        items:
                            _difficulties.map((difficulty) {
                              return DropdownMenuItem(
                                value: difficulty,
                                child: Text(difficulty.toUpperCase()),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDifficulty = value!;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Category
                    _buildSectionTitle('Category'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          prefixIcon: Icon(
                            Icons.category_outlined,
                            color: Colors.grey,
                          ),
                        ),
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Colors.black),
                        items:
                            _categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category.toUpperCase()),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Number of Questions
                    _buildSectionTitle('Number of Questions'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: DropdownButtonFormField<int>(
                        value: _selectedQuestions,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          prefixIcon: Icon(Icons.quiz, color: Colors.grey),
                        ),
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Colors.black),
                        items:
                            _questionCounts.map((count) {
                              return DropdownMenuItem(
                                value: count,
                                child: Text('$count Questions'),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedQuestions = value!;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Start Interview Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                            state is InterviewLoading ? null : _startInterview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child:
                            state is InterviewLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.play_arrow),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Start Interview',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(color: Colors.white),
                                    ),
                                  ],
                                ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Make sure you have a stable internet connection and are in a quiet environment.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.blue.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  void _startInterview() {
    if (_formKey.currentState!.validate()) {
      context.read<McqInterviewBloc>().add(
        StartInterviewEvent(
          userId: _userIdController.text,
          jobRole: _jobRoleController.text.trim(),
          difficultyLevel: _selectedDifficulty,
          numQuestions: _selectedQuestions,
          category: _selectedCategory,
        ),
      );
    }
  }
}
