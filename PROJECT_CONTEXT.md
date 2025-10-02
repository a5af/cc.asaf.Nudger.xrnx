# Project Context - Note Properties (Nudger)

**Date**: 2025-10-02
**Current Version**: v2.0.6-beta (committed, not released)
**Status**: Selection note movement COMPLETE, ready for testing

---

## Project Overview

**Note Properties (Nudger)** is a Renoise scripting tool for keyboard-centric note manipulation in the pattern and phrase editors. The tool provides operations to nudge (modify properties), move, clone, and clear notes with comprehensive error handling and Renoise 3.5+ support.

### Key Features
- **Nudge Operations**: Increment/decrement note properties (note, instrument, volume, panning, delay, effects)
- **Move Operations**: Relocate notes in all four directions (up/down/left/right)
- **Clone Operations**: Duplicate notes in all four directions
- **Clear Operations**: Delete note data for single notes or selections
- **Pattern & Phrase Editor Support**: Works in both contexts with Renoise 3.5+
- **Input Context Tracking**: Detects cursor vs selection intent via observables
- **Undo Grouping**: Batch operations in single undo step (Renoise 3.5+)

---

## Architecture

### Layered Design
```
UI Layer (main.lua, keybindings)
    ↓
Operations Layer (operations/)
    ↓
Accessor Layer (renoise/)
    ↓
Core Layer (core/)
    ↓
Renoise API
```

### Module Structure

**Core Modules** (`core/`):
- `constants.lua` - All magic numbers and constants
- `error_handler.lua` - Logging with 4 levels (DEBUG, INFO, WARN, ERROR)
- `validator.lua` - Input and state validation
- `config_manager.lua` - Configuration with user override support

**Renoise Accessors** (`renoise/`):
- `context.lua` - Editor type detection (pattern vs phrase)
- `pattern_accessor.lua` - Pattern editor API access with validation
- `phrase_accessor.lua` - Phrase editor API access (Renoise 3.5+)
- `selection_accessor.lua` - Selection operations and iteration
- `input_tracker.lua` - **NEW in v2.0.5**: Observable-based input tracking

**Operations** (`operations/`):
- `nudge.lua` - Unified nudge operations (60% code reduction)
- `move.lua` - Move operations with input tracking integration
- `clone.lua` - Clone operations in all directions
- `clear.lua` - Clear operations with undo grouping

---

## Recent Development History

### v2.0.0-beta to v2.0.4-beta - Architectural Overhaul & Bug Fixes

**v2.0.0-beta** (Major refactor):
- Created modular architecture (6-phase implementation)
- Reduced code duplication by 60%
- Added comprehensive error handling and validation
- Completed effect column operations
- Completed clone left/right operations
- Fixed critical move right bug

**v2.0.1-beta** (Bug fix):
- **Critical**: Fixed "variable 'get_current_subcol' is not declared" error
- Removed legacy files (clone.lua, utils.lua, constants.lua)
- Created KEYBINDINGS.md setup guide

**v2.0.2-beta** (Bug fix):
- **Critical**: Restored missing clone operation keybindings
- Added menu entries for all operations

**v2.0.3-beta** (Bug fix):
- **Critical**: Fixed move/clone left/right cursor positioning
- Cursor now follows moved/cloned notes across tracks

**v2.0.4-beta** (Bug fix):
- **Critical**: Fixed operations to respect visible_note_columns
- Pattern/phrase accessors use visible columns for navigation
- Cross-track movement honors UI visibility settings

### v2.0.6-beta - Selection Note Movement (CURRENT - Testing Pending)

**Problem Solved**: Selection move/clone operations only updated bounds, didn't move actual note data.

**Implementation Complete**:

1. **Created `SelectionAccessor.move_notes(direction)`** (renoise/selection_accessor.lua):
   - Collects all notes from source selection into table
   - Calculates destination bounds with validation
   - Copies notes to destination
   - Clears source notes
   - Updates selection to new position
   - Uses undo grouping for single undo step

2. **Created `SelectionAccessor.clone_notes(direction)`**:
   - Same as move_notes but keeps source intact
   - Supports all four directions

