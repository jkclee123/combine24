import 'dart:math';

import 'package:flutter/material.dart';
import 'package:combine24/config/const.dart';
import 'package:combine24/pages/home/home_bloc.dart';
import 'package:combine24/pages/home/home_event.dart';
import 'package:combine24/pages/home/home_state.dart';
import 'package:combine24/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_grid/responsive_grid.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: BlocBuilder<HomeBloc, HomeState>(builder: (_, state) {
        return SafeArea(
          child: RefreshIndicator(
            onRefresh: (() => Future.sync(
                () => context.read<HomeBloc>().add(HomeResetEvent()))),
            child: ListView(
              padding: const EdgeInsets.all(Const.edgeInsets),
              physics: const AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                _buildHandView(context),
                _buildDeckView(context),
                _buildSolutionView(context),
              ],
            ),
          ),
        );
      }),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(AppBarConst.title),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          onPressed: (() => context.read<ThemeCubit>().toggleTheme()),
          icon: Theme.of(context).brightness == Brightness.light
              ? const Icon(Icons.dark_mode_outlined)
              : const Icon(Icons.light_mode_outlined),
          tooltip: Theme.of(context).brightness == Brightness.light
              ? AppBarConst.dartModeTooltip
              : AppBarConst.lightModeTooltip,
        ),
        IconButton(
          onPressed: (() => context.read<HomeBloc>().add(HomeResetEvent())),
          icon: const Icon(Icons.refresh_rounded),
          tooltip: AppBarConst.resetTooltip,
        ),
      ],
    );
  }

  Widget _buildHandView(BuildContext context) {
    HomeState state = context.watch<HomeBloc>().state;
    double width = MediaQuery.of(context).size.width;
    return ResponsiveGridList(
      desiredItemWidth: min(width / HandConst.desiredItemWidthDivisor,
          HandConst.minDesiredItemWidth),
      squareCells: true,
      scroll: false,
      minSpacing: width / HandConst.minSpacingDivisor,
      rowMainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int index in List.generate(4, (index) => index))
          GestureDetector(
            onTap: (() =>
                context.read<HomeBloc>().add(HomeRemoveEvent(index: index))),
            child: Card(
              elevation: HandConst.elevation,
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: Text(state.cardList.length > index
                    ? state.cardList[index]
                    : Const.emptyString),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDeckView(BuildContext context) {
    HomeState state = context.watch<HomeBloc>().state;
    double width = MediaQuery.of(context).size.width;
    return ResponsiveGridList(
      desiredItemWidth: min(width / DeckConst.desiredItemWidthDivisor,
          DeckConst.minDesiredItemWidth),
      squareCells: true,
      scroll: false,
      minSpacing: DeckConst.minSpacing,
      rowMainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (String card in DeckConst.deckList)
          ElevatedButton(
            onPressed: state is HomeDrawState
                ? (() =>
                    context.read<HomeBloc>().add(HomeDrawEvent(card: card)))
                : null,
            child: Text(card),
          ),
      ],
    );
  }

  Widget _buildSolutionView(BuildContext context) {
    HomeState state = context.watch<HomeBloc>().state;
    if (state is HomeLoadingState) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is HomeErrorState) {
      return const Center(
        child: Text("Unexpected Error occur :("),
      );
    } else if (state is HomeSolutionState) {
      List<String> solutionList = state.solutionList;
      return ListView.separated(
        itemBuilder: (_, index) {
          return ListTile(title: Text(solutionList.elementAt(index)));
        },
        separatorBuilder: (_, index) => const Divider(),
        itemCount: solutionList.length,
        shrinkWrap: true,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
