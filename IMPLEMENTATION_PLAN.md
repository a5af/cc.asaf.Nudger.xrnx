# Implementation Plan - Selection Operations

**Version**: v2.0.5-beta to v2.1.0
**Status**: In Progress
**Last Updated**: 2025-10-01

## Current Status

### ✅ Completed (v2.0.5-beta - Phase 1)
- [x] Created `renoise/input_tracker.lua` module
  - Observable-based input detection
  - Tracks cursor vs selection input
  - Configuration support for input modes
  - Timeout mechanism for stale input
  - Debug information API

### 🔄 In Progress
- [ ] Integrate input tracker with main.lua
- [ ] Update config.lua with new settings
- [ ] Test input tracking behavior
- [ ] Update operations to use input tracker

### ⏳ Remaining Work

## Phase 1: Input Tracking Foundation (v2.0.5-beta)

### Step 1: Configuration ✅ NEXT
Add to `config.lua`:
```lua
-- Input mode configuration
input_mode = "AUTO",  -- "AUTO", "CURSOR_ONLY", "SELECTION_ONLY"
input_timeout_ms = 500,  -- How long to remember last input

-- Selection behavior
auto_select_moved_notes = true,
auto_select_cloned_notes = true,
```

### Step 2: Initialize in main.lua ✅ NEXT
```lua
-- In main.lua after loading modules
local InputTracker = require('renoise/input_tracker')

-- Initialize when tool loads
function initialize_tool()
  ConfigManager.load()
  ErrorHandler.set_log_level(ConfigManager.get_log_level_number())
  InputTracker.initialize()  -- ADD THIS
end

-- Cleanup on tool unload
_AUTO_RELOAD_DEBUG = function()
  InputTracker.cleanup()
  print("tools reloaded")
end
```

### Step 3: Update Operations
Modify move/clone operations to check input context:
```lua
-- In operations/move.lua
function Move.move_left()
  ErrorHandler.trace_enter("Move.move_left")

  -- Check input context instead of just selection
  if InputTracker.should_use_selection() then
    return Move.move_selection_left()
  end

  -- Regular cursor-based move...
end
```

### Step 4: Testing
- Test cursor navigation (should set CURSOR input type)
- Test selection creation (should set SELECTION input type)
- Test timeout behavior
- Test configuration modes (AUTO, CURSOR_ONLY, SELECTION_ONLY)

### Step 5: Commit v2.0.5-beta
```bash
git add -A
git commit -m "v2.0.5-beta - Input context tracking

- Created InputTracker module with Renoise observables
- Detects cursor vs selection input intent
- Configuration for input modes
- Integration with move/clone operations"
git push origin main
git tag -a v2.0.5-beta -m "Input context tracking"
git push origin v2.0.5-beta
```

**Estimated Time**: 2-3 hours remaining

---

## Phase 2: Selection Operations Implementation (v2.0.6-beta)

### Step 1: Implement SelectionAccessor.move_notes()
File: `renoise/selection_accessor.lua`

```lua
-- Move all notes in selection by direction
function SelectionAccessor.move_notes(direction)
  ErrorHandler.trace_enter("SelectionAccessor.move_notes", direction)

  -- 1. Validate can move
  local can_move, err = SelectionAccessor.can_move(direction)
  if not can_move then
    return false, err
  end

  local selection, err = SelectionAccessor.get_bounds()
  if not selection then
    return false, err
  end

  -- 2. Collect all notes from source
  local notes_to_move = {}
  SelectionAccessor.iterate_note_columns(function(note_column, track_idx, line_idx, col_idx)
    local note_data = {
      note_value = note_column.note_value,
      instrument_value = note_column.instrument_value,
      volume_value = note_column.volume_value,
      panning_value = note_column.panning_value,
      delay_value = note_column.delay_value,
      effect_number_value = note_column.effect_number_value,
      effect_amount_value = note_column.effect_amount_value,
      track = track_idx,
      line = line_idx,
      col = col_idx
    }
    table.insert(notes_to_move, note_data)
  end)

  -- 3. Calculate destination bounds
  local dest_bounds = calculate_dest_bounds(selection, direction)

  -- 4. Copy to destination and clear source
  SelectionAccessor.with_undo_grouping("Move Selection", function()
    local song = renoise.song()
    local pattern = song.patterns[song.selected_pattern_index]

    for _, note_data in ipairs(notes_to_move) do
      local dest_pos = translate_position(note_data, direction)

      -- Copy to destination
      local dest_line = pattern.tracks[dest_pos.track].lines[dest_pos.line]
      local dest_note = dest_line:note_column(dest_pos.col)

      dest_note.note_value = note_data.note_value
      dest_note.instrument_value = note_data.instrument_value
      dest_note.volume_value = note_data.volume_value
      dest_note.panning_value = note_data.panning_value
      dest_note.delay_value = note_data.delay_value
      dest_note.effect_number_value = note_data.effect_number_value
      dest_note.effect_amount_value = note_data.effect_amount_value

      -- Clear source
      local source_line = pattern.tracks[note_data.track].lines[note_data.line]
      local source_note = source_line:note_column(note_data.col)
      clear_note(source_note)
    end
  end)

  -- 5. Update selection to destination
  song.selection_in_pattern = dest_bounds

  return true, nil
end

-- Helper: Calculate destination bounds
local function calculate_dest_bounds(selection, direction)
  local new_bounds = {
    start_line = selection.start_line,
    end_line = selection.end_line,
    start_track = selection.start_track,
    end_track = selection.end_track,
    start_column = selection.start_column,
    end_column = selection.end_column
  }

  if direction == Constants.DIRECTION.UP then
    new_bounds.start_line = selection.start_line - 1
    new_bounds.end_line = selection.end_line - 1
  elseif direction == Constants.DIRECTION.DOWN then
    new_bounds.start_line = selection.start_line + 1
    new_bounds.end_line = selection.end_line + 1
  elseif direction == Constants.DIRECTION.LEFT then
    new_bounds.start_column = selection.start_column - 1
    new_bounds.end_column = selection.end_column - 1
  elseif direction == Constants.DIRECTION.RIGHT then
    new_bounds.start_column = selection.start_column + 1
    new_bounds.end_column = selection.end_column + 1
  end

  return new_bounds
end

-- Helper: Translate position by direction
local function translate_position(pos, direction)
  local new_pos = {
    track = pos.track,
    line = pos.line,
    col = pos.col
  }

  if direction == Constants.DIRECTION.UP then
    new_pos.line = pos.line - 1
  elseif direction == Constants.DIRECTION.DOWN then
    new_pos.line = pos.line + 1
  elseif direction == Constants.DIRECTION.LEFT then
    new_pos.col = pos.col - 1
  elseif direction == Constants.DIRECTION.RIGHT then
    new_pos.col = pos.col + 1
  end

  return new_pos
end
```

