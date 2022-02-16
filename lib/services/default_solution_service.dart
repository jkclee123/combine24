import 'package:combine24/services/solution_service.dart';
import 'package:function_tree/function_tree.dart';
import 'package:tuple/tuple.dart';

class DefaultSolutionService implements SolutionService {
  static const String hintRegExp = r' .*? .*? ';
  static const String divOneRegExp = r'\/1[\+\-\*\/\)]|\/1$';
  static const Map<String, String> cardTranslateMap = {
    "J": "11",
    "Q": "12",
    "K": "13",
    "A": "1",
  };
  static const Map<String, String> opTranslateMap = {
    "+": " + ",
    "-": " - ",
    "*": " x ",
    "/": " ÷ ",
  };
  static const List<String> opList = ["+", "-", "*", "/", "r-", "r/"];
  static const List<String> lowOpList = ["+", "-"];
  static const List<String> highOpList = ["*", "/"];
  static const List<String> lowOpWithRList = ["+", "-", "r-"];
  static const List<String> highOpWithRList = ["*", "/", "r/"];

  bool isReverseOp(String op) => op.contains('r');

  bool isAddOp(String op) => op == '+';

  bool isMinusOp(String op) => op == '-';

  bool isMulOp(String op) => op == '*';

  bool isDivOp(String op) => op == '/';

  bool isReverseMinusOp(String op) => op == 'r-';

  bool isReverseDivOp(String op) => op == 'r/';

  bool isLowOp(String op) =>
      isAddOp(op) || isMinusOp(op) || isReverseMinusOp(op);

  bool isHighOp(String op) => isMulOp(op) || isDivOp(op) || isReverseDivOp(op);

  bool canCombine24(String formula) => formula.interpret().compareTo(24) == 0;

  bool containsDivOne(String formula) => formula.contains(RegExp(divOneRegExp));

  bool isValidFormula(String a, String b, String op) =>
      !(b.interpret().compareTo(1) == 0 && isDivOp(op)) &&
      !(a.interpret().compareTo(1) == 0 && isReverseDivOp(op)) &&
      buildFormula(a, b, op).interpret() is int &&
      !buildFormula(a, b, op).interpret().isNegative;

  bool isValidTwoPairOp(String op1, String op2, String op3) =>
      !((isLowOp(op1) && isLowOp(op2) && isLowOp(op3)) ||
          (isHighOp(op1) && isHighOp(op2) && isHighOp(op3))) &&
      !((isDivOp(op3) && isMulOp(op2)) ||
          (isReverseDivOp(op1) && isMulOp(op3))) &&
      !((isAddOp(op3) || isMinusOp(op3)) && isReverseMinusOp(op2));

  bool isMulOne(String a, String b, String op) =>
      isMulOp(op) && (a == '1' || b == '1');

  @override
  List<String> findSolutions(List<String> cardList) {
    List<String> solutionList = <String>[];
    List<String> mathCardList =
        cardList.map((card) => translateCard(card)).toList();
    mathCardList.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    Map<Tuple2, List<String>> pairSingleMap = buildPairSingleMap(mathCardList);
    Map<Tuple2, Tuple2> twoPairMap = buildTwoPairMap(pairSingleMap);
    Map<Tuple3, String> tripletSingleMap = buildTripletSingleMap(mathCardList);
    solutionList.addAll(buildAllLowSolutionList(mathCardList));
    solutionList.addAll(buildAllHighSolutionList(mathCardList));
    solutionList.addAll(buildLowTripletSolutionList(tripletSingleMap));
    solutionList.addAll(buildHighTripletSolutionList(tripletSingleMap));
    solutionList.addAll(buildLowPairSolutionList(pairSingleMap));
    solutionList.addAll(buildHighPairSolutionList(pairSingleMap));
    solutionList.addAll(buildTwoPairSolutionList(twoPairMap));
    solutionList =
        solutionList.map((solution) => translateSolution(solution)).toList();
    return solutionList;
  }

  @override
  List<String> extractHint(List<String> solutionList) {
    return solutionList.map((solution) {
      RegExp regexp = RegExp(hintRegExp);
      int endIndex = regexp.allMatches(solution).first.end - 1;
      return solution.substring(0, endIndex);
    }).toList();
  }

  String translateCard(String card) {
    cardTranslateMap
        .forEach((key, value) => card = card.replaceAll(key, value));
    return card;
  }

  String translateSolution(String solution) {
    opTranslateMap
        .forEach((key, value) => solution = solution.replaceAll(key, value));
    return solution;
  }

  String addBracket(String formula) => "($formula)";

  String buildFormula(String a, String b, String op) {
    if (isReverseOp(op)) {
      return "$b${op.replaceAll('r', '')}$a";
    } else {
      return "$a$op$b";
    }
  }

