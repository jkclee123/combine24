import 'package:collection/collection.dart';
import 'package:combine24/config/const.dart';
import 'package:combine24/services/schema_service.dart';
import 'package:combine24/services/impl/default_translate_service.dart';
import 'package:combine24/services/translate_service.dart';
import 'package:combine24/utils/cal_util.dart';
import 'package:combine24/utils/op_util.dart';

class DefaultSchemaService implements SchemaService {
  final TranslateService translateService;

  DefaultSchemaService({TranslateService? translateService})
      : translateService = translateService ?? DefaultTranslateService();
  static final bool Function(Object?, Object?) unOrdDeepEq = const DeepCollectionEquality.unordered().equals;
  static final RegExp bracketSplitRegex = RegExp(r"(?<=\))|(?=\()");
  static final RegExp bracketCharsRegex = RegExp(r"\(|\)");
  static final RegExp cardTokenRegex = RegExp(r"[A-Z0-9]");
  static final RegExp operatorRegex = RegExp(r"[\+\-\*\/]");

  String computeGroupHeadOperator(String op) =>
      OpUtil.isHighOp(op) ? OpConst.calMulOp : OpConst.addOp;

  String _normalizeFormula(String formula) {
    formula = translateService.read2CalFormula(formula);
    formula = cleanUnusedBracket(formula);
    formula = handleDivOne(formula);
    return formula;
  }

  ({List<Object> operands, List<String> operators, List<int> operatorOrderByIndex}) _tokenize(String normalizedFormula) {
    final operatorOrderByIndex = getOperatorOrderByIndex(normalizedFormula);
    final formulaWithoutBrackets = cleanUnusedChar(normalizedFormula);
    final operands = List<Object>.from(formulaWithoutBrackets.split(operatorRegex));
    final operators = formulaWithoutBrackets
        .replaceAll(cardTokenRegex, Const.emptyString)
        .split(Const.emptyString);
    return (operands: operands, operators: operators, operatorOrderByIndex: operatorOrderByIndex);
  }

  List<Object> _buildGroupSchema(List<Object> groupOperands, List<String> groupOperators) {
    final groupSchema = <Object>[];
    for (int index = 0; index < groupOperands.length; index++) {
      groupSchema.add([groupOperators[index], groupOperands[index]]);
    }
    return groupSchema;
  }

  String _flipAddMinusInsideGroup(String s) {
    return s
        .replaceAll(OpConst.addOp, Const.tempSign)
        .replaceAll(OpConst.minusOp, OpConst.addOp)
        .replaceAll(Const.tempSign, OpConst.minusOp);
  }

  String _flipMulDivInsideGroup(String s) {
    return s
        .replaceAll(OpConst.calMulOp, Const.tempSign)
        .replaceAll(OpConst.calDivOp, OpConst.calMulOp)
        .replaceAll(Const.tempSign, OpConst.calDivOp);
  }

  /// Builds a hierarchical schema representing the mathematical structure of a formula.
  ///
  /// The schema is a nested list structure where each element is either a terminal value
  /// (card/token) or a list representing an operation with [operator, operand] pairs.
  /// Higher-precedence operations are grouped first, creating a tree structure.
  @override
  Object buildFormulaSchema(String formula) {
    final normalizedFormula = _normalizeFormula(formula);
    final tokenization = _tokenize(normalizedFormula);
    final operandTokens = tokenization.operands;
    final operatorTokens = tokenization.operators;
    final operatorOrderByIndex = tokenization.operatorOrderByIndex;

    while (operatorOrderByIndex.isNotEmpty) {
      final minOrder = operatorOrderByIndex.reduce((a, b) => a < b ? a : b);
      final startIndex = operatorOrderByIndex.indexOf(minOrder);
      final groupOperands = <Object>[operandTokens.removeAt(startIndex)];
      final groupOperators = <String>[computeGroupHeadOperator(operatorTokens[startIndex])];
      final groupIndexList = <int>[];

      for (int index = startIndex;
          index < operatorOrderByIndex.length && operatorOrderByIndex[index] == minOrder;
          index++) {
        groupOperands.add(operandTokens[index]);
        groupOperators.add(operatorTokens[index]);
        groupIndexList.add(index);
      }

      // Remove processed elements in reverse order to maintain indices
      for (final index in groupIndexList.reversed) {
        operandTokens.removeAt(index);
        operatorTokens.removeAt(index);
        operatorOrderByIndex.removeAt(index);
      }

      if (groupIndexList.isNotEmpty) {
        final groupSchema = _buildGroupSchema(groupOperands, groupOperators);
        final insertIndex = groupIndexList.reduce((a, b) => a < b ? a : b);
        operandTokens.insert(insertIndex, groupSchema);
      }
    }

    if (operandTokens.isEmpty) return Const.emptyString;
    if (operandTokens.length == 1 && operandTokens[0] == Const.emptyString) return Const.emptyString;
    return operandTokens[0];
  }

