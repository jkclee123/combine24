import 'package:combine24/config/const.dart';
import 'package:combine24/services/impl/default_translate_service.dart';
import 'package:combine24/services/schema_service.dart';
import 'package:combine24/services/impl/default_schema_service.dart';
import 'package:combine24/services/solution_service.dart';
import 'package:combine24/services/translate_service.dart';
import 'package:combine24/utils/cal_util.dart';
import 'package:combine24/utils/op_util.dart';
import 'package:tuple/tuple.dart';

class DefaultSolutionService implements SolutionService {
  final TranslateService _translateService;
  final SchemaService _schemaService;
  static final RegExp _hintRegExp = RegExp(r' .*? .*? ');

  DefaultSolutionService({
    TranslateService? translateService,
    SchemaService? schemaService,
  })  : _translateService = translateService ?? DefaultTranslateService(),
        _schemaService = schemaService ?? DefaultSchemaService();

  bool _isValidFormula(String formula1, String formula2, String op) =>
      !(CalUtil.resultIsOne(formula1) && OpUtil.isReverseDivOp(op)) &&
      !(CalUtil.resultIsOne(formula2) && OpUtil.isDivOp(op)) &&
      CalUtil.resultIsPosInt(_buildFormula(formula1, formula2, op));

  bool _isMulOne(String card1, String card2, String op) =>
      OpUtil.isMulOp(op) && (card1 == '1' || card2 == '1');

  bool _isValidTwoPairOp(String firstOp, String secondOp, String midOp,
          String secondPair1, String secondPair2) =>
      !(OpUtil.isAllLowOp([firstOp, secondOp, midOp]) ||
          OpUtil.isAllHighOp([firstOp, secondOp, midOp])) &&
      !(OpUtil.isDivOp(midOp) && OpUtil.isMulOp(secondOp)) &&
      !((OpUtil.isAddOp(midOp) || OpUtil.isMinusOp(midOp)) &&
          OpUtil.isReverseMinusOp(secondOp)) &&
      !(secondPair1 == secondPair2 &&
          OpUtil.isMinusOp(midOp) &&
          OpUtil.isAddOp(secondOp));

  @override
  List<String> findSolutions(List<String> cardList) {
    List<String> solutionList = <String>[];
    List<String> mathCardList = _translateService.read2CalCard(cardList);
    mathCardList
        .sort((card1, card2) => int.parse(card1).compareTo(int.parse(card2)));
    Map<Tuple2<String, String>, List<String>> pairSingleMap = _buildPairSingleMap(mathCardList);
    Map<Tuple2<String, String>, Tuple2<String, String>> twoPairMap = _buildTwoPairMap(pairSingleMap);
    Map<Tuple3<String, String, String>, String> tripletSingleMap = _buildTripletSingleMap(mathCardList);
    solutionList.addAll(_buildAllLowSolutionList(mathCardList));
    solutionList.addAll(_buildAllHighSolutionList(mathCardList));
    solutionList.addAll(_buildLowTripletSolutionList(tripletSingleMap));
    solutionList.addAll(_buildHighTripletSolutionList(tripletSingleMap));
    solutionList.addAll(_buildLowPairSolutionList(pairSingleMap));
    solutionList.addAll(_buildHighPairSolutionList(pairSingleMap));
    solutionList.addAll(_buildTwoPairSolutionList(twoPairMap));
    solutionList = _translateService.cal2ReadFormulaList(solutionList);
    solutionList = _schemaService.removeSameSchema(solutionList);
    return solutionList;
  }


  @override
  List<String> extractHint(List<String> solutionList) {
    return solutionList.map((solution) {
      final Match firstMatch = _hintRegExp.allMatches(solution).first;
      int endIndex = firstMatch.end - 1;
      return solution.substring(0, endIndex);
    }).toList();
  }

  String _addBracket(String formula) => "($formula)";

  String _buildFormula(String a, String b, String op) {
    if (OpUtil.isReverseOp(op)) {
      return "$b${op.replaceAll(OpConst.reverseIdentifier, Const.emptyString)}$a";
    } else {
      return "$a$op$b";
    }
  }

