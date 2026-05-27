## Unreleased
### Added
- When creating an extract, a long press on the button on mobile or a right-click on desktop will also open the priority selector dialog, allowing for smooth prioritization.
- Closing the keyboard when reviewing fragment no longer remove the selection, just the cursor.

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
