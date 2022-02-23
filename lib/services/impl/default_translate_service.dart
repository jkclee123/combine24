import 'package:combine24/services/translate_service.dart';

class DefaultTranslateService implements TranslateService {
  static const Map<String, String> readCardTranslateMap = {
    "J": "11",
    "Q": "12",
    "K": "13",
    "A": "1",
  };
  static const Map<String, String> mathCardTranslateMap = {
    "10": "T",
    "11": "J",
    "12": "Q",
    "13": "K",
    "1": "A",
    "T": "10",
  };
  static const Map<String, String> opTranslateMap = {
    "+": " + ",
    "-": " - ",
    "*": " x ",
    "/": " ÷ ",
  };
  @override
  List<String> readCard2MathCard(List<String> cardList) {
    return cardList
        .map((card) => card = readCardTranslateMap[card] ?? card)
        .toList();
  }

  @override
  String readSolution2MathSolution(String solution) {
    readCardTranslateMap
        .forEach((key, value) => solution = solution.replaceAll(key, value));
    opTranslateMap
        .forEach((key, value) => solution = solution.replaceAll(value, key));
    return solution;
  }

  @override
  List<String> mathSolutions2ReadSolutions(List<String> solutionList) {
    return solutionList.map((solution) {
      opTranslateMap
          .forEach((key, value) => solution = solution.replaceAll(key, value));
      mathCardTranslateMap
          .forEach((key, value) => solution = solution.replaceAll(key, value));
      return solution;
    }).toList();
  }
}
