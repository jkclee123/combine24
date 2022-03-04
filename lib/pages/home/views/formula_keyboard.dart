import 'dart:math';

import 'package:combine24/config/const.dart';
import 'package:combine24/utils/op_util.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class FormulaKeyboard extends StatefulWidget
    with KeyboardCustomPanelMixin<String>
    implements PreferredSizeWidget {
  @override
  final ValueNotifier<String> notifier;
  final FocusNode focusNode;
  final List<String> cardList;
  final BuildContext context;
  FormulaKeyboard({
    Key? key,
    required this.notifier,
    required this.focusNode,
    required this.cardList,
    required this.context,
  }) : super(key: key);

  double get preferredHeight {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return min(
        width * FormulaKeyboardConst.preferredHeightWidthWeight +
            FormulaKeyboardConst.preferredHeightWidthBias,
        height * FormulaKeyboardConst.preferredHeightHeightWeight);
  }

  @override
  Size get preferredSize => Size.fromHeight(preferredHeight);

  @override
  _FormulaKeyboardState createState() => _FormulaKeyboardState();
}

class _FormulaKeyboardState extends State<FormulaKeyboard> {
  bool isNextCard = true;
  bool isInBracket = false;
  int lenFromBracket = 0;
  List<bool> availCard = [true, true, true, true];
  bool submited = false;

  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(() => onAnsChanged());
    onAnsChanged();
  }

  void onAnsChanged() {
    if (!mounted) {
      return;
    }
    String ans = widget.notifier.value;
    bool isNextCardCopy = true;
    bool isInBracketCopy = false;
    int lenFromBracketCopy = 0;
    List<bool> availCardCopy = [true, true, true, true];
    ans = ans.replaceAll("10", "T");
    for (String char in ans.split(Const.emptyString)) {
      char = char.replaceAll("T", "10");
      if (OpUtil.isOpenBracket(char)) {
        isInBracketCopy = true;
        lenFromBracketCopy = 0;
      } else if (OpUtil.isCloseBracket(char)) {
        isInBracketCopy = false;
      } else if (char != Const.space) {
        lenFromBracketCopy += 1;
        if (OpUtil.isOp(char)) {
          isNextCardCopy = true;
        } else {
          isNextCardCopy = false;
        }
        if (widget.cardList.contains(char)) {
          for (int index = 0; index < widget.cardList.length; index++) {
            if (widget.cardList[index] == char && availCardCopy[index]) {
              availCardCopy[index] = false;
              break;
            }
          }
        }
      }
    }
    setState(() {
      isNextCard = isNextCardCopy;
      isInBracket = isInBracketCopy;
      lenFromBracket = lenFromBracketCopy;
      availCard = List<bool>.from(availCardCopy);
    });
  }

  bool get noAvailCard => availCard.every((avail) => !avail);

  bool canAddCard(int index) => availCard[index] && isNextCard;

  bool get canAddOp => !noAvailCard && !isNextCard;

  bool get canAddBracket => canAddOpenBracket || canAddCloseBracket;

  bool get canAddOpenBracket => !noAvailCard && isNextCard && !isInBracket;

  bool get canAddCloseBracket =>
      !isNextCard && isInBracket && lenFromBracket > 2;

  bool get canSubmit => noAvailCard && !isInBracket && !submited;

  void onTapCard(int index) =>
      widget.updateValue("${widget.notifier.value}${widget.cardList[index]}");

  void onTapOp(String op) =>
      widget.updateValue("${widget.notifier.value} $op ");

  void onTapAllClear() => widget.updateValue(Const.emptyString);

  void onTapBracket() {
    if (canAddOpenBracket) {
      widget.updateValue("${widget.notifier.value}${OpConst.openBracket}");
    } else if (canAddCloseBracket) {
      widget.updateValue("${widget.notifier.value}${OpConst.closeBracket}");
    }
  }

  void onTapBackspace() {
    String currVal = widget.notifier.value;
    if (currVal.endsWith(Const.space)) {
      widget.updateValue(currVal.substring(0, currVal.length - 3));
    } else if (currVal.isNotEmpty) {
      widget.updateValue(currVal.substring(0, currVal.length - 1));
    }
  }

  void onTapSubmit() {
    widget.updateValue("${widget.notifier.value}${FormulaKeyboardConst.eof}");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.all(Const.edgeInsets),
      child: SizedBox(
        width: max(
            widget.preferredHeight * FormulaKeyboardConst.containerWidthWeight +
                FormulaKeyboardConst.containerWidthBias,
            0),
        child: GridView(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1,
            crossAxisSpacing: FormulaKeyboardConst.crossAxisSpacing,
            mainAxisSpacing: FormulaKeyboardConst.mainAxisSpacing,
          ),
          children: <Widget>[
            buildButton(
                text: FormulaKeyboardConst.allClear,
                isEnabled: true,
                callback: () => onTapAllClear()),
            buildButton(
                text: OpConst.readDivOp,
                isEnabled: canAddOp,
                callback: () => onTapOp(OpConst.readDivOp)),
            buildButton(
                text: OpConst.readMulOp,
                isEnabled: canAddOp,
                callback: () => onTapOp(OpConst.readMulOp)),
            buildButton(
                text: OpConst.minusOp,
                isEnabled: canAddOp,
                callback: () => onTapOp(OpConst.minusOp)),
            buildButton(
                text: widget.cardList[0],
                isEnabled: canAddCard(0),
                callback: () => onTapCard(0)),
            buildButton(
                text: widget.cardList[1],
                isEnabled: canAddCard(1),
                callback: () => onTapCard(1)),
            buildButton(
                text: FormulaKeyboardConst.bracket,
                isEnabled: canAddBracket,
                callback: () => onTapBracket()),
            buildButton(
                text: OpConst.addOp,
                isEnabled: canAddOp,
                callback: () => onTapOp(OpConst.addOp)),
            buildButton(
                text: widget.cardList[2],
                isEnabled: canAddCard(2),
                callback: () => onTapCard(2)),
            buildButton(
                text: widget.cardList[3],
                isEnabled: canAddCard(3),
                callback: () => onTapCard(3)),
            buildButton(
                icon: Icons.backspace_outlined,
                isEnabled: true,
                callback: () => onTapBackspace()),
            buildButton(
                text: FormulaKeyboardConst.submit,
                isEnabled: canSubmit,
                callback: () => onTapSubmit()),
          ],
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
        onTap: isEnabled ? callback : null,
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(FormulaKeyboardConst.edgeInsets),
            child: text != null
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
