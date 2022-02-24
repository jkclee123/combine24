import 'dart:math';

import 'package:combine24/config/const.dart';
import 'package:combine24/services/answer_service.dart';
import 'package:collection/collection.dart';
import 'package:combine24/utils/op_util.dart';

class DefaultAnswerService implements AnswerService {
  static Function unOrdDeepEq = const DeepCollectionEquality.unordered().equals;
  static const String bracketSplitRegExp = r"(?<=\))|(?=\()";
  static const String bracketRegExp = r"\(|\)";
  static const String cardRegExp = r"[A-Z0-9]";
  static const String opRegExp = r"[\+\-x÷]";

  String getHeadOp(String op) =>
      OpUtil.isMulOp(op) ? OpConst.readMulOp : OpConst.addOp;

  @override
  int matchAnswer(String answer, List<String> solutionList) {
    Object answerSchema = buildFormulaSchema(answer);
    List<Object> solutionSchemaList =
        solutionList.map((s) => buildFormulaSchema(s)).toList();
    for (int index = 0; index < solutionSchemaList.length; index++) {
      Object solutionSchema = solutionSchemaList[index];
      if (unOrdDeepEq(answerSchema, solutionSchema)) {
        return index;
      }
    }
    return -1;
  }

  @override
  Object buildFormulaSchema(String formula) {
    formula = formula.replaceAll(Const.space, Const.emptyString);
    formula = cleanUnusedBracket(formula);
    List<int> orderList = getOpOrder(formula);
    formula = cleanUnusedChar(formula);
    List<Object> cardList = List<Object>.from(formula.split(RegExp(opRegExp)));
    List<String> opList = formula
        .replaceAll(RegExp(cardRegExp), Const.emptyString)
        .split(Const.emptyString);
    while (orderList.isNotEmpty) {
      int minOrder = orderList.reduce(min);
      int startIndex = orderList.indexOf(minOrder);
      List<Object> groupCardList = <Object>[cardList.removeAt(startIndex)];
      List<String> groupOpList = <String>[getHeadOp(opList[startIndex])];
      List<int> groupIndexList = <int>[];
      for (int index = startIndex;
          index < orderList.length && orderList[index] == minOrder;
          index++) {
        groupCardList.add(cardList[index]);
        groupOpList.add(opList[index]);
        groupIndexList.add(index);
      }
      for (int index in groupIndexList.reversed) {
        cardList.removeAt(index);
        opList.removeAt(index);
        orderList.removeAt(index);
      }
      List<Object> schemaList = <Object>[];
      for (int index = 0; index < groupCardList.length; index++) {
        schemaList.add([groupOpList[index], groupCardList[index]]);
      }
      cardList.insert(groupIndexList.reduce(min), schemaList);
    }
    return cardList[0];
  }

  /// Order 0: (x÷)
  /// Order 1: (+-)
  /// Order 2: x÷
  /// Order 3: +-
  List<int> getOpOrder(String formula) {
    List<int> orderList = <int>[];
    formula = formula.replaceAll(RegExp(cardRegExp), Const.emptyString);
    bool isInBracket = false;
    for (String op in formula.split(Const.emptyString)) {
      int order = -1;
      if (OpUtil.isBracket(op)) {
        isInBracket = !isInBracket;
      } else if (OpUtil.isHighOp(op)) {
        order = 2;
      } else if (OpUtil.isLowOp(op)) {
        order = 3;
      }
      if (isInBracket) {
        order -= 2;
      }
      if (!OpUtil.isBracket(op)) {
        orderList.add(order);
      }
    }
    return orderList;
  }

  String cleanUnusedChar(String formula) {
    return formula.replaceAll(RegExp(bracketRegExp), Const.emptyString);
  }

  String cleanUnusedBracket(String formula) {
    List<String> partList = formula.split(RegExp(bracketSplitRegExp));
    List<bool> hasBracketList =
        partList.map((p) => p.contains(OpConst.openBracket)).toList();
    List<bool> hasLowOpList =
        partList.map((p) => OpUtil.containsLowReadOp(p)).toList();
    List<bool> hasHighOpList =
        partList.map((p) => OpUtil.containsHighReadOp(p)).toList();
    for (int index = 0; index < partList.length; index++) {
      if (hasBracketList[index] &&
          (!hasLowOpList[index] ||
              (hasLowOpList[index] &&
                  (index - 1 < 0 || !hasHighOpList[index - 1]) &&
                  (index + 1 >= partList.length ||
                      !hasHighOpList[index + 1])))) {
        partList[index] =
            partList[index].replaceAll(OpConst.openBracket, Const.emptyString);
        partList[index] =
            partList[index].replaceAll(OpConst.closeBracket, Const.emptyString);
        if (index - 1 >= 0 && partList[index - 1].contains(OpConst.minusOp)) {
          partList[index] =
              partList[index].replaceAll(OpConst.addOp, Const.tempSign);
          partList[index] =
              partList[index].replaceAll(OpConst.minusOp, OpConst.addOp);
          partList[index] =
              partList[index].replaceAll(Const.tempSign, OpConst.minusOp);
        } else if (index - 1 >= 0 &&
            partList[index - 1].contains(OpConst.readDivOp)) {
          partList[index] =
              partList[index].replaceAll(OpConst.readMulOp, Const.tempSign);
          partList[index] =
              partList[index].replaceAll(OpConst.readDivOp, OpConst.readMulOp);
          partList[index] =
              partList[index].replaceAll(Const.tempSign, OpConst.readDivOp);
        }
      }
    }
    return partList.join(Const.emptyString);
  }
}