3. **Helper functions added**:
   - `calculate_dest_bounds(selection, direction)` - Calculates new bounds
   - `is_within_bounds(bounds, context)` - Validates against pattern limits
   - `copy_note_column(src, dst)` - Copies all note properties
   - `clear_note_column(note)` - Clears to blank state

4. **Updated operations/move.lua**:
   - `move_selection_*()` now call `SelectionAccessor.move_notes()`
   - Actually moves note data instead of just bounds

5. **Updated operations/clone.lua**:
   - Added InputTracker checks to all clone operations
   - Implemented `clone_selection_up/down/left/right()`
   - Full cursor and selection mode support

**Files Changed** (Commit 9b0bb66):
- renoise/selection_accessor.lua (+350 lines)
- operations/move.lua (4 lines changed)
- operations/clone.lua (+28 lines)
- CHANGELOG.md (updated)
- manifest.xml (version → 2.0.6)

**Status**: ✅ Code Complete, ✅ Committed to main, ⏳ Testing Required

### v2.0.5-beta - Input Context Tracking

**Problem Identified**: Operations weren't respecting user selections properly. When a selection existed, operations would sometimes act on cursor position instead of selection, leading to confusing behavior.

**Root Cause**: SelectionAccessor.move() only updates selection bounds without moving actual note data. Additionally, no mechanism existed to determine if user intended cursor or selection operation.

**Solution**: Input tracking system that monitors last input type (cursor vs selection) to determine user intent.

**Implementation**:

1. **Created `renoise/input_tracker.lua`**:
   ```lua
   InputTracker.INPUT_TYPE = {
     CURSOR = "CURSOR",
     SELECTION = "SELECTION",
     UNKNOWN = "UNKNOWN"
   }

   function InputTracker.should_use_selection()
     -- Returns true if last input was selection-based
     -- Respects config.input_mode (AUTO, CURSOR_ONLY, SELECTION_ONLY)
     -- Uses configurable timeout (default 500ms)
   end
   ```

2. **Observable Subscriptions**:
   - `selected_line_index_observable` - Tracks cursor movement
   - `selection_in_pattern_observable` - Tracks selection changes
   - Auto-cleanup on tool reload and new document

3. **Configuration Options** (config.lua):
   ```lua
   input_mode = "AUTO"  -- "AUTO", "CURSOR_ONLY", "SELECTION_ONLY"
   input_timeout_ms = 500
   auto_select_moved_notes = true
   auto_select_cloned_notes = true
   ```

4. **Integration** (operations/move.lua):
   ```lua
   function Move.move_up()
     if InputTracker.should_use_selection() then
       return Move.move_selection_up()
     end
     -- ... cursor-based move
   end
   ```

**Status**: ✅ Phase 1 Complete - Input tracking foundation working

---

## Current Issues & Next Steps

### Status: v2.0.6-beta COMPLETE - Testing Required

**What Was Done**:
✅ Implemented `SelectionAccessor.move_notes()` - moves actual note data
✅ Implemented `SelectionAccessor.clone_notes()` - clones notes to new position
✅ Added helper functions for bounds calculation and validation
✅ Updated operations/move.lua to use move_notes()
✅ Updated operations/clone.lua with selection support
✅ Updated CHANGELOG.md and manifest.xml
✅ Committed to main branch (commit 9b0bb66)

**What's Next - IMMEDIATE**:

1. **Install Lua/Busted** (if testing locally):
   ```bash
   # Install Lua 5.1 or 5.2
   # Install LuaRocks
   # Install Busted: luarocks install busted
   ```

2. **Run Tests** (if Lua installed):
   ```bash
   cd /home/asafe/Repo/cc.asaf.Nudger.xrnx
   busted tests/spec
   ```

3. **Manual Testing in Renoise** (recommended):
   - Load tool in Renoise
   - Test selection move operations (up/down/left/right)
   - Test selection clone operations
   - Verify boundary checking
   - Verify undo grouping works

4. **Create Release** (after testing passes):
   ```bash
   git tag v2.0.6-beta
   git push origin v2.0.6-beta
   # GitHub Actions will auto-create release with .xrnx
   ```

