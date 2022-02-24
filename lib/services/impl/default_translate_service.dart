import 'package:combine24/config/const.dart';
import 'package:combine24/services/translate_service.dart';

class DefaultTranslateService implements TranslateService {
  static const Map<String, String> readCardTranslateMap = {
    "J": "11",
    "Q": "12",
    "K": "13",
    "A": "1",
  };
  static const Map<String, String> calCardTranslateMap = {
    "10": "T",
    "11": "J",
    "12": "Q",
    "13": "K",
    "1": "A",
    "T": "10",
  };
  static const Map<String, String> opTranslateMap = {
    OpConst.addOp: " ${OpConst.addOp} ",
    OpConst.minusOp: " ${OpConst.minusOp} ",
    OpConst.calMulOp: " ${OpConst.readMulOp} ",
    OpConst.calDivOp: " ${OpConst.readDivOp} ",
  };
  @override
  List<String> read2CalCard(List<String> cardList) {
    return cardList
        .map((card) => card = readCardTranslateMap[card] ?? card)
        .toList();
  }

  @override
  String read2CalFormula(String formula) {
    readCardTranslateMap
        .forEach((key, value) => formula = formula.replaceAll(key, value));
    opTranslateMap
        .forEach((key, value) => formula = formula.replaceAll(value, key));
    return formula;
  }

  @override
  List<String> cal2ReadFormulaList(List<String> formulaList) {
    return formulaList.map((solution) {
      opTranslateMap
          .forEach((key, value) => solution = solution.replaceAll(key, value));
      calCardTranslateMap
          .forEach((key, value) => solution = solution.replaceAll(key, value));
      return solution;
    }).toList();
  }
}
