import 'dart:math';

import 'package:combine24/pages/home/views/formula_keyboard.dart';
import 'package:combine24/services/impl/default_translate_service.dart';
import 'package:combine24/services/translate_service.dart';
import 'package:flutter/material.dart';
import 'package:combine24/config/const.dart';
import 'package:combine24/pages/home/home_bloc.dart';
import 'package:combine24/pages/home/home_event.dart';
import 'package:combine24/pages/home/home_state.dart';
import 'package:combine24/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:function_tree/function_tree.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final FocusNode focusNode;
  late final ValueNotifier<String> keyboardNotifier;
  late final TextEditingController answerController;
  late final TranslateService translateService;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    keyboardNotifier = ValueNotifier<String>(Const.emptyString);
    answerController = TextEditingController();
    translateService = DefaultTranslateService();
    keyboardNotifier.addListener(() => onAnswerChanged());
  }

  void onAnswerChanged() {
    if (keyboardNotifier.value.contains(FormulaKeyboardConst.eof)) {
      BlocProvider.of<HomeBloc>(context)
          .add(HomeSubmitEvent(answer: keyboardNotifier.value));
      keyboardNotifier.value = Const.emptyString;
      focusNode.unfocus();
    } else {
      answerController.value = TextEditingValue(
        text: keyboardNotifier.value,
        selection: TextSelection.fromPosition(
          TextPosition(offset: keyboardNotifier.value.length),
        ),
      );
    }
  }

  void copyHint2Ans(String hint) {
    keyboardNotifier.value = hint;
  }

  String subTotal(String formula) {
    if (formula.isEmpty) {
      return "= 0";
    }
    try {
      formula = translateService.read2CalFormula(formula);
      if (OpConst.openBracket.allMatches(formula).length == 1 &&
          OpConst.closeBracket.allMatches(formula).isEmpty) {
        formula = formula.replaceAll(OpConst.openBracket, Const.emptyString);
      }
      return "= ${formula.interpret().toStringAsFixed(1)}";
    } catch (e, _) {
      return "= --";
    }
  }

  @override
  Widget build(BuildContext context) {
    // BlocProvider.of<HomeBloc>(context).add(HomeTestEvent());
    return BlocBuilder<HomeBloc, HomeState>(builder: (_, state) {
      return RefreshIndicator(
        onRefresh: () => Future.delayed(
            const Duration(seconds: Const.refreshDelay),
            () => BlocProvider.of<HomeBloc>(context).add(HomeResetEvent())),
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(Const.edgeInsets),
              physics: const AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                _buildHandView(context),
                const Divider(),
                _buildDisplayView(context)
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
              notifier: keyboardNotifier,
              cardList: cardList,
              context: context),
        ),
      ],
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: GestureDetector(
          onTap: () => BlocProvider.of<HomeBloc>(context).add(HomeResetEvent()),
          child: const Text(Const.title)),
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
      desiredItemWidth: min(width * HandViewConst.desiredItemWidthWeight,
          HandViewConst.minDesiredItemWidth),
      squareCells: true,
      scroll: false,
      minSpacing: width * HandViewConst.minSpacingWeight,
      rowMainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int index = 0; index < 4; index++)
          Card(
            elevation: Const.elevation,
            child: FittedBox(
              child: Padding(
                padding: const EdgeInsets.all(HandViewConst.edgeInsets),
                child: Text(state.cardList.length > index
                    ? state.cardList[index]
                    : Const.emptyString),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDisplayView(BuildContext context) {
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
        children: _buildSolutionStateView(context),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildAnswerView(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width * SolutionStateViewConst.widthWeight +
          SolutionStateViewConst.widthBias,
      child: KeyboardActions(
        autoScroll: false,
        tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
        isDialog: false,
        config: _buildConfig(context),
        child: KeyboardCustomInput<String>(
          focusNode: focusNode,
          notifier: keyboardNotifier,
          builder: (context, val, hasFocus) {
            return TextField(
              showCursor: true,
              readOnly: true,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.none,
              controller: answerController,
              decoration: InputDecoration(
                labelText: SolutionStateViewConst.answerLabelText,
                border: const OutlineInputBorder(),
                counterText: subTotal(answerController.text),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSolutionCard(BuildContext context, int index) {
    HomeSolutionState state =
        context.watch<HomeBloc>().state as HomeSolutionState;
    List<String> solutionList = state.solutionList;
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width * SolutionStateViewConst.widthWeight +
          SolutionStateViewConst.widthBias,
      child: Card(
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: Colors.green,
            width: SolutionStateViewConst.borderWidth,
          ),
          borderRadius:
              BorderRadius.circular(SolutionStateViewConst.borderRadius),
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
      ),
    );
  }

  Widget _buildHintCard(BuildContext context, int index) {
    HomeSolutionState state =
        context.watch<HomeBloc>().state as HomeSolutionState;
    List<String> hintList = state.hintList;
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width * SolutionStateViewConst.widthWeight +
          SolutionStateViewConst.widthBias,
      child: GestureDetector(
        onTap: () => copyHint2Ans(hintList[index]),
        child: Card(
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              color: Colors.yellow,
              width: SolutionStateViewConst.borderWidth,
            ),
            borderRadius:
                BorderRadius.circular(SolutionStateViewConst.borderRadius),
          ),
          elevation: Const.elevation,
          child: ListTile(
            leading: Opacity(
              opacity: Const.opacity,
              child: Text("${index + 1}"),
            ),
            title: Center(
              child: Text(hintList[index]),
            ),
            trailing: const IconButton(
              icon: Icon(
                Icons.lightbulb,
              ),
              onPressed: null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHideSolutionCard(BuildContext context, int index) {
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width * SolutionStateViewConst.widthWeight +
          SolutionStateViewConst.widthBias,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(SolutionStateViewConst.borderRadius),
        ),
        elevation: Const.elevation,
        child: ListTile(
          leading: Opacity(
            opacity: Const.opacity,
            child: Text("${index + 1}"),
          ),
          trailing: IconButton(
            tooltip: SolutionStateViewConst.hintTooltip,
            icon: Icon(
              Icons.lightbulb,
              color: Colors.yellow[600],
            ),
            onPressed: () => BlocProvider.of<HomeBloc>(context)
                .add(HomeOpenHintEvent(index: index)),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSolutionStateView(BuildContext context) {
    HomeSolutionState state =
        context.watch<HomeBloc>().state as HomeSolutionState;
    List<String> solutionList = state.solutionList;
    List<bool> solutionMaskList = state.solutionMaskList;
    List<bool> hintMaskList = state.hintMaskList;
    double width = MediaQuery.of(context).size.width;
    return [
      _buildAnswerView(context),
      for (int index = 0; index < solutionList.length; index++)
        SizedBox(
          width: width * SolutionStateViewConst.widthWeight +
              SolutionStateViewConst.widthBias,
          child: solutionMaskList[index]
              ? _buildSolutionCard(context, index)
              : hintMaskList[index]
                  ? _buildHintCard(context, index)
                  : _buildHideSolutionCard(context, index),
        ),
    ];
  }
}
