--[[============================================================================
operations/move.lua
============================================================================]]--

--[[

Move operations for Nudger tool.
Moves notes/selections between lines and columns.
FIXED: get_right_note bug (was decrementing instead of incrementing)

]]--

local Constants = require('core/constants')
local Validator = require('core/validator')
local ErrorHandler = require('core/error_handler')
local ConfigManager = require('core/config_manager')
local Context = require('renoise/context')
local InputTracker = require('renoise/input_tracker')
local PatternAccessor = require('renoise/pattern_accessor')
local PhraseAccessor = require('renoise/phrase_accessor')
local SelectionAccessor = require('renoise/selection_accessor')

local Move = {}

-- ============================================================================
-- Note Helper Functions
-- ============================================================================

-- Copy all note values from source to destination
local function copy_note_values(src, dest)
  dest.note_value = src.note_value
  dest.instrument_value = src.instrument_value
  dest.volume_value = src.volume_value
  dest.panning_value = src.panning_value
  dest.delay_value = src.delay_value
  dest.effect_number_value = src.effect_number_value
  dest.effect_amount_value = src.effect_amount_value
end

-- Clear note values to blank
local function clear_note_values(note)
  note.note_value = Constants.NOTE.BLANK
  note.instrument_value = Constants.INSTRUMENT.BLANK
  note.volume_value = Constants.VOLUME.BLANK
  note.panning_value = Constants.PANNING.BLANK
  note.delay_value = 0
  note.effect_number_value = 0
  note.effect_amount_value = 0
end

-- Check if note is blank
local function is_note_blank(note)
  return note.note_value == Constants.NOTE.BLANK and
         note.instrument_value == Constants.INSTRUMENT.BLANK and
         note.volume_value == Constants.VOLUME.BLANK and
         note.panning_value == Constants.PANNING.BLANK and
         note.delay_value == 0 and
         note.effect_number_value == 0 and
         note.effect_amount_value == 0
end

-- Find first blank column in line
local function find_blank_column(line)
  for i, note_col in ipairs(line.note_columns) do
    if is_note_blank(note_col) then
      return i
    end
  end
  return nil
end

-- ============================================================================
-- Single Note Move
-- ============================================================================

-- Move note up
function Move.move_up()
  ErrorHandler.trace_enter("Move.move_up")

  -- Check input context for selection intent
  if InputTracker.should_use_selection() then
    return Move.move_selection_up()
  end

  -- Get context
  local context, err = Context.get_current()
  if not context then
    ErrorHandler.warn(err)
    return false, err
  end

  if not context.has_note_column then
    return false, "No note column selected"
  end

  -- Check if can move up
  local can_move = (context.editor_type == Constants.EDITOR_CONTEXT.PHRASE)
    and PhraseAccessor.can_move_up(context)
    or PatternAccessor.can_move_up(context)

  if not can_move then
    ErrorHandler.info("Already at first line")
    return false, "Already at first line"
  end

  -- Get current and destination lines
  local current_note, dest_line, dest_col_idx
  local song = renoise.song()

  if context.editor_type == Constants.EDITOR_CONTEXT.PHRASE then
    current_note = PhraseAccessor.get_current_note_column()
    dest_line = PhraseAccessor.get_line_above(context)
    dest_col_idx = find_blank_column(dest_line) or 1

    -- Move note
    local dest_note = dest_line:note_column(dest_col_idx)
    copy_note_values(current_note, dest_note)
    clear_note_values(current_note)

    -- Update selection
    song.selected_phrase_line = song.selected_phrase_line - 1
    song.selected_phrase_note_column = dest_col_idx
  else
    current_note = PatternAccessor.get_current_note_column()
    dest_line = PatternAccessor.get_line_above(context)
    dest_col_idx = find_blank_column(dest_line) or 1

    -- Move note
    local dest_note = dest_line:note_column(dest_col_idx)
    copy_note_values(current_note, dest_note)
    clear_note_values(current_note)

    -- Update selection
    song.selected_line_index = song.selected_line_index - 1
    song.selected_note_column_index = dest_col_idx
  end

  ErrorHandler.trace_exit("Move.move_up", true)
  return true, nil
end

