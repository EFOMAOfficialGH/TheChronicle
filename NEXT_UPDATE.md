# The Chronicle — next update development progress

## Current milestone

Implemented the character-creation method chooser and Character Builder stage 1.

When a new character is started from the Characters tab or from a campaign, the app now shows **Choose creation process** with:

- **Character Builder** — opens the new fixed seven-stage builder.
- **Manual Mode** — opens the previous character form unchanged.

Manual Mode also has a **Change creation process** link so the choice can be revisited.

## Character Builder stage 1: Class

Implemented:

- Theme-aware fixed progress bar with seven connected circles.
- Fixed bottom navigation with Back and Continue buttons; the class list scrolls independently.
- Official 5e base classes: Barbarian, Bard, Cleric, Druid, Fighter, Monk, Paladin, Ranger, Rogue, Sorcerer, Warlock, and Wizard.
- Custom Class at the end of the list.
- Class metadata: hit die, saving throws, spellcasting ability where applicable, and subclass-option count.
- Selecting a class highlights it and opens its subclass list.
- Subclass summaries and short mechanical-play notes.
- Subclass `?` buttons with level-by-level feature panels.
- Continue is disabled until an official class and subclass are selected. Custom Class can continue without a subclass.
- Stage 2–7 currently display exactly `(Still not implemented)`.

## Important implementation notes

- The feature is currently contained in `index.html` to match the existing project architecture.
- The builder stores temporary selections under `S.modal.builder`.
- The selected class/subclass is not yet converted into a character. That should happen during the later review/create stage.
- The existing `SUBS` data remains in place for Manual Mode and character editing.
- Do not remove the current manual flow while implementing later builder stages.

## Next up

1. Implement Stage 2: Ancestry/Race.
2. Preserve the selected class and subclass in the builder state and use them when creating the final character.
3. Add Back/Continue behavior that safely carries state across all stages.
4. Implement the remaining stages in order: Background, Ability Scores, Equipment, Details, and Review.
5. Replace the final placeholder with character creation logic that works both from the Characters tab and inside a campaign.
6. Add focused validation for mobile layout, theme variants, and keyboard/focus behavior.

## Validation completed for this milestone

- JavaScript syntax check with `node --check` should be run after each edit.
- Keep the repository as a static no-build Cloudflare Pages site.
- Push each completed stage to `main` so it can be tested independently.

## Latest corrective milestone: subclass feature overlay

- The `?` button now opens feature details for any subclass, even before that subclass is selected.
- The overlay uses pointer capture, `touch-action: none`, overscroll containment, and transform-based animation so dragging the handle does not trigger mobile pull-to-refresh.
- Dragging now updates the sheet smoothly and supports pointer cancellation without leaving a stuck transform.
- Builder selection rerenders preserve the independently scrolling content position instead of jumping to the top.
- Feature entries are now collapsed by default: each level shows the feature name only, and pressing the name expands its flavor/mechanics details.
- Knowledge Domain’s level 6 **Read Thoughts** entry includes the complete detailed text requested for the accordion example.

## Validation for latest corrective milestone

- HTML parser check passed.
- JavaScript `node --check` passed.
- `git diff --check` passed.