---

## Implementation Roadmap

### Phase 2: v2.0.6-beta - Selection Operations ✅ COMPLETE

**Status**: ✅ Implementation complete, committed to main (9b0bb66)

**Completed**:
✅ Implemented `SelectionAccessor.move_notes(direction)` with full validation
✅ Implemented `SelectionAccessor.clone_notes(direction)`
✅ Helper functions: `calculate_dest_bounds()`, `is_within_bounds()`, etc.
✅ Updated `Move.move_selection_*` to use move_notes()
✅ Added clone selection support in Clone module
✅ Updated documentation and version

**Next**: Testing and release

### Phase 3: v2.0.7-beta - Integration & Polish (NEXT)

**Tasks**:
- Visual feedback for input mode (status line message)
- Configuration helpers (menu for changing input_mode)
- Documentation updates for selection workflows
- Performance testing with large selections (100+ notes)
- Edge case handling (selections spanning hidden columns)

**Estimated Effort**: 4-6 hours

### Phase 4: v2.1.0 - Stable Release

**Tasks**:
- Complete test coverage (target >80%)
- User acceptance testing
- Final documentation review
- Performance optimizations
- Stable release

**Estimated Effort**: 6-8 hours

---

## Testing Infrastructure

### Framework: Busted
```bash
cd /home/asafe/Repo/cc.asaf.Nudger.xrnx
busted tests/spec
```

### Test Files
- `tests/spec/core/constants_spec.lua` - Constants validation ✅
- `tests/spec/operations/move_spec.lua` - Move operations (defines expected behavior)
- `tests/spec/operations/clone_spec.lua` - Clone operations (defines expected behavior)
- `tests/spec/helpers/mock_renoise.lua` - Mock Renoise API for testing

### Mock Strategy
Mock objects replicate Renoise API structure:
```lua
song.patterns[1].tracks[1].lines[1]:note_column(1).note_value = 48
```

Tests define expected behavior before implementation (TDD approach).

---

## Configuration System

### System Config: `config.lua`
Default configuration for all users:
```lua
{
  log_level = "INFO",
  debug_mode = false,

  -- Input tracking
  input_mode = "AUTO",
  input_timeout_ms = 500,

  -- Auto-selection
  auto_select_moved_notes = true,
  auto_select_cloned_notes = true,

  -- Nudge settings
  auto_advance_after_nudge = false,
  wrap_on_nudge = true,

  -- OSC
  osc_enabled = false,
  osc_server_port = 8000,
  osc_client_host = "127.0.0.1",
  osc_client_port = 8001
}
```

### User Override: `user_config.lua` (gitignored)
Users can override any setting:
```lua
return {
  log_level = "DEBUG",
  input_mode = "CURSOR_ONLY"
}
```

### Access in Code
```lua
local ConfigManager = require('core/config_manager')
local mode = ConfigManager.get("input_mode", "AUTO")  -- With default fallback
```

---

## CI/CD Pipeline

### GitHub Actions: `.github/workflows/release.yml`

**Trigger**: Push tag matching `v*` (e.g., `v2.0.5-beta`)

**Process**:
1. Checkout code
2. Extract version from tag
3. Package .xrnx file (zip of project root)
4. Create GitHub Release
5. Upload .xrnx as release asset

**Release Command**:
```bash
git tag v2.0.6-beta
git push origin v2.0.6-beta
# GitHub Actions automatically creates release with .xrnx download
```

---

## Code Quality Standards

### Error Handling
All operations return `(success, error)`:
```lua
local success, err = Move.move_up()
if not success then
  ErrorHandler.warn(err)
  return false
end
```

### Logging Levels
- **DEBUG**: Trace function entry/exit, variable values
- **INFO**: User-visible operations, state changes
- **WARN**: Recoverable errors, boundary conditions
- **ERROR**: Critical failures

### Validation
All inputs validated before use:
```lua
if not Validator.is_valid_direction(direction) then
  return false, "Invalid direction"
end
```

### Observable Management
Always cleanup observables:
```lua
function Module.cleanup()
  if state.cursor_notifier then
    renoise.song().selected_line_index_observable:remove_notifier(state.cursor_notifier)
    state.cursor_notifier = nil
  end
end
```

