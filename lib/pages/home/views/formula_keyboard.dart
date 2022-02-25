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
      const Size.fromHeight(KeyboardViewConst.preferredSizeHeight);

  @override
  _FormulaKeyboardState createState() => _FormulaKeyboardState();
}

class _FormulaKeyboardState extends State<FormulaKeyboard> {
  bool isNextCard = true;
  bool isInBracket = false;
  int lenFromBracket = 0;
  List<bool> availCard = [true, true, true, true];
  bool submited = false;

  void initKeyboardState() {
    setState(() {
      isNextCard = true;
      isInBracket = false;
      lenFromBracket = 0;
      availCard = [true, true, true, true];
      submited = false;
    });
  }

  bool get noAvailCard => availCard.every((avail) => !avail);

  bool canAddCard(int index) => availCard[index] && isNextCard;

  bool get canAddOp => !noAvailCard && !isNextCard;

  bool get canAddOpenBracket => !noAvailCard && isNextCard && !isInBracket;

  bool get canAddCloseBracket =>
      !isNextCard && isInBracket && lenFromBracket > 2;

  bool get canSubmit => noAvailCard && !isInBracket && !submited;

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
    String temp = currentValue + OpConst.openBracket;
    setState(() {
      isInBracket = true;
      lenFromBracket = 0;
    });
    widget.updateValue(temp);
  }

  void onTapCloseBracket() {
    String currentValue = widget.notifier.value;
    String temp = currentValue + OpConst.closeBracket;
    setState(() {
      isInBracket = false;
      lenFromBracket = 0;
    });
    widget.updateValue(temp);
  }

  void onTapSubmit() {
    String currentValue = widget.notifier.value;
    String temp = currentValue + KeyboardViewConst.eof;
    setState(() {
      submited = true;
    });
    widget.updateValue(temp);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(Const.edgeInsets),
        child: ResponsiveGridList(
          desiredItemWidth: width > height
              ? width * KeyboardViewConst.widthWeight
              : height * KeyboardViewConst.heightWeight,
          squareCells: true,
          minSpacing: KeyboardViewConst.minSpacing,
          children: <Widget>[
            for (int index = 0; index < 4; index++) buildCardButton(index),
            for (String op in KeyboardViewConst.opList) buildOpButton(op),
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
      borderRadius: BorderRadius.circular(KeyboardViewConst.borderRadius),
      color: canAddCard(index) ? Colors.blue : Colors.grey[800],
      elevation: Const.elevation,
      child: InkWell(
        onTap: canAddCard(index) ? () => onTapCard(index) : null,
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(KeyboardViewConst.edgeInsets),
            child: Text(
              widget.cardList[index],
              style: TextStyle(
                color: canAddCard(index) ? Colors.white : Colors.grey,
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
      borderRadius: BorderRadius.circular(KeyboardViewConst.borderRadius),
      color: canAddOp ? Colors.blue : Colors.grey[800],
      elevation: Const.elevation,
      child: InkWell(
        onTap: canAddOp ? () => onTapOp(op) : null,
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(KeyboardViewConst.edgeInsets),
            child: Text(
              op,
              style: TextStyle(
                color: canAddOp ? Colors.white : Colors.grey,
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
      borderRadius: BorderRadius.circular(KeyboardViewConst.borderRadius),
      color: Colors.redAccent,
      elevation: Const.elevation,
      child: InkWell(
        onTap: () => onTapClear(),
        child: const FittedBox(
          child: Padding(
            padding: EdgeInsets.all(KeyboardViewConst.edgeInsets),
            child: Icon(
              Icons.format_clear_outlined,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOpenBracketButton() {
    return Material(
      borderRadius: BorderRadius.circular(KeyboardViewConst.borderRadius),
      color: canAddOpenBracket ? Colors.blue : Colors.grey[800],
      elevation: Const.elevation,
      child: InkWell(
        onTap: canAddOpenBracket ? () => onTapOpenBracket() : null,
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(KeyboardViewConst.edgeInsets),
            child: Text(
              OpConst.openBracket,
              style: TextStyle(
                color: canAddOpenBracket ? Colors.white : Colors.grey,
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
      borderRadius: BorderRadius.circular(KeyboardViewConst.borderRadius),
      color: canAddCloseBracket ? Colors.blue : Colors.grey[800],
      elevation: Const.elevation,
      child: InkWell(
        onTap: canAddCloseBracket ? () => onTapCloseBracket() : null,
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(KeyboardViewConst.edgeInsets),
            child: Text(
              OpConst.closeBracket,
              style: TextStyle(
                color: canAddCloseBracket ? Colors.white : Colors.grey,
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
      shape: const CircleBorder(),
      color: canSubmit ? Colors.greenAccent[400] : Colors.grey[800],
      elevation: Const.elevation,
      child: InkWell(
        onTap: canSubmit ? () => onTapSubmit() : null,
        child: FittedBox(
          child: Padding(
              padding: const EdgeInsets.all(KeyboardViewConst.edgeInsets),
              child: Icon(
                Icons.send_rounded,
                color: canSubmit ? Colors.white : Colors.grey,
              )),
        ),
      ),
    );
  }
}
