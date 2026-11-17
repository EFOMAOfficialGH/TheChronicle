# Stage 4 Skills implementation plan

Implement Stage 4 in the existing character builder in `index.html`, retaining the static, single-file, vanilla JavaScript architecture and gothic card styling. Rename the fourth stage from “Ability Scores” to “Skills”; leave the other stages and the completed Stage 1–3 behavior unchanged.

Use a canonical list of the 18 D&D skills and class-specific 2014 Player’s Handbook skill-choice counts and pools, cross-checking subclass grants against available 2014 rules texts and transcriptions. Display the skill proficiencies granted by the selected official or custom background as a separate, non-selectable section. Show the class list under the exact heading “Class skill choices (X)” and display each available skill as a right-checkbox row whose full row toggles the choice. Where the selected PHB subclass grants additional chosen skill proficiencies, render a separate counted choice section with its own rules-defined pool. Keep choices distinct from background-granted skills and from other selected skill proficiencies. Treat Custom Class as all skills available with no numeric choice limit.

Extend the builder’s existing transient state, delegated DOM event handling, stage rendering, and `builderStageReady` logic for these choices. Stage 1 includes an explicit stated character-level selector, defaulting to level 1. Stage 4 readiness requires the exact number of class/subclass selections for rules-based classes, with no duplicate or background-granted choices; subclass grants are included only when the stated level reaches the matching subclass feature level; Custom Class may continue with any number of non-duplicate choices. Reuse Stage 3’s official background records and custom background skill text rather than adding persistence or backend changes. Preserve the selected subclass when computing additional skill grants.

## Project structure

The app is a static Cloudflare Pages site. `index.html` contains the complete HTML document, CSS, application state, view rendering, delegated event handling, and builder data. `plan.md`, `TODO.md`, and `NOTES.md` document implementation decisions and outcomes. There is no build step or framework, and no backend changes or new dependencies are required.

## Stage 5 Attributes

Stage 5 uses three transient builder methods: the fixed Standard Array, 27-point Point Buy, and Roll 4d6 with the lowest die removed. Roll results and physical-dice entries are stored as indexed result tokens so duplicate numbers remain independently assignable while each result is still used once. Physical Dice uses one Enter-driven input, immediate validation, removable result chips, and a Clear all action. Point Buy starts all six attributes at 8 and uses the standard 8–15 cost table. Racial and subrace ability-score increases are parsed from the existing race data and displayed separately from the base score and final total.

## Stage 6 Basic Info

Stage 6 stores transient `basicName`, `basicAge`, `basicHeight`, and `basicBackstory` fields in the existing builder state. Character Name is the only required field; delegated input handling updates the state and Continue readiness as the user types. The stage list is expanded to nine entries so Equipment, Details, and Review follow Basic Info without changing the Supabase schema.
