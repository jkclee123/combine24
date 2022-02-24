import 'package:function_tree/function_tree.dart';

class CalUtil {
  static bool canCombine24(String formula) =>
      formula.interpret().compareTo(24) == 0;

  static bool resultIsOne(String formula) =>
      formula.interpret().compareTo(1) == 0;

  static bool resultIsPosInt(String formula) =>
      !formula.interpret().isNegative && formula.interpret() is int;
}
