import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit()
      : super(SchedulerBinding.instance!.window.platformBrightness ==
                Brightness.light
            ? _lightTheme
            : _darkTheme);

  static final _lightTheme = ThemeData.light().copyWith();

  static final _darkTheme = ThemeData.dark().copyWith(
    appBarTheme: const AppBarTheme().copyWith(
      backgroundColor: Colors.black12,
      foregroundColor: Colors.yellow[400],
    ),
  );

  void toggleTheme() {
    emit(state.brightness == Brightness.light ? _darkTheme : _lightTheme);
  }
}
