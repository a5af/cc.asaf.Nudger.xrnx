# Moving Forward - Selection & Operation Strategy

**Status**: Work in Progress
**Date**: 2025-10-01
**Version**: 2.0.4-beta+

## Critical Issues Identified

### 1. Selection Move/Clone Not Implemented
**Problem**: Selection move operations only update selection bounds, don't move actual note data.

**Current Behavior**:
```lua
-- SelectionAccessor.move() only updates selection box position
-- Doesn't copy/move note data inside selection
```

**Expected Behavior**:
- Move should copy all notes in selection to new location and clear source
- Clone should copy all notes in selection to new location, preserve source
- Cursor should follow to moved/cloned location

### 2. Cursor vs Selection Ambiguity
**Problem**: Tool doesn't distinguish between cursor-based and selection-based input.

**Current Logic**:
```lua
if Context.has_selection() then
  return Move.move_selection_*()  -- Currently broken
else
  return Move.move_*()  -- Works
end
```

**Issues**:
- Always prefers selection if one exists
- User might want cursor operation even with lingering selection
- No way to know user's intent

## Proposed Solution: Input Context Tracking

### Strategy: Last Input Detection

Track what the user's last action was to determine intent:

```lua
-- New module: renoise/input_tracker.lua
local InputTracker = {
  last_input_type = nil,  -- "CURSOR" or "SELECTION"
  last_input_time = 0
}

-- Called by Renoise observables
function InputTracker.on_cursor_move()
  InputTracker.last_input_type = "CURSOR"
  InputTracker.last_input_time = os.clock()
end

function InputTracker.on_selection_change()
  InputTracker.last_input_type = "SELECTION"
  InputTracker.last_input_time = os.clock()
end

function InputTracker.should_use_selection()
  -- If selection exists AND last input was selection-related
  return Context.has_selection() and
         InputTracker.last_input_type == "SELECTION"
end
```

### Implementation Approach

**Phase 1: Input Tracking** (v2.0.5-beta)
1. Create `renoise/input_tracker.lua`
2. Subscribe to Renoise observables:
   - `song.selected_line_index_observable`
   - `song.selected_note_column_index_observable`
   - `song.selection_in_pattern_observable`
3. Track last input type and timestamp
4. Provide `should_use_selection()` helper

**Phase 2: Fix Selection Operations** (v2.0.6-beta)
1. Implement proper selection move:
   ```lua
   function SelectionAccessor.move_notes(direction)
     -- 1. Get all notes in selection
     -- 2. Calculate destination bounds
     -- 3. Copy notes to destination
     -- 4. Clear source notes
     -- 5. Update selection to new location
   end
   ```

2. Implement proper selection clone:
   ```lua
   function SelectionAccessor.clone_notes(direction)
     -- 1. Get all notes in selection
     -- 2. Calculate destination bounds
     -- 3. Copy notes to destination
     -- 4. Keep source notes
     -- 5. Update selection to cloned location (configurable)
   end
   ```

**Phase 3: Integrate Input Context** (v2.0.7-beta)
1. Update operations to use `InputTracker.should_use_selection()`
2. Provide config option to force cursor/selection mode
3. Add visual feedback for which mode is active

## Testing Strategy

### Test-Driven Development Approach

**Write Tests First** to define expected behavior:

1. **Selection Move Tests**:
   ```lua
   describe("Move.move_left with selection", function()
     it("should move all notes in selection left", function()
       -- Setup: 2x2 selection with notes
       -- Action: move_left()
       -- Assert: Notes moved left, source cleared
     end)
   end)
   ```

2. **Selection Clone Tests**:
   ```lua
   describe("Clone.clone_right with selection", function()
     it("should clone all notes in selection right", function()
       -- Setup: 2x2 selection with notes
       -- Action: clone_right()
       -- Assert: Notes cloned right, source preserved
     end)
   end)
   ```

3. **Input Context Tests**:
   ```lua
   describe("InputTracker", function()
     it("should detect cursor input", function()
       -- Simulate cursor move
       -- Assert: should_use_selection() == false
     end)

     it("should detect selection input", function()
       -- Simulate selection change
       -- Assert: should_use_selection() == true
     end)
   end)
   ```

### Test Files to Create

**Priority 1** - Define expected behavior:
- `tests/spec/operations/move_spec.lua`
- `tests/spec/operations/clone_spec.lua`
- `tests/spec/renoise/selection_accessor_spec.lua`

**Priority 2** - Support infrastructure:
- `tests/spec/renoise/input_tracker_spec.lua`
- `tests/spec/operations/nudge_spec.lua`
- `tests/spec/operations/clear_spec.lua`

