import 'package:combine24/pages/home/home_bloc.dart';
import 'package:combine24/pages/home/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeSideEffectsListener extends StatelessWidget {
  final Widget child;

  const HomeSideEffectsListener({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        // Handle side effects here
      },
      child: child,
    );
  }
}
