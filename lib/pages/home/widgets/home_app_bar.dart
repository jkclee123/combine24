import 'package:combine24/config/const.dart';
import 'package:combine24/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppBarConst.helpDialogTitle),
          content: SingleChildScrollView(
            child: Text(AppBarConst.helpDialogContent),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppBarConst.helpDialogButtonText),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(AppBarConst.title),
      centerTitle: true,
      leading: IconButton(
        onPressed: () => _showHelpDialog(context),
        icon: const Icon(Icons.help_outline),
        tooltip: AppBarConst.helpTooltip,
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          icon: Theme.of(context).brightness == Brightness.light
              ? const Icon(Icons.dark_mode_outlined)
              : const Icon(Icons.light_mode_outlined),
          tooltip: Theme.of(context).brightness == Brightness.light
              ? AppBarConst.dartModeTooltip
              : AppBarConst.lightModeTooltip,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
