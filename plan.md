# Stage 3 Background implementation plan

Implement Stage 3 inside the existing character-builder in `index.html`, keeping the current single-file, vanilla JavaScript architecture and gothic card styling. Use the 2014 Player’s Handbook background set already aligned with the app’s 2014 race catalog: 13 core backgrounds plus named PHB variants (Spy, Gladiator, Guild Merchant, Knight, and Pirate). Store skills, tool proficiencies, feature names, and concise feature descriptions in a local data array. Render selectable cards in the existing race-card visual pattern; the selected card receives the existing accent highlight and immediately expands an in-flow feature-details area. Put the custom background card after every official option, with inputs for name, skills, tools, feature name, and feature description.

Extend builder state, delegated input handling, and `builderStageReady` so official choices can continue immediately and a custom choice must have a name, skills, feature name, and feature description. Keep the current Stage 1/2 behavior unchanged and use the existing UI design, with no new dependencies or backend changes. Update `NOTES.md` to record completion and retain the existing SRD attribution in `README.md`.

## Project structure

The app is a static Cloudflare Pages site. `index.html` contains all HTML, CSS, application state, view rendering, event actions, and builder data. `NOTES.md` tracks project status and decisions. There is no build step, framework, or backend modification required for this feature.