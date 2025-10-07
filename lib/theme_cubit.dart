import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit()
      : super(WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.light
            ? _lightTheme
            : _darkTheme) {
    // Notify initial theme state to web page
    _notifyWebThemeChange(state.brightness);
  }

  static final _lightTheme = ThemeData.light().copyWith(
    appBarTheme: const AppBarTheme().copyWith(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData().copyWith(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
  );

  static final _darkTheme = ThemeData.dark().copyWith(
    appBarTheme: const AppBarTheme().copyWith(
      backgroundColor: Colors.amber,
      foregroundColor: Colors.black,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData().copyWith(
      backgroundColor: Colors.amber,
      foregroundColor: Colors.black,
    ),
  );

  void toggleTheme() {
    final newTheme = state.brightness == Brightness.light ? _darkTheme : _lightTheme;
    emit(newTheme);

    // Notify web page of theme change for consistent browser theming
    _notifyWebThemeChange(newTheme.brightness);
  }

  void _notifyWebThemeChange(Brightness brightness) {
    try {
      // Use JavaScript interop to notify the web page of theme changes
      web.window.postMessage(
        {
          'type': 'theme-change',
          'theme': brightness == Brightness.dark ? 'dark' : 'light'
        }.jsify(),
        '*'.toJS,
      );
    } catch (e) {
      // Silently fail if not running in web context
    }
  }
}
