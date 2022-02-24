import 'package:combine24/config/const.dart';
import 'package:combine24/services/answer_service.dart';
import 'package:collection/collection.dart';
import 'package:combine24/utils/op_util.dart';

class DefaultAnswerService implements AnswerService {
  static Function unOrdDeepEq = const DeepCollectionEquality.unordered().equals;
  static const String bracketRegExp = r"(?<=\))|(?=\()";

  @override
  int matchAnswer(String answer, List<String> solutionList) {
    answer = cleanBracket(answer);

    return 1;
  }

  List<Object> buildElemList(String formula) {
    List<Object> fullElemList = <Object>[];

    return fullElemList;
  }

  List<int> getOpOrder(String formula) {
    return [];
  }

  String cleanBracket(String formula) {
    List<String> partList = formula.split(RegExp(bracketRegExp));
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
