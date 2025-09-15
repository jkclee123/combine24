import 'package:combine24/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:combine24/app_bloc_observer.dart';

void main() {
  Bloc.observer = AppBlocObserver();
  runApp(const App());
}
