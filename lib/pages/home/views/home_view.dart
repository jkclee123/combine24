import 'dart:math';

import 'package:combine24/pages/home/views/formula_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:combine24/config/const.dart';
import 'package:combine24/pages/home/home_bloc.dart';
import 'package:combine24/pages/home/home_event.dart';
import 'package:combine24/pages/home/home_state.dart';
import 'package:combine24/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final FocusNode focusNode;
  late final ValueNotifier<String> customNotifier;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    customNotifier = ValueNotifier<String>(Const.emptyString);
    customNotifier.addListener(() => onSubmit());
  }

  void onSubmit() {
    if (customNotifier.value.contains(KeyboardConst.eof)) {
      String answer =
          customNotifier.value.replaceAll(KeyboardConst.eof, Const.emptyString);
      BlocProvider.of<HomeBloc>(context).add(HomeSubmitEvent(answer: answer));
      focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<HomeBloc>(context).add(HomeTestEvent());
    return BlocBuilder<HomeBloc, HomeState>(builder: (_, state) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: (() => Future.delayed(
                const Duration(seconds: Const.refreshDelay),
                () =>
                    BlocProvider.of<HomeBloc>(context).add(HomeResetEvent()))),
            child: ListView(
              padding: const EdgeInsets.all(Const.edgeInsets),
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              children: <Widget>[
                _buildHandView(context),
                const Divider(),
                _buildSolutionView(context),
              ],
            ),
          ),
        ),
      );
    });
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    List<String> cardList = BlocProvider.of<HomeBloc>(context).state.cardList;
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      actions: [
        KeyboardActionsItem(
          focusNode: focusNode,
          displayActionBar: false,
          footerBuilder: (context) => FormulaKeyboard(
              focusNode: focusNode,
              notifier: customNotifier,
              cardList: cardList),
        ),
      ],
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: GestureDetector(
          onTap: () => BlocProvider.of<HomeBloc>(context).add(HomeResetEvent()),
          child: const Text(AppBarConst.title)),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          icon: Theme.of(context).brightness == Brightness.light
              ? const Icon(Icons.dark_mode_outlined)
              : const Icon(Icons.light_mode_outlined),
          tooltip: Theme.of(context).brightness == Brightness.light
              ? AppBarConst.dartModeTooltip
              : AppBarConst.lightModeTooltip,
        ),
        IconButton(
          onPressed: () =>
              BlocProvider.of<HomeBloc>(context).add(HomeRandomDrawEvent()),
          icon: const Icon(Icons.copy_rounded),
          tooltip: AppBarConst.randomDrawTooltip,
        ),
      ],
    );
  }

  Widget _buildHandView(BuildContext context) {
    HomeState state = BlocProvider.of<HomeBloc>(context).state;
    double width = MediaQuery.of(context).size.width;
    return ResponsiveGridList(
      desiredItemWidth: min(width * HandConst.desiredItemWidthWeight,
          HandConst.minDesiredItemWidth),
      squareCells: true,
      scroll: false,
      minSpacing: width * HandConst.minSpacingWeight,
      rowMainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int index = 0; index < 4; index++)
          Card(
            elevation: Const.elevation,
            child: FittedBox(
              child: Padding(
                padding: const EdgeInsets.all(HandConst.edgeInsets),
                child: Text(state.cardList.length > index
                    ? state.cardList[index]
                    : Const.emptyString),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSolutionView(BuildContext context) {
    HomeState state = BlocProvider.of<HomeBloc>(context).state;
    if (state is HomeLoadingState) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is HomeErrorState) {
      return const Center(
        child: Text(ErrorConst.errorMsg),
      );
    } else if (state is HomeSolutionState) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _buildSolutionColumnView(context),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  List<Widget> _buildSolutionColumnView(
    BuildContext context,
  ) {
    HomeSolutionState state =
        context.watch<HomeBloc>().state as HomeSolutionState;
    List<String> solutionList = state.solutionList;
    List<String> hintList = state.hintList;
    List<bool> solutionMaskList = state.solutionMaskList;
    List<bool> hintMaskList = state.hintMaskList;
    int solutionLength = solutionList.length;
    double width = MediaQuery.of(context).size.width;
    return [
      SizedBox(
        width: width * SolutionConst.widthWeight + SolutionConst.widthBias,
        height: SolutionConst.answerHeight,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SolutionConst.borderRadius),
          ),
          elevation: Const.elevation,
          child: Center(
            child: KeyboardActions(
              autoScroll: false,
              tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
              isDialog: false,
              config: _buildConfig(context),
              child: KeyboardCustomInput<String>(
                  focusNode: focusNode,
                  notifier: customNotifier,
                  builder: (context, val, hasFocus) {
                    if (hasFocus != null && !hasFocus) {
                      val = Const.emptyString;
                      customNotifier.value = Const.emptyString;
                    }
                    return Center(
                      child: Opacity(
                        opacity: Const.opacity,
                        child: Text(
                          val.isEmpty ? SolutionConst.answerPlaceholder : val,
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ),
      ),
      for (int index = 0; index < solutionLength; index++)
        SizedBox(
          width: width * SolutionConst.widthWeight + SolutionConst.widthBias,
          child: solutionMaskList[index]
              ? Card(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(SolutionConst.borderRadius),
                  ),
                  elevation: Const.elevation,
                  child: ListTile(
                    leading: Opacity(
                      opacity: Const.opacity,
                      child: Text("${index + 1}"),
                    ),
                    title: Center(
                      child: Text(solutionList[index]),
                    ),
                    trailing: const Icon(
                      Icons.check,
                      color: Colors.green,
                    ),
                  ),
                )
              : Card(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(SolutionConst.borderRadius),
                  ),
                  elevation: Const.elevation,
                  child: hintMaskList[index]
                      ? ListTile(
                          leading: Opacity(
                            opacity: Const.opacity,
                            child: Text("${index + 1}"),
                          ),
                          title: Center(
                            child: Text(hintList[index]),
                          ),
                          trailing: const IconButton(
                            icon: Icon(
                              Icons.lightbulb_outline_rounded,
                            ),
                            onPressed: null,
                          ),
                        )
                      : ListTile(
                          leading: Opacity(
                            opacity: 0.5,
                            child: Text("${index + 1}"),
                          ),
                          trailing: IconButton(
                            tooltip: SolutionConst.hintTooltip,
                            icon: Icon(
                              Icons.lightbulb_outline_rounded,
                              color: Colors.yellow[600],
                            ),
                            onPressed: (() => BlocProvider.of<HomeBloc>(context)
                                .add(HomeOpenHintEvent(index: index))),
                          ),
                        ),
                ),
        ),
    ];
  }
}
