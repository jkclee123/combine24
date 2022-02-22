import 'package:combine24/config/const.dart';
import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class FormulaKeyboard extends StatefulWidget
    with KeyboardCustomPanelMixin<String>
    implements PreferredSizeWidget {
  @override
  final ValueNotifier<String> notifier;
  final FocusNode focusNode;
  final List<String> cardList;
  FormulaKeyboard({
    Key? key,
    required this.notifier,
    required this.focusNode,
    required this.cardList,
  }) : super(key: key);

  @override
  Size get preferredSize =>
      const Size.fromHeight(KeyboardConst.preferredSizeHeight);

  @override
  _FormulaKeyboardState createState() => _FormulaKeyboardState();
}

class _FormulaKeyboardState extends State<FormulaKeyboard> {
  bool isNextCard = true;
  late bool isInBracket = false;
  late int lenFromBracket = 0;
  late List<bool> availCard = [true, true, true, true];

  void initKeyboardState() {
    setState(() {
      isNextCard = true;
      isInBracket = false;
      lenFromBracket = 0;
      availCard = [true, true, true, true];
    });
  }

  bool get noAvailCard => availCard.every((avail) => !avail);

  bool canAddCard(int index) => availCard[index] && isNextCard;

  bool get canAddOp => !noAvailCard && !isNextCard;

  bool get canAddOpenBracket => !noAvailCard && isNextCard && !isInBracket;

  bool get canAddCloseBracket =>
      !isNextCard && isInBracket && lenFromBracket > 2;

  bool get canSubmit => noAvailCard && !isInBracket;

  void onTapCard(int index) {
    String currentValue = widget.notifier.value;
    String temp = currentValue + widget.cardList[index];
    setState(() {
      isNextCard = !isNextCard;
      if (isInBracket) {
        lenFromBracket += 1;
      }
      availCard[index] = false;
    });
    widget.updateValue(temp);
  }

  void onTapOp(String op) {
    String currentValue = widget.notifier.value;
    String temp = currentValue + " $op ";
    setState(() {
      isNextCard = !isNextCard;
      if (isInBracket) {
        lenFromBracket += 1;
      }
    });
    widget.updateValue(temp);
  }

  void onTapClear() {
    initKeyboardState();
    widget.updateValue(Const.emptyString);
  }

  void onTapOpenBracket() {
    String currentValue = widget.notifier.value;
    String temp = currentValue + KeyboardConst.openBracket;
    setState(() {
      isInBracket = true;
      lenFromBracket = 0;
    });
    widget.updateValue(temp);
  }

  void onTapCloseBracket() {
    String currentValue = widget.notifier.value;
    String temp = currentValue + KeyboardConst.closeBracket;
    setState(() {
      isInBracket = false;
      lenFromBracket = 0;
    });
    widget.updateValue(temp);
  }

  void onTapSubmit() {
    String currentValue = widget.notifier.value;
    String temp = currentValue + KeyboardConst.eof;
    widget.updateValue(temp);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(Const.edgeInsets),
        child: ResponsiveGridList(
          desiredItemWidth: width > height
              ? width * KeyboardConst.widthWeight
              : height * KeyboardConst.heightWeight,
          squareCells: true,
          minSpacing: KeyboardConst.minSpacing,
          children: <Widget>[
            for (int index = 0; index < 4; index++) buildCardButton(index),
            for (String op in KeyboardConst.opList) buildOpButton(op),
            buildOpenBracketButton(),
            buildCloseBracketButton(),
            buildClearButton(),
            buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget buildCardButton(int index) {
    return Material(
      borderRadius: BorderRadius.circular(KeyboardConst.borderRadius),
      color: canAddCard(index)
          ? Colors.blue
          : const Color(KeyboardConst.disabledColorHex),
      elevation: Const.elevation,
      child: InkWell(
        onTap: canAddCard(index) ? () => onTapCard(index) : null,
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(KeyboardConst.edgeInsets),
            child: Text(
              widget.cardList[index],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOpButton(String op) {
    return Material(
      borderRadius: BorderRadius.circular(KeyboardConst.borderRadius),
      color:
          canAddOp ? Colors.blue : const Color(KeyboardConst.disabledColorHex),
      elevation: 5,
      child: InkWell(
        onTap: canAddOp ? () => onTapOp(op) : null,
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(KeyboardConst.edgeInsets),
            child: Text(
              op,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildClearButton() {
    return Material(
      borderRadius: BorderRadius.circular(KeyboardConst.borderRadius),
      color: const Color(KeyboardConst.disabledColorHex),
      elevation: Const.elevation,
      child: InkWell(
        onTap: () => onTapClear(),
        child: const FittedBox(
          child: Padding(
            padding: EdgeInsets.all(KeyboardConst.edgeInsets),
            child: Icon(
              Icons.clear_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOpenBracketButton() {
    return Material(
      borderRadius: BorderRadius.circular(KeyboardConst.borderRadius),
      color: canAddOpenBracket
          ? Colors.blue
          : const Color(KeyboardConst.disabledColorHex),
      elevation: Const.elevation,
      child: InkWell(
        onTap: canAddOpenBracket ? () => onTapOpenBracket() : null,
        child: const FittedBox(
          child: Padding(
            padding: EdgeInsets.all(KeyboardConst.edgeInsets),
            child: Text(
              KeyboardConst.openBracket,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCloseBracketButton() {
    return Material(
      borderRadius: BorderRadius.circular(KeyboardConst.borderRadius),
      color: canAddCloseBracket
          ? Colors.blue
          : const Color(KeyboardConst.disabledColorHex),
      elevation: Const.elevation,
      child: InkWell(
        onTap: canAddCloseBracket ? () => onTapCloseBracket() : null,
        child: const FittedBox(
          child: Padding(
            padding: EdgeInsets.all(KeyboardConst.edgeInsets),
            child: Text(
              KeyboardConst.closeBracket,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSubmitButton() {
    return Material(
      borderRadius: BorderRadius.circular(KeyboardConst.sumbitBorderRadius),
      color: canSubmit
          ? Colors.greenAccent[400]
          : const Color(KeyboardConst.disabledColorHex),
      elevation: Const.elevation,
      child: InkWell(
        onTap: canSubmit ? () => onTapSubmit() : null,
        child: const FittedBox(
          child: Padding(
              padding: EdgeInsets.all(KeyboardConst.edgeInsets),
              child: Icon(
                Icons.send_rounded,
                color: Colors.white,
              )),
        ),
      ),
    );
  }
}
