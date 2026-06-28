# Project Overview
Mycelium is a cross-platform learning app built on top of Mycel, an agnostic backend 
exposing a REST API and handling all learning logic. Mycelium is a seamless client 
around Mycel and does not handle any learning logic itself. It is built in Flutter 
and must be supported on all major platforms (Windows, macOS, Linux, Android, iOS).

# Architecture
- ui/ — mostly widgets and pages
- data/ — infrastructure and communication with Mycel
- domain/ — use cases, acting as reusable logic black boxes
- viewmodels/ — logic attached to specific pages, going through use cases 
  as much as possible except for straightforward page-specific logic
- core/ — app-level utilities with no business logic

The flow is: page → ViewModel → (Use cases →) → Repository 
(handles caching/retry) → Services → API service, and back up the same way.

# Key Concepts
- Spore: atomic unit of knowledge to memorize (like a flashcard) 
  (equivalent to an Item in SuperMemo)
- Fragment: equivalent to a Topic in SuperMemo

# Stack
- Flutter with ChangeNotifier + Provider for state management
- Dependency injection: get_it, configured in injection.dart
- Navigation: standard Flutter Navigator.push
- Error handling: custom ApiResult type propagated up through 
  use cases and viewmodels, handled case by case at the call site

# Conventions
- Follow existing code conventions — when in doubt, look at what's already there
- Everything written into files (code, comments, ...) must be written in English.
- Keep comments minimal — only add them when the code is not self-explanatory or when explicitly asked.
- Follow the app's graphical theme; use the primary color as the base

# Testing
- Unit tests: `./test_unit`
- Integration tests: `./test_integration` — runs against a mock Mycel server 
  generated from the OpenAPI spec. Always run integration tests when touching 
  the API layer.
- Standard Flutter test commands otherwise
- The test/ folder mirrors the main source structure, with separate 
  subdirectories for unit and integration tests.
  
# Workflow
- When adding a feature, always discuss the testing approach together 
  before implementing it.

# What NOT to do
- Don't implement learning logic independently — delegate to Mycel
- Don't break the layer architecture

# Commits
- Follow Conventional Commits: feat/fix/refactor/chore: short description (english).
- Add a body when the commit message alone is not self-explanatory, or for releases. Skip it for trivial changes.
- Add Co-authored-by: <model-name> only when the agent wrote or significantly modified the code, not for simple instructions applied as-is.
- Always write in English in commit messages, even if we are talking in another language.
- After each meaningful commit, add an entry to CHANGELOG.md under the Unreleased section, in the appropriate category (Added, Fixed, or Refactored), in English. Skip trivial or chore commits.
