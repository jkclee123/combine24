## Hand View → Card Keyboard: Implementation Plan (aligned to current events/states)

### Goal
- **Tap hand view**: clear `cardList`, show card keyboard (`card_keyboard.dart`).
- **Card keyboard input**: populate `cardList` reactively, and when 4 cards are chosen, finalize to solutions.

### Design Overview
- Use existing events/state already introduced in the codebase:
  - `HomeStartPickCardEvent` to enter the picking phase with an empty hand.
  - `HomePickCardState` to represent the ongoing picking phase with the current `cardList`.
  - `HomePickCardEvent` to either keep the user in picking mode or finalize (when 4 cards are selected) and compute solutions.
- Add a small, UI-to-BLoC sync event to carry the raw keyboard buffer from `CardKeyboard` into BLoC so `state.cardList` always reflects the current selection.

### Events (in `lib/pages/home/home_event.dart`)
- **HomeStartPickCardEvent**: dispatched when the hand view is tapped to start picking. BLoC emits `HomePickCardState(cardList: [])`.
- **HomePickCardEvent**: dispatched when picking should be evaluated/finalized. If the current `cardList` has 4 cards, BLoC computes solutions and emits `HomeSolutionState`; otherwise it stays in `HomePickCardState`.
- Add **HomeCardInputChangedEvent { final String buffer; }**: dispatched from the UI whenever `cardKeyboardNotifier` changes to sync the raw buffer into BLoC. This keeps `HomePickCardState.cardList` in lockstep with the keyboard.

### BLoC Changes (in `lib/pages/home/home_bloc.dart`)
- Confirm existing handlers:
  - `on<HomeStartPickCardEvent>(_startPickCard)` → `emit(HomePickCardState(cardList: <String>[]))`.
  - `on<HomePickCardEvent>(_pickCard)` → if `state.cardList.length == 4`, compute solutions → `HomeSolutionState`; else remain in `HomePickCardState`.
- Add handler for `HomeCardInputChangedEvent`:
  - Parse `event.buffer` from the card keyboard into a normalized `List<String>` of up to 4 cards.
  - `emit(HomePickCardState(cardList: parsedCards))` each time the buffer changes.

### State (in `lib/pages/home/home_state.dart`)
- Use the existing **HomePickCardState** for the picking phase:
  - `class HomePickCardState extends HomeState { HomePickCardState({required List<String> cardList}) { this.cardList = cardList; } }`
- No additional picking state is needed.

### UI Changes (in `lib/pages/home/views/home_view.dart`)
1. **Open card keyboard on hand tap**
   - Wrap the hand grid in `KeyboardActions` using `_buildCardKeyboardConfig(context)` (already available).
   - On tap of the hand view:
     - Dispatch `HomeStartPickCardEvent()`.
     - Set `cardKeyboardNotifier.value = Const.emptyString`.
     - Request focus on the shared `focusNode` and increment `_keyboardOpenTick` to rebuild the footer.
2. **Sync keyboard input to BLoC**
   - Implement `onCardChanged()` to dispatch `HomeCardInputChangedEvent(buffer: cardKeyboardNotifier.value)` on every change.
3. **Finalize when 4 cards chosen**
   - When the selection reaches 4 cards, dispatch `HomePickCardEvent()` and unfocus to close the keyboard. This can be triggered after dispatching `HomeCardInputChangedEvent` by checking either:
     - the parsed token count in the UI (simple split and count), or
     - observe `state.cardList.length` via `BlocBuilder` and dispatch when it becomes 4.
4. **Render**
   - Continue rendering the hand cells from `state.cardList` (already implemented). In `HomePickCardState`, this will update live as the user picks.

### Parsing Rules for Card Buffer (used in BLoC)
- The buffer is built by `CardKeyboard` via concatenation of card labels and backspace.
- Normalize by splitting on spaces, treating `10` as one token.
- Enforce a maximum of 4 tokens.
- Prevent duplicates beyond availability: ignore the 3rd occurrence of the same value, etc.

### Card Keyboard (`lib/pages/home/views/card_keyboard.dart`)
- Keep current behavior; it writes to its `notifier` and supports backspace.
- No changes required to the widget itself for this feature.

### UX/Focus Handling
- Reuse the same `focusNode` pattern as the formula keyboard.
- Use `_keyboardOpenTick` to force-rebuild the footer when focus changes.
- Dismiss keyboard when picking completes (4 cards) or tapping outside.

### Validation and Flow
- Tap hand → `HomeStartPickCardEvent` → BLoC emits `HomePickCardState([])` → UI focuses and shows card keyboard.
- User selects cards → `cardKeyboardNotifier` changes → UI dispatches `HomeCardInputChangedEvent` → BLoC parses and emits `HomePickCardState([...])` → hand grid reflects current picks.
- When there are 4 cards → UI dispatches `HomePickCardEvent` → BLoC computes and emits `HomeSolutionState` → card keyboard closes.

### Test Checklist
- Hand tap dispatches `HomeStartPickCardEvent` and shows card keyboard with empty hand.
- Selecting cards updates `HomePickCardState.cardList` in order; disabled cards in `CardKeyboard` mirror chosen ones.
- Backspace updates both the buffer and `HomePickCardState.cardList`.
- Exactly four cards are enforced; on reaching 4, `HomePickCardEvent` finalizes to `HomeSolutionState` and the keyboard closes.
- Formula keyboard flow remains unchanged.