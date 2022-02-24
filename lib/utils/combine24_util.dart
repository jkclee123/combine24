import 'package:function_tree/function_tree.dart';

class Combine24Util {
  static bool canCombine24(String formula) =>
      formula.interpret().compareTo(24) == 0;
}