### Step 2: Implement SelectionAccessor.clone_notes()
Similar to move_notes but don't clear source:
```lua
function SelectionAccessor.clone_notes(direction)
  -- Same as move_notes but skip clear_note(source_note)
  -- Optionally update selection to cloned area based on config
end
```

### Step 3: Update Move/Clone Operations
File: `operations/move.lua`, `operations/clone.lua`

Replace calls to:
```lua
-- OLD
SelectionAccessor.move(direction)

-- NEW
SelectionAccessor.move_notes(direction)
```

### Step 4: Testing
- Run `busted tests/spec/operations/move_spec.lua`
- Fix failing tests
- Test multi-line, multi-column selections
- Test boundary conditions

### Step 5: Commit v2.0.6-beta
```bash
git commit -m "v2.0.6-beta - Implement selection move/clone

- SelectionAccessor.move_notes() fully implemented
- SelectionAccessor.clone_notes() fully implemented
- Operations use note-aware selection methods
- All tests passing"
git tag -a v2.0.6-beta -m "Selection operations working"
git push origin main v2.0.6-beta
```

**Estimated Time**: 8-10 hours

---

## Phase 3: Integration & Polish (v2.0.7-beta)

### Step 1: Visual Feedback
Add status line indicator for input mode:
```lua
-- Show current input mode in Renoise status line
function show_input_mode()
  local mode = InputTracker.get_input_type()
  renoise.app():show_status("Input Mode: " .. mode)
end
```

### Step 2: Configuration UI Helpers
Create helper functions:
```lua
-- Toggle input mode
function toggle_input_mode()
  local modes = {"AUTO", "CURSOR_ONLY", "SELECTION_ONLY"}
  local current = ConfigManager.get("input_mode", "AUTO")
  -- Cycle through modes
end
```

### Step 3: Documentation Updates
- Update USER_GUIDE.md with selection workflows
- Add EXAMPLES.md section for selection operations
- Update KEYBINDINGS.md with selection tips

### Step 4: Performance Testing
- Test with large selections (8x64 notes)
- Profile undo grouping performance
- Optimize if needed

### Step 5: Commit v2.0.7-beta
```bash
git commit -m "v2.0.7-beta - Integration and polish

- Visual feedback for input mode
- Configuration helpers
- Updated documentation
- Performance optimization"
git tag -a v2.0.7-beta -m "Integration complete"
git push origin main v2.0.7-beta
```

**Estimated Time**: 4-6 hours

---

## Phase 4: Stable Release (v2.1.0)

### Step 1: Complete Test Coverage
- Write tests for input_tracker
- Write tests for selection_accessor
- Ensure >80% code coverage
- Document test cases

### Step 2: User Acceptance Testing
- Create test song with various scenarios
- Test all operations manually
- Gather user feedback

### Step 3: Final Documentation
- Review all documentation
- Create video tutorial (optional)
- Update changelog

### Step 4: Release v2.1.0
```bash
git commit -m "v2.1.0 - Stable release with full selection support"
git tag -a v2.1.0 -m "Stable release"
git push origin main v2.1.0
```

**Estimated Time**: 6-8 hours

---

## Total Estimated Time

| Phase | Description | Hours |
|-------|-------------|-------|
| v2.0.5-beta | Input tracking (remaining) | 2-3 |
| v2.0.6-beta | Selection operations | 8-10 |
| v2.0.7-beta | Integration & polish | 4-6 |
| v2.1.0 | Stable release | 6-8 |
| **Total** | | **20-27** |

---

## Success Criteria

- [ ] Input tracker correctly identifies cursor vs selection intent
- [ ] Selection move works in all directions (up/down/left/right)
- [ ] Selection clone works in all directions
- [ ] Multi-line, multi-column selections work
- [ ] Boundary conditions handled gracefully
- [ ] Performance acceptable for large selections
- [ ] All tests passing
- [ ] Documentation complete
- [ ] User-facing configuration options

---

## Risk Mitigation

### Risk: Observable Performance
**Mitigation**: Test with large patterns, optimize if needed

### Risk: Multi-track Selection Complexity
**Mitigation**: Start with single-track, expand incrementally

### Risk: Phrase Editor Differences
**Mitigation**: Test both pattern and phrase, handle differences

---

## Next Immediate Actions

1. ✅ Add config settings to `config.lua`
2. ✅ Initialize InputTracker in `main.lua`
3. ✅ Update operations to use `InputTracker.should_use_selection()`
4. ✅ Test input tracking behavior
5. ✅ Commit v2.0.5-beta

Then proceed to Phase 2: Selection operations implementation.
