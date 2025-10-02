# Changelog

All notable changes to Note Properties (Nudger) will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.5-beta] - 2025-10-01 - Input Context Tracking

### Added
- **InputTracker module**: Detects cursor vs selection input intent
  - Subscribes to Renoise observables for cursor and selection changes
  - Tracks last input type (CURSOR or SELECTION)
  - Configurable timeout for input memory (default 500ms)
  - Configuration modes: AUTO, CURSOR_ONLY, SELECTION_ONLY
  - Debug API for troubleshooting

### Changed
- Move operations now use `InputTracker.should_use_selection()`
- Operations respect user's last input type instead of just checking if selection exists
- Input mode configurable via `config.lua`

### Configuration
- New config: `input_mode` - Controls cursor vs selection behavior
- New config: `input_timeout_ms` - How long to remember last input
- New config: `auto_select_moved_notes` - Update selection after move
- New config: `auto_select_cloned_notes` - Update selection after clone

**Note**: Selection move/clone still not fully implemented (moves bounds only)

## [2.0.4-beta] - 2025-10-01 - Respect Visible Note Columns

### Fixed
- **Critical**: Operations now respect visible_note_columns instead of all columns
  - Pattern accessor uses track.visible_note_columns for navigation
  - Phrase accessor uses phrase.visible_note_columns for navigation
  - Move/clone left/right honor UI visibility settings
  - Cursor positioning uses visible columns only

### Changed
- get_note_column_count() now returns visible column count
- can_move_right() checks against visible columns
- Cross-track navigation uses visible columns for positioning

## [2.0.3-beta] - 2025-10-01 - Fix Move/Clone Left/Right

### Fixed
- **Critical**: Fixed move left/right operations not updating cursor position
  - Now properly updates track index when moving across tracks
  - Cursor follows moved note to correct position
- **Critical**: Fixed clone left/right operations not updating cursor position
  - Now properly updates track index when cloning across tracks
  - Cursor follows cloned note when auto_select_cloned_note is enabled

### Changed
- Move/clone left/right now properly handle cross-track movement
- Cursor positioning is consistent with up/down operations

## [2.0.2-beta] - 2025-10-01 - Restore Missing Keybindings

### Fixed
- **Critical**: Restored missing clone operation keybindings (Clone Up/Down/Left/Right)
- Added missing menu entries for Move operations
- Added missing menu entry for Clear operation

### Changed
- All operations now have both keybindings and menu entries for consistency

## [2.0.1-beta] - 2025-10-01 - Critical Bug Fixes

### Fixed
- **Critical**: Fixed "variable 'get_current_subcol' is not declared" error in clone operations
- Removed legacy `clone.lua` file that was conflicting with new operations/clone.lua
- Removed legacy `utils.lua` and `constants.lua` files that were no longer used
- Cleaned up main.lua to only load new modular architecture files

### Added
- KEYBINDINGS.md - Comprehensive keybinding setup guide with platform-specific instructions
- Alternative keybinding suggestions for conflict resolution
- Quick setup reference table in README

### Changed
- Updated README to reference KEYBINDINGS.md for setup instructions

## [2.0.0-beta] - 2025-10-01 - Architectural Overhaul

### Added
- **Core Infrastructure**
  - Constants module with all magic numbers documented
  - Error handler with 4-level logging (DEBUG, INFO, WARN, ERROR)
  - Validator with comprehensive input and state validation
  - Config manager with user config override support
  - Configuration system for customizable behavior

- **Renoise API Abstraction**
  - Context detection for pattern vs phrase editor
  - Pattern accessor with validated API access
  - Phrase accessor for Renoise 3.5+ support
  - Selection accessor with undo grouping
  - Unified interface across editors

- **Unified Operations**
  - Nudge: Single implementation for up/down (60% code reduction)
  - Move: All directions with selection support
  - Clone: All four directions (completed left/right)
  - Clear: Single notes and selections with undo grouping

- **Renoise 3.5 Features**
  - Full phrase editor support
  - Undo/redo integration with batch grouping
  - Automatic editor type detection
  - Graceful degradation for Renoise 3.4

- **Documentation**
  - Comprehensive user guide
  - Developer guide with architecture details
  - Examples with 20+ common workflows
  - Architecture overhaul document
  - Code analysis document

### Changed
- Refactored nudge operations into single parameterized function
- Reduced code duplication from ~180 lines to ~40 lines
- Moved all Renoise API calls to accessor layer
- Improved error messages and user feedback
- Updated manifest metadata (author, category, description)

### Fixed
- **Critical**: Fixed move right bug (was decrementing instead of incrementing)
- **Critical**: Fixed get_right_note logic errors
- Completed effect column nudging (was printing debug messages)
- Completed clone left/right operations (were stubs)
- Proper boundary validation for all operations
- Selection move boundary checking

### Removed
- 500+ lines of legacy code from main.lua
- Old nudgeUp/nudgeDown implementations
- Old move/clone/clear implementations
- Duplicate helper functions
- Unused utility code

## [1.0] - Previous Version

### Features
- Basic nudge up/down for note properties
- Move operations (with bugs)
- Clone up/down (left/right incomplete)
- Clear operations
- Pattern editor support only
- No error handling
- Hardcoded configuration

### Known Issues (Fixed in 0.1.1)
- Move right not working correctly
- No phrase editor support
- Effect columns only printing debug messages
- Clone left/right not implemented
- No validation or error handling
- Code duplication in nudge operations

## Roadmap

### Future Versions

**v2.1.0** (Optional Enhancements):
- OSC server/client integration
- Preference panel UI
- Macro recording system
- Performance optimizations
- Additional features based on user feedback

## Migration Guide

### From v1.0 to v2.0

**Breaking Changes**: None - fully backward compatible

**New Features**:
- Phrase editor support (Renoise 3.5+)
- Effect column nudging now works
- Clone left/right now functional
- Selection operations improved

**Configuration**:
- Create `user_config.lua` to customize behavior
- See `config.lua` for all available options

**Keybindings**:
- Same keybinding names
- Recommend setting up shortcuts per README

## Support

- **Issues**: https://github.com/a5af/cc.asaf.Nudger.xrnx/issues
- **Documentation**: See `docs/` folder
- **Source**: https://github.com/a5af/cc.asaf.Nudger.xrnx
