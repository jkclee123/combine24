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
      body: SafeArea(
        child: RefreshIndicator(
            onRefresh: (() => Future.delayed(
                const Duration(seconds: Const.refreshDelay),
                () =>
                    BlocProvider.of<HomeBloc>(context).add(HomeResetEvent()))),
            child: BlocBuilder<HomeBloc, HomeState>(builder: (_, state) {
              return ListView(
                padding: const EdgeInsets.all(Const.edgeInsets),
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                children: <Widget>[
                  _buildHandView(context),
                  _buildDeckView(context),
                  const Divider(),
                  _buildSolutionView(context),
                ],
              );
            })),
      ),
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
          onPressed: (() =>
              BlocProvider.of<HomeBloc>(context).add(HomeRandomDrawEvent())),
          icon: const Icon(Icons.copy_rounded),
          tooltip: AppBarConst.randomDrawTooltip,
        ),
        IconButton(
          onPressed: (() =>
              BlocProvider.of<HomeBloc>(context).add(HomeResetEvent())),
          icon: const Icon(Icons.refresh_rounded),
          tooltip: AppBarConst.resetTooltip,
        ),
      ],
    );
  }

  Widget _buildHandView(BuildContext context) {
    HomeState state = BlocProvider.of<HomeBloc>(context).state;
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
            onTap: (() => BlocProvider.of<HomeBloc>(context)
                .add(HomeRemoveEvent(index: index))),
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
    HomeState state = BlocProvider.of<HomeBloc>(context).state;
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
                ? (() => BlocProvider.of<HomeBloc>(context)
                    .add(HomeDrawEvent(card: card)))
                : null,
            child: Text(card),
          ),
      ],
    );
  }

  Widget _buildSolutionView(BuildContext context) {
    HomeState state = BlocProvider.of<HomeBloc>(context).state;
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
      if (solutionList.isEmpty) {
        return const Center(
          child: Text("No solution"),
        );
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _buildSolutionColumnView(context),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  List<Widget> _buildSolutionColumnView(
    BuildContext context,
  ) {
    HomeSolutionState state =
        context.watch<HomeBloc>().state as HomeSolutionState;
    List<String> solutionList = state.solutionList;
    List<String> hintList = state.hintList;
    List<bool> solutionMaskList = state.solutionMaskList;
    List<bool> hintMaskList = state.hintMaskList;
    int solutionLength = solutionList.length;
    double width = MediaQuery.of(context).size.width;
    return [
      for (int index = 0; index < solutionLength; index++)
        SizedBox(
          width: width / 4 + 200,
          child: solutionMaskList[index]
              ? Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  color: Colors.blue,
                  elevation: 8.0,
                  child: ListTile(
                    title: Center(
                      child: Text(solutionList[index]),
                    ),
                    trailing: const IconButton(
                      icon: Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                      onPressed: null,
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: (() => BlocProvider.of<HomeBloc>(context)
                      .add(HomeOpenSolutionEvent(index: index))),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 8.0,
                    child: hintMaskList[index]
                        ? ListTile(
                            title: Center(
                              child: Text(hintList[index]),
                            ),
                            trailing: const IconButton(
                              icon: Icon(
                                Icons.lightbulb_outline_rounded,
                              ),
                              onPressed: null,
                            ),
                          )
                        : ListTile(
                            title: Center(
                              child: Opacity(
                                opacity: 0.5,
                                child: Text("${index + 1}"),
                              ),
                            ),
                            trailing: IconButton(
                              tooltip: "提示",
                              icon: Icon(
                                Icons.lightbulb_outline_rounded,
                                color: Colors.yellow[400],
                              ),
                              onPressed: (() =>
                                  BlocProvider.of<HomeBloc>(context)
                                      .add(HomeOpenHintEvent(index: index))),
                            ),
                          ),
                  ),
                ),
        ),
    ];
  }
}