  /// Computes operator precedence order for each operator in the formula.
  ///
  /// Returns a list where each element corresponds to an operator's precedence level:
  /// - 0: multiplication/division inside parentheses (highest precedence when nested)
  /// - 1: addition/subtraction inside parentheses
  /// - 2: multiplication/division (normal precedence)
  /// - 3: addition/subtraction (lowest precedence)
  ///
  /// The returned list has the same length as the number of operators in the formula.
  List<int> getOperatorOrderByIndex(String formula) {
    final operatorOrderByIndex = <int>[];
    formula = formula.replaceAll(cardTokenRegex, Const.emptyString);
    int bracketDepth = 0;
    for (final op in formula.split(Const.emptyString)) {
      if (OpUtil.isOpenBracket(op)) {
        bracketDepth++;
      } else if (OpUtil.isCloseBracket(op)) {
        bracketDepth--;
      } else {
        int order = -1;
        if (OpUtil.isHighOp(op)) {
          order = 2;
        } else if (OpUtil.isLowOp(op)) {
          order = 3;
        }
        order -= 2 * bracketDepth;
        operatorOrderByIndex.add(order);
      }
    }
    return operatorOrderByIndex;
  }

  String cleanUnusedChar(String formula) {
    return formula.replaceAll(bracketCharsRegex, Const.emptyString);
  }

  String handleDivOne(String formula) {
    if (CalUtil.containsDivOne(formula)) {
      formula = formula.replaceAll(OpConst.divOne, OpConst.mulOne);
    }
    List<String> partList = formula.split(bracketSplitRegex);
    for (int index = 0; index < partList.length; index++) {
      if (partList[index].contains(OpConst.openBracket) &&
          CalUtil.resultIsOne(partList[index]) &&
          (index - 1 >= 0 && partList[index - 1].endsWith(OpConst.calDivOp))) {
        partList[index - 1] = partList[index - 1].replaceFirst(
            OpConst.calDivOp, OpConst.calMulOp, partList[index - 1].length - 1);
      }
    }
    return partList.join();
  }

  bool _shouldCleanBrackets(List<String> partList, int index) {
    return partList[index].contains(OpConst.openBracket) &&
        (!OpUtil.containsLowOp(partList[index]) ||
            (OpUtil.containsLowOp(partList[index]) &&
                (index - 1 < 0 ||
                    !OpUtil.connectOpIsHighOp(partList[index - 1])) &&
                (index + 1 >= partList.length ||
                    !OpUtil.connectOpIsHighOp(partList[index + 1]))));
  }

  String cleanUnusedBracket(String formula) {
    List<String> partList = formula.split(bracketSplitRegex);
    for (int index = 0; index < partList.length; index++) {
      if (_shouldCleanBrackets(partList, index)) {
        partList[index] =
            partList[index].replaceAll(OpConst.openBracket, Const.emptyString);
        partList[index] =
            partList[index].replaceAll(OpConst.closeBracket, Const.emptyString);
        if (index - 1 >= 0 && partList[index - 1].contains(OpConst.minusOp)) {
          partList[index] = _flipAddMinusInsideGroup(partList[index]);
        } else if (index - 1 >= 0 &&
            partList[index - 1].contains(OpConst.calDivOp)) {
          partList[index] = _flipMulDivInsideGroup(partList[index]);
        }
      }
    }
    return partList.join();
  }

  /// Removes duplicate formulas that have the same mathematical structure.
  ///
  /// Compares formulas by their schema representation and returns only unique ones.
  /// The first occurrence of each unique schema is preserved.
  @override
  List<String> removeSameSchema(List<String> formulaList) {
    List<String> resultList = <String>[];
    List<Object> schemaList = <Object>[];
    for (String formula in formulaList) {
      Object nextSchema = buildFormulaSchema(formula);
      bool isSame = false;
      for (Object schema in schemaList) {
        if (unOrdDeepEq(nextSchema, schema)) {
          isSame = true;
          break;
        }
      }
      if (!isSame) {
        schemaList.add(nextSchema);
        resultList.add(formula);
      }
    }
    return resultList;
  }

  /// Finds the index of a formula in a list that has the same mathematical structure.
  ///
  /// Returns the index of the first matching formula, or -1 if no match is found.
  /// Matching is based on schema equality, not string equality.
  @override
  int matchFormula(String formula, List<String> formulaList) {
    Object answerSchema = buildFormulaSchema(formula);
    List<Object> solutionSchemaList =
        formulaList.map((s) => buildFormulaSchema(s)).toList();
    for (int index = 0; index < solutionSchemaList.length; index++) {
      Object solutionSchema = solutionSchemaList[index];
      if (unOrdDeepEq(answerSchema, solutionSchema)) {
        return index;
      }
    }
    return -1;
  }

  /// Checks if two formulas have the same mathematical structure.
  ///
  /// Returns 1 if the formulas are structurally equivalent, -1 otherwise.
  /// This is a convenience method that returns the result as an integer for consistency
  /// with other matching methods in the service.
  @override
  int matchSingleFormula(String formula1, String formula2) {
    Object answerSchema = buildFormulaSchema(formula1);
    Object solutionSchema = buildFormulaSchema(formula2);
    if (unOrdDeepEq(answerSchema, solutionSchema)) {
      return 1;
    }
    return -1;
  }
}
