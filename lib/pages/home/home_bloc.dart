import 'dart:async';
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

  HomeBloc() : super(HomeInitState()) {
    on<HomeRandomDrawEvent>(_randomDraw);
    on<HomeOpenHintEvent>(_openHint);
    on<HomeSubmitEvent>(_submit);
    on<HomeResetEvent>(_reset);
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
          cardList.add(Const.deckList[rng.nextInt(13)]);
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

  void _openHint(HomeOpenHintEvent event, Emitter<HomeState> emit) {
    if (state is HomeSolutionState) {
      HomeSolutionState oldState = (state as HomeSolutionState);
      List<bool> hintMaskList = List<bool>.from(oldState.hintMaskList);
      hintMaskList[event.index] = true;
      emit(oldState.copyWith(hintMaskList: hintMaskList));
    }
  }

  void _submit(HomeSubmitEvent event, Emitter<HomeState> emit) {
    print("${event.answer}");
  }

  void _reset(HomeResetEvent event, Emitter<HomeState> emit) {
    emit(HomeInitState());
  }
}
