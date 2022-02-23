import 'package:combine24/services/answer_service.dart';
import 'package:function_tree/function_tree.dart';
import 'package:collection/collection.dart';

class DefaultAnswerService implements AnswerService {
  static Function unOrdDeepEq = const DeepCollectionEquality.unordered().equals;
  static const String bracketRegExp = r"(?<=\))|(?=\()";

  @override
  int matchAnswer(String answer, List<String> solutionList) {
    answer = cleanBracket(answer);

    return 1;
  }

  @override
  bool canCombine24(String answer) => answer.interpret().compareTo(24) == 0;

  List<Object> buildElemList(String formula) {
    List<Object> fullElemList = <Object>[];

    return fullElemList;
  }

  List<int> getOpOrder(String formula) {
    return [];
  }

  String cleanBracket(String formula) {
    List<String> partList = formula.split(RegExp(bracketRegExp));
    List<bool> hasBracketList = partList.map((p) => p.contains("(")).toList();
    List<bool> hasLowOpList =
        partList.map((p) => p.contains("+") || p.contains("-")).toList();
    List<bool> hasHighOpList =
        partList.map((p) => p.contains("x") || p.contains("÷")).toList();
    for (int index = 0; index < partList.length; index++) {
      if (hasBracketList[index] &&
          (!hasLowOpList[index] ||
              (hasLowOpList[index] &&
                  (index - 1 < 0 || !hasHighOpList[index - 1]) &&
                  (index + 1 >= partList.length ||
                      !hasHighOpList[index + 1])))) {
        partList[index] = partList[index].replaceAll("(", "");
        partList[index] = partList[index].replaceAll(")", "");
        if (index - 1 >= 0 && partList[index - 1].contains("-")) {
          partList[index] = partList[index].replaceAll("+", "@");
          partList[index] = partList[index].replaceAll("-", "+");
          partList[index] = partList[index].replaceAll("@", "-");
        } else if (index - 1 >= 0 && partList[index - 1].contains("÷")) {
          partList[index] = partList[index].replaceAll("x", "@");
          partList[index] = partList[index].replaceAll("÷", "x");
          partList[index] = partList[index].replaceAll("@", "÷");
        }
      }
    }
    return partList.join("");
  }
}
