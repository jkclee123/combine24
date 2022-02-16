import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:combine24/config/const.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:combine24/pages/home/home_event.dart';
import 'package:combine24/pages/home/home_state.dart';
import 'package:combine24/services/default_solution_service.dart';
import 'package:combine24/services/solution_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final Completer _completer = Completer();
  final SolutionService _solutionService = DefaultSolutionService();

  HomeBloc() : super(HomeDrawState()) {
    on<HomeDrawEvent>(_drawCard);
    on<HomeRandomDrawEvent>(_randomDraw);
    on<HomeRemoveEvent>(_removeCard);
    on<HomeResetEvent>(_reset);
  }

  void _drawCard(HomeDrawEvent event, Emitter<HomeState> emit) {
    List<String> cardList = List.from(state.cardList);
    try {
      if (state is HomeDrawState) {
        cardList.add(event.card);
        if (cardList.length < 4) {
          emit(HomeDrawState(cardList: cardList));
        } else {
          emit(HomeLoadingState(cardList: cardList));
          List<String> solutionList = _solutionService.findSolutions(cardList);
          List<String> hintList = _solutionService.extractHint(solutionList);
          emit(HomeSolutionState(
              cardList: cardList,
              solutionList: solutionList,
              hintList: hintList));
        }
      }
    } catch (e, stacktrace) {
      emit(HomeErrorState(cardList: cardList));
      _completer.completeError(e, stacktrace);
    }
  }

  void _randomDraw(HomeRandomDrawEvent event, Emitter<HomeState> emit) {
    List<String> cardList = List<String>.from(state.cardList);
    try {
      emit(HomeLoadingState(cardList: cardList));
      Random rng = Random();
      List<String> solutionList = <String>[];
      while (solutionList.isEmpty) {
        cardList.clear();
        for (int index = 0; index < 4; index++) {
          cardList.add(DeckConst.deckList[rng.nextInt(13)]);
        }
        solutionList = _solutionService.findSolutions(cardList);
      }
      List<String> hintList = _solutionService.extractHint(solutionList);
      emit(HomeSolutionState(
          cardList: cardList, solutionList: solutionList, hintList: hintList));
    } catch (e, stacktrace) {
      emit(HomeErrorState(cardList: cardList));
      _completer.completeError(e, stacktrace);
    }
  }

  void _removeCard(HomeRemoveEvent event, Emitter<HomeState> emit) {
    List<String> cardList = List<String>.from(state.cardList);
    try {
      if (cardList.length > event.index) {
        cardList.removeAt(event.index);
        emit(HomeDrawState(cardList: cardList));
      }
    } catch (e, stacktrace) {
      emit(HomeErrorState(cardList: cardList));
      _completer.completeError(e, stacktrace);
    }
  }

  void _reset(HomeResetEvent event, Emitter<HomeState> emit) {
    emit(HomeDrawState());
  }
}
