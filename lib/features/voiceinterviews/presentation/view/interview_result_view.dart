import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/theme/colorpalette/app_colors.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/bloc/interview_result/interview_result_bloc.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/bloc/interview_result/interview_result_event.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/bloc/interview_result/interview_result_state.dart';
import '../../domain/entities/interview_config.dart';
import '../../domain/entities/interview_session.dart';
import '../../domain/entities/interview_message.dart';
import '../../utils/ai_response_cleaner.dart';

class InterviewResultView extends StatelessWidget {
  final InterviewSession session;
  final InterviewConfig config;

  const InterviewResultView({
    super.key,
    required this.session,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              InterviewResultBloc()
                ..add(StartEvaluation(session: session, config: config)),
      child: _InterviewResultViewContent(session: session, config: config),
    );
  }
}

class _InterviewResultViewContent extends StatefulWidget {
  final InterviewSession session;
  final InterviewConfig config;

  const _InterviewResultViewContent({
    required this.session,
    required this.config,
  });

  @override
  State<_InterviewResultViewContent> createState() =>
      _InterviewResultViewContentState();
}

class _InterviewResultViewContentState
    extends State<_InterviewResultViewContent>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _scoreAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _scoreAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scoreAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InterviewResultBloc, InterviewResultState>(
      listener: (context, state) {
        if (state is InterviewResultEvaluated && !state.shouldAnimateScore) {
          // Trigger score animation after evaluation completes
          _scoreAnimationController.forward();
          // Update the state to show the animation has been triggered
          context.read<InterviewResultBloc>().add(StartScoreAnimation());
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryPurple.withOpacity(0.05),
                AppColors.lightBackground,
                AppColors.lightSecondary.withOpacity(0.03),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildCompactAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: _buildCompactResultHeader(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildCompactScoresSection(),
                        const SizedBox(height: 20),
                        _buildCompactFeedbackSection(),
                        const SizedBox(height: 20),
                        _buildChatTranscriptSection(),
                        const SizedBox(height: 24),
                        _buildCompactActionButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.primaryPurple,
                size: 20,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Interview Results',
              style: TextStyle(
                color: AppColors.primaryPurple,
                fontWeight: FontWeight.w700,
                fontSize: 18, // Reduced from 20
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildCompactResultHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20), // Reduced from 32
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.white.withOpacity(0.9)],
        ),
        borderRadius: BorderRadius.circular(16), // Reduced from 24
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16), // Reduced from 20
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryPurple, AppColors.primaryPurpleDark],
              ),
              borderRadius: BorderRadius.circular(16), // Reduced from 24
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.psychology,
              size: 32, // Reduced from 48
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16), // Reduced from 24
          Text(
            'AI Analysis Complete',
            style: TextStyle(
              fontSize: 20, // Reduced from 28
              fontWeight: FontWeight.bold,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 8), // Reduced from 12
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ), // Reduced padding
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryPurple.withOpacity(0.1),
                  AppColors.primaryPurple.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${widget.config.jobRole} • ${widget.config.category.displayName}',
              style: TextStyle(
                fontSize: 14, // Reduced from 16
                color: AppColors.primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactScoresSection() {
    return BlocBuilder<InterviewResultBloc, InterviewResultState>(
      builder: (context, state) {
        if (state is InterviewResultEvaluating) {
          return _buildLoadingCard(
            title: 'AI Evaluation in Progress',
            subtitle: 'Analyzing your performance...',
            icon: Icons.analytics,
          );
        }

        if (state is InterviewResultError) {
          return _buildErrorCard(state.message);
        }

        if (state is! InterviewResultEvaluated) {
          return const SizedBox.shrink();
        }

        final evaluationResult = state.evaluationResult;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.white.withOpacity(0.95)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.blue.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.auto_graph,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Performance Scores',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                        Text(
                          'Based on comprehensive analysis',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.lightOnSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              AnimatedBuilder(
                animation: _scoreAnimation,
                builder: (context, child) {
                  return Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _getScoreColor(
                              evaluationResult.overallScore,
                            ).withOpacity(0.2),
                            _getScoreColor(
                              evaluationResult.overallScore,
                            ).withOpacity(0.05),
                          ],
                        ),
                        border: Border.all(
                          color: _getScoreColor(evaluationResult.overallScore),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              child: Text(
                                (evaluationResult.overallScore *
                                        _scoreAnimation.value)
                                    .toStringAsFixed(1),
                                key: ValueKey(_scoreAnimation.value),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: _getScoreColor(
                                    evaluationResult.overallScore,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              'Overall',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _getScoreColor(
                                  evaluationResult.overallScore,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Communication & Content Scores
              Row(
                children: [
                  Expanded(
                    child: _buildCompactScoreCard(
                      'Communication',
                      evaluationResult.communicationScore,
                      Icons.record_voice_over,
                      'Clarity & Delivery',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCompactScoreCard(
                      'Content',
                      evaluationResult.contentScore,
                      Icons.lightbulb,
                      'Knowledge & Depth',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompactScoreCard(
    String title,
    double score,
    IconData icon,
    String subtitle,
  ) {
    final color = _getScoreColor(score);

    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12), // Reduced from 20
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(12), // Reduced from 20
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8), // Reduced from 12
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8), // Reduced from 12
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ), // Reduced from 24
              ),
              const SizedBox(height: 8), // Reduced from 12
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14, // Reduced from 16
                ),
              ),
              const SizedBox(height: 2), // Reduced from 4
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.lightOnSurface,
                  fontSize: 10, // Reduced from 12
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6), // Reduced from 8
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  '${(score * _scoreAnimation.value).toStringAsFixed(1)}/10',
                  key: ValueKey('${title}_${_scoreAnimation.value}'),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // Reduced from 20
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8.0) return Colors.green;
    if (score >= 6.0) return Colors.orange;
    return Colors.red;
  }

  Widget _buildCompactFeedbackSection() {
    return BlocBuilder<InterviewResultBloc, InterviewResultState>(
      builder: (context, state) {
        if (state is InterviewResultEvaluating ||
            state is! InterviewResultEvaluated) {
          return const SizedBox.shrink();
        }

        final cleanedFeedback = AIResponseCleaner.cleanAIResponse(
          state.evaluationResult.feedback,
        );

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.white.withOpacity(0.95)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple, Colors.purple.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Feedback',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                        Text(
                          'Personalized insights for improvement',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.lightOnSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  cleanedFeedback.isNotEmpty
                      ? cleanedFeedback
                      : 'No feedback available.',
                  style: TextStyle(
                    color: AppColors.darkDivider,
                    fontSize: 14,
                    height: 1.5,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatTranscriptSection() {
    if (widget.session.messages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.white.withOpacity(0.95)],
        ),
        borderRadius: BorderRadius.circular(16), // Reduced from 24
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16), // Reduced from 24
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8), // Reduced from 12
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal, Colors.teal.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.chat,
                    color: Colors.white,
                    size: 20,
                  ), // Changed icon and reduced size
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Interview Conversation',
                        style: TextStyle(
                          fontSize: 18, // Reduced from 22
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      Text(
                        'Complete conversation record',
                        style: TextStyle(
                          fontSize: 12, // Reduced from 14
                          color: AppColors.lightOnSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            constraints: const BoxConstraints(
              maxHeight: 300,
            ), // Reduced from 400
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                16,
              ), // Reduced padding
              itemCount: widget.session.messages.length,
              separatorBuilder:
                  (context, index) =>
                      const SizedBox(height: 8), // Reduced from 16
              itemBuilder: (context, index) {
                final message = widget.session.messages[index];
                final isUser = message.type == MessageType.user;

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ), // Reduced padding
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            isUser
                                ? [
                                  AppColors.primaryPurple,
                                  AppColors.primaryPurple.withOpacity(0.8),
                                ]
                                : [Colors.grey.shade100, Colors.grey.shade50],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft:
                            isUser
                                ? const Radius.circular(16)
                                : const Radius.circular(4),
                        bottomRight:
                            isUser
                                ? const Radius.circular(4)
                                : const Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isUser
                                  ? AppColors.primaryPurple
                                  : Colors.grey)
                              .withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isUser ? Icons.person : Icons.smart_toy,
                              color:
                                  isUser ? Colors.white : Colors.grey.shade600,
                              size: 14, // Reduced from 16
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isUser ? 'You' : 'AI',
                              style: TextStyle(
                                color:
                                    isUser
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 12, // Reduced from 14
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTimestamp(message.timestamp),
                              style: TextStyle(
                                color:
                                    isUser
                                        ? Colors.white70
                                        : AppColors.lightOnSurface,
                                fontSize: 10, // Reduced from 12
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6), // Reduced from 12
                        Text(
                          message.content,
                          style: TextStyle(
                            color:
                                isUser ? Colors.white : AppColors.darkDivider,
                            fontSize: 13, // Reduced from 14
                            height: 1.4, // Reduced from 1.5
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(24), // Reduced from 32
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white.withOpacity(0.95)],
        ),
        borderRadius: BorderRadius.circular(16), // Reduced from 24
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12), // Reduced from 16
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryPurple, AppColors.primaryPurpleDark],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 24), // Reduced from 32
          ),
          const SizedBox(height: 16), // Reduced from 20
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
          ),
          const SizedBox(height: 16), // Reduced from 20
          Text(
            title,
            style: TextStyle(
              fontSize: 18, // Reduced from 20
              fontWeight: FontWeight.bold,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 6), // Reduced from 8
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12, // Reduced from 14
              color: AppColors.lightOnSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white.withOpacity(0.95)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 36, color: Colors.red),
          const SizedBox(height: 12),
          Text(
            'Evaluation Error',
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: TextStyle(color: AppColors.lightOnSurface, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<InterviewResultBloc>().add(
                RetryEvaluation(session: widget.session, config: widget.config),
              );
            },
            icon: Icon(Icons.refresh, color: Colors.white),
            label: Text(
              'Retry Evaluation',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48, // Reduced from 56
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryPurple),
              borderRadius: BorderRadius.circular(12), // Reduced from 16
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: Icon(
                Icons.home,
                color: AppColors.primaryPurple,
                size: 18,
              ), // Reduced icon size
              label: Text(
                'Back to Home',
                style: TextStyle(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w600,
                  fontSize: 14, // Added explicit font size
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12), // Reduced from 16
        Expanded(
          child: Container(
            height: 48, // Reduced from 56
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryPurple, AppColors.primaryPurpleDark],
              ),
              borderRadius: BorderRadius.circular(12), // Reduced from 16
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.3),
                  blurRadius: 8, // Reduced from 12
                  offset: const Offset(0, 3), // Reduced from 4
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
                size: 18,
              ), // Reduced icon size
              label: const Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14, // Added explicit font size
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