-- Move note down
function Move.move_down()
  ErrorHandler.trace_enter("Move.move_down")

  -- Check input context for selection intent
  if InputTracker.should_use_selection() then
    return Move.move_selection_down()
  end

  -- Get context
  local context, err = Context.get_current()
  if not context then
    ErrorHandler.warn(err)
    return false, err
  end

  if not context.has_note_column then
    return false, "No note column selected"
  end

  -- Check if can move down
  local can_move = (context.editor_type == Constants.EDITOR_CONTEXT.PHRASE)
    and PhraseAccessor.can_move_down(context)
    or PatternAccessor.can_move_down(context)

  if not can_move then
    ErrorHandler.info("Already at last line")
    return false, "Already at last line"
  end

  -- Get current and destination lines
  local current_note, dest_line, dest_col_idx
  local song = renoise.song()

  if context.editor_type == Constants.EDITOR_CONTEXT.PHRASE then
    current_note = PhraseAccessor.get_current_note_column()
    dest_line = PhraseAccessor.get_line_below(context)
    dest_col_idx = find_blank_column(dest_line) or 1

    -- Move note
    local dest_note = dest_line:note_column(dest_col_idx)
    copy_note_values(current_note, dest_note)
    clear_note_values(current_note)

    -- Update selection
    song.selected_phrase_line = song.selected_phrase_line + 1
    song.selected_phrase_note_column = dest_col_idx
  else
    current_note = PatternAccessor.get_current_note_column()
    dest_line = PatternAccessor.get_line_below(context)
    dest_col_idx = find_blank_column(dest_line) or 1

    -- Move note
    local dest_note = dest_line:note_column(dest_col_idx)
    copy_note_values(current_note, dest_note)
    clear_note_values(current_note)

    -- Update selection
    song.selected_line_index = song.selected_line_index + 1
    song.selected_note_column_index = dest_col_idx
  end

  ErrorHandler.trace_exit("Move.move_down", true)
  return true, nil
end

-- Move note left (FIXED: previously had wrong logic)
function Move.move_left()
  ErrorHandler.trace_enter("Move.move_left")

  -- Check input context for selection intent
  if InputTracker.should_use_selection() then
    return Move.move_selection_left()
  end

  -- Get context
  local context, err = Context.get_current()
  if not context then
    ErrorHandler.warn(err)
    return false, err
  end

  if not context.has_note_column then
    return false, "No note column selected"
  end

  -- Get current note and left note
  local current_note, left_note, err

  if context.editor_type == Constants.EDITOR_CONTEXT.PHRASE then
    current_note = PhraseAccessor.get_current_note_column()
    left_note, err = PhraseAccessor.get_note_column_left(context)
  else
    current_note = PatternAccessor.get_current_note_column()
    left_note, err = PatternAccessor.get_note_column_left(context)
  end

  if not left_note then
    ErrorHandler.info(err or "Cannot move left")
    return false, err or "Cannot move left"
  end

  -- Move note
  copy_note_values(current_note, left_note)
  clear_note_values(current_note)

  -- Update cursor to follow moved note
  local song = renoise.song()
  if context.note_col > 1 then
    -- Moving within same track
    song.selected_note_column_index = context.note_col - 1
  elseif context.track > 1 then
    -- Moving to previous track, last visible column
    song.selected_track_index = context.track - 1
    song.selected_note_column_index = song.tracks[context.track - 1].visible_note_columns
  end

  ErrorHandler.trace_exit("Move.move_left", true)
  return true, nil
end

-- Move note right (FIXED BUG: was decrementing instead of incrementing)
function Move.move_right()
  ErrorHandler.trace_enter("Move.move_right")

  -- Check input context for selection intent
  if InputTracker.should_use_selection() then
    return Move.move_selection_right()
  end

  -- Get context
  local context, err = Context.get_current()
  if not context then
    ErrorHandler.warn(err)
    return false, err
  end

  if not context.has_note_column then
    return false, "No note column selected"
  end

  -- Get current note and right note (FIXED: using correct accessor method)
  local current_note, right_note, err

  if context.editor_type == Constants.EDITOR_CONTEXT.PHRASE then
    current_note = PhraseAccessor.get_current_note_column()
    right_note, err = PhraseAccessor.get_note_column_right(context)
  else
    current_note = PatternAccessor.get_current_note_column()
    right_note, err = PatternAccessor.get_note_column_right(context)
  end

  if not right_note then
    ErrorHandler.info(err or "Cannot move right")
    return false, err or "Cannot move right"
  end

  -- Move note
  copy_note_values(current_note, right_note)
  clear_note_values(current_note)

  -- Update cursor to follow moved note
  local song = renoise.song()
  local pattern = song.patterns[context.pattern]
  local visible_cols = song.tracks[context.track].visible_note_columns

  if context.note_col < visible_cols then
    -- Moving within same track
    song.selected_note_column_index = context.note_col + 1
  elseif context.track < #pattern.tracks then
    -- Moving to next track, first column
    song.selected_track_index = context.track + 1
    song.selected_note_column_index = 1
  end

  ErrorHandler.trace_exit("Move.move_right", true)
  return true, nil
end

-- ============================================================================
-- Selection Move
-- ============================================================================

-- Move selection up
function Move.move_selection_up()
  return SelectionAccessor.move(Constants.DIRECTION.UP)
end

-- Move selection down
function Move.move_selection_down()
  return SelectionAccessor.move(Constants.DIRECTION.DOWN)
end

-- Move selection left
function Move.move_selection_left()
  return SelectionAccessor.move(Constants.DIRECTION.LEFT)
end

-- Move selection right
function Move.move_selection_right()
  return SelectionAccessor.move(Constants.DIRECTION.RIGHT)
end

return Move
