import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class HomeState extends Equatable {
  late final List<String> cardList;

  @override
  List<Object> get props => [];
}

@immutable
class HomeInitState extends HomeState {
  HomeInitState() {
    cardList = <String>[];
  }

  @override
  List<Object> get props => [cardList];
}

class HomeLoadingState extends HomeState {
  HomeLoadingState({required List<String> cardList}) {
    this.cardList = cardList;
  }
}

class HomeSolutionState extends HomeState {
  late final List<String> solutionList;
  late final List<String> hintList;
  late final List<bool> solutionMaskList;
  late final List<bool> hintMaskList;
  late final bool wrongAnswer;

  HomeSolutionState(
      {required List<String> cardList,
      required this.solutionList,
      required this.hintList,
      List<bool>? solutionMaskList,
      List<bool>? hintMaskList,
      bool? wrongAnswer}) {
    this.cardList = cardList;
    this.solutionMaskList =
        solutionMaskList ?? List.generate(solutionList.length, (_) => false);
    this.hintMaskList =
        hintMaskList ?? List.generate(hintList.length, (_) => false);
    this.wrongAnswer = false;
  }

  HomeSolutionState copyWith(
      {List<String>? cardList,
      List<String>? solutionList,
      List<String>? hintList,
      List<bool>? solutionMaskList,
      List<bool>? hintMaskList,
      bool? wrongAnswer}) {
    return HomeSolutionState(
        cardList: cardList ?? this.cardList,
        solutionList: solutionList ?? this.solutionList,
        hintList: hintList ?? this.hintList,
        solutionMaskList: solutionMaskList ?? this.solutionMaskList,
        hintMaskList: hintMaskList ?? this.hintMaskList,
        wrongAnswer: wrongAnswer ?? this.wrongAnswer);
  }

  @override
  List<Object> get props => [
        cardList,
        solutionList,
        hintList,
        solutionMaskList,
        hintMaskList,
        wrongAnswer
      ];
}

class HomeErrorState extends HomeState {
  HomeErrorState({required List<String> cardList}) {
    this.cardList = cardList;
  }
}