## Implementation Roadmap

### v2.0.5-beta: Input Tracking Foundation
**Goal**: Track cursor vs selection input

- [ ] Create `renoise/input_tracker.lua`
- [ ] Subscribe to Renoise observables
- [ ] Add configuration for input mode preferences
- [ ] Write tests for input tracking
- [ ] Update operations to check input context

**Estimated Effort**: 4-6 hours

### v2.0.6-beta: Selection Operations Core
**Goal**: Implement proper selection move/clone

- [ ] Write comprehensive selection operation tests
- [ ] Implement `SelectionAccessor.move_notes()`
- [ ] Implement `SelectionAccessor.clone_notes()`
- [ ] Handle multi-track selections
- [ ] Handle boundary conditions
- [ ] Add undo grouping for batch operations

**Estimated Effort**: 8-10 hours

### v2.0.7-beta: Integration & Polish
**Goal**: Complete selection support

- [ ] Integrate input tracker with operations
- [ ] Add user configuration options
- [ ] Visual feedback for active mode
- [ ] Update documentation
- [ ] Create workflow examples

**Estimated Effort**: 4-6 hours

### v2.1.0: Stable Release
**Goal**: Production-ready with full selection support

- [ ] Complete test coverage (>80%)
- [ ] Performance optimization
- [ ] User acceptance testing
- [ ] Final documentation review

**Estimated Effort**: 6-8 hours

## Design Decisions

### Why Track Last Input?

**Alternative 1**: Always prefer cursor (current behavior for single notes)
- ❌ User can't operate on selections
- ❌ Inconsistent with Renoise UI patterns

**Alternative 2**: Always prefer selection when exists
- ❌ User can't use cursor with lingering selection
- ❌ Requires manual deselection

**Alternative 3**: Track last input type ✅
- ✅ Intuitive - follows user's last action
- ✅ Configurable with override options
- ✅ Consistent with DAW expectations
- ⚠️ Requires observable subscriptions

### Selection Move Algorithm

**Approach**: Copy-then-Clear

```lua
function move_selection(direction)
  -- 1. Validate destination bounds available
  if not can_move_selection(direction) then
    return false, "Cannot move selection"
  end

  -- 2. Collect all notes from source
  local notes = {}
  for track, line, col in iterate_selection() do
    notes[{track,line,col}] = get_note(track, line, col)
  end

  -- 3. Calculate destination bounds
  local dest_bounds = calculate_dest_bounds(selection, direction)

  -- 4. Copy to destination
  with_undo_grouping("Move Selection", function()
    for pos, note in pairs(notes) do
      local dest_pos = translate_position(pos, direction)
      copy_note(note, dest_pos)
    end

    -- 5. Clear source
    for track, line, col in iterate_selection() do
      clear_note(track, line, col)
    end
  end)

  -- 6. Update selection to destination
  update_selection(dest_bounds)
end
```

### Configuration Options

Add to `config.lua`:

```lua
return {
  -- Input mode
  input_mode = "AUTO",  -- "AUTO", "CURSOR_ONLY", "SELECTION_ONLY"

  -- Selection behavior
  auto_select_moved_notes = true,  -- Update selection after move
  auto_select_cloned_notes = true,  -- Update selection after clone

  -- Input tracking
  input_timeout_ms = 500,  -- How long to remember last input
}
```

## Known Limitations

1. **Multi-track selections**: Complex logic for cross-track moves
2. **Hidden columns**: Must respect visible_note_columns
3. **Phrase editor**: Different API, may have limitations
4. **Performance**: Large selections may be slow (use undo grouping)

## Success Criteria

- [ ] Tests define all expected behaviors
- [ ] Selection move works correctly in all directions
- [ ] Selection clone works correctly in all directions
- [ ] Input tracking correctly identifies user intent
- [ ] Configuration allows user preferences
- [ ] Documentation explains selection workflow
- [ ] Performance acceptable for large selections (tested with 8x64 selections)

## References

- Current implementation: `operations/move.lua`, `operations/clone.lua`
- Selection accessor: `renoise/selection_accessor.lua`
- Test framework: `tests/README.md`
- Architecture: `docs/DEVELOPMENT.md`

## Next Immediate Steps

1. **Write comprehensive tests** for move/clone with selections
2. **Create input tracker** module with observables
3. **Implement selection move/clone** operations
4. **Test with real Renoise** (manual integration testing)
5. **Document workflows** with selection examples

---

**Note**: This is a living document. Update as implementation progresses and new insights emerge.
