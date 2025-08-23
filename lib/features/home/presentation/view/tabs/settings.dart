import 'package:flutter/material.dart';
import 'package:mock_interview/core/constants/app_strings.dart';
import 'package:mock_interview/core/theme/colorpalette/app_colors.dart';
import '../../../../../core/services/settings_manager.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab>
    with TickerProviderStateMixin {
  bool pushNotifications = true;
  bool sound = true;
  bool vibration = false;
  bool darkMode = false;
  bool voiceRecordingQuality = true;
  bool autoSaveRecordings = true;
  bool isLoading = true;
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
    _loadSettings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    try {
      final settings = SettingsManager.getAllSettings();
      setState(() {
        pushNotifications = settings['pushNotifications'];
        sound = settings['sound'];
        vibration = settings['vibration'];
        darkMode = settings['darkMode'];
        voiceRecordingQuality = settings['voiceRecordingQuality'];
        autoSaveRecordings = settings['autoSaveRecordings'];
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      print('Error loading settings: $e');
      setState(() {
        isLoading = false;
      });
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
        case 'vibration':
          await SettingsManager.setVibration(value);
          break;
        case 'darkMode':
          await SettingsManager.setDarkMode(value);
          break;
        case 'voiceRecordingQuality':
          await SettingsManager.setVoiceRecordingQuality(value);
          break;
        case 'autoSaveRecordings':
          await SettingsManager.setAutoSaveRecordings(value);
          break;
      }
    } catch (e) {
      print('Error updating setting $setting: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (isLoading) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.lightGradient,
          ),
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurpleLight),
          ),
        ),
      );
    }

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
            // Enhanced Header
            Container(
              margin: const EdgeInsets.all(24.0),
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.lightGradient,
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryPurpleLight,
                          AppColors.primaryPurpleLight.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    AppStrings.settings,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Notifications
                      _buildEnhancedSettingsCard(
                        context,
                        AppStrings.notifications,
                        Icons.notifications,
                        AppColors.primaryPurpleLight,
                        [
                          _buildEnhancedSwitchTile(
                            context,
                            AppStrings.pushNotifications,
                            AppStrings.receiveInterviewReminders,
                            pushNotifications,
                            (value) {
                              setState(() => pushNotifications = value);
                              _updateSetting('pushNotifications', value);
                            },
                          ),
                          _buildEnhancedSwitchTile(
                            context,
                            AppStrings.sound,
                            AppStrings.notificationSounds,
                            sound,
                            (value) {
                              setState(() => sound = value);
                              _updateSetting('sound', value);
                            },
                          ),
                          _buildEnhancedSwitchTile(
                            context,
                            AppStrings.vibration,
                            AppStrings.vibrateOnNotifications,
                            vibration,
                            (value) {
                              setState(() => vibration = value);
                              _updateSetting('vibration', value);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Appearance
                      _buildEnhancedSettingsCard(
                        context,
                        AppStrings.appearance,
                        Icons.brightness_6,
                        AppColors.darkSecondaryVariant,
                        [
                          _buildEnhancedSwitchTile(
                            context,
                            AppStrings.darkMode,
                            AppStrings.switchToDarkTheme,
                            darkMode,
                            (value) {
                              setState(() => darkMode = value);
                              _updateSetting('darkMode', value);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Audio Settings
                      _buildEnhancedSettingsCard(
                        context,
                        'Audio',
                        Icons.volume_up,
                        AppColors.primaryPurpleLight,
                        [
                          _buildEnhancedSwitchTile(
                            context,
                            AppStrings.voiceRecordingQuality,
                            AppStrings.highQualityRecordings,
                            voiceRecordingQuality,
                            (value) {
                              setState(() => voiceRecordingQuality = value);
                              _updateSetting('voiceRecordingQuality', value);
                            },
                          ),
                          _buildEnhancedSwitchTile(
                            context,
                            AppStrings.autoSaveRecordings,
                            AppStrings.automaticallySaveRecordings,
                            autoSaveRecordings,
                            (value) {
                              setState(() => autoSaveRecordings = value);
                              _updateSetting('autoSaveRecordings', value);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Account & Security
                      _buildEnhancedMenuCard(
                        context,
                        'Privacy & Security',
                        'Manage your account security',
                        Icons.security,
                        AppColors.primaryPurpleLight,
                        () {},
                      ),
                      const SizedBox(height: 16),

                      _buildEnhancedMenuCard(
                        context,
                        'Help & Support',
                        'Get help and contact support',
                        Icons.help_outline,
                        AppColors.primaryPurpleLight,
                        () {},
                      ),
                      const SizedBox(height: 32),

                      // Enhanced Logout Button
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.red.shade400,
                                Colors.red.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  AppStrings.signOut,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedSettingsCard(
    BuildContext context,
    String title,
    IconData icon,
    Color accentColor,
    List<Widget> children,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:AppColors.lightGradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
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
                        accentColor,
                        accentColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.2,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: AppColors.primaryPurpleLight,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: AppColors.darkSecondaryVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMenuCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color accentColor,
    VoidCallback onTap,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:AppColors.lightGradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor,
                      accentColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
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
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: accentColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
