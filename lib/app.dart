import 'package:combine24/config/const.dart';
import 'package:combine24/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:combine24/theme_cubit.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeData>(
        builder: (_, theme) {
          return MaterialApp(
            title: Const.title,
            theme: theme,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
