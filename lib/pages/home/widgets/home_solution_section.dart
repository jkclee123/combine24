import 'dart:math';

import 'package:combine24/config/const.dart';
import 'package:combine24/pages/home/home_bloc.dart';
import 'package:combine24/pages/home/home_event.dart';
import 'package:combine24/pages/home/home_state.dart';
import 'package:combine24/pages/home/widgets/home_answer_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeSolutionSection extends StatelessWidget {
  final HomeState state;
  final FocusNode formulaFocusNode;
  final ValueNotifier<String> formulaKeyboardNotifier;
  final List<String> cardList;

  const HomeSolutionSection({
    super.key,
    required this.state,
    required this.formulaFocusNode,
    required this.formulaKeyboardNotifier,
    required this.cardList,
  });

  @override
  Widget build(BuildContext context) {
    if (state is HomeLoadingState) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is HomeErrorState) {
      return const Center(
        child: Text(ErrorConst.errorMsg),
      );
    } else if (state is HomeSolutionState) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _buildSolutionStateView(context, state as HomeSolutionState),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  List<Widget> _buildSolutionStateView(BuildContext context, HomeSolutionState state) {
    final solutionList = state.solutionList;
    final width = MediaQuery.of(context).size.width;

    return [
      if (state.solutionList.isNotEmpty)
        HomeAnswerInputWithBloc(
          key: const ValueKey('answer_input'),
          formulaFocusNode: formulaFocusNode,
          formulaKeyboardNotifier: formulaKeyboardNotifier,
          cardList: cardList,
        ),
      for (int index = 0; index < solutionList.length; index++)
        SizedBox(
          width: width * SolutionStateViewConst.widthWeight +
              SolutionStateViewConst.widthBias,
          child: _buildFlipAnimation(context, index, state),
        ),
    ];
  }

  Widget _buildFlipAnimation(BuildContext context, int index, HomeSolutionState state) {
    final solutionMaskList = state.solutionMaskList;
    final hintMaskList = state.hintMaskList;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: SolutionStateViewConst.flipDuration),
      transitionBuilder: _transitionBuilder,
      layoutBuilder: (widget, list) {
        if (widget != null) {
          return Stack(children: [widget, ...list]);
        } else {
          return Stack(children: list);
        }
      },
      switchInCurve: Curves.easeInBack,
      switchOutCurve: Curves.easeInBack.flipped,
      child: solutionMaskList[index]
          ? _buildSolutionCard(context, index, state)
          : hintMaskList[index]
              ? _buildHintCard(context, index, state)
              : _buildEmptySolutionCard(context, index),
    );
  }

  Widget _buildEmptySolutionCard(BuildContext context, int index) {
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      key: const ValueKey(false),
      width: width * SolutionStateViewConst.widthWeight +
          SolutionStateViewConst.widthBias,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SolutionStateViewConst.borderRadius),
        ),
        elevation: Const.elevation,
        child: ListTile(
          leading: Opacity(
            opacity: Const.opacity,
            child: Text("${index + 1}"),
          ),
          trailing: IconButton(
            tooltip: SolutionStateViewConst.hintTooltip,
            icon: Icon(
              Icons.lightbulb,
              color: Colors.yellow[600],
            ),
            onPressed: () => _onHintPressed(context, index),
          ),
        ),
      ),
    );
  }

  Widget _buildHintCard(BuildContext context, int index, HomeSolutionState state) {
    final hintList = state.hintList;
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      key: const ValueKey(false),
      width: width * SolutionStateViewConst.widthWeight +
          SolutionStateViewConst.widthBias,
      child: GestureDetector(
        onTap: () => _onHintTapped(context, hintList[index]),
        child: Card(
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              color: Colors.yellow,
              width: SolutionStateViewConst.borderWidth,
            ),
            borderRadius: BorderRadius.circular(SolutionStateViewConst.borderRadius),
          ),
          elevation: Const.elevation,
          child: ListTile(
            leading: Opacity(
              opacity: Const.opacity,
              child: Text("${index + 1}"),
            ),
            title: Center(
              child: Text(hintList[index]),
            ),
            trailing: const IconButton(
              icon: Icon(Icons.lightbulb),
              onPressed: null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSolutionCard(BuildContext context, int index, HomeSolutionState state) {
    final solutionList = state.solutionList;
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      key: const ValueKey(true),
      width: width * SolutionStateViewConst.widthWeight +
          SolutionStateViewConst.widthBias,
      child: Card(
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: Colors.green,
            width: SolutionStateViewConst.borderWidth,
          ),
          borderRadius: BorderRadius.circular(SolutionStateViewConst.borderRadius),
        ),
        elevation: Const.elevation,
        child: ListTile(
          leading: Opacity(
            opacity: Const.opacity,
            child: Text("${index + 1}"),
          ),
          title: Center(
            child: Text(solutionList[index]),
          ),
          trailing: const Icon(
            Icons.check,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  void _onHintPressed(BuildContext context, int index) {
    context.read<HomeBloc>().add(HomeOpenHintEvent(index: index));
  }

  void _onHintTapped(BuildContext context, String hint) {
    context.read<HomeBloc>().add(HomeCopyHintEvent(hint: hint));
  }

  Widget _transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
      animation: rotateAnim,
      child: widget,
      builder: (context, widget) {
        final isUnder = const ValueKey(true) != widget!.key;
        var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
        tilt *= isUnder ? -1.0 : 1.0;
        final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
        return Transform(
          transform: Matrix4.rotationX(value)..setEntry(3, 1, tilt),
          alignment: Alignment.center,
          child: widget,
        );
      },
    );
  }
}
