import 'package:combine24/config/const.dart';
import 'package:combine24/pages/home/home_bloc.dart';
import 'package:combine24/pages/home/home_event.dart';
import 'package:combine24/pages/home/home_state.dart';
import 'package:combine24/pages/home/listeners/home_side_effects_listener.dart';
import 'package:combine24/pages/home/widgets/home_app_bar.dart';
import 'package:combine24/pages/home/widgets/home_hand_section.dart';
import 'package:combine24/pages/home/widgets/home_solution_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final FocusNode formulaFocusNode;
  late final FocusNode cardFocusNode;
  late final ValueNotifier<String> formulaKeyboardNotifier;
  late final ValueNotifier<String> cardKeyboardNotifier;

  @override
  void initState() {
    super.initState();
    formulaFocusNode = FocusNode();
    cardFocusNode = FocusNode();
    formulaKeyboardNotifier = ValueNotifier<String>(Const.emptyString);
    cardKeyboardNotifier = ValueNotifier<String>(Const.emptyString);
  }

  @override
  void dispose() {
    formulaFocusNode.dispose();
    cardFocusNode.dispose();
    formulaKeyboardNotifier.dispose();
    cardKeyboardNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HomeSideEffectsListener(
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () {
              final homeBloc = context.read<HomeBloc>();
              return Future.delayed(
                const Duration(seconds: Const.refreshDelay),
                () => homeBloc.add(HomeResetEvent()),
              );
            },
            child: Scaffold(
              appBar: const HomeAppBar(),
              body: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(Const.edgeInsets),
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    HomeHandSection(
                      cardFocusNode: cardFocusNode,
                      cardKeyboardNotifier: cardKeyboardNotifier,
                      formulaKeyboardNotifier: formulaKeyboardNotifier,
                    ),
                    const Divider(),
                    HomeSolutionSection(
                      state: state,
                      formulaFocusNode: formulaFocusNode,
                      formulaKeyboardNotifier: formulaKeyboardNotifier,
                      cardList: state.cardList,
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  formulaKeyboardNotifier.value = Const.emptyString;
                  cardKeyboardNotifier.value = Const.emptyString;
                  context.read<HomeBloc>().add(HomeRandomDrawEvent());
                },
                tooltip: Const.randomDrawTooltip,
                child: const Icon(Icons.quiz_rounded),
              ),
            ),
          );
        },
      ),
    );
  }

}
