import 'package:combine24/config/const.dart';
import 'package:flutter/material.dart';

/// Utility class to warm up Chinese text rendering to prevent crossed squares/tofu characters
class TextWarmer {
  static Future<void> warmUpChineseText() async {
    // Collect all Chinese text from const.dart that needs to be warmed up
    final chineseTexts = [

      // AppBarConst
      AppBarConst.title,
      AppBarConst.lightModeTooltip,
      AppBarConst.dartModeTooltip,
      AppBarConst.helpTooltip,
      AppBarConst.helpDialogTitle,
      AppBarConst.helpDialogContent,
      AppBarConst.helpDialogButtonText,

      Const.randomDrawTooltip,

      // ErrorConst
      ErrorConst.errorMsg,

      // SolutionStateViewConst
      SolutionStateViewConst.answerHintText,
      SolutionStateViewConst.hintTooltip,
    ];

    // Create TextPainter for each Chinese text to warm up glyph caching
    for (final text in chineseTexts) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontFamily: 'NotoSansCJK',
            fontSize: 14,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      painter.layout();
    }
  }
}
