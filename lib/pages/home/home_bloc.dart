import 'dart:async';
import 'dart:math';

import 'package:combine24/config/const.dart';
import 'package:combine24/services/answer_service.dart';
import 'package:combine24/services/impl/default_answer_service.dart';
import 'package:combine24/services/impl/default_translate_service.dart';
import 'package:combine24/services/translate_service.dart';
import 'package:combine24/utils/cal_util.dart';
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
    List<String> cardList = List<String>.from(state.cardList);
    if (state is HomeSolutionState) {
      try {
        HomeSolutionState oldState = (state as HomeSolutionState);
        String calAnswer = _translateService.read2CalFormula(event.answer);
        if (!CalUtil.canCombine24(calAnswer)) {
          emit(oldState.copyWith(wrongAnswer: true));
        } else {
          int index =
              _answerService.matchAnswer(event.answer, oldState.solutionList);
          if (!index.isNegative) {
            List<bool> solutionMaskList =
                List<bool>.from(oldState.solutionMaskList);
            solutionMaskList[index] = true;
            emit(oldState.copyWith(solutionMaskList: solutionMaskList));
          }
        }
      } catch (e, stacktrace) {
        emit(HomeErrorState(cardList: cardList));
        _completer.completeError(e, stacktrace);
      }
    }
  }

  void _test(HomeTestEvent event, Emitter<HomeState> emit) {
    List<String> sl = _solutionService.findSolutions(["7", "8", "5", "4"]);
    print("sl $sl");
  }

  void _reset(HomeResetEvent event, Emitter<HomeState> emit) {
    emit(HomeInitState());
  }
}
