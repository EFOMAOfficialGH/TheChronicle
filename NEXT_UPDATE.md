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
- The overlay uses pointer capture, vertical touch handling, overscroll containment, and transform-based animation so the whole sheet can be dragged downward without triggering mobile pull-to-refresh.
- Dragging now updates the sheet smoothly and supports pointer cancellation without leaving a stuck transform.
- Builder selection rerenders preserve the independently scrolling content position instead of jumping to the top.
- Feature entries are collapsed by default: each level shows the feature name only, and pressing the name expands a concise flavor-and-mechanics summary below it.
- The summary format applies to every feature in every subclass; the long Knowledge Domain **Read Thoughts** text was replaced with a compact rules summary.
- Expanding or collapsing a feature now updates the existing overlay in place instead of rerendering the entire builder and visibly reloading the sheet.
- Replaced the feature data for all 12 classes and 40 listed subclasses with concise summaries for all 221 official subclass feature entries, including split features such as domain/oath spell lists and multi-part subclass features.
- Summaries were checked against official D&D Beyond class/subclass pages and Wizards of the Coast SRD/Basic Rules documents, including the 2014 rules basis used by this builder.
- Mobile drag handling uses pointer capture and vertical touch handling on the complete sheet, so downward dismissal works on phone browsers as well as desktop without blocking scrolling.
- The sheet now preserves native vertical scrolling on phones; downward dismissal starts only when the sheet is already scrolled to the top, so long feature summaries can be read completely.

## Validation for latest corrective milestone

- HTML parser check passed.
- JavaScript `node --check` passed.
- `git diff --check` passed.
- Browser smoke test passed after escaping the multiline Read Thoughts string; the app mounts normally in Chromium.
- JavaScript syntax check and `git diff --check` passed after the in-place accordion and full-sheet drag changes.
- JavaScript syntax check and `git diff --check` passed after the complete official feature-data replacement and mobile pointer-capture fix.
- JavaScript syntax check and `git diff --check` passed after restoring mobile scrolling alongside drag-to-dismiss.

## Latest milestone: conditional Feature Choice and Review

- The builder now uses a dynamic 8- or 9-stage flow.
- The normal flow labels Stage 8 **Review**. Characters with class/subclass decisions use Stage 8 **Feature Choice** and Stage 9 **Review**.
- Implemented Feature Choice examples for Ranger (Favored Enemy and Natural Explorer), Fighter (Fighting Style), Rogue (two Expertise choices), Draconic Bloodline Sorcerer (Dragon Ancestor), and Totem Warrior Barbarian (Totem Spirit).
- The Review screen includes Identity, Class, Starting Gold, Race, Background, Skills, Attributes, Tool Proficiencies, Starting Equipment, and Class Equipment sections.
- Review includes a starting-gold formula, Roll button, editable gold value, removable starting-item checkboxes, and class equipment choose-one selectors with descriptions.
- The final character-save action remains intentionally pending until the Review/Equipment integration is completed.

## Validation for conditional Feature Choice and Review

- HTML parser check passed.
- JavaScript `node --check` passed.
- `git diff --check` passed.
- Chromium smoke test passed; the app mounts and Ranger activates a nine-step progress bar.

## Follow-up layout fix

- Review cards now stack vertically in a single column instead of appearing side by side.
- Removed the separate placeholder Equipment stage from the guided flow. The normal flow is now 7 stages with Review at Stage 7; characters needing Feature Choice use 8 stages with Feature Choice at Stage 7 and Review at Stage 8.

## Review controls refinement

- Tool proficiency entries such as “One artisan’s tool type,” “One gaming set,” and “One musical instrument” now render a dropdown with the available choices, and the selected choice is retained in builder state.
- The six attributes now use compact square stat cards with the score above the attribute name.
- Review AC labels now read “AC (Unarmored)” and “AC (Leather Armor)”.
- Class-equipment options now include `?` buttons that open an in-builder description overlay; the removed Equipment stage is not needed for these descriptions.

## Equipment detail refinement

- Class-equipment choice summaries now update immediately when a different dropdown option is selected.
- The `?` overlay now describes the currently selected option with Summary, Type, Category, Weight, Damage, Damage Type, and Cost fields.
- Equipment detail data covers the common weapons, armor, packs, spellcasting focuses, tools, and other options used by the builder; unavailable values are shown as em dashes rather than omitted.
