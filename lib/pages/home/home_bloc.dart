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
    on<HomePickCardEvent>(_pickCard);
    on<HomeStartPickCardEvent>(_startPickCard);
  }

  void _pickCard(HomePickCardEvent event, Emitter<HomeState> emit) {
    try {
      final String buffer = event.buffer;
      final List<String> parsedCards = <String>[];
      int i = 0;
      while (i < buffer.length && parsedCards.length < 4) {
        if (i + 1 < buffer.length && buffer[i] == '1' && buffer[i + 1] == '0') {
          if (!parsedCards.contains('10')) {
            parsedCards.add('10');
          }
          i += 2;
          continue;
        }
        final String ch = buffer[i];
        if (Const.deckList.contains(ch)) {
          if (!parsedCards.contains(ch)) {
            parsedCards.add(ch);
          }
        }
        i += 1;
      }
      
      print('parsedCards: $parsedCards');
      if (parsedCards.length == 4) {
        final List<String> solutionList = _solutionService.findSolutions(parsedCards);
        final List<String> hintList = _solutionService.extractHint(solutionList);
        emit(HomeSolutionState(
            cardList: parsedCards, solutionList: solutionList, hintList: hintList));
      } else {
        print('HomePickCardState');
        if (state is HomePickCardState) {
          print('HomePickCardState2');
          HomePickCardState oldState = (state as HomePickCardState);
          emit(oldState.copyWith(cardList: parsedCards));
        }
      }
    } catch (e, stacktrace) {
      emit(HomeErrorState(cardList: state.cardList));
      _completer.completeError(e, stacktrace);
    }
  }

  void _startPickCard(HomeStartPickCardEvent event, Emitter<HomeState> emit) {
    emit(HomePickCardState(cardList: <String>[]));
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
        String answer = event.answer
            .replaceAll(FormulaKeyboardConst.eof, Const.emptyString);
        String calAnswer = _translateService.read2CalFormula(answer);
        if (!CalUtil.canCombine24(calAnswer)) {
          emit(oldState.copyWith(wrongAnswer: true));
        } else {
          int index = _answerService.matchAnswer(answer, oldState.solutionList);
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

  void _test(HomeTestEvent event, Emitter<HomeState> emit) {}

  void _reset(HomeResetEvent event, Emitter<HomeState> emit) {
    emit(HomeInitState());
  }
}
