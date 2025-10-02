--[[============================================================================
renoise/selection_accessor.lua
============================================================================]]--

--[[

Selection accessor for Nudger tool.
Provides access to multi-note selections and operations.

]]--

local Constants = require('core/constants')
local Validator = require('core/validator')
local ErrorHandler = require('core/error_handler')
local ConfigManager = require('core/config_manager')

local SelectionAccessor = {}

-- ============================================================================
-- Selection Information
-- ============================================================================

-- Get current selection bounds
-- @return selection table or nil, error
function SelectionAccessor.get_bounds()
  local success, err = Validator.validate_selection_in_pattern()
  if not success then
    return nil, err
  end

  local song = renoise.song()
  local selection = song.selection_in_pattern

  return {
    start_line = selection.start_line,
    end_line = selection.end_line,
    start_track = selection.start_track,
    end_track = selection.end_track,
    start_column = selection.start_column,
    end_column = selection.end_column
  }, nil
end

-- Get selection size (number of lines)
-- @return line_count or 0
function SelectionAccessor.get_line_count()
  local selection, err = SelectionAccessor.get_bounds()
  if not selection then
    return 0
  end

  return (selection.end_line - selection.start_line + 1)
end

-- Get selection track count
-- @return track_count or 0
function SelectionAccessor.get_track_count()
  local selection, err = SelectionAccessor.get_bounds()
  if not selection then
    return 0
  end

  return (selection.end_track - selection.start_track + 1)
end

-- Get selection column count (within a track)
-- @return column_count or 0
function SelectionAccessor.get_column_count()
  local selection, err = SelectionAccessor.get_bounds()
  if not selection then
    return 0
  end

  return (selection.end_column - selection.start_column + 1)
end

-- Get total number of notes in selection (approximate)
-- @return note_count
function SelectionAccessor.get_note_count()
  local line_count = SelectionAccessor.get_line_count()
  local track_count = SelectionAccessor.get_track_count()
  local col_count = SelectionAccessor.get_column_count()

  -- Approximate: lines * tracks * columns
  return line_count * track_count * col_count
end

-- ============================================================================
-- Selection Movement
-- ============================================================================

-- Check if selection can move in direction
-- @param direction: "up", "down", "left", "right"
-- @return boolean, error_message
function SelectionAccessor.can_move(direction)
  local selection, err = SelectionAccessor.get_bounds()
  if not selection then
    return false, err
  end

  local Context = require('renoise/context')
  local context, err = Context.get_pattern_context()
  if not context then
    return false, err
  end

  local PatternAccessor = require('renoise/pattern_accessor')
  local line_count = PatternAccessor.get_line_count(context)
  local track_count = PatternAccessor.get_track_count(context)

  if direction == Constants.DIRECTION.UP then
    return selection.start_line > 1, "Already at first line"
  elseif direction == Constants.DIRECTION.DOWN then
    return selection.end_line < line_count, "Already at last line"
  elseif direction == Constants.DIRECTION.LEFT then
    return selection.start_column > 1, "Already at leftmost column"
  elseif direction == Constants.DIRECTION.RIGHT then
    -- Need to check against actual column count
    local song = renoise.song()
    local pattern = song.patterns[context.pattern]
    local track = pattern.tracks[context.track]
    local line = track.lines[context.line]
    local col_count = #line.note_columns
    return selection.end_column < col_count, "Already at rightmost column"
  else
    return false, "Invalid direction"
  end
end

-- Move selection in direction
-- @param direction: "up", "down", "left", "right"
-- @return success, error_message
function SelectionAccessor.move(direction)
  local can_move, err = SelectionAccessor.can_move(direction)
  if not can_move then
    ErrorHandler.info(err)
    return false, err
  end

  local selection, err = SelectionAccessor.get_bounds()
  if not selection then
    return false, err
  end

  -- Calculate new selection bounds
  local new_selection = {
    start_line = selection.start_line,
    end_line = selection.end_line,
    start_track = selection.start_track,
    end_track = selection.end_track,
    start_column = selection.start_column,
    end_column = selection.end_column
  }

  if direction == Constants.DIRECTION.UP then
    new_selection.start_line = selection.start_line - 1
    new_selection.end_line = selection.end_line - 1
  elseif direction == Constants.DIRECTION.DOWN then
    new_selection.start_line = selection.start_line + 1
    new_selection.end_line = selection.end_line + 1
  elseif direction == Constants.DIRECTION.LEFT then
    new_selection.start_column = selection.start_column - 1
    new_selection.end_column = selection.end_column - 1
  elseif direction == Constants.DIRECTION.RIGHT then
    new_selection.start_column = selection.start_column + 1
    new_selection.end_column = selection.end_column + 1
  else
    return false, "Invalid direction"
  end

  -- Apply new selection
  local song = renoise.song()
  song.selection_in_pattern = new_selection

  return true, nil
end

-- ============================================================================
-- Selection Iteration
-- ============================================================================

-- Iterate over all note columns in selection
-- @param callback: function(note_column, line_index, track_index, column_index)
-- @return success, error_message
function SelectionAccessor.iterate_note_columns(callback)
  local success, err = Validator.validate_function(callback, "callback")
  if not success then
    return false, err
  end

  local selection, err = SelectionAccessor.get_bounds()
  if not selection then
    return false, err
  end

  local Context = require('renoise/context')
  local context, err = Context.get_pattern_context()
  if not context then
    return false, err
  end

  local song = renoise.song()
  local pattern = song.patterns[context.pattern]

  -- Iterate over selection bounds
  for track_idx = selection.start_track, selection.end_track do
    local track = pattern.tracks[track_idx]

    for line_idx = selection.start_line, selection.end_line do
      local line = track.lines[line_idx]

      -- Determine column range for this track
      local start_col = (track_idx == selection.start_track) and selection.start_column or 1
      local end_col = (track_idx == selection.end_track) and selection.end_column or #line.note_columns

      for col_idx = start_col, math.min(end_col, #line.note_columns) do
        local note_column = line:note_column(col_idx)
        callback(note_column, line_idx, track_idx, col_idx)
      end
    end
  end

  return true, nil
end

-- Count non-blank notes in selection
-- @return note_count
function SelectionAccessor.count_non_blank_notes()
  local count = 0

  SelectionAccessor.iterate_note_columns(function(note_column)
    if note_column.note_value ~= Constants.NOTE.BLANK then
      count = count + 1
    end
  end)

  return count
end

-- ============================================================================
-- Selection Operations with Undo Grouping
-- ============================================================================

-- Execute operation on selection with undo grouping (Renoise 3.5+)
-- @param operation_name: Name for undo history
-- @param operation_fn: Function to execute
-- @return success, error_message
function SelectionAccessor.with_undo_grouping(operation_name, operation_fn)
  local success, err = Validator.validate_function(operation_fn, "operation_fn")
  if not success then
    return false, err
  end

  local song = renoise.song()

  -- Check if undo grouping is available and enabled
  if ConfigManager.use_undo_grouping() and song.describe_batch_undo then
    -- Use Renoise 3.5+ undo grouping
    song:describe_batch_undo(operation_name, function()
      operation_fn()
    end)
  else
    -- Fall back to direct execution (multiple undo steps)
    operation_fn()
  end

  return true, nil
end

return SelectionAccessor
