--[[============================================================================
renoise/pattern_accessor.lua
============================================================================]]--

--[[

Pattern editor accessor for Nudger tool.
Provides validated access to pattern editor elements.

]]--

local Constants = require('core/constants')
local Validator = require('core/validator')
local ErrorHandler = require('core/error_handler')

local PatternAccessor = {}

-- ============================================================================
-- Note Column Access
-- ============================================================================

-- Get note column at specified position
-- @param context: Context table with pattern, track, line, note_col
-- @return note_column or nil, error
function PatternAccessor.get_note_column(context)
  -- Validate indices
  local success, err = Validator.validate_line_exists(
    context.pattern,
    context.track,
    context.line
  )
  if not success then
    return nil, err
  end

  local song = renoise.song()
  local pattern = song.patterns[context.pattern]
  local track = pattern.tracks[context.track]
  local line = track.lines[context.line]

  -- Validate note column index
  if context.note_col < 1 or context.note_col > #line.note_columns then
    return nil, string.format("Note column %d out of range [1, %d]",
      context.note_col, #line.note_columns)
  end

  return line:note_column(context.note_col), nil
end

-- Get current note column
-- @return note_column or nil, error
function PatternAccessor.get_current_note_column()
  local success, err = Validator.validate_note_column_selected()
  if not success then
    return nil, err
  end

  local Context = require('renoise/context')
  local context, err = Context.get_pattern_context()
  if not context then
    return nil, err
  end

  return PatternAccessor.get_note_column(context)
end

-- ============================================================================
-- Effect Column Access
-- ============================================================================

-- Get effect column at specified position
-- @param context: Context table with pattern, track, line, effect_col
-- @return effect_column or nil, error
function PatternAccessor.get_effect_column(context)
  -- Validate indices
  local success, err = Validator.validate_line_exists(
    context.pattern,
    context.track,
    context.line
  )
  if not success then
    return nil, err
  end

  local song = renoise.song()
  local pattern = song.patterns[context.pattern]
  local track = pattern.tracks[context.track]
  local line = track.lines[context.line]

  -- Validate effect column index
  if context.effect_col < 1 or context.effect_col > #line.effect_columns then
    return nil, string.format("Effect column %d out of range [1, %d]",
      context.effect_col, #line.effect_columns)
  end

  return line:effect_column(context.effect_col), nil
end

-- Get current effect column
-- @return effect_column or nil, error
function PatternAccessor.get_current_effect_column()
  local success, err = Validator.validate_effect_column_selected()
  if not success then
    return nil, err
  end

  local Context = require('renoise/context')
  local context, err = Context.get_pattern_context()
  if not context then
    return nil, err
  end

  return PatternAccessor.get_effect_column(context)
end

-- ============================================================================
-- Line Access
-- ============================================================================

-- Get line at specified position
-- @param context: Context table with pattern, track, line
-- @return line or nil, error
function PatternAccessor.get_line(context)
  local success, err = Validator.validate_line_exists(
    context.pattern,
    context.track,
    context.line
  )
  if not success then
    return nil, err
  end

  local song = renoise.song()
  local pattern = song.patterns[context.pattern]
  local track = pattern.tracks[context.track]

  return track.lines[context.line], nil
end

-- Get current line
-- @return line or nil, error
function PatternAccessor.get_current_line()
  local Context = require('renoise/context')
  local context, err = Context.get_pattern_context()
  if not context then
    return nil, err
  end

  return PatternAccessor.get_line(context)
end

-- ============================================================================
-- Navigation Helpers
-- ============================================================================

-- Check if can move up from current line
-- @param context: Context table
-- @return boolean
function PatternAccessor.can_move_up(context)
  return context.line > 1
end

-- Check if can move down from current line
-- @param context: Context table
-- @return boolean
function PatternAccessor.can_move_down(context)
  local success, err = Validator.validate_track_exists(context.pattern, context.track)
  if not success then
    return false
  end

  local song = renoise.song()
  local pattern = song.patterns[context.pattern]
  local track = pattern.tracks[context.track]
  local line_count = #track.lines

  return context.line < line_count
end

-- Check if can move left from current column
-- @param context: Context table
-- @return boolean
function PatternAccessor.can_move_left(context)
  if context.note_col and context.note_col > 1 then
    return true
  end

  -- Can move to previous track if not on first track
  if context.track > 1 then
    return true
  end

  return false
end

-- Check if can move right from current column
-- @param context: Context table
-- @return boolean
function PatternAccessor.can_move_right(context)
  local success, err = Validator.validate_line_exists(
    context.pattern,
    context.track,
    context.line
  )
  if not success then
    return false
  end

  local song = renoise.song()
  local pattern = song.patterns[context.pattern]
  local track = pattern.tracks[context.track]
  local line = track.lines[context.line]
  local col_count = #line.note_columns

  if context.note_col and context.note_col < col_count then
    return true
  end

  -- Can move to next track if not on last track
  if context.track < #pattern.tracks then
    return true
  end

  return false
end

-- ============================================================================
-- Line/Column Retrieval by Direction
-- ============================================================================

-- Get line above current
-- @param context: Context table
-- @return line or nil, error
function PatternAccessor.get_line_above(context)
  if not PatternAccessor.can_move_up(context) then
    return nil, "Already at first line"
  end

  local new_context = {
    pattern = context.pattern,
    track = context.track,
    line = context.line - 1
  }

  return PatternAccessor.get_line(new_context)
end

-- Get line below current
-- @param context: Context table
-- @return line or nil, error
function PatternAccessor.get_line_below(context)
  if not PatternAccessor.can_move_down(context) then
    return nil, "Already at last line"
  end

  local new_context = {
    pattern = context.pattern,
    track = context.track,
    line = context.line + 1
  }

  return PatternAccessor.get_line(new_context)
end

-- Get note column to the left
-- @param context: Context table
-- @return note_column or nil, error
function PatternAccessor.get_note_column_left(context)
  if not context.note_col then
    return nil, "No note column selected"
  end

  local new_context = {
    pattern = context.pattern,
    track = context.track,
    line = context.line,
    note_col = context.note_col
  }

  if context.note_col > 1 then
    -- Move within same track
    new_context.note_col = context.note_col - 1
  elseif context.track > 1 then
    -- Move to previous track, last column
    new_context.track = context.track - 1
    local song = renoise.song()
    local pattern = song.patterns[new_context.pattern]
    local track = pattern.tracks[new_context.track]
    local line = track.lines[new_context.line]
    new_context.note_col = #line.note_columns
  else
    return nil, "Already at leftmost column"
  end

  return PatternAccessor.get_note_column(new_context)
end

-- Get note column to the right
-- @param context: Context table
-- @return note_column or nil, error
function PatternAccessor.get_note_column_right(context)
  if not context.note_col then
    return nil, "No note column selected"
  end

  local song = renoise.song()
  local pattern = song.patterns[context.pattern]
  local track = pattern.tracks[context.track]
  local line = track.lines[context.line]
  local col_count = #line.note_columns

  local new_context = {
    pattern = context.pattern,
    track = context.track,
    line = context.line,
    note_col = context.note_col
  }

  if context.note_col < col_count then
    -- Move within same track
    new_context.note_col = context.note_col + 1
  elseif context.track < #pattern.tracks then
    -- Move to next track, first column
    new_context.track = context.track + 1
    new_context.note_col = 1
  else
    return nil, "Already at rightmost column"
  end

  return PatternAccessor.get_note_column(new_context)
end

-- ============================================================================
-- Pattern/Track Information
-- ============================================================================

-- Get line count in current track
-- @param context: Context table
-- @return line_count or 0
function PatternAccessor.get_line_count(context)
  local success, err = Validator.validate_track_exists(context.pattern, context.track)
  if not success then
    return 0
  end

  local song = renoise.song()
  local pattern = song.patterns[context.pattern]
  local track = pattern.tracks[context.track]

  return #track.lines
end

-- Get track count in current pattern
-- @param context: Context table
-- @return track_count or 0
function PatternAccessor.get_track_count(context)
  local success, err = Validator.validate_pattern_exists(context.pattern)
  if not success then
    return 0
  end

  local song = renoise.song()
  local pattern = song.patterns[context.pattern]

  return #pattern.tracks
end

-- Get note column count in current line
-- @param context: Context table
-- @return column_count or 0
function PatternAccessor.get_note_column_count(context)
  local line, err = PatternAccessor.get_line(context)
  if not line then
    return 0
  end

  return #line.note_columns
end

return PatternAccessor
