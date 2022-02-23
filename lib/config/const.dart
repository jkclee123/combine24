class Const {
  static const String emptyString = "";
  static const double edgeInsets = 10.0;
  static const int refreshDelay = 1;
  static const double elevation = 8.0;
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

class AppBarConst {
  static const String title = "合廿四";
  static const String lightModeTooltip = "眼盲模式";
  static const String dartModeTooltip = "正常模式";
  static const String randomDrawTooltip = "出題";
  static const String resetTooltip = "重置";
}

class HandConst {
  static const double minDesiredItemWidth = 120.0;
  static const double desiredItemWidthWeight = 1 / 6;
  static const double minSpacingWeight = 1 / 120;
  static const double edgeInsets = 3.0;
}

class ErrorConst {
  static const String errorMsg = "你個嘢壞咗呀☹ F5啦";
}

class SolutionConst {
  static const double answerHeight = 55;
  static const String answerPlaceholder = "我知答案!";
  static const double widthWeight = 1 / 4;
  static const double widthBias = 200;
  static const double borderRadius = 15.0;
  static const String hintTooltip = "提示";
}

class KeyboardConst {
  static const double preferredSizeHeight = 240.0;
  static const List<String> opList = [
    "+",
    "-",
    "x",
    "÷",
  ];
  static const String openBracket = "(";
  static const String closeBracket = ")";
  static const String eof = "\u0000";
  static const double widthWeight = 1 / 14;
  static const double heightWeight = 1 / 14;
  static const double minSpacing = 10.0;
  static const int disabledColorHex = 0xFF4A4A4A;
  static const double borderRadius = 5.0;
  static const double sumbitBorderRadius = 40.0;
  static const double edgeInsets = 3.0;
}
