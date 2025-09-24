import 'package:combine24/config/const.dart';
import 'package:combine24/services/translate_service.dart';

/// Service for translating between display and calculation representations
/// of cards and mathematical operations in the 24 game.
class DefaultTranslateService implements TranslateService {
  /// Maps display card representations to calculation values.
  /// Face cards (J, Q, K) and Ace (A) are converted to their numeric equivalents.
  static const Map<String, String> readCardTranslateMap = {
    "J": "11",
    "Q": "12",
    "K": "13",
    "A": "1",
  };

  /// Maps calculation card values back to display representations.
  /// Includes special handling for 10 ("T") to avoid confusion with "1"+"0".
  static const Map<String, String> calCardTranslateMap = {
    "10": "T",
    "11": "J",
    "12": "Q",
    "13": "K",
    "1": "A",
    "T": "10",
  };

  /// Maps calculation operators to display operators with proper spacing.
  /// Multiplication (*) becomes " x ", division (/) becomes " ÷ ".
  static const Map<String, String> opTranslateMap = {
    OpConst.addOp: " ${OpConst.addOp} ",
    OpConst.minusOp: " ${OpConst.minusOp} ",
    OpConst.calMulOp: " ${OpConst.readMulOp} ",
    OpConst.calDivOp: " ${OpConst.readDivOp} ",
  };

  @override
  List<String> read2CalCard(List<String> cardList) {
    return cardList
        .map((card) => readCardTranslateMap[card] ?? card)
        .toList();
  }

  @override
  String read2CalFormula(String formula) {
    // Convert display cards to calculation values
    readCardTranslateMap.forEach((display, calc) {
      formula = formula.replaceAll(display, calc);
    });

    // Convert display operators back to calculation operators
    opTranslateMap.forEach((calc, display) {
      formula = formula.replaceAll(display, calc);
    });

    return formula;
  }

  @override
  List<String> cal2ReadFormulaList(List<String> formulaList) {
    return formulaList.map((solution) {
      // Convert calculation operators to display operators
      opTranslateMap.forEach((calc, display) {
        solution = solution.replaceAll(calc, display);
      });

      // Convert calculation card values to display representations
      calCardTranslateMap.forEach((calc, display) {
        solution = solution.replaceAll(calc, display);
      });

      return solution;
    }).toList();
  }
}
