import 'package:flutter/material.dart';
import 'package:mock_interview/core/theme/colorpalette/app_colors.dart';
import 'package:mock_interview/features/home/presentation/widgets/gradient_background.dart';
import 'package:mock_interview/features/home/presentation/widgets/history_header.dart';
import 'package:mock_interview/features/home/presentation/widgets/history_interview_list.dart';
import '../../../../../core/services/session_manager.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab>
    with TickerProviderStateMixin {
  bool isLoading = false;
  List<Map<String, dynamic>> interviewHistory = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      const String currentUserId = 'current_user_id';
      final sessions = await SessionManager.getUserSessions(currentUserId);
      final historyList = sessions.map((session) {
        return SessionManager.sessionToDisplayFormat(session);
      }).toList();

      if (!mounted) return;
      setState(() {
        interviewHistory = historyList;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      print('Error loading history: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            // Enhanced Header
            const HistoryHeader(),

            // Content
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurpleLight),
                      ),
                    )
                  : interviewHistory.isEmpty
                      ? _buildEnhancedEmptyState()
                      : FadeTransition(
                          opacity: _fadeAnimation,
                          child: HistoryInterviewList(
                            interviewHistory: interviewHistory,
                          ),
                        ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedEmptyState() {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.lightGradient
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurpleLight.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryPurpleLight.withOpacity(0.2),
                    AppColors.primaryPurpleLight.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.history,
                size: 40,
                color: AppColors.primaryPurpleLight,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No interview history yet',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Complete your first interview to see it here',
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loadHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurpleLight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Refresh',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