  Map<Tuple2<String, String>, List<String>> _buildPairSingleMap(List<String> mathCardList) {
    Map<Tuple2<String, String>, List<String>> pairSingleMap = <Tuple2<String, String>, List<String>>{};
    for (int index1 = 0; index1 < mathCardList.length; index1++) {
      for (int index2 = index1 + 1; index2 < mathCardList.length; index2++) {
        List<String> dummyCardList = List<String>.from(mathCardList);
        String card1 = mathCardList[index1];
        String card2 = mathCardList[index2];
        Tuple2<String, String> cardPair = Tuple2(card1, card2);
        dummyCardList.remove(card1);
        dummyCardList.remove(card2);
        pairSingleMap[cardPair] = dummyCardList;
      }
    }
    return pairSingleMap;
  }

  Map<Tuple2<String, String>, Tuple2<String, String>> _buildTwoPairMap(
      Map<Tuple2<String, String>, List<String>> pairSingleMap) {
    Set<Tuple2<String, String>> addedPair = <Tuple2<String, String>>{};
    Map<Tuple2<String, String>, Tuple2<String, String>> twoPairMap = <Tuple2<String, String>, Tuple2<String, String>>{};
    pairSingleMap.forEach((pair1, singleList) {
      Tuple2<String, String> pair2 = Tuple2<String, String>.fromList(singleList);
      if (!(addedPair.contains(pair1) || addedPair.contains(pair2))) {
        twoPairMap[pair1] = pair2;
      }
      addedPair.addAll({pair1, pair2});
    });
    return twoPairMap;
  }

  Map<Tuple3<String, String, String>, String> _buildTripletSingleMap(List<String> mathCardList) {
    Map<Tuple3<String, String, String>, String> tripletSingleMap = <Tuple3<String, String, String>, String>{};
    for (String single in mathCardList) {
      List<String> dummyCardList = List<String>.from(mathCardList);
      dummyCardList.remove(single);
      Tuple3<String, String, String> triplet = Tuple3<String, String, String>.fromList(dummyCardList);
      tripletSingleMap[triplet] = single;
    }
    return tripletSingleMap;
  }

