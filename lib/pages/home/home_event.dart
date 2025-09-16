import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class HomeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

@immutable
class HomeRandomDrawEvent extends HomeEvent {}

@immutable
class HomeStartPickCardEvent extends HomeEvent {}

@immutable
class HomePickCardEvent extends HomeEvent {}

@immutable
class HomeOpenHintEvent extends HomeEvent {
  final int index;
  HomeOpenHintEvent({required this.index});
}

@immutable
class HomeSubmitEvent extends HomeEvent {
  final String answer;
  HomeSubmitEvent({required this.answer});
}

@immutable
class HomeTestEvent extends HomeEvent {}

@immutable
class HomeResetEvent extends HomeEvent {}
