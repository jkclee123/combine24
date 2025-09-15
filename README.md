# combine24 (合廿四)

combine24 (合廿四) is an interactive "24 game" solver built with Flutter. The Chinese name means "combine 24" - the classic mathematical puzzle where you must use each of four given numbers exactly once, combining them with addition, subtraction, multiplication, division, and parentheses to make exactly 24.

Enter expressions using the on-screen formula keyboard to solve the puzzle. The app provides live hints, validates your answers, and shows all possible solutions when available.

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

1. **Get your numbers**: You are given four random numbers between 1-13.
2. **Build your expression**: Use each number exactly once, combining them with +, −, ×, ÷, and parentheses to make exactly 24.
3. **Use the keyboard**: Enter your mathematical expression using the on-screen formula keyboard.
4. **Get hints**: When stuck, tap the hint cards to reveal partial solutions. Tap any hint to copy it directly into your input field.
5. **Submit & verify**: Press Submit to check your answer. The app will validate and show if you're correct.

## Local Development

Prerequisites:

- Flutter SDK with Dart 3.x (the project enforces `environment: ">=3.0.0 <4.0.0"`)
- Recommended: Flutter 3.10.x or later

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

- **Framework**: Flutter + Dart 3.x
- **State Management**: `flutter_bloc` (BLoC pattern implementation)
- **Expression Parsing**: `function_tree` (mathematical expression evaluation)
- **UI Components**: `responsive_grid` (responsive layouts), `keyboard_actions` (custom keyboard handling)
- **Utilities**: `equatable` (value equality), `tuple` (immutable tuples), `collection` (enhanced collections)

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