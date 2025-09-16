import 'dart:math';

import 'package:combine24/config/const.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class CardKeyboard extends StatefulWidget
    with KeyboardCustomPanelMixin<String>
    implements PreferredSizeWidget {
  @override
  final ValueNotifier<String> notifier;
  final FocusNode focusNode;
  final List<String> selectedCards;
  final BuildContext context;

  @override
  void updateValue(String value) {
    notifier.value = value;
  }

  CardKeyboard({
    super.key,
    required this.notifier,
    required this.focusNode,
    required this.selectedCards,
    required this.context,
  });

  double get preferredHeight {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return min(
        width * CardKeyboardConst.preferredHeightWidthWeight +
            CardKeyboardConst.preferredHeightWidthBias,
        height * CardKeyboardConst.preferredHeightHeightWeight);
  }

  @override
  Size get preferredSize => Size.fromHeight(preferredHeight);

  @override
  State<CardKeyboard> createState() => _CardKeyboardState();
}

class _CardKeyboardState extends State<CardKeyboard> {
  List<bool> availCard = List<bool>.filled(Const.deckList.length, true);

  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(() => onSelectionChanged());
    onSelectionChanged();
    widget.focusNode.requestFocus();
  }

  void onSelectionChanged() {
    if (!mounted) {
      return;
    }
    List<String> selected = widget.selectedCards;
    List<bool> availCardCopy = List<bool>.filled(Const.deckList.length, true);

    for (String card in selected) {
      int index = Const.deckList.indexOf(card);
      if (index != -1) {
        availCardCopy[index] = false;
      }
    }

    setState(() {
      availCard = availCardCopy;
    });
  }

  bool canSelectCard(int index) => availCard[index] && widget.selectedCards.length < 4;

  bool get canBackspace => widget.selectedCards.isNotEmpty;

  void onTapCard(int index) {
    widget.updateValue("${widget.notifier.value}${Const.deckList[index]}");
  }

  void onTapBackspace() {
    String currVal = widget.notifier.value;
    if (currVal.endsWith(Const.space)) {
      widget.updateValue(currVal.substring(0, currVal.length - 3));
    } else if (currVal.isNotEmpty) {
      widget.updateValue(currVal.substring(0, currVal.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      canRequestFocus: false,
      child: Container(
        color: Colors.grey[900],
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.all(Const.edgeInsets),
        child: SizedBox(
          width: max(
              widget.preferredHeight * CardKeyboardConst.containerWidthWeight +
                  CardKeyboardConst.containerWidthBias,
              0),
          child: GridView(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 0.75,
              crossAxisSpacing: CardKeyboardConst.crossAxisSpacing,
              mainAxisSpacing: CardKeyboardConst.mainAxisSpacing,
            ),
            children: <Widget>[
              // First row: A, 2, 3, 4, 5
              ...List.generate(5, (index) => buildButton(
                  text: Const.deckList[index],
                  isEnabled: canSelectCard(index),
                  callback: () => onTapCard(index))),
              // Second row: 6, 7, 8, 9, 10
              ...List.generate(5, (index) => buildButton(
                  text: Const.deckList[index + 5],
                  isEnabled: canSelectCard(index + 5),
                  callback: () => onTapCard(index + 5))),
              // Third row: J, Q, K, Enter, empty
              buildButton(
                  text: Const.deckList[10], // J
                  isEnabled: canSelectCard(10),
                  callback: () => onTapCard(10)),
              buildButton(
                  text: Const.deckList[11], // Q
                  isEnabled: canSelectCard(11),
                  callback: () => onTapCard(11)),
              buildButton(
                  text: Const.deckList[12], // K
                  isEnabled: canSelectCard(12),
                  callback: () => onTapCard(12)),
              buildButton(text: "", isEnabled: false, callback: (){}),
              buildButton(
                  icon: Icons.backspace_outlined,
                  isEnabled: canBackspace,
                  callback: () => onTapBackspace()),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton(
      {String? text,
      IconData? icon,
      required bool isEnabled,
      required VoidCallback callback}) {
    return Material(
      shape: const CircleBorder(),
      color: isEnabled ? Colors.blueGrey : Colors.grey[850],
      elevation: Const.elevation,
      child: InkWell(
        onTapDown: isEnabled ? (_) { if (!widget.focusNode.hasFocus) widget.focusNode.requestFocus(); } : null,
        onTap: isEnabled ? callback : null,
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(CardKeyboardConst.edgeInsets),
            child: text != null && text.isNotEmpty
                ? buildBtnText(text, isEnabled)
                : icon != null
                    ? buildBtnIcon(icon, isEnabled)
                    : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  Widget buildBtnText(String text, bool isEnabled) {
    return Text(
      text,
      style: TextStyle(
        color: isEnabled ? Colors.white : Colors.grey[700],
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget buildBtnIcon(IconData icon, bool isEnabled) {
    return Icon(
      icon,
      color: isEnabled ? Colors.white : Colors.grey[700],
    );
  }
}
