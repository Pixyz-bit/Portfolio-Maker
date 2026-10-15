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
- Visibility controls retain the last confirmed status while saving; card clicks and keyboard activation use the same submission path.
- Account Settings keeps the signed-in account active; protected avatar URLs enforce portfolio visibility for each request.
- Admin search and filters apply to all accounts, with 12 accounts per SQL page. Failed reads are distinct from empty results.
- Invalid account forms remain open with preserved nonsecret values and persistent, announced errors linked to fields.
- Mobile account names and emails wrap within the viewport; visible action buttons have at least 44-pixel touch targets.
- User menus announce expanded state and hide closed content from keyboard navigation. Wizard steps have descriptive names, current-step semantics and heading focus.

## Last updated

13 October 2026: security, persistence, search, image validation, and accessibility repair; existing visual design retained.

15 October 2026: repaired visibility submission, confirmed-state feedback, account-status protection and authorized avatar delivery; existing visual design retained.

15 October 2026: added admin pagination, complete summary/error handling, bounded names, safer form recovery and mobile/accessibility refinements.