  Map<Tuple2, List<String>> buildPairSingleMap(List<String> mathCardList) {
    Map<Tuple2, List<String>> pairSingleMap = <Tuple2, List<String>>{};
    for (int index1 = 0; index1 < mathCardList.length; index1++) {
      for (int index2 = index1 + 1; index2 < mathCardList.length; index2++) {
        List<String> dummyCardList = List<String>.from(mathCardList);
        String card1 = mathCardList.elementAt(index1);
        String card2 = mathCardList.elementAt(index2);
        Tuple2 cardPair = Tuple2(card1, card2);
        dummyCardList.remove(card1);
        dummyCardList.remove(card2);
        pairSingleMap[cardPair] = dummyCardList;
      }
    }
    return pairSingleMap;
  }

  Map<Tuple2, Tuple2> buildTwoPairMap(Map<Tuple2, List<String>> pairSingleMap) {
    Set<Tuple2> addedPair = <Tuple2>{};
    Map<Tuple2, Tuple2> twoPairMap = <Tuple2, Tuple2>{};
    pairSingleMap.forEach((pair1, singleList) {
      Tuple2 pair2 = Tuple2.fromList(singleList);
      if (!(addedPair.contains(pair1) || addedPair.contains(pair2))) {
        twoPairMap[pair1] = pair2;
      }
      addedPair.addAll({pair1, pair2});
    });
    return twoPairMap;
  }

  Map<Tuple3, String> buildTripletSingleMap(List<String> mathCardList) {
    Map<Tuple3, String> tripletSingleMap = <Tuple3, String>{};
    for (String single in mathCardList) {
      List<String> dummyCardList = List<String>.from(mathCardList);
      dummyCardList.remove(single);
      Tuple3 triplet = Tuple3.fromList(dummyCardList);
      tripletSingleMap[triplet] = single;
    }
    return tripletSingleMap;
  }

  List<String> buildAllLowSolutionList(List<String> mathCardList) {
    Set<String> formulaSet = <String>{};
    List<List<String>> opCard2dList = [
      for (String card in mathCardList)
        [for (String op in lowOpList) "$op$card"]
    ];
    List<List<String>> opCardComb2dList = [
      for (String opCard1 in opCard2dList[0])
        for (String opCard2 in opCard2dList[1])
          for (String opCard3 in opCard2dList[2])
            for (String opCard4 in opCard2dList[3])
              [opCard1, opCard2, opCard3, opCard4]
    ];
    for (List<String> opCardCombList in opCardComb2dList) {
      opCardCombList.sort();
      opCardCombList[0] = opCardCombList[0].substring(1);
      formulaSet.add(opCardCombList.join());
    }
    return formulaSet.where((formula) => canCombine24(formula)).toList();
  }

  List<String> buildAllHighSolutionList(List<String> mathCardList) {
    Set<String> formulaSet = <String>{};
    List<List<String>> opCard2dList = [
      for (String card in mathCardList)
        [for (String op in highOpList) "$op$card"]
    ];
    List<List<String>> opCardComb2dList = [
      for (String opCard1 in opCard2dList[0])
        for (String opCard2 in opCard2dList[1])
          for (String opCard3 in opCard2dList[2])
            for (String opCard4 in opCard2dList[3])
              [opCard1, opCard2, opCard3, opCard4]
    ];
    for (List<String> opCardCombList in opCardComb2dList) {
      opCardCombList.sort();
      opCardCombList[0] = opCardCombList[0].substring(1);
      formulaSet.add(opCardCombList.join());
    }
    return formulaSet
        .where((formula) => canCombine24(formula) && !containsDivOne(formula))
        .toList();
  }

  List<String> buildLowTripletSolutionList(
      Map<Tuple3, String> tripletSingleMap) {
    Set<String> formulaSet = <String>{};
    tripletSingleMap.forEach((triplet, single) {
      List<List<String>> opCard2dList = [
        for (String card in triplet.toList())
          [for (String op in lowOpList) "$op$card"]
      ];
      List<List<String>> opCardComb2dList = [
        for (String opCard1 in opCard2dList[0])
          for (String opCard2 in opCard2dList[1])
            for (String opCard3 in opCard2dList[2]) [opCard1, opCard2, opCard3]
      ];
      for (List<String> opCardCombList in opCardComb2dList) {
        opCardCombList.sort();
        opCardCombList[0] = opCardCombList[0].substring(1);
        String tripletFormula = addBracket(opCardCombList.join());
        for (String op in highOpWithRList) {
          String formula = buildFormula(tripletFormula, single, op);
          formulaSet.add(formula);
        }
      }
    });
    return formulaSet
        .where((formula) => canCombine24(formula) && !containsDivOne(formula))
        .toList();
  }

