import 'package:combine24/config/const.dart';

class OpUtil {
  static bool isReverseOp(String op) => op.contains(OpConst.reverseIdentifier);

  static bool isAddOp(String op) => op == OpConst.addOp;

  static bool isMinusOp(String op) => op == OpConst.minusOp;

  static bool isMulOp(String op) => op == OpConst.calMulOp;

  static bool isDivOp(String op) => op == OpConst.calDivOp;

  static bool isReverseMinusOp(String op) => op == OpConst.reverseMinusOp;

  static bool isReverseDivOp(String op) => op == OpConst.reverseDivOp;

  static bool isOpenBracket(String op) => op == OpConst.openBracket;

  static bool isCloseBracket(String op) => op == OpConst.closeBracket;

  static bool isBracket(String op) => isOpenBracket(op) || isCloseBracket(op);

  static bool isLowOp(String op) =>
      isAddOp(op) || isMinusOp(op) || isReverseMinusOp(op);

  static bool isHighOp(String op) =>
      isMulOp(op) || isDivOp(op) || isReverseDivOp(op);

  static bool isAllLowOp(List<String> opList) =>
      opList.isNotEmpty && opList.every((op) => isLowOp(op));

  static bool isAllHighOp(List<String> opList) =>
      opList.isNotEmpty && opList.every((op) => isHighOp(op));

  static bool containsLowOp(String formula) =>
      formula.contains(OpConst.addOp) || formula.contains(OpConst.minusOp);

  static bool containsHighOp(String formula) =>
      formula.contains(OpConst.calMulOp) || formula.contains(OpConst.calDivOp);
}
