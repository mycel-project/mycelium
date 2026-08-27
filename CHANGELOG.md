## Unreleased
This update introduces another refactor of the Markdown engine (live_markdown_editor), as WebView was not viable for full cross-platform compatibility. It reintroduces Linux support alongside web support.

### Added
- Use live_markdown_editor package to render markdown.

### Fixed
- Fix notification system deadlock: use a queue-based bus and StatefulWidget listener with try/catch to prevent toast failures from blocking all future notifications.
- Wrap dialogs with PointerInterceptor to restore clickability over iframe on web.

### Refactored
- Remove flutter in_app_webview
- Extract EditorBackend abstraction with sealed command/event classes for Stream-based editor communication. Replace InAppWebView inline widget with Provider-injected backend.
- Adapt editor action buttons layout for web (kIsWeb): move outside Stack to avoid HtmlElementView DOM overlay.
- Use evaluateJavascript instead of callAsyncJavaScript for cross-platform WebView JS execution.
- Reword home widget when no Mycel instance is connected.
- Display API error message on config page when connection check fails.
- Auto-check API reachability on config page open; reset error message on mode switch.
- Catch empty base URL in ApiClient._guard() with user-friendly message instead of raw HTTP error.
- Add `silent` parameter to CheckApiUseCase.execute() to control notifications; dot widget uses `silent: false` for voluntary clicks.
- Refactor health check flow: route `/health` and `/version` through `ApiClient` for unified connection status tracking. Add request sequencing in `ApiClient._guard()` to ignore stale HTTP responses. Add staleness guard in `CheckApiUseCase` to prevent outdated health-check results from corrupting `ApiStore`. Add generation counter in `ApiViewModel` to protect local state from stale callbacks.

## v0.1.5
This update introduces a total refactor of the Markdown rendering engine, switching from a custom one to CodeMirror with live rendering and support for more elements. It also temporarily removes Linux support but introduces a web build for Mycelium, along with other changes detailed below.

### BREAKING
- Remove Linux build. Web views are too inconsistent in the Flutter ecosystem for Linux but it evolves quickly. Linux users can still access Mycelium through the web build.

### Added
- Introduce a global priority coloring system (rainbow spectrum from violet to red) that dynamically colors priority chips and the reprioritization slider based on the priority value.
- Sanitize base URL and token inputs by automatically stripping spaces, invisible control characters, and (for URLs) trailing slashes, and prefixing with 'http://' if missing.
- Auto-select the "Default" collection if no active collection is found (e.g. fresh install).
- Track current slot during reviews (to prepare for multi-spore nodes).
- AI instructions skills for better consistency

### Refactored
- Refactored Markdown rendering logic by using CodeMirror with package `live-markdown-rendering`
- Redesign API config page UI and improve custom URL handling when switching connection methods.
- Change default slot value from 0 to 1 across the codebase for consistency with Mycel.
- Implement robust JavaScript-to-Flutter scroll synchronization for CodeMirror, removing legacy Flutter `ScrollController` dependencies.
- Delegate Undo/Redo history management entirely to CodeMirror, replacing the obsolete Flutter `UndoHistoryController`.

### Fixed
- Fix spore cloze fields that were displaying the slot number rather than spore content
- Hide import buttons when no collection is selected
- Fix mobile keyboard remaining active when opening drawers by natively bridging Flutter's focus tree with CodeMirror's focus state.
- Fix outline navigation layout shifting and inaccuracies by synchronizing scroll position using exact absolute character offsets instead of relative scroll percentages.

## v0.1.4
### Added
- When removing links, remove cursor and restore scroll position.
- Enhance highlighting of the selected heading in the outline
- Close button (x) added to top-right of desktop dialogs
- Left panel closes automatically on desktop when navigating to a spore under review to avoid spoiling the answer
- Spore editor now highlights in red when no cloze field is detected. Error toasts once and the highlight persists until corrected. Invalid states are rejected by the backend and the last valid state is preserved.
- Add tests (for services)
- Functionnality to split nodes by heading
- Add background color when node is dismissed and for spores

