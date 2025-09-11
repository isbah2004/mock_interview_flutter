import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/services/settings_manager.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(isDarkMode: false)) {
    _loadThemeFromSettings();
  }

  void _loadThemeFromSettings() {
    final settings = SettingsManager.getAllSettings();
    final isDarkMode = settings['darkMode'] ?? false;
    emit(ThemeState(isDarkMode: isDarkMode));
  }

  void toggleTheme() {
    final newDarkMode = !state.isDarkMode;
    _saveThemeToSettings(newDarkMode);
    emit(ThemeState(isDarkMode: newDarkMode));
  }

  void setTheme(bool isDark) {
    _saveThemeToSettings(isDark);
    emit(ThemeState(isDarkMode: isDark));
  }

  void _saveThemeToSettings(bool isDarkMode) {
    SettingsManager.setDarkMode(isDarkMode);
  }
}
