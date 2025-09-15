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

## How It Handles Equivalent Solutions

A unique feature of this app is its ability to recognize that different-looking formulas are mathematically equivalent. For example, with the numbers 3, 8, 6, and 7, the solutions 3+8+6+7 and 3+6+7+8 are considered the same. This is achieved by converting every formula into a standardized, order-independent "schema" before comparison.

Here’s a deeper look at how this works:

### For Commutative Operations (+ and ×)

Addition and multiplication are commutative, meaning the order of the numbers doesn't change the result (e.g., 2 * 3 is the same as 3 * 2). The app's schema represents these operations as an unordered group.
- Example with cards 2, 3, 4, 6:
  - The answers (2 * 4) + (3 * 6) and (6 * 3) + (4 * 2) both equal 24.
  - The app sees both of these as a sum of two products, and since both addition and multiplication are commutative, it treats them as the same fundamental solution.

### For Non-Commutative Operations (- and ÷)

Subtraction and division are not commutative, so order matters. The schema preserves the order for these operations.
- Example with cards 2, 4, 6, 8:
  - The solution 6 * 8 / (4 - 2) is valid.
  - However, (4 - 2) / (6 * 8) is a different calculation and gives a different result. The app's schema will treat these as distinct, ensuring that only mathematically correct variations are accepted.

### How Parentheses and Precedence Are Handled
The app correctly respects the order of operations, where expressions in parentheses are evaluated first, followed by multiplication/division, and then addition/subtraction. This is built into the schema generation.

- Example with cards 1, 2, 3, 4:
  - The solution (1 + 2 + 3) * 4 forces the additions to happen before the multiplication.
  - The schema for this would be different from 1 + 2 + (3 * 4), reflecting the different structure of the calculation.

However, the app would correctly identify 4 * (3 + 2 + 1) as being equivalent to the first solution, since the order of numbers in the addition part and the order of the two main groups in the multiplication don't change the outcome.

This smart comparison system ensures that you are credited for a correct solution, no matter how you've arranged the numbers, as long as the underlying mathematical structure is the same as one of the valid solutions.

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