  List<String> buildHighTripletSolutionList(
      Map<Tuple3, String> tripletSingleMap) {
    Set<String> formulaSet = <String>{};
    tripletSingleMap.forEach((triplet, single) {
      List<List<String>> opCard2dList = [
        for (String card in triplet.toList())
          [for (String op in highOpList) "$op$card"]
      ];
      List<List<String>> opCardComb2dList = [
        for (String opCard1 in opCard2dList[0])
          for (String opCard2 in opCard2dList[1])
            for (String opCard3 in opCard2dList[2]) [opCard1, opCard2, opCard3]
      ];
      for (List<String> opCardCombList in opCardComb2dList) {
        opCardCombList.sort();
        opCardCombList[0] = opCardCombList[0].substring(1);
        String tripletFormula = opCardCombList.join();
        for (String op in lowOpWithRList) {
          String formula = buildFormula(tripletFormula, single, op);
          formulaSet.add(formula);
        }
      }
    });
    return formulaSet
        .where((formula) => canCombine24(formula) && !containsDivOne(formula))
        .toList();
  }

  List<String> buildLowPairSolutionList(
      Map<Tuple2, List<String>> pairSingleMap) {
    Set<String> formulaSet = <String>{};
    pairSingleMap.forEach((pair, singleList) {
      for (String op1 in lowOpWithRList) {
        if (!isValidFormula(pair.item1, pair.item2, op1)) {
          continue;
        }
        String formula1 = addBracket(buildFormula(pair.item1, pair.item2, op1));
        for (String card in singleList) {
          List<String> dummySingleList = List<String>.from(singleList);
          dummySingleList.remove(card);
          for (String op2 in highOpWithRList) {
            if (!isValidFormula(formula1, card, op2)) {
              continue;
            }
            String formula2 = buildFormula(formula1, card, op2);
            for (String op3 in lowOpWithRList) {
              if (!isValidFormula(formula2, dummySingleList.first, op3)) {
                continue;
              }
              formulaSet
                  .add(buildFormula(formula2, dummySingleList.first, op3));
            }
          }
        }
      }
    });
    return formulaSet.where((formula) => canCombine24(formula)).toList();
  }

  // (2 high 1 low) 1 high
  List<String> buildHighPairSolutionList(
      Map<Tuple2, List<String>> pairSingleMap) {
    Set<String> formulaSet = <String>{};
    pairSingleMap.forEach((pair, singleList) {
      for (String op1 in highOpWithRList) {
        if (!isValidFormula(pair.item1, pair.item2, op1) ||
            isMulOne(pair.item1, pair.item2, op1)) {
          continue;
        }
        String formula1 = buildFormula(pair.item1, pair.item2, op1);
        for (String card in singleList) {
          List<String> dummySingleList = List<String>.from(singleList);
          dummySingleList.remove(card);
          for (String op2 in lowOpWithRList) {
            if (!isValidFormula(formula1, card, op2)) {
              continue;
            }
            String formula2 = addBracket(buildFormula(formula1, card, op2));
            for (String op3 in highOpWithRList) {
              if (!isValidFormula(formula2, dummySingleList.first, op3)) {
                continue;
              }
              formulaSet
                  .add(buildFormula(formula2, dummySingleList.first, op3));
            }
          }
        }
      }
    });
    return formulaSet.where((formula) => canCombine24(formula)).toList();
  }

  List<String> buildTwoPairSolutionList(Map<Tuple2, Tuple2> twoPairMap) {
    Set<String> formulaSet = <String>{};
    twoPairMap.forEach((pair1, pair2) {
      for (String op1 in opList) {
        if (!isValidFormula(pair1.item1, pair1.item2, op1)) {
          continue;
        }
        String formula1 = buildFormula(pair1.item1, pair1.item2, op1);
        for (String op2 in opList) {
          if (!isValidFormula(pair2.item1, pair2.item2, op2)) {
            continue;
          }
          String formula2 = buildFormula(pair2.item1, pair2.item2, op2);
          for (String op3 in opList) {
            if (!isValidFormula(formula1, formula2, op3) ||
                !isValidTwoPairOp(op1, op2, op3)) {
              continue;
            }
            String firstFormula =
                isLowOp(op1) && isHighOp(op3) ? addBracket(formula1) : formula1;
            String secondFormula =
                isLowOp(op2) && isHighOp(op3) ? addBracket(formula2) : formula2;
            formulaSet.add(buildFormula(firstFormula, secondFormula, op3));
          }
        }
      }
    });
    return formulaSet.where((formula) => canCombine24(formula)).toList();
  }
}