  List<String> _buildAllLowSolutionList(List<String> mathCardList) {
    Set<String> formulaSet = <String>{};
    List<List<String>> opCard2dList = [
      for (String card in mathCardList)
        [for (String op in OpConst.lowOpList) "$op$card"]
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
        .where((formula) => CalUtil.canCombine24(formula))
        .toList();
  }

  List<String> _buildAllHighSolutionList(List<String> mathCardList) {
    Set<String> formulaSet = <String>{};
    List<List<String>> opCard2dList = [
      for (String card in mathCardList)
        [for (String op in OpConst.highOpList) "$op$card"]
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
        .where((formula) =>
            CalUtil.canCombine24(formula) && !CalUtil.containsDivOne(formula))
        .toList();
  }

  List<String> _buildLowTripletSolutionList(
      Map<Tuple3<String, String, String>, String> tripletSingleMap) {
    Set<String> formulaSet = <String>{};
    tripletSingleMap.forEach((triplet, single) {
      List<List<String>> opCard2dList = [
        for (String card in triplet.toList())
          [for (String op in OpConst.lowOpList) "$op$card"]
      ];
      List<List<String>> opCardComb2dList = [
        for (String opCard1 in opCard2dList[0])
          for (String opCard2 in opCard2dList[1])
            for (String opCard3 in opCard2dList[2]) [opCard1, opCard2, opCard3]
      ];
      for (List<String> opCardCombList in opCardComb2dList) {
        opCardCombList.sort();
        opCardCombList[0] = opCardCombList[0].substring(1);
        String tripletFormula = _addBracket(opCardCombList.join());
        for (String op in OpConst.highOpWithRList) {
          String formula = _buildFormula(tripletFormula, single, op);
          formulaSet.add(formula);
        }
      }
    });
    return formulaSet
        .where((formula) =>
            CalUtil.canCombine24(formula) && !CalUtil.containsDivOne(formula))
        .toList();
  }

  List<String> _buildHighTripletSolutionList(
      Map<Tuple3<String, String, String>, String> tripletSingleMap) {
    Set<String> formulaSet = <String>{};
    tripletSingleMap.forEach((triplet, single) {
      List<List<String>> opCard2dList = [
        for (String card in triplet.toList())
          [for (String op in OpConst.highOpList) "$op$card"]
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
        for (String op in OpConst.lowOpWithRList) {
          String formula = _buildFormula(tripletFormula, single, op);
          formulaSet.add(formula);
        }
      }
    });
    return formulaSet
        .where((formula) =>
            CalUtil.canCombine24(formula) && !CalUtil.containsDivOne(formula))
        .toList();
  }

  List<String> _buildLowPairSolutionList(
      Map<Tuple2<String, String>, List<String>> pairSingleMap) {
    Set<String> formulaSet = <String>{};
    pairSingleMap.forEach((pair, singleList) {
      for (String op1 in OpConst.lowOpWithRList) {
        if (!_isValidFormula(pair.item1, pair.item2, op1)) {
          continue;
        }
        String formula1 = _addBracket(_buildFormula(pair.item1, pair.item2, op1));
        for (String card in singleList) {
          List<String> dummySingleList = List<String>.from(singleList);
          dummySingleList.remove(card);
          for (String op2 in OpConst.highOpWithRList) {
            if (!_isValidFormula(formula1, card, op2)) {
              continue;
            }
            String formula2 = _buildFormula(formula1, card, op2);
            for (String op3 in OpConst.lowOpWithRList) {
              if (!_isValidFormula(formula2, dummySingleList.first, op3)) {
                continue;
              }
              formulaSet
                  .add(_buildFormula(formula2, dummySingleList.first, op3));
            }
          }
        }
      }
    });
    return formulaSet
        .where((formula) => CalUtil.canCombine24(formula))
        .toList();
  }

  // (2 high 1 low) 1 high
  List<String> _buildHighPairSolutionList(
      Map<Tuple2<String, String>, List<String>> pairSingleMap) {
    Set<String> formulaSet = <String>{};
    pairSingleMap.forEach((pair, singleList) {
      for (String op1 in OpConst.highOpWithRList) {
        if (!_isValidFormula(pair.item1, pair.item2, op1) ||
            _isMulOne(pair.item1, pair.item2, op1)) {
          continue;
        }
        String formula1 = _buildFormula(pair.item1, pair.item2, op1);
        for (String card in singleList) {
          List<String> dummySingleList = List<String>.from(singleList);
          dummySingleList.remove(card);
          for (String op2 in OpConst.lowOpWithRList) {
            if (!_isValidFormula(formula1, card, op2)) {
              continue;
            }
            String formula2 = _addBracket(_buildFormula(formula1, card, op2));
            for (String op3 in OpConst.highOpWithRList) {
              if (!_isValidFormula(formula2, dummySingleList.first, op3)) {
                continue;
              }
              formulaSet
                  .add(_buildFormula(formula2, dummySingleList.first, op3));
            }
          }
        }
      }
    });
    return formulaSet
        .where((formula) => CalUtil.canCombine24(formula))
        .toList();
  }

  List<String> _buildTwoPairSolutionList(
      Map<Tuple2<String, String>, Tuple2<String, String>> twoPairMap) {
    Set<String> formulaSet = <String>{};
    twoPairMap.forEach((pair1, pair2) {
      for (String firstOp in OpConst.opWithRList) {
        if (!_isValidFormula(pair1.item1, pair1.item2, firstOp)) {
          continue;
        }
        String formula1 = _buildFormula(pair1.item1, pair1.item2, firstOp);
        for (String secondOp in OpConst.opWithRList) {
          if (!_isValidFormula(pair2.item1, pair2.item2, secondOp)) {
            continue;
          }
          String formula2 = _buildFormula(pair2.item1, pair2.item2, secondOp);
          for (String midOp in OpConst.opWithRList) {
            String firstFormula =
                (OpUtil.isLowOp(firstOp) && OpUtil.isHighOp(midOp)) ||
                        OpUtil.isReverseDivOp(midOp)
                    ? _addBracket(formula1)
                    : formula1;
            String secondFormula =
                OpUtil.isLowOp(secondOp) && OpUtil.isHighOp(midOp)
                    ? _addBracket(formula2)
                    : formula2;
            if (!_isValidFormula(firstFormula, secondFormula, midOp) ||
                !_isValidTwoPairOp(
                    firstOp, secondOp, midOp, pair2.item1, pair2.item2)) {
              continue;
            }
            formulaSet.add(_buildFormula(firstFormula, secondFormula, midOp));
          }
        }
      }
    });
    return formulaSet
        .where((formula) => CalUtil.canCombine24(formula))
        .toList();
  }
}