---

## Development Workflow

### Standard Iteration
1. **Plan**: Update IMPLEMENTATION_PLAN.md or create todo list
2. **Implement**: Write code following architecture patterns
3. **Test**: Run Busted tests, fix failures
4. **Document**: Update CHANGELOG.md
5. **Version**: Bump version in manifest.xml
6. **Commit**: Descriptive commit message with emoji header
7. **Release**: Tag and push for automated release

### Commit Message Format
```
Phase N: Feature Name

Brief description of what was accomplished.

Detailed changes:
- Module 1 (file1.lua):
  - Change description
  - Another change

Results:
✅ Achievement 1
✅ Achievement 2

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Testing During Development
```bash
# Run all tests
busted tests/spec

# Run specific module
busted tests/spec/operations/move_spec.lua

# Verbose output
busted tests/spec -v
```

---

## Key Technical Insights

### Visible Columns vs All Columns
**Critical**: Always use `visible_note_columns`, not `#note_columns`:
```lua
-- WRONG:
local count = #line.note_columns

// RIGHT:
local count = song.tracks[track_idx].visible_note_columns
```

Hidden columns exist in data but aren't shown in UI. Operations must respect UI visibility.

### Cross-Track Navigation
When moving left/right across track boundaries:
```lua
-- Moving left from first column of track 2
if context.note_col == 1 and context.track > 1 then
  song.selected_track_index = context.track - 1
  -- Move to LAST visible column of previous track
  song.selected_note_column_index = song.tracks[context.track - 1].visible_note_columns
end
```

### Phrase Editor Limitations
Phrase editor doesn't support cross-track movement (single track context):
```lua
if context.editor_type == Constants.EDITOR_CONTEXT.PHRASE then
  -- Can't move to previous/next track
  if context.note_col == 1 then
    return nil, "Already at leftmost column"
  end
end
```

### Undo Grouping (Renoise 3.5+)
Batch multiple changes into single undo step:
```lua
if renoise.API_VERSION >= 6.2 then
  song:describe_undo("Move Selection")
end

-- ... perform multiple note changes ...

-- Automatically groups as single undo
```

### Observable Pattern
Subscribe to Renoise events:
```lua
-- Subscribe
local notifier = function() on_cursor_changed() end
renoise.song().selected_line_index_observable:add_notifier(notifier)

-- CRITICAL: Always cleanup
function cleanup()
  if notifier then
    renoise.song().selected_line_index_observable:remove_notifier(notifier)
    notifier = nil
  end
end
```

---

## Common Patterns

### Operation Template
```lua
function Operation.do_something()
  ErrorHandler.trace_enter("Operation.do_something")

  -- 1. Get context
  local context, err = Context.get_current()
  if not context then
    ErrorHandler.warn(err)
    return false, err
  end

  -- 2. Validate
  if not Validator.can_do_something(context) then
    return false, "Cannot do something"
  end

  -- 3. Perform operation
  if context.editor_type == Constants.EDITOR_CONTEXT.PHRASE then
    -- Phrase editor path
  else
    -- Pattern editor path
  end

  ErrorHandler.trace_exit("Operation.do_something", true)
  return true, nil
end
```

### Accessor Template
```lua
function Accessor.get_something(context)
  -- Validate context
  if not Validator.is_valid_context(context) then
    return nil, "Invalid context"
  end

  -- Access Renoise API safely
  local song = renoise.song()
  if not song then
    return nil, "No song loaded"
  end

  -- Return data or nil + error
  return data, nil
end
```

---

## Critical Files Reference

### Most Frequently Modified
1. `operations/move.lua` - Move operations logic
2. `operations/clone.lua` - Clone operations logic
3. `renoise/selection_accessor.lua` - Selection operations (needs work)
4. `config.lua` - Configuration defaults
5. `main.lua` - Tool initialization and keybindings
6. `CHANGELOG.md` - Version history
7. `manifest.xml` - Version and metadata

