import 'package:flutter/material.dart';
import 'package:mock_interview/core/constants/app_strings.dart';
import '../../../../../core/services/settings_manager.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool pushNotifications = true;
  bool sound = true;
  bool vibration = false;
  bool darkMode = false;
  bool voiceRecordingQuality = true;
  bool autoSaveRecordings = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
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
          // TODO: Update app theme
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (isLoading) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surface.withOpacity(0.8),
              colorScheme.surface,
            ],
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface,
            colorScheme.surface.withOpacity(0.8),
            colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                AppStrings.settings,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Notifications
                    _buildSettingsCard(
                      context,
                      AppStrings.notifications,
                      Icons.notifications,
                      [
                        _buildSwitchTile(
                          context,
                          AppStrings.pushNotifications,
                          AppStrings.receiveInterviewReminders,
                          pushNotifications,
                          (value) {
                            setState(() => pushNotifications = value);
                            _updateSetting('pushNotifications', value);
                          },
                        ),
                        _buildSwitchTile(
                          context,
                          AppStrings.sound,
                          AppStrings.notificationSounds,
                          sound,
                          (value) {
                            setState(() => sound = value);
                            _updateSetting('sound', value);
                          },
                        ),
                        _buildSwitchTile(
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
                    _buildSettingsCard(
                      context,
                      AppStrings.appearance,
                      Icons.brightness_6,
                      [
                        _buildSwitchTile(
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
                    _buildSettingsCard(context, 'Audio', Icons.volume_up, [
                      _buildSwitchTile(
                        context,
                        AppStrings.voiceRecordingQuality,
                        AppStrings.highQualityRecordings,
                        voiceRecordingQuality,
                        (value) {
                          setState(() => voiceRecordingQuality = value);
                          _updateSetting('voiceRecordingQuality', value);
                        },
                      ),
                      _buildSwitchTile(
                        context,
                        AppStrings.autoSaveRecordings,
                        AppStrings.automaticallySaveRecordings,
                        autoSaveRecordings,
                        (value) {
                          setState(() => autoSaveRecordings = value);
                          _updateSetting('autoSaveRecordings', value);
                        },
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // Account & Security
                    _buildMenuCard(
                      context,
                      'Privacy & Security',
                      'Manage your account security',
                      Icons.security,
                      () {
                        // Navigate to security settings
                      },
                    ),
                    const SizedBox(height: 12),

                    _buildMenuCard(
                      context,
                      'Help & Support',
                      'Get help and contact support',
                      Icons.help_outline,
                      () {
                        // Navigate to help
                      },
                    ),
                    const SizedBox(height: 24),

                    // Logout
                    GestureDetector(
                      onTap: () {
                        // Handle logout
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.logout,
                                color: colorScheme.onPrimary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                AppStrings.signOut,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: colorScheme.onPrimary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: colorScheme.primary,
            activeTrackColor: colorScheme.primary.withOpacity(0.5),
            inactiveThumbColor: colorScheme.onSurface.withOpacity(0.3),
            inactiveTrackColor: colorScheme.outline.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: colorScheme.onPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
