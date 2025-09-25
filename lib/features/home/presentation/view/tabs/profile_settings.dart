import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/cubits/usercubit/user_cubit.dart';
import 'package:mock_interview/core/utils/app_logger.dart';
import 'package:mock_interview/core/cubits/theme_cubit/theme_cubit.dart';
import 'package:mock_interview/core/navigation/routes_name.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_event.dart';
import 'package:mock_interview/core/utils/color_compat.dart';
import '../../../../../core/services/profile_manager.dart';
import '../../../../../core/services/settings_manager.dart';

class ProfileSettingsTab extends StatefulWidget {
  const ProfileSettingsTab({super.key});

  @override
  State<ProfileSettingsTab> createState() => _ProfileSettingsTabState();
}

class _ProfileSettingsTabState extends State<ProfileSettingsTab> {
  // Profile data
  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  // Settings data
  bool pushNotifications = true;
  bool sound = true;
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Load profile data
      final userCubit = context.read<UserCubit>();
      final currentUser = userCubit.currentUser;

      if (currentUser != null) {
        final profile = await ProfileManager.getUserProfile(currentUser.id);

        // Load settings
        final settings = SettingsManager.getAllSettings();

        if (mounted) {
          setState(() {
            userProfile = profile;
            pushNotifications = settings['pushNotifications'] ?? true;
            sound = settings['sound'] ?? true;
            darkMode = settings['darkMode'] ?? false;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      AppLogger.error('Error loading data: $e');
      // Try to create missing profile if needed
      final userCubit = context.read<UserCubit>();
      final currentUser = userCubit.currentUser;

      if (currentUser != null && e.toString().contains('document_not_found')) {
        try {
          await ProfileManager.createUserProfile(
            userId: currentUser.id,
            name: currentUser.name,
            email: currentUser.email,
            provider: currentUser.provider.toString(),
          );

          final profile = await ProfileManager.getUserProfile(currentUser.id);

          if (mounted) {
            setState(() {
              userProfile = profile;
              isLoading = false;
            });
          }
        } catch (createError) {
          AppLogger.error('Error creating profile: $createError');
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _updateSetting(String setting, dynamic value) async {
    try {
      switch (setting) {
        case 'pushNotifications':
          await SettingsManager.setPushNotifications(value);
          break;
        case 'sound':
          await SettingsManager.setSound(value);
          break;
        case 'darkMode':
          await SettingsManager.setDarkMode(value);
          // Update the theme cubit for immediate UI change
          if (mounted) {
            final themeCubit = context.read<ThemeCubit>();
            themeCubit.setTheme(value);
          }
          break;
      }
    } catch (e) {
      AppLogger.error('Error updating setting $setting: $e');
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacityCompat(0.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacityCompat(0.6),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Trigger the proper logout flow through AuthBloc
                context.read<AuthBloc>().add(const AuthSignOutRequested());
                // Navigate to login and clear the stack
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacityCompat(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outline.withOpacityCompat(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: colorScheme.primary,
                          child: Text(
                            userProfile?['name']
                                    ?.substring(0, 1)
                                    .toUpperCase() ??
                                'U',
                            style: textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userProfile?['name'] ?? 'User',
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      colorScheme
                                          .onSurface, // Replaced hardcoded Colors.black
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userProfile?['email'] ?? 'user@example.com',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacityCompat(
                                    0.7,
                                  ), // Replaced hardcoded Colors.black.withOpacity(0.7)
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Statistics Section
                  Text(
                    'Statistics',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          colorScheme
                              .onSurface, // Replaced hardcoded Colors.black
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withOpacityCompat(0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Interviews',
                          '${userProfile?['totalInterviews'] ?? 0}',
                          Icons.quiz,
                          colorScheme,
                          textTheme,
                        ),
                        _buildStatItem(
                          'Average Score',
                          '${userProfile?['averageScore'] ?? 0}%',
                          Icons.star,
                          colorScheme,
                          textTheme,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Settings Section
                  Text(
                    'Settings',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          colorScheme
                              .onSurface, // Replaced hardcoded Colors.black
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withOpacityCompat(0.1),
                      ),
                    ),
                    child: _buildSettingTile(
                      'Dark Mode',
                      'Enable dark theme',
                      Icons.dark_mode,
                      themeState
                          .isDarkMode, // Use ThemeCubit state instead of local state
                      (value) {
                        setState(() => darkMode = value);
                        _updateSetting('darkMode', value);
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Actions Section
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withOpacityCompat(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.help_outline,
                            color: colorScheme.primary,
                          ),
                          title: Text(
                            'Help & Support',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                            ), // Replaced hardcoded Colors.black
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: colorScheme.onSurface.withOpacityCompat(
                              0.5,
                            ), // Replaced hardcoded Colors.black.withOpacity(0.5)
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Help & Support'),
                                    content: const Text(
                                      'For support, please contact us at support@mockinterview.com',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.info_outline,
                            color: colorScheme.primary,
                          ),
                          title: Text(
                            'About',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                            ), // Replaced hardcoded Colors.black
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: colorScheme.onSurface.withOpacityCompat(
                              0.5,
                            ), // Replaced hardcoded Colors.black.withOpacity(0.5)
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('About'),
                                    content: const Text(
                                      'Mock Interview App v1.0.0\n\nHelping you prepare for your next interview with AI-powered practice sessions.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.logout, color: colorScheme.error),
                          title: Text(
                            'Logout',
                            style: TextStyle(color: colorScheme.error),
                          ),
                          onTap: _showLogoutDialog,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacityCompat(
              0.7,
            ), // Replaced hardcoded Colors.black.withOpacity(0.7)
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ), // Replaced hardcoded Colors.black
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacityCompat(0.7),
        ), // Replaced hardcoded Colors.black.withOpacity(0.7)
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: Theme.of(context).colorScheme.primary,
    );
  }
}
