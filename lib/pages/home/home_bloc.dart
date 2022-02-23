import 'dart:async';
import 'dart:math';

import 'package:combine24/config/const.dart';
import 'package:combine24/services/answer_service.dart';
import 'package:combine24/services/impl/default_answer_service.dart';
import 'package:combine24/services/impl/default_translate_service.dart';
import 'package:combine24/services/translate_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:combine24/pages/home/home_event.dart';
import 'package:combine24/pages/home/home_state.dart';
import 'package:combine24/services/impl/default_solution_service.dart';
import 'package:combine24/services/solution_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final Completer _completer = Completer();
  final SolutionService _solutionService = DefaultSolutionService();
  final AnswerService _answerService = DefaultAnswerService();
  final TranslateService _translateService = DefaultTranslateService();

  HomeBloc() : super(HomeInitState()) {
    on<HomeRandomDrawEvent>(_randomDraw);
    on<HomeOpenHintEvent>(_openHint);
    on<HomeSubmitEvent>(_submit);
    on<HomeTestEvent>(_test);
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
        List<String> mathCardList =
            _translateService.readCard2MathCard(cardList);
        List<String> mathSolutionList =
            _solutionService.findSolutions(mathCardList);
        solutionList =
            _translateService.mathSolutions2ReadSolutions(mathSolutionList);
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
    List<String> cardList = List<String>.from(state.cardList);
    if (state is HomeSolutionState) {
      try {
        HomeSolutionState oldState = (state as HomeSolutionState);
        String mathAnswer =
            _translateService.readSolution2MathSolution(event.answer);
        if (!_answerService.canCombine24(mathAnswer)) {
          emit(oldState.copyWith(wrongAnswer: true));
        } else {
          int index =
              _answerService.matchAnswer(event.answer, oldState.solutionList);
        }
      } catch (e, stacktrace) {
        emit(HomeErrorState(cardList: cardList));
        _completer.completeError(e, stacktrace);
      }
    }
  }

  void _test(HomeTestEvent event, Emitter<HomeState> emit) {
    DefaultAnswerService haha = DefaultAnswerService();
    haha.cleanBracket("");
  }

  void _reset(HomeResetEvent event, Emitter<HomeState> emit) {
    emit(HomeInitState());
  }
}
