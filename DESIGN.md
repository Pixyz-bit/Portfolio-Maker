# Design

The existing portfolio uses a monochrome neo-brutalist design with bold borders, offset shadows, rounded controls, and green/red status colors. This repair preserves that identity.

## Typography and layout

Local Plus Jakarta Sans and Inter assets remain in use. Page CSS owns its existing spacing and responsive breakpoints. No framework or font migration is part of these bug fixes.

## Interaction requirements

- Fields have associated labels, including generated onboarding rows.
- Modal dialogs have an accessible title, dialog semantics, initial focus, trapped Tab navigation, Escape dismissal, and restored focus.
- Keyboard focus uses a three-pixel green outline with an offset.
- Reduced-motion preferences suppress modal/toast entrances while preserving meaningful states.
- Public search runs on the server across the whole directory; previous/next controls paginate results.
- Save errors preserve form values and describe recovery. Success is shown only after the database transaction commits.

## Last updated

13 October 2026: security, persistence, search, image validation, and accessibility repair; existing visual design retained.
