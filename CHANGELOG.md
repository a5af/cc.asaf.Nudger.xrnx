# Changelog

All notable changes to Note Properties (Nudger) will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-01-XX - Architectural Overhaul

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
