import 'package:flutter/material.dart';

class Const {
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
  static const String title = "合廿四";
  static const String lightModeTooltip = "眼盲模式";
  static const String dartModeTooltip = "正常模式";
  static const String randomDrawTooltip = "出題";
  static const String resetTooltip = "重置";
}

class HandViewConst {
  static const double minDesiredItemWidth = 120.0;
  static const double desiredItemWidthWeight = 1 / 6;
  static const double minSpacingWeight = 1 / 120;
  static const double edgeInsets = 3.0;
}

class ErrorConst {
  static const String errorMsg = "你個嘢壞咗呀☹ F5啦";
}

class SolutionViewConst {
  static const double answerHeight = 70;
  static const String answerPlaceholder = "我諗到啦😎";
  static const double widthWeight = 1 / 4;
  static const double widthBias = 200;
  static const double borderRadius = 15.0;
  static const String hintTooltip = "提示";
  static const double borderWidth = 1.5;
  static const double noFocusFontSize = 14;
  static const double hasFocusFontSize = 16;
  static const FontWeight fontWeight = FontWeight.w300;
}

class KeyboardViewConst {
  static const double preferredSizeHeight = 240.0;
  static const List<String> opList = [
    OpConst.addOp,
    OpConst.minusOp,
    OpConst.readMulOp,
    OpConst.readDivOp
  ];
  static const String eof = "\u0000";
  static const double widthWeight = 1 / 14;
  static const double heightWeight = 1 / 14;
  static const double minSpacing = 10.0;
  static const double borderRadius = 5.0;
  static const double sumbitBorderRadius = 40.0;
  static const double edgeInsets = 3.0;
}
