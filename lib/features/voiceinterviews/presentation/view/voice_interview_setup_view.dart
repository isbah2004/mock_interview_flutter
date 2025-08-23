import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/theme/colorpalette/app_colors.dart';
import 'package:mock_interview/core/theme/fontstyle/light_text_theme.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_config.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/bloc/interview_setup/interview_setup_bloc.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/bloc/interview_setup/interview_setup_event.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/bloc/interview_setup/interview_setup_state.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/view/voice_interview_view.dart';

class VoiceInterviewSetupView extends StatefulWidget {
  const VoiceInterviewSetupView({super.key});

  @override
  State<VoiceInterviewSetupView> createState() =>
      _VoiceInterviewSetupViewState();
}

class _VoiceInterviewSetupViewState extends State<VoiceInterviewSetupView>
    with TickerProviderStateMixin {
  final TextEditingController _jobRoleController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _jobRoleController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              // AppColors.primaryOverlay,
              AppColors.lightBackground,
              AppColors.lightSurface,
            ],
          ),
        ),
        child: SafeArea(
          child: BlocListener<InterviewSetupBloc, InterviewSetupState>(
            listener: (context, state) {
              if (state is InterviewSetupReady) {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            VoiceInterviewView(config: state.config),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
                  ),
                );
              }
            },
            child: BlocBuilder<InterviewSetupBloc, InterviewSetupState>(
              builder: (context, state) {
                final config =
                    state is InterviewSetupConfiguring
                        ? state.config
                        : const InterviewConfig(
                          jobRole: '',
                          category: InterviewCategory.general,
                          difficulty: InterviewDifficulty.intermediate,
                          numberOfQuestions: 5,
                        );
                final isValid =
                    state is InterviewSetupConfiguring ? state.isValid : false;

                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 120,
                      floating: false,
                      pinned: false,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.lightSurface.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          'Voice Interview Setup',
                          style: customTextTheme.headlineSmall?.copyWith(
                            color: AppColors.primaryPurple,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        centerTitle: true,
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(24.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: _buildHeaderCard(),
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildJobRoleField(),
                          const SizedBox(height: 24),
                          _buildCategoryField(config),
                          const SizedBox(height: 24),
                          _buildDifficultyField(config),
                          const SizedBox(height: 24),
                          _buildQuestionCountField(config),
                          const SizedBox(height: 32),

                          _buildStartButton(isValid),
                        ]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryPurple.withOpacity(0.1),
            AppColors.lightSecondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryPurple.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryPurple, AppColors.primaryPurpleDark],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.mic, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            'Voice Interview',
            style: customTextTheme.headlineLarge?.copyWith(
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Configure your personalized voice interview experience',
            style: customTextTheme.bodyLarge?.copyWith(
              color: AppColors.lightOnSurface,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildJobRoleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Role',
          style: customTextTheme.titleLarge?.copyWith(
            color: AppColors.primaryPurple,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _jobRoleController,
            onChanged: (value) {
              context.read<InterviewSetupBloc>().add(UpdateJobRole(value));
            },
            decoration: InputDecoration(
              hintText: 'Enter job role (e.g., Software Engineer)',
              hintStyle: TextStyle(color: AppColors.lightOnSurface),
              filled: true,
              fillColor: AppColors.lightSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.primaryPurple.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.primaryPurple,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
            style: customTextTheme.bodyLarge?.copyWith(
              color: AppColors.lightOnBackground,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryField(InterviewConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interview Category',
          style: customTextTheme.titleLarge?.copyWith(
            color: AppColors.primaryPurple,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryPurple.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<InterviewCategory>(
              value: config.category,
              onChanged: (value) {
                if (value != null) {
                  context.read<InterviewSetupBloc>().add(UpdateCategory(value));
                }
              },
              items:
                  InterviewCategory.values.map((category) {
                    return DropdownMenuItem<InterviewCategory>(
                      value: category,
                      child: Text(
                        category.displayName,
                        style: customTextTheme.bodyLarge?.copyWith(
                          color: AppColors.lightOnBackground,
                        ),
                      ),
                    );
                  }).toList(),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.primaryPurple,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyField(InterviewConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Difficulty Level',
          style: customTextTheme.titleLarge?.copyWith(
            color: AppColors.primaryPurple,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryPurple.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<InterviewDifficulty>(
              value: config.difficulty,
              onChanged: (value) {
                if (value != null) {
                  context.read<InterviewSetupBloc>().add(
                    UpdateDifficulty(value),
                  );
                }
              },
              items:
                  InterviewDifficulty.values.map((difficulty) {
                    return DropdownMenuItem<InterviewDifficulty>(
                      value: difficulty,
                      child: Text(
                        difficulty.displayName,
                        style: customTextTheme.bodyLarge?.copyWith(
                          color: AppColors.lightOnBackground,
                        ),
                      ),
                    );
                  }).toList(),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.primaryPurple,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCountField(InterviewConfig config) {
    final List<int> questionCounts = [3, 5, 7, 10];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of Questions',
          style: customTextTheme.titleLarge?.copyWith(
            color: AppColors.primaryPurple,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children:
              questionCounts.map((count) {
                final isSelected = config.numberOfQuestions == count;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap:
                          () => context.read<InterviewSetupBloc>().add(
                            UpdateQuestionCount(count),
                          ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient:
                              isSelected
                                  ? LinearGradient(
                                    colors: [
                                      AppColors.primaryPurple,
                                      AppColors.primaryPurpleDark,
                                    ],
                                  )
                                  : null,
                          color: isSelected ? null : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppColors.primaryPurple
                                    : AppColors.primaryPurple.withOpacity(0.2),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: AppColors.primaryPurple
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Text(
                          '$count',
                          style: customTextTheme.titleMedium?.copyWith(
                            color:
                                isSelected
                                    ? Colors.white
                                    : AppColors.primaryPurple,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildStartButton(bool isValid) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient:
            isValid
                ? LinearGradient(
                  colors: [
                    AppColors.primaryPurple,
                    AppColors.primaryPurpleDark,
                  ],
                )
                : null,
        color: isValid ? null : AppColors.lightOnSurface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        boxShadow:
            isValid
                ? [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
                : null,
      ),
      child: ElevatedButton(
        onPressed:
            isValid
                ? () {
                  context.read<InterviewSetupBloc>().add(StartInterview());
                }
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Start Voice Interview',
          style: customTextTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
