class Const {
  static const String title = "合廿四";
  static const String space = " ";
  static const String emptyString = "";
  static const String tempSign = "@";
  static const double edgeInsets = 10.0;
  static const int refreshDelay = 1;
  static const double elevation = 10.0;
  static const double opacity = 0.5;
  static const List<String> deckList = [
    "A",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "J",
    "Q",
    "K"
  ];
}

class OpConst {
  static const String addOp = "+";
  static const String minusOp = "-";
  static const String readMulOp = "x";
  static const String calMulOp = "*";
  static const String readDivOp = "÷";
  static const String calDivOp = "/";
  static const String reverseMinusOp = "r-";
  static const String reverseDivOp = "r/";
  static const String openBracket = "(";
  static const String closeBracket = ")";
  static const String reverseIdentifier = "r";
  static const String divOne = "/1";
  static const String mulOne = "*1";
  static const List<String> opList = [addOp, minusOp, calMulOp, calDivOp];
  static const List<String> opWithRList = [
    addOp,
    minusOp,
    calMulOp,
    calDivOp,
    reverseMinusOp,
    reverseDivOp
  ];
  static const List<String> lowOpList = [addOp, minusOp];
  static const List<String> highOpList = [calMulOp, calDivOp];
  static const List<String> lowOpWithRList = [addOp, minusOp, reverseMinusOp];
  static const List<String> highOpWithRList = [
    calMulOp,
    calDivOp,
    reverseDivOp
  ];
}

class AppBarConst {
  static const String lightModeTooltip = "淺色模式";
  static const String dartModeTooltip = "深色模式";
  static const String randomDrawTooltip = "出題";
}

class HandViewConst {
  static const double minDesiredItemWidth = 120;
  static const double desiredItemWidthWeight = 1 / 6;
  static const double minSpacingWeight = 1 / 120;
  static const double edgeInsets = 3;
}

class ErrorConst {
  static const String errorMsg = "你個嘢壞咗呀☹";
}

class SolutionStateViewConst {
  static const String answerLabelText = "輸入答案";
  static const double widthWeight = 1 / 4;
  static const double widthBias = 200;
  static const double borderRadius = 15;
  static const String hintTooltip = "提示";
  static const double borderWidth = 2;
  static const String subTotalZero = "= 0";
  static const String subTotalError = "= --";
  static const int flipDuration = 800;
}

class FormulaKeyboardConst {
  static const String allClear = "AC";
  static const String bracket = "()";
  static const String submit = "=";
  static const String eof = "\u0000";
  static const double crossAxisSpacing = 10;
  static const double mainAxisSpacing = 10;
  static const double edgeInsets = 8;
  static const double preferredHeightWidthWeight = 3 / 4;
  static const double preferredHeightWidthBias = 20;
  static const double preferredHeightHeightWeight = 5 / 11;
  static const double containerWidthWeight = 4 / 3;
  static const double containerWidthBias = -40;
}
