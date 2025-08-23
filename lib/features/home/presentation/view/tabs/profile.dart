import 'package:flutter/material.dart';
import 'package:mock_interview/core/constants/app_strings.dart';
import 'package:mock_interview/core/theme/colorpalette/app_colors.dart';
import '../../../../../core/services/profile_manager.dart';
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab>
    with TickerProviderStateMixin {
  Map<String, dynamic>? userProfile;
  List<Map<String, dynamic>> achievements = [];
  Map<String, dynamic>? performanceInsights;
  bool isLoading = true;
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
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _loadProfileData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      isLoading = true;
    });

    try {
      const String currentUserId = 'current_user_id';

      final results = await Future.wait([
        ProfileManager.getUserProfile(currentUserId),
        ProfileManager.getUserAchievements(currentUserId),
        ProfileManager.getPerformanceInsights(currentUserId),
      ]);

      setState(() {
        userProfile = results[0] as Map<String, dynamic>;
        achievements = results[1] as List<Map<String, dynamic>>;
        performanceInsights = results[2] as Map<String, dynamic>;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      print('Error loading profile data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          'Profile editing functionality will be implemented here.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: AppColors.primaryPurple),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.lightGradient,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            // Header with floating effect
                            Container(
                              margin: const EdgeInsets.all(24.0),
                              padding: const EdgeInsets.all(24.0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: AppColors.lightGradient
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryPurple.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const SizedBox(width: 36),
                                      Text(
                                        AppStrings.profile,
                                        style: textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: _showEditProfileDialog,
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryPurple.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.edit,
                                            color: AppColors.primaryPurple,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),

                                  // Profile Avatar with glow effect
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: AppColors.lightGradient,
                                      ),
                                      borderRadius: BorderRadius.circular(60),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryPurple.withOpacity(0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 60,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    AppStrings.johnDoe,
                                    style: textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppStrings.johnDoeEmail,
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.lightSecondary,
                                          AppColors.lightSecondary.withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          AppStrings.premiumMember,
                                          style: textTheme.labelMedium?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Stats Cards with enhanced design
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildEnhancedStatCard(
                                          context,
                                          '87',
                                          AppStrings.averageScore,
                                          Icons.emoji_events,
                                          AppColors.primaryPurpleLight,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildEnhancedStatCard(
                                          context,
                                          '15',
                                          AppStrings.interviews,
                                          Icons.track_changes,
                                          AppColors.primaryPurpleLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Enhanced Achievement Card
                                  _buildEnhancedAchievementCard(context),
                                  const SizedBox(height: 24),

                                  // Enhanced Performance Insights
                                  _buildEnhancedPerformanceInsights(context),
                                ],
                              ),
                            ),

                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color gradientColor,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradientColor,
            gradientColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedAchievementCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final recentAchievement = achievements.isNotEmpty ? achievements.first : null;
    final progressToNext = performanceInsights?['progressToMilestone'] ?? 0.0;
    final nextMilestone = performanceInsights?['nextMilestone'] ?? '5 interviews';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.lightGradient
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurpleLight.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.lightSecondary,
                        AppColors.lightSecondary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    recentAchievement?['icon'] ?? Icons.military_tech,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recentAchievement?['title'] ?? 'Next Achievement',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        recentAchievement?['description'] ?? 'Complete your first interview',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.lightSecondaryVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progressToNext.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:AppColors.purpleGradient,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${(progressToNext * 100).round()}% to $nextMilestone',
              style: textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedPerformanceInsights(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final improvementRate = performanceInsights?['improvementRate'] ?? '0.0';
    final currentStreak = performanceInsights?['currentStreak'] ?? 0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.lightGradient
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.improvementTips,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            _buildEnhancedInsightRow(
              context,
              Icons.trending_up,
              'Improvement Rate',
              'Last 30 days',
              '+$improvementRate%',
              'vs previous period',
              AppColors.primaryPurple,
            ),
            const SizedBox(height: 20),
            _buildEnhancedInsightRow(
              context,
              Icons.calendar_today,
              'Streak',
              'Current streak',
              '$currentStreak days',
              currentStreak > 0 ? 'Keep it up!' : 'Start a new streak!',
              AppColors.primaryPurple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedInsightRow(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String value,
    String valueSubtitle,
    Color accentColor,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accentColor,
                accentColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            Text(
              valueSubtitle,
              style: textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