### Fixed
- When changing the displayed node, systematically remove focus to avoid keyboard/cursor inconsistencies.
- The “Remove links” option is still enabled right after hiding the keyboard.
- Scroll animation is now correctly playing in outline section
- Restored unsaved changes confirmation dialog when switching nodes with pending changes, accidentally removed in a previous refactor.
- Invert prioritisation logic to follow mycel new standard.

### Refactor
- **Adapt API contract to follow mycel v0.2.0 (changed models, use slots, use contentPreview built by Mycel, etc.)**
- Removed NodeType class: Mycel now uses raw strings ("fragment", "spore") instead of integers for types.
- Change route for: cloze_regex

## v0.1.3
### Added
- Add an outline panel in the right drawer showing the table of contents of the current node. Headings are clickable for quick navigation, the active heading is highlighted and updates as you scroll, and content is cached per node to avoid redundant requests.
- When creating an extract, a long press on the button on mobile or a right-click on desktop will also open the priority selector dialog, allowing for smooth prioritization.
- Closing the keyboard when reviewing fragment no longer remove the selection, just the cursor.
- Keep selection when extraction failed (+ add custom error message)

### Fixed
- Fixed an issue where edits made during a save operation could be silently discarded.

## v0.1.2
### Added
- Prerelease versions now share the same compatibility rules as their corresponding release
- Rescheduling a node that is currently under review now automatically clears its review state.
- Show "No collection selected" when no collection is active in the right drawer. 
- Remove link formatting now applies to the full content when nothing is selected.
- Added undo action to the end-of-review screen.
- Canceling a warning dialog on a settings field now properly reverts the slider to its previous value.

### Fixed
- Use double rather than int to display priorities
- Static URL to mycel-project.com
- Navigating to an already open node no longer clears the navigation history.
- When renaming a node in NodeTree, don't open it.
- Expand/collapse tree indicators in deleted node page now correctly reflect the dismiss state of child nodes.
- Refresh node navigability status when changing collections

## v0.1.1
### Added
- Pass timezone to Mycel when reviewing node

## v0.1.0
### Added
- Linux and Windows support
- Change drawer icon on mobile
- Responsiveness based on Device type and screen width:
  - Custom drawer/pannel behaviour based on device type
  - Appbar buttons and padding
  - Page animations
  - Review buttons
  - Map mobile "hold" actions to desktop right click
  - Better sheet display on desktop
- Hide spores responses fields in NodeTree

### Fixed
- Incoherent node selection in NodeTree (Desktop)

## v0.0.5
### Added
- Calendar Widget to visualize repetitions left for months/days (heatmap coloration, plugged to backend)
- Plug timezone when querying reps calendar or next review, and when creating nodes
- Reschedule widget to change current node due date
- Refresh the node data after it has been reviewed

### Fixed
- In node tree, left triangle was grayed out even if the current node had a non-dismissed fragment child, when that fragment only had spore children. It is not the case anymore.

## v0.0.4
### Added
- Warning message when undoing a review of a deleted node.
- Spore title/pre-text appears in primary color in the node tree

### Fixed
- Delete the previous Mycel instance cache when changing the Mycel instance
- Include newlines in cloze regex matching (currently disallowed)
- Markdown-mycel-fork: Fixed two crashes in the rendering engine and resolved a code syntax stripping inconsistency.

## v0.0.3
### Added
- Better api connection status indicator in AppBar (orange if incompatible, MycelProject icon if reachable and compatible, spin animation)
- You can now choose whether newly created extracts are added to navigation history for quick access

### Fixed
- App initialization in correct order
- App now opens instantly even without network connection

## v0.0.2
- Display informations on Mycel/Mycelium compatibility

## v0.0.1
- Initial release (only for Android)
- Very unstable
