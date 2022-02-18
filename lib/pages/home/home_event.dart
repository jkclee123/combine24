import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class HomeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

@immutable
class HomeDrawEvent extends HomeEvent {
  final String card;
  HomeDrawEvent({required this.card});
}

@immutable
class HomeRandomDrawEvent extends HomeEvent {}

@immutable
class HomeRemoveEvent extends HomeEvent {
  final int index;
  HomeRemoveEvent({required this.index});
}

@immutable
class HomeOpenHintEvent extends HomeEvent {
  final int index;
  HomeOpenHintEvent({required this.index});
}

@immutable
class HomeOpenSolutionEvent extends HomeEvent {
  final int index;
  HomeOpenSolutionEvent({required this.index});
}

@immutable
class HomeResetEvent extends HomeEvent {}
