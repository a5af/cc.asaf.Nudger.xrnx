--[[============================================================================
operations/clone.lua
============================================================================]]--

--[[

Clone operations for Nudger tool.
Duplicates notes to adjacent positions.
COMPLETED: clone_left and clone_right (were stubs)

]]--

local Constants = require('core/constants')
local Validator = require('core/validator')
local ErrorHandler = require('core/error_handler')
local ConfigManager = require('core/config_manager')
local Context = require('renoise/context')
local PatternAccessor = require('renoise/pattern_accessor')
local PhraseAccessor = require('renoise/phrase_accessor')

local Clone = {}

-- ============================================================================
-- Helper Functions
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

-- ============================================================================
-- Clone Operations
-- ============================================================================

-- Clone note up
function Clone.clone_up()
  ErrorHandler.trace_enter("Clone.clone_up")

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

  -- Get current note and destination line
  local current_note, dest_line
  local song = renoise.song()

  if context.editor_type == Constants.EDITOR_CONTEXT.PHRASE then
    current_note = PhraseAccessor.get_current_note_column()
    dest_line = PhraseAccessor.get_line_above(context)

    -- Clone note
    local dest_note = dest_line:note_column(context.note_col)
    copy_note_values(current_note, dest_note)

    -- Move cursor if configured
    if ConfigManager.get("auto_select_cloned_note", true) then
      song.selected_phrase_line = song.selected_phrase_line - 1
    end
  else
    current_note = PatternAccessor.get_current_note_column()
    dest_line = PatternAccessor.get_line_above(context)

    -- Clone note
    local dest_note = dest_line:note_column(context.note_col)
    copy_note_values(current_note, dest_note)

    -- Move cursor if configured
    if ConfigManager.get("auto_select_cloned_note", true) then
      song.selected_line_index = song.selected_line_index - 1
    end
  end

  ErrorHandler.trace_exit("Clone.clone_up", true)
  return true, nil
end

-- Clone note down
function Clone.clone_down()
  ErrorHandler.trace_enter("Clone.clone_down")

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

  -- Get current note and destination line
  local current_note, dest_line
  local song = renoise.song()

  if context.editor_type == Constants.EDITOR_CONTEXT.PHRASE then
    current_note = PhraseAccessor.get_current_note_column()
    dest_line = PhraseAccessor.get_line_below(context)

    -- Clone note
    local dest_note = dest_line:note_column(context.note_col)
    copy_note_values(current_note, dest_note)

    -- Move cursor if configured
    if ConfigManager.get("auto_select_cloned_note", true) then
      song.selected_phrase_line = song.selected_phrase_line + 1
    end
  else
    current_note = PatternAccessor.get_current_note_column()
    dest_line = PatternAccessor.get_line_below(context)

    -- Clone note
    local dest_note = dest_line:note_column(context.note_col)
    copy_note_values(current_note, dest_note)

    -- Move cursor if configured
    if ConfigManager.get("auto_select_cloned_note", true) then
      song.selected_line_index = song.selected_line_index + 1
    end
  end

  ErrorHandler.trace_exit("Clone.clone_down", true)
  return true, nil
end

-- Clone note left (COMPLETED: was stub)
function Clone.clone_left()
  ErrorHandler.trace_enter("Clone.clone_left")

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
    ErrorHandler.info(err or "Cannot clone left")
    return false, err or "Cannot clone left"
  end

  -- Clone note
  copy_note_values(current_note, left_note)

  -- Move cursor if configured
  if ConfigManager.get("auto_select_cloned_note", true) then
    local song = renoise.song()
    if context.editor_type == Constants.EDITOR_CONTEXT.PHRASE then
      if context.note_col > 1 then
        song.selected_phrase_note_column = context.note_col - 1
      else
        -- Moving to previous track (phrase editor doesn't support cross-track)
        song.selected_phrase_note_column = context.note_col
      end
    else
      if context.note_col > 1 then
        -- Moving within same track
        song.selected_note_column_index = context.note_col - 1
      elseif context.track > 1 then
        -- Moving to previous track, last column
        song.selected_track_index = context.track - 1
        local pattern = song.patterns[context.pattern]
        local track = pattern.tracks[context.track - 1]
        local line = track.lines[context.line]
        song.selected_note_column_index = #line.note_columns
      end
    end
  end

  ErrorHandler.trace_exit("Clone.clone_left", true)
  return true, nil
end

-- Clone note right (COMPLETED: was stub)
function Clone.clone_right()
  ErrorHandler.trace_enter("Clone.clone_right")

  -- Get context
  local context, err = Context.get_current()
  if not context then
    ErrorHandler.warn(err)
    return false, err
  end

  if not context.has_note_column then
    return false, "No note column selected"
  end

  -- Get current note and right note
  local current_note, right_note, err

  if context.editor_type == Constants.EDITOR_CONTEXT.PHRASE then
    current_note = PhraseAccessor.get_current_note_column()
    right_note, err = PhraseAccessor.get_note_column_right(context)
  else
    current_note = PatternAccessor.get_current_note_column()
    right_note, err = PatternAccessor.get_note_column_right(context)
  end

  if not right_note then
    ErrorHandler.info(err or "Cannot clone right")
    return false, err or "Cannot clone right"
  end

  -- Clone note
  copy_note_values(current_note, right_note)

  -- Move cursor if configured
  if ConfigManager.get("auto_select_cloned_note", true) then
    local song = renoise.song()
    if context.editor_type == Constants.EDITOR_CONTEXT.PHRASE then
      local col_count = PhraseAccessor.get_note_column_count(context)
      if context.note_col < col_count then
        song.selected_phrase_note_column = context.note_col + 1
      else
        -- At last column (phrase editor doesn't support cross-track)
        song.selected_phrase_note_column = context.note_col
      end
    else
      local col_count = PatternAccessor.get_note_column_count(context)
      if context.note_col < col_count then
        -- Moving within same track
        song.selected_note_column_index = context.note_col + 1
      else
        -- Moving to next track, first column
        local pattern = song.patterns[context.pattern]
        if context.track < #pattern.tracks then
          song.selected_track_index = context.track + 1
          song.selected_note_column_index = 1
        end
      end
    end
  end

  ErrorHandler.trace_exit("Clone.clone_right", true)
  return true, nil
end

return Clone
