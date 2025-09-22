import 'dart:math';

import 'package:combine24/pages/home/views/formula_keyboard.dart';
import 'package:combine24/pages/home/views/card_keyboard.dart';
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
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final FocusNode formulaFocusNode;
  late final FocusNode cardFocusNode;
  late final ValueNotifier<String> formulaKeyboardNotifier;
  late final ValueNotifier<String> cardKeyboardNotifier;
  late final TextEditingController answerController;
  late final TranslateService translateService;

  @override
  void initState() {
    super.initState();
    formulaFocusNode = FocusNode();
    cardFocusNode = FocusNode();
    formulaKeyboardNotifier = ValueNotifier<String>(Const.emptyString);
    cardKeyboardNotifier = ValueNotifier<String>(Const.emptyString);
    answerController = TextEditingController();
    translateService = DefaultTranslateService();
    formulaKeyboardNotifier.addListener(() => onAnswerChanged());
    cardKeyboardNotifier.addListener(() => onCardChanged());
  }

  void onAnswerChanged() {
    if (formulaKeyboardNotifier.value.contains(FormulaKeyboardConst.eof)) {
      // on sumbit clear input
      BlocProvider.of<HomeBloc>(context)
          .add(HomeSubmitEvent(answer: formulaKeyboardNotifier.value));
      formulaKeyboardNotifier.value = Const.emptyString;
      formulaFocusNode.unfocus();
    } else {
      answerController.value = TextEditingValue(
        text: formulaKeyboardNotifier.value,
        selection: TextSelection.fromPosition(
          TextPosition(offset: formulaKeyboardNotifier.value.length),
        ),
      );
    }
  }

  void onCardChanged() {
    String buffer = cardKeyboardNotifier.value;
    BlocProvider.of<HomeBloc>(context).add(HomePickCardEvent(buffer: buffer));
    if (buffer.length == 4) {
      cardKeyboardNotifier.value = Const.emptyString;
      cardFocusNode.unfocus();
    }
  }

  void copyHint2Ans(String hint) {
    formulaKeyboardNotifier.value = hint;
  }

  String subTotal(String formula) {
    if (formula.isEmpty) {
      return SolutionStateViewConst.subTotalZero;
    }
    try {
      formula = translateService.read2CalFormula(formula);
      if (OpConst.openBracket.allMatches(formula).length == 1 &&
          OpConst.closeBracket.allMatches(formula).isEmpty) {
        formula = formula.replaceAll(OpConst.openBracket, Const.emptyString);
      }
      return "= ${formula.interpret().toStringAsFixed(1)}";
    } catch (e, _) {
      return SolutionStateViewConst.subTotalError;
    }
  }

  @override
  Widget build(BuildContext context) {
    // BlocProvider.of<HomeBloc>(context).add(HomeTestEvent());
    return BlocBuilder<HomeBloc, HomeState>(builder: (_, state) {
      return RefreshIndicator(
        onRefresh: () {
          final homeBloc = context.read<HomeBloc>();
          return Future.delayed(
            const Duration(seconds: Const.refreshDelay),
            () => homeBloc.add(HomeResetEvent()),
          );
        },
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
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              formulaKeyboardNotifier.value = Const.emptyString;
              cardKeyboardNotifier.value = Const.emptyString;
              BlocProvider.of<HomeBloc>(context).add(HomeRandomDrawEvent());
            },
            tooltip: Const.randomDrawTooltip,
            child: const Icon(Icons.quiz_rounded),
          ),
        ),
      );
    });
  }

  KeyboardActionsConfig _buildFormulaKeyboardConfig(BuildContext context) {
    List<String> cardList = BlocProvider.of<HomeBloc>(context).state.cardList;
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      actions: [
        KeyboardActionsItem(
          focusNode: formulaFocusNode,
          displayActionBar: false,
          footerBuilder: (context) => FormulaKeyboard(
              key: const ValueKey("formula"),
              focusNode: formulaFocusNode,
              notifier: formulaKeyboardNotifier,
              cardList: cardList,
              context: context),
        ),
      ],
    );
  }

  KeyboardActionsConfig _buildCardKeyboardConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      actions: [
        KeyboardActionsItem(
          focusNode: cardFocusNode,
          displayActionBar: false,
          footerBuilder: (context) => CardKeyboard(
              key: const ValueKey("card"),
              notifier: cardKeyboardNotifier,
              focusNode: cardFocusNode,
              context: context),
        ),
      ],
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(Const.title),
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
      ],
    );
  }

  Widget _buildHandView(BuildContext context) {
    HomeState state = BlocProvider.of<HomeBloc>(context).state;
    double width = MediaQuery.of(context).size.width;
    return KeyboardActions(
      autoScroll: false,
      tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
      isDialog: false,
      config: _buildCardKeyboardConfig(context),
      child: KeyboardCustomInput<String>(
        focusNode: cardFocusNode,
        notifier: cardKeyboardNotifier,
        builder: (context, val, hasFocus) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              BlocProvider.of<HomeBloc>(context).add(HomePickCardEvent(buffer: cardKeyboardNotifier.value));
              formulaKeyboardNotifier.value = Const.emptyString;
              if (!cardFocusNode.hasFocus) {
                cardFocusNode.requestFocus();
              }
            },
            child: ResponsiveGridList(
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
            ),
          );
        },
      ),
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

  List<Widget> _buildSolutionStateView(BuildContext context) {
    HomeSolutionState state =
        BlocProvider.of<HomeBloc>(context).state as HomeSolutionState;
    List<String> solutionList = state.solutionList;
    double width = MediaQuery.of(context).size.width;
    return [
      if (state.solutionList.isNotEmpty)
        _buildAnswerView(context),
      for (int index = 0; index < solutionList.length; index++)
        SizedBox(
          width: width * SolutionStateViewConst.widthWeight +
              SolutionStateViewConst.widthBias,
          child: _buildFlipAnimation(context, index),
        ),
    ];
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
        config: _buildFormulaKeyboardConfig(context),
        child: KeyboardCustomInput<String>(
          focusNode: formulaFocusNode,
          notifier: formulaKeyboardNotifier,
          builder: (context, val, hasFocus) {
            return TextField(
              showCursor: false,
              readOnly: true,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.none,
              controller: answerController,
              decoration: InputDecoration(
                hintText: SolutionStateViewConst.answerHintText,
                border: const OutlineInputBorder(),
                counterText: subTotal(answerController.text),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFlipAnimation(BuildContext context, int index) {
    HomeSolutionState state =
        BlocProvider.of<HomeBloc>(context).state as HomeSolutionState;
    List<bool> solutionMaskList = state.solutionMaskList;
    List<bool> hintMaskList = state.hintMaskList;
    return AnimatedSwitcher(
      duration:
          const Duration(milliseconds: SolutionStateViewConst.flipDuration),
      transitionBuilder: _transitionBuilder,
      layoutBuilder: (widget, list) {
        if (widget != null) {
          return Stack(children: [widget, ...list]);
        } else {
          return Stack(children: list);
        }
      },
      switchInCurve: Curves.easeInBack,
      switchOutCurve: Curves.easeInBack.flipped,
      child: solutionMaskList[index]
          ? _buildSolutionCard(context, index)
          : hintMaskList[index]
              ? _buildHintCard(context, index)
              : _buildEmptySolutionCard(context, index),
    );
  }

  Widget _buildEmptySolutionCard(BuildContext context, int index) {
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      key: const ValueKey(false),
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

  Widget _buildHintCard(BuildContext context, int index) {
    HomeSolutionState state =
        BlocProvider.of<HomeBloc>(context).state as HomeSolutionState;
    List<String> hintList = state.hintList;
    double width = MediaQuery.of(context).size.width;
    copyHint2Ans(hintList[index]);
    return SizedBox(
      key: const ValueKey(false),
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

  Widget _buildSolutionCard(BuildContext context, int index) {
    HomeSolutionState state =
        BlocProvider.of<HomeBloc>(context).state as HomeSolutionState;
    List<String> solutionList = state.solutionList;
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      key: const ValueKey(true),
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

  Widget _transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
      animation: rotateAnim,
      child: widget,
      builder: (context, widget) {
        final isUnder = const ValueKey(true) != widget!.key;
        var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
        tilt *= isUnder ? -1.0 : 1.0;
        final value =
            isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
        return Transform(
          transform: Matrix4.rotationX(value)..setEntry(3, 1, tilt),
          alignment: Alignment.center,
          child: widget,
        );
      },
    );
  }
}
