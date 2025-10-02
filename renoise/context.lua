--[[============================================================================
renoise/context.lua
============================================================================]]--

--[[

Context detection and retrieval for Nudger tool.
Detects whether pattern or phrase editor is active and provides context info.

]]--

local Constants = require('core/constants')
local Validator = require('core/validator')
local ErrorHandler = require('core/error_handler')

local Context = {}

-- ============================================================================
-- Editor Context Detection
-- ============================================================================

-- Detect which editor is currently active
-- @return editor_type: "pattern", "phrase", or "unknown"
function Context.get_editor_type()
  local success, err = Validator.validate_song_loaded()
  if not success then
    return Constants.EDITOR_CONTEXT.UNKNOWN
  end

  local song = renoise.song()

  -- Check for Renoise 3.5+ phrase editor support
  if song.selected_phrase_line then
    -- Phrase editor API available
    -- Check if phrase is actually selected/active
    if song.selected_phrase then
      return Constants.EDITOR_CONTEXT.PHRASE
    end
  end

  -- Default to pattern editor
  return Constants.EDITOR_CONTEXT.PATTERN
end

-- Check if pattern editor is active
-- @return boolean
function Context.is_pattern_editor()
  return Context.get_editor_type() == Constants.EDITOR_CONTEXT.PATTERN
end

-- Check if phrase editor is active (Renoise 3.5+)
-- @return boolean
function Context.is_phrase_editor()
  return Context.get_editor_type() == Constants.EDITOR_CONTEXT.PHRASE
end

-- ============================================================================
-- Context Information Retrieval
-- ============================================================================

-- Get current context information for pattern editor
-- @return context table or nil, error
function Context.get_pattern_context()
  local success, err = Validator.validate_song_loaded()
  if not success then
    return nil, err
  end

  local song = renoise.song()

  return {
    editor_type = Constants.EDITOR_CONTEXT.PATTERN,
    line = song.selected_line_index,
    track = song.selected_track_index,
    note_col = song.selected_note_column_index,
    effect_col = song.selected_effect_column_index,
    pattern = song.selected_pattern_index,
    instrument = song.selected_instrument_index,
    sub_column_type = song.selected_sub_column_type,
    has_note_column = song.selected_note_column ~= nil,
    has_effect_column = song.selected_effect_column ~= nil
  }, nil
end

-- Get current context information for phrase editor (Renoise 3.5+)
-- @return context table or nil, error
function Context.get_phrase_context()
  local success, err = Validator.validate_phrase_selected()
  if not success then
    return nil, err
  end

  local song = renoise.song()

  return {
    editor_type = Constants.EDITOR_CONTEXT.PHRASE,
    line = song.selected_phrase_line,
    phrase = song.selected_phrase,
    note_col = song.selected_phrase_note_column,
    effect_col = song.selected_phrase_effect_column,
    instrument = song.selected_instrument_index,
    sub_column_type = song.selected_sub_column_type,
    has_note_column = song.selected_phrase_note_column ~= nil,
    has_effect_column = song.selected_phrase_effect_column ~= nil
  }, nil
end

-- Get current context (automatically detects editor type)
-- @return context table or nil, error
function Context.get_current()
  local editor_type = Context.get_editor_type()

  if editor_type == Constants.EDITOR_CONTEXT.PHRASE then
    return Context.get_phrase_context()
  elseif editor_type == Constants.EDITOR_CONTEXT.PATTERN then
    return Context.get_pattern_context()
  else
    return nil, "Could not determine editor context"
  end
end

-- ============================================================================
-- Column Type Detection
-- ============================================================================

-- Get current column type (note or effect)
-- @return column_type: "note_column" or "effect_column" or nil
function Context.get_column_type()
  local success, err = Validator.validate_song_loaded()
  if not success then
    return nil
  end

  local song = renoise.song()

  if song.selected_note_column or song.selected_phrase_note_column then
    return Constants.COLUMN_TYPE.NOTE
  elseif song.selected_effect_column or song.selected_phrase_effect_column then
    return Constants.COLUMN_TYPE.EFFECT
  end

  return nil
end

-- Check if note column is selected (pattern or phrase)
-- @return boolean
function Context.is_note_column_selected()
  return Context.get_column_type() == Constants.COLUMN_TYPE.NOTE
end

-- Check if effect column is selected (pattern or phrase)
-- @return boolean
function Context.is_effect_column_selected()
  return Context.get_column_type() == Constants.COLUMN_TYPE.EFFECT
end

-- ============================================================================
-- Selection Information
-- ============================================================================

-- Get selection bounds if selection exists
-- @return selection table or nil
function Context.get_selection()
  local success, err = Validator.validate_song_loaded()
  if not success then
    return nil
  end

  local song = renoise.song()
  local selection = song.selection_in_pattern

  if not selection then
    return nil
  end

  return {
    start_line = selection.start_line,
    end_line = selection.end_line,
    start_track = selection.start_track,
    end_track = selection.end_track,
    start_column = selection.start_column,
    end_column = selection.end_column
  }
end

-- Check if a selection exists in pattern
-- @return boolean
function Context.has_selection()
  return Context.get_selection() ~= nil
end

-- Get selection size (number of lines)
-- @return line_count or 0
function Context.get_selection_size()
  local selection = Context.get_selection()
  if not selection then
    return 0
  end

  return (selection.end_line - selection.start_line + 1)
end

return Context
