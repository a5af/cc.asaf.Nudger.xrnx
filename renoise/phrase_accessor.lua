--[[============================================================================
renoise/phrase_accessor.lua
============================================================================]]--

--[[

Phrase editor accessor for Nudger tool (Renoise 3.5+).
Provides validated access to phrase editor elements.

]]--

local Constants = require('core/constants')
local Validator = require('core/validator')
local ErrorHandler = require('core/error_handler')

local PhraseAccessor = {}

-- ============================================================================
-- Note Column Access
-- ============================================================================

-- Get note column at specified position in phrase
-- @param context: Context table with phrase, line, note_col
-- @return note_column or nil, error
function PhraseAccessor.get_note_column(context)
  local success, err = Validator.validate_phrase_selected()
  if not success then
    return nil, err
  end

  local phrase = context.phrase

  -- Validate line index
  if context.line < 1 or context.line > phrase.number_of_lines then
    return nil, string.format("Phrase line %d out of range [1, %d]",
      context.line, phrase.number_of_lines)
  end

  local line = phrase.lines[context.line]

  -- Validate note column index
  if context.note_col < 1 or context.note_col > #line.note_columns then
    return nil, string.format("Note column %d out of range [1, %d]",
      context.note_col, #line.note_columns)
  end

  return line:note_column(context.note_col), nil
end

-- Get current note column in phrase
-- @return note_column or nil, error
function PhraseAccessor.get_current_note_column()
  local Context = require('renoise/context')
  local context, err = Context.get_phrase_context()
  if not context then
    return nil, err
  end

  if not context.note_col then
    return nil, "No note column selected in phrase"
  end

  return PhraseAccessor.get_note_column(context)
end

-- ============================================================================
-- Effect Column Access
-- ============================================================================

-- Get effect column at specified position in phrase
-- @param context: Context table with phrase, line, effect_col
-- @return effect_column or nil, error
function PhraseAccessor.get_effect_column(context)
  local success, err = Validator.validate_phrase_selected()
  if not success then
    return nil, err
  end

  local phrase = context.phrase

  -- Validate line index
  if context.line < 1 or context.line > phrase.number_of_lines then
    return nil, string.format("Phrase line %d out of range [1, %d]",
      context.line, phrase.number_of_lines)
  end

  local line = phrase.lines[context.line]

  -- Validate effect column index
  if context.effect_col < 1 or context.effect_col > #line.effect_columns then
    return nil, string.format("Effect column %d out of range [1, %d]",
      context.effect_col, #line.effect_columns)
  end

  return line:effect_column(context.effect_col), nil
end

-- Get current effect column in phrase
-- @return effect_column or nil, error
function PhraseAccessor.get_current_effect_column()
  local Context = require('renoise/context')
  local context, err = Context.get_phrase_context()
  if not context then
    return nil, err
  end

  if not context.effect_col then
    return nil, "No effect column selected in phrase"
  end

  return PhraseAccessor.get_effect_column(context)
end

-- ============================================================================
-- Line Access
-- ============================================================================

-- Get line at specified position in phrase
-- @param context: Context table with phrase, line
-- @return line or nil, error
function PhraseAccessor.get_line(context)
  local success, err = Validator.validate_phrase_selected()
  if not success then
    return nil, err
  end

  local phrase = context.phrase

  -- Validate line index
  if context.line < 1 or context.line > phrase.number_of_lines then
    return nil, string.format("Phrase line %d out of range [1, %d]",
      context.line, phrase.number_of_lines)
  end

  return phrase.lines[context.line], nil
end

-- Get current line in phrase
-- @return line or nil, error
function PhraseAccessor.get_current_line()
  local Context = require('renoise/context')
  local context, err = Context.get_phrase_context()
  if not context then
    return nil, err
  end

  return PhraseAccessor.get_line(context)
end

-- ============================================================================
-- Navigation Helpers
-- ============================================================================

-- Check if can move up from current line in phrase
-- @param context: Context table
-- @return boolean
function PhraseAccessor.can_move_up(context)
  return context.line > 1
end

-- Check if can move down from current line in phrase
-- @param context: Context table
-- @return boolean
function PhraseAccessor.can_move_down(context)
  local success, err = Validator.validate_phrase_selected()
  if not success then
    return false
  end

  local phrase = context.phrase
  return context.line < phrase.number_of_lines
end

-- Check if can move left from current column in phrase
-- @param context: Context table
-- @return boolean
function PhraseAccessor.can_move_left(context)
  if context.note_col and context.note_col > 1 then
    return true
  end

  return false
end

-- Check if can move right from current column in phrase
-- @param context: Context table
-- @return boolean
function PhraseAccessor.can_move_right(context)
  local success, err = Validator.validate_phrase_selected()
  if not success then
    return false
  end

  local phrase = context.phrase
  local visible_cols = phrase.visible_note_columns

  if context.note_col and context.note_col < visible_cols then
    return true
  end

  return false
end

-- ============================================================================
-- Line/Column Retrieval by Direction
-- ============================================================================

-- Get line above current in phrase
-- @param context: Context table
-- @return line or nil, error
function PhraseAccessor.get_line_above(context)
  if not PhraseAccessor.can_move_up(context) then
    return nil, "Already at first line"
  end

  local new_context = {
    phrase = context.phrase,
    line = context.line - 1
  }

  return PhraseAccessor.get_line(new_context)
end

-- Get line below current in phrase
-- @param context: Context table
-- @return line or nil, error
function PhraseAccessor.get_line_below(context)
  if not PhraseAccessor.can_move_down(context) then
    return nil, "Already at last line"
  end

  local new_context = {
    phrase = context.phrase,
    line = context.line + 1
  }

  return PhraseAccessor.get_line(new_context)
end

-- Get note column to the left in phrase
-- @param context: Context table
-- @return note_column or nil, error
function PhraseAccessor.get_note_column_left(context)
  if not context.note_col then
    return nil, "No note column selected"
  end

  if context.note_col <= 1 then
    return nil, "Already at leftmost column"
  end

  local new_context = {
    phrase = context.phrase,
    line = context.line,
    note_col = context.note_col - 1
  }

  return PhraseAccessor.get_note_column(new_context)
end

-- Get note column to the right in phrase
-- @param context: Context table
-- @return note_column or nil, error
function PhraseAccessor.get_note_column_right(context)
  if not context.note_col then
    return nil, "No note column selected"
  end

  local phrase = context.phrase
  local visible_cols = phrase.visible_note_columns

  if context.note_col >= visible_cols then
    return nil, "Already at rightmost column"
  end

  local new_context = {
    phrase = context.phrase,
    line = context.line,
    note_col = context.note_col + 1
  }

  return PhraseAccessor.get_note_column(new_context)
end

-- ============================================================================
-- Phrase Information
-- ============================================================================

-- Get line count in phrase
-- @param context: Context table
-- @return line_count or 0
function PhraseAccessor.get_line_count(context)
  local success, err = Validator.validate_phrase_selected()
  if not success then
    return 0
  end

  return context.phrase.number_of_lines
end

-- Get note column count (visible) in current phrase
-- @param context: Context table
-- @return column_count or 0
function PhraseAccessor.get_note_column_count(context)
  local success, err = Validator.validate_phrase_selected()
  if not success then
    return 0
  end

  return context.phrase.visible_note_columns
end

return PhraseAccessor
