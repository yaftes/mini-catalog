import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(newMode);

    final settingsBox = Hive.box('settings');
    await settingsBox.put('isDark', newMode == ThemeMode.dark);
  }

  void _loadTheme() {
    final settingsBox = Hive.box('settings');
    final isDark = settingsBox.get('isDark', defaultValue: false);
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
