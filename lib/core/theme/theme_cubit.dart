// lib/core/theme/theme_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart'; // For local storage persistence

// This cubit manages the ThemeMode of the application.
class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themeBoxName = 'appSettings';
  static const String _themeKey = 'themeMode';

  // Constructor: Initializes the cubit with the saved theme or system default.
  ThemeCubit() : super(ThemeMode.system) {
    _loadTheme();
  }

  // Loads the saved theme preference from local storage.
  Future<void> _loadTheme() async {
    final box = await Hive.openBox(_themeBoxName);
    final savedTheme = box.get(_themeKey);
    if (savedTheme == 'light') {
      emit(ThemeMode.light);
    } else if (savedTheme == 'dark') {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.system); // Default or if no preference saved
    }
  }

  // Toggles the theme mode between light and dark (or system if currently custom).
  // If no specific theme is set (i.e., currently system), toggles to light/dark based on current system brightness.
  // This method primarily toggles, but relies on UserProfilePage to set and save user preference.
  void toggleTheme() {
    ThemeMode newThemeMode;
    if (state == ThemeMode.light) {
      newThemeMode = ThemeMode.dark;
    } else if (state == ThemeMode.dark) {
      newThemeMode = ThemeMode.light; // Or ThemeMode.system if you want it to cycle
    } else { // Currently ThemeMode.system or initial
      // When system is active, toggle to light or dark.
      // We'll set it to light for consistency when toggling from system.
      // UserProfilePage will explicitly set the theme.
      newThemeMode = ThemeMode.light;
    }
    emit(newThemeMode);
    _saveTheme(newThemeMode); // Save the toggled state locally
  }

  // Sets a specific theme mode and saves it.
  Future<void> setTheme(bool isDarkMode) async {
    final newThemeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    if (state != newThemeMode) {
      emit(newThemeMode);
      await _saveTheme(newThemeMode);
    }
  }

  // Saves the theme preference to local storage.
  Future<void> _saveTheme(ThemeMode themeMode) async {
    final box = await Hive.openBox(_themeBoxName);
    await box.put(_themeKey, themeMode.name);
  }
}