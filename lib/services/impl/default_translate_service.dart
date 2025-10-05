import 'package:combine24/config/const.dart';
import 'package:combine24/services/translate_service.dart';

/// Service for translating between display and calculation representations
/// of cards and mathematical operations in the 24 game.
class DefaultTranslateService implements TranslateService {
  /// Maps calculation operators to display operators with proper spacing.
  /// Multiplication (*) becomes " x ", division (/) becomes " ÷ ".
  static const Map<String, String> opTranslateMap = {
    OpConst.addOp: " ${OpConst.addOp} ",
    OpConst.minusOp: " ${OpConst.minusOp} ",
    OpConst.calMulOp: " ${OpConst.readMulOp} ",
    OpConst.calDivOp: " ${OpConst.readDivOp} ",
  };

  @override
  String read2CalFormula(String formula) {
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

      return solution;
    }).toList();
  }
}
