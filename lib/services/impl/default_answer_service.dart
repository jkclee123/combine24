import 'package:combine24/services/answer_service.dart';
import 'package:collection/collection.dart';
import 'package:function_tree/function_tree.dart';

class DefaultAnswerService implements AnswerService {
  static Function unOrdDeepEq = const DeepCollectionEquality.unordered().equals;

  @override
  int matchAnswer(String answer, List<String> solutionList) {
    print(answer);
    print(solutionList);
    return 1;
  }

  @override
  bool canCombine24(String answer) => answer.interpret().compareTo(24) == 0;

  Set<Set<String>> buildCombSet(String solution) {
    Set<Set<String>> allCombSet = <Set<String>>{};

    return allCombSet;
  }
}
