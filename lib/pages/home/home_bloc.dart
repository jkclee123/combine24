import 'dart:async';
import 'dart:math';

import 'package:combine24/config/const.dart';
import 'package:combine24/services/schema_service.dart';
import 'package:combine24/services/impl/default_schema_service.dart';
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

  // Lazy initialization backing fields
  SolutionService? _solutionService;
  SchemaService? _schemaService;
  TranslateService? _translateService;

  // Lazy initialization of heavy services
  SolutionService get solutionService => _solutionService ??= DefaultSolutionService();
  SchemaService get schemaService => _schemaService ??= DefaultSchemaService();
  TranslateService get translateService => _translateService ??= DefaultTranslateService();

  HomeBloc() : super(HomeInitState()) {
    on<HomeRandomDrawEvent>(_randomDraw);
    on<HomeOpenHintEvent>(_openHint);
    on<HomeSubmitEvent>(_submit);
    on<HomeTestEvent>(_test);
    on<HomeResetEvent>(_reset);
    on<HomePickCardEvent>(_pickCard);
  }

  void _pickCard(HomePickCardEvent event, Emitter<HomeState> emit) async {
    if (state is HomeLoadingState) return;
    if (state is HomeInitState || state is HomeSolutionState) {
        emit(HomePickCardState(cardList: <String>[]));
        return;
    }

    try {
      final List<String> cardList = event.buffer
          .split('')
          .map((card) => card == 'T' ? '10' : card)
          .toList();

      if (cardList.length == 4) {
        emit(HomeLoadingState(cardList: cardList));
        // Small delay to show loading state
        await Future.delayed(const Duration(milliseconds: 50));

        final List<String> solutionList = solutionService.findSolutions(cardList);
        final List<String> hintList = solutionService.extractHint(solutionList);
        emit(HomeSolutionState(
            cardList: cardList, solutionList: solutionList, hintList: hintList));
        return;
      } 
      if (state is HomePickCardState) {
          emit((state as HomePickCardState).copyWith(cardList: cardList));
      }
    } catch (e, stacktrace) {
      emit(HomeErrorState(cardList: state.cardList));
      _completer.completeError(e, stacktrace);
    }
  }

  void _randomDraw(HomeRandomDrawEvent event, Emitter<HomeState> emit) async {
    // Prevent multiple simultaneous random draws
    if (state is HomeLoadingState) return;

    List<String> cardList = <String>[];
    try {
      emit(HomeLoadingState(cardList: <String>[]));
      // Add small delay to show loading state
      await Future.delayed(const Duration(milliseconds: 100));
      Random rng = Random();
      List<String> solutionList = <String>[];

      while (solutionList.isEmpty) {
        cardList.clear();
        for (int index = 0; index < 4; index++) {
          cardList.add(Const.deckList[rng.nextInt(13)]);
        }
        solutionList = solutionService.findSolutions(cardList);
      }
      List<String> hintList = solutionService.extractHint(solutionList);
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
        String calAnswer = translateService.read2CalFormula(answer);
        if (!CalUtil.canCombine24(calAnswer)) {
          emit(oldState.copyWith(wrongAnswer: true));
        } else {
          int index = schemaService.matchFormula(answer, oldState.solutionList);
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
