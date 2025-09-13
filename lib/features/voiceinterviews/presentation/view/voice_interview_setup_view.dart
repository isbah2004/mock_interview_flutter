import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_config.dart';
import 'voice_interview_view.dart';
import 'package:get_it/get_it.dart';
import 'package:mock_interview/core/cubits/usercubit/user_cubit.dart';
import '../bloc/voice_interview_bloc.dart';
import '../bloc/voice_interview_event.dart';
import '../bloc/voice_interview_state.dart';

class VoiceInterviewSetupView extends StatelessWidget {
  const VoiceInterviewSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _VoiceInterviewSetupContent();
  }
}

class _VoiceInterviewSetupContent extends StatefulWidget {
  const _VoiceInterviewSetupContent();

  @override
  State<_VoiceInterviewSetupContent> createState() =>
      _VoiceInterviewSetupContentState();
}

class _VoiceInterviewSetupContentState
    extends State<_VoiceInterviewSetupContent> {
  final _formKey = GlobalKey<FormState>();
  final _jobRoleController = TextEditingController();

  String _selectedDifficulty = 'medium';
  String _selectedCategory = 'general';
  int _selectedQuestions = 5;

  final List<String> _difficulties = ['easy', 'medium', 'hard'];
  final List<String> _categories = ['general', 'technical', 'behavioral'];
  final List<int> _questionCounts = [3, 5, 7, 10];

  @override
  void dispose() {
    _jobRoleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Voice Interview Setup',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocListener<VoiceInterviewBloc, VoiceInterviewState>(
        listener: (context, state) {
          if (state is VoiceInterviewSetupReady) {
            // Dispatch InitializeInterview on the existing bloc instance so the
            // same instance is reused by the interview view. This keeps state
            // and resources consistent (TTS, listeners, etc.).
            final bloc = context.read<VoiceInterviewBloc>();
            final userId =
                GetIt.instance<UserCubit>().currentUser?.id ?? 'anonymous_user';
            bloc.add(InitializeInterview(config: state.config, userId: userId));

            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        BlocProvider.value(
                          value: bloc,
                          child: VoiceInterviewScreen(sessionId: userId),
                        ),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          } else if (state is VoiceInterviewError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: BlocBuilder<VoiceInterviewBloc, VoiceInterviewState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),

                    _buildCard(
                      'Personal Information',
                      Icons.person_outline,
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _jobRoleController,
                            decoration: InputDecoration(
                              labelText: 'Job Role',
                              hintText:
                                  'e.g., Software Engineer, Data Scientist',
                              prefixIcon: Icon(Icons.work_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a job role';
                              }
                              if (value.trim().length < 3) {
                                return 'Job role must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildCard(
                      'Difficulty Level',
                      Icons.trending_up,
                      Column(
                        children: [
                          const SizedBox(height: 12),
                          Row(
                            children:
                                _difficulties.map((difficulty) {
                                  final isSelected =
                                      _selectedDifficulty == difficulty;
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: GestureDetector(
                                        onTap:
                                            () => setState(
                                              () =>
                                                  _selectedDifficulty =
                                                      difficulty,
                                            ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isSelected
                                                    ? Theme.of(
                                                      context,
                                                    ).colorScheme.primary
                                                    : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color:
                                                  isSelected
                                                      ? Theme.of(
                                                        context,
                                                      ).colorScheme.primary
                                                      : Theme.of(
                                                        context,
                                                      ).colorScheme.outline,
                                            ),
                                          ),
                                          child: Text(
                                            difficulty.toUpperCase(),
                                            textAlign: TextAlign.center,
                                            style:
                                                isSelected
                                                    ? Theme.of(context)
                                                        .textTheme
                                                        .labelMedium!
                                                        .copyWith(
                                                          color: Colors.white,
                                                        )
                                                    : Theme.of(
                                                      context,
                                                    ).textTheme.labelMedium,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildCard(
                      'Interview Category',
                      Icons.category_outlined,
                      Column(
                        children: [
                          const SizedBox(height: 12),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            children:
                                _categories.map((category) {
                                  final isSelected =
                                      _selectedCategory == category;
                                  return GestureDetector(
                                    onTap:
                                        () => setState(
                                          () => _selectedCategory = category,
                                        ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                                : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                  : Theme.of(
                                                    context,
                                                  ).colorScheme.outline,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                          category.toUpperCase(),
                                          textAlign: TextAlign.center,
                                          style:
                                              isSelected
                                                  ? Theme.of(context)
                                                      .textTheme
                                                      .labelMedium!
                                                      .copyWith(
                                                        color: Colors.white,
                                                      )
                                                  : Theme.of(
                                                    context,
                                                  ).textTheme.labelMedium,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildCard(
                      'Number of Questions',
                      Icons.quiz_outlined,
                      Column(
                        children: [
                          const SizedBox(height: 12),
                          Row(
                            children:
                                _questionCounts.map((count) {
                                  final isSelected =
                                      _selectedQuestions == count;
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: GestureDetector(
                                        onTap:
                                            () => setState(
                                              () => _selectedQuestions = count,
                                            ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isSelected
                                                    ? Theme.of(
                                                      context,
                                                    ).colorScheme.primary
                                                    : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color:
                                                  isSelected
                                                      ? Theme.of(
                                                        context,
                                                      ).colorScheme.primary
                                                      : Theme.of(
                                                        context,
                                                      ).colorScheme.outline,
                                            ),
                                          ),
                                          child: Text(
                                            '$count',
                                            textAlign: TextAlign.center,
                                            style:
                                                isSelected
                                                    ? Theme.of(context)
                                                        .textTheme
                                                        .labelMedium!
                                                        .copyWith(
                                                          color: Colors.white,
                                                        )
                                                    : Theme.of(
                                                      context,
                                                    ).textTheme.labelMedium,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildCard(
                      'Interview Instructions',
                      Icons.info_outline,
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          ...[
                            'Speak clearly and at a moderate pace',
                            'Ensure you are in a quiet environment',
                            'Allow microphone access when prompted',
                            'Think before you speak - quality over speed',
                            'You can pause between answers if needed',
                          ].map(_buildInstructionItem),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    _buildStartButton(state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, Widget content) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content,
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String instruction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 12),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              instruction,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(VoiceInterviewState state) {
    if (state is VoiceInterviewInitial ||
        state is VoiceInterviewError ||
        (state is! VoiceInterviewSetupConfiguring &&
            state is! VoiceInterviewLoading)) {
      return ElevatedButton(
        onPressed: () => _startInterview(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'Start Voice Interview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    } else if (state is VoiceInterviewSetupConfiguring ||
        state is VoiceInterviewLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _startInterview(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final config = InterviewConfig(
        jobRole: _jobRoleController.text.trim(),
        difficulty:
            _selectedDifficulty == 'easy'
                ? InterviewDifficulty.beginner
                : _selectedDifficulty == 'medium'
                ? InterviewDifficulty.intermediate
                : InterviewDifficulty.advanced,
        category:
            _selectedCategory == 'general'
                ? InterviewCategory.general
                : _selectedCategory == 'behavioral'
                ? InterviewCategory.behavioral
                : _selectedCategory == 'technical'
                ? InterviewCategory.technical
                : InterviewCategory.industrySpecific,
        numberOfQuestions: _selectedQuestions,
      );

      context.read<VoiceInterviewBloc>().add(StartInterviewSetup(config));
    }
  }
}
