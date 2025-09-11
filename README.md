# combine24

An interactive "24 game" solver built with Flutter. Enter expressions using the on-screen formula keyboard to make 24 from four numbers. The app gives live hints, validates your answer, and shows all solutions when available.

- Live demo: [combine24.vercel.app](https://combine24.vercel.app/)

## Features

- Interactive custom formula keyboard with numbers, operators, and parentheses
- Live subtotal preview while you type
- Hint system that reveals partial solutions (tap to copy into the answer box)
- Flip animation between empty/hint/solution cards
- Random draw for a new hand of four numbers
- Pull to refresh to reset the current round
- Light/Dark theme toggle
- Web, iOS, Android, and desktop-ready (Flutter)

## How to Play

1. You are given four numbers. Use each number exactly once.
2. Combine them using +, −, ×, ÷, and parentheses to make 24.
3. Use the on-screen keyboard to build your expression and press Submit.
4. Open a hint for each solution slot; tap a hint to copy it into the input.

## Local Development

Prerequisites:

- Flutter SDK with Dart 2.x (the project enforces `environment: ">=2.16.1 <3.0.0"`)
  - If your global Flutter uses Dart 3.x, consider using FVM or installing a Flutter SDK that ships with Dart 2.x (e.g., Flutter 3.7.x).

Install and run (web):

```bash
flutter pub get
flutter run -d chrome
```

Run on mobile/emulator:

```bash
flutter devices
flutter run -d <device_id>
```

Build for web:

```bash
flutter build web --release
```

## Tech Stack

- Flutter + Dart
- State management: `flutter_bloc`
- Expression parsing/eval: `function_tree`
- UI helpers: `responsive_grid`, `keyboard_actions`
- Utilities: `equatable`, `tuple`, `collection`

## Project Structure (high-level)

- `lib/app.dart` — App root, theme provider, routing to `HomePage`
- `lib/pages/home/` — Home screen BLoC, state, and view
  - `views/formula_keyboard.dart` — custom on-screen keyboard
  - `views/home_view.dart` — layout, hints/solutions, interactions
- `lib/services/` — solution & answer services
  - `impl/default_solution_service.dart` — generates valid 24 formulas
  - `impl/default_answer_service.dart` — normalizes and matches answers
- `lib/utils/` — math and operator utilities
- `web/` — PWA manifest and icons

## Notes

- Solver rules align with common 24-game conventions: use each number once; operators are + − × ÷; parentheses allowed. The solver filters out trivial variations (e.g., some divide-by-1 forms) and normalizes equivalent expressions when matching your answer.
- The app is fully client-side; solutions are computed locally in the browser/device.