### Architecture Foundation (Rarely Change)
- `core/constants.lua` - Constants definitions
- `core/error_handler.lua` - Logging system
- `core/validator.lua` - Validation functions
- `core/config_manager.lua` - Config loading

### Renoise API Access (Occasionally Update)
- `renoise/context.lua` - Context detection
- `renoise/pattern_accessor.lua` - Pattern API
- `renoise/phrase_accessor.lua` - Phrase API
- `renoise/input_tracker.lua` - Input tracking (NEW)

---

## File Locations

```
cc.asaf.Nudger.xrnx/
├── core/
│   ├── constants.lua
│   ├── error_handler.lua
│   ├── validator.lua
│   └── config_manager.lua
├── renoise/
│   ├── context.lua
│   ├── pattern_accessor.lua
│   ├── phrase_accessor.lua
│   ├── selection_accessor.lua ← NEEDS WORK
│   └── input_tracker.lua ← NEW in v2.0.5
├── operations/
│   ├── nudge.lua
│   ├── move.lua ← Recently updated
│   ├── clone.lua
│   └── clear.lua
├── tests/
│   └── spec/
│       ├── core/
│       │   └── constants_spec.lua
│       ├── operations/
│       │   ├── move_spec.lua ← Defines expected behavior
│       │   └── clone_spec.lua ← Defines expected behavior
│       └── helpers/
│           └── mock_renoise.lua
├── docs/
│   ├── USER_GUIDE.md
│   ├── DEVELOPMENT.md
│   └── EXAMPLES.md
├── .github/
│   └── workflows/
│       └── release.yml ← CI/CD pipeline
├── config.lua ← System defaults
├── user_config.lua ← User overrides (gitignored)
├── main.lua ← Tool entry point
├── manifest.xml ← Version: 2.0.5
├── CHANGELOG.md
├── KEYBINDINGS.md
├── IMPLEMENTATION_PLAN.md ← Detailed roadmap
├── MOVING_FORWARD.md ← Strategy document
└── PROJECT_CONTEXT.md ← This file
```

---

## Contact & Resources

- **Repository**: https://github.com/a5af/cc.asaf.Nudger.xrnx
- **Issues**: https://github.com/a5af/cc.asaf.Nudger.xrnx/issues
- **Author**: Asaf Ebgi (https://asaf.cc)
- **Renoise API**: https://files.renoise.com/xrnx/documentation/

---

## Quick Commands

### Development
```bash
# Run tests
cd /home/asafe/Repo/cc.asaf.Nudger.xrnx
busted tests/spec

# Test specific module
busted tests/spec/operations/move_spec.lua -v

# Check git status
git status

# View recent commits
git log --oneline -5
```

### Release
```bash
# Update version in manifest.xml first!
# Update CHANGELOG.md with new version entry!

# Commit changes
git add .
git commit -m "Phase N: Feature Name

Details...

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
"

# Push and create release
git push origin main
git tag v2.0.6-beta
git push origin v2.0.6-beta

# GitHub Actions will automatically create release with .xrnx download
```

---

## Summary

**Current State**: v2.0.6-beta implementation COMPLETE and committed to main (9b0bb66). Selection move/clone operations now actually move note data. Ready for testing.

**What Was Accomplished**:
- ✅ Implemented `SelectionAccessor.move_notes()` - moves actual note data
- ✅ Implemented `SelectionAccessor.clone_notes()` - clones notes
- ✅ Added helper functions for bounds calculation and validation
- ✅ Updated move and clone operations to use new functions
- ✅ Updated documentation (CHANGELOG.md, manifest.xml)
- ✅ Code committed and pushed to GitHub

**Immediate Next Steps**:
1. Install Lua/Busted for local testing (optional)
2. Test in Renoise (selection move/clone operations)
3. Create release tag: `git tag v2.0.6-beta && git push origin v2.0.6-beta`

**Timeline**: v2.0.6-beta ready for release → v2.0.7-beta polish (4-6 hours) → v2.1.0 stable (6-8 hours)

**Critical Path**: Testing → Release → Polish → Stable

---

*This document provides comprehensive context for continuing development.*

*Last Updated: 2025-10-02 - After v2.0.6-beta implementation*
