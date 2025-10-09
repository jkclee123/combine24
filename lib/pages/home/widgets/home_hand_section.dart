import 'dart:math';

import 'package:combine24/config/const.dart';
import 'package:combine24/pages/home/home_bloc.dart';
import 'package:combine24/pages/home/home_event.dart';
import 'package:combine24/pages/home/widgets/home_card_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:responsive_grid/responsive_grid.dart';

class HomeHandSection extends StatefulWidget {
  final FocusNode cardFocusNode;
  final ValueNotifier<String> cardKeyboardNotifier;
  final ValueNotifier<String> formulaKeyboardNotifier;

  const HomeHandSection({
    super.key,
    required this.cardFocusNode,
    required this.cardKeyboardNotifier,
    required this.formulaKeyboardNotifier,
  });

  @override
  State<HomeHandSection> createState() => _HomeHandSectionState();
}

class _HomeHandSectionState extends State<HomeHandSection> {
  @override
  void initState() {
    super.initState();
    widget.cardKeyboardNotifier.addListener(_onCardChanged);
  }

  @override
  void dispose() {
    widget.cardKeyboardNotifier.removeListener(_onCardChanged);
    super.dispose();
  }

  void _onCardChanged() {
    final buffer = widget.cardKeyboardNotifier.value;
    context.read<HomeBloc>().add(HomePickCardEvent(buffer: buffer));
    if (buffer.length == 4) {
      widget.cardKeyboardNotifier.value = Const.emptyString;
      widget.cardFocusNode.unfocus();
    }
  }

  KeyboardActionsConfig _buildCardKeyboardConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      actions: [
        KeyboardActionsItem(
          focusNode: widget.cardFocusNode,
          displayActionBar: false,
          footerBuilder: (context) => HomeCardKeyboard(
              key: const ValueKey("card"),
              notifier: widget.cardKeyboardNotifier,
              focusNode: widget.cardFocusNode,
              context: context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeBloc>().state;
    final width = MediaQuery.of(context).size.width;

    return KeyboardActions(
      autoScroll: false,
      tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
      isDialog: false,
      config: _buildCardKeyboardConfig(context),
      child: KeyboardCustomInput<String>(
        focusNode: widget.cardFocusNode,
        notifier: widget.cardKeyboardNotifier,
        builder: (context, val, hasFocus) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.formulaKeyboardNotifier.value = Const.emptyString;
              context.read<HomeBloc>().add(HomePickCardEvent(buffer: widget.cardKeyboardNotifier.value));
              if (!widget.cardFocusNode.hasFocus) {
                widget.cardFocusNode.requestFocus();
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
}
