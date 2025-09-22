import 'package:combine24/config/const.dart';
import 'package:combine24/pages/home/home_bloc.dart';
import 'package:combine24/pages/home/home_event.dart';
import 'package:combine24/pages/home/home_state.dart';
import 'package:combine24/pages/home/widgets/home_formula_keyboard.dart';
import 'package:combine24/services/impl/default_translate_service.dart';
import 'package:combine24/services/translate_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:function_tree/function_tree.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class HomeAnswerInput extends StatefulWidget {
  final FocusNode formulaFocusNode;
  final ValueNotifier<String> formulaKeyboardNotifier;
  final List<String> cardList;

  const HomeAnswerInput({
    super.key,
    required this.formulaFocusNode,
    required this.formulaKeyboardNotifier,
    required this.cardList,
  });

  @override
  State<HomeAnswerInput> createState() => _HomeAnswerInputState();
}

class HomeAnswerInputWithBloc extends StatelessWidget {
  final FocusNode formulaFocusNode;
  final ValueNotifier<String> formulaKeyboardNotifier;
  final List<String> cardList;

  const HomeAnswerInputWithBloc({
    super.key,
    required this.formulaFocusNode,
    required this.formulaKeyboardNotifier,
    required this.cardList,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (previous, current) {
        if (previous is HomeSolutionState && current is HomeSolutionState) {
          return previous.copiedHint != current.copiedHint && current.copiedHint != null;
        }
        return false;
      },
      listener: (context, state) {
        if (state is HomeSolutionState && state.copiedHint != null) {
          formulaKeyboardNotifier.value = state.copiedHint!;
        }
      },
      child: HomeAnswerInput(
        formulaFocusNode: formulaFocusNode,
        formulaKeyboardNotifier: formulaKeyboardNotifier,
        cardList: cardList,
      ),
    );
  }
}

class _HomeAnswerInputState extends State<HomeAnswerInput> {
  late final TextEditingController answerController;
  late final TranslateService translateService;
  late final VoidCallback _answerChangedListener;

  @override
  void initState() {
    super.initState();
    answerController = TextEditingController();
    translateService = DefaultTranslateService();
    _answerChangedListener = () => onAnswerChanged();
    widget.formulaKeyboardNotifier.addListener(_answerChangedListener);
  }

  @override
  void dispose() {
    widget.formulaKeyboardNotifier.removeListener(_answerChangedListener);
    answerController.dispose();
    super.dispose();
  }

  void onAnswerChanged() {
    if (widget.formulaKeyboardNotifier.value.contains(FormulaKeyboardConst.eof)) {
      // on submit clear input
      context.read<HomeBloc>().add(HomeSubmitEvent(answer: widget.formulaKeyboardNotifier.value));
      widget.formulaKeyboardNotifier.value = Const.emptyString;
      widget.formulaFocusNode.unfocus();
    } else {
      answerController.value = TextEditingValue(
        text: widget.formulaKeyboardNotifier.value,
        selection: TextSelection.fromPosition(
          TextPosition(offset: widget.formulaKeyboardNotifier.value.length),
        ),
      );
    }
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

  KeyboardActionsConfig _buildFormulaKeyboardConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      actions: [
        KeyboardActionsItem(
          focusNode: widget.formulaFocusNode,
          displayActionBar: false,
          footerBuilder: (context) => HomeFormulaKeyboard(
              key: const ValueKey("formula"),
              focusNode: widget.formulaFocusNode,
              notifier: widget.formulaKeyboardNotifier,
              cardList: widget.cardList,
              context: context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width * SolutionStateViewConst.widthWeight +
          SolutionStateViewConst.widthBias,
      child: KeyboardActions(
        autoScroll: false,
        tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
        isDialog: false,
        config: _buildFormulaKeyboardConfig(context),
        child: KeyboardCustomInput<String>(
          focusNode: widget.formulaFocusNode,
          notifier: widget.formulaKeyboardNotifier,
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
}
