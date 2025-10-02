--[[============================================================================
operations/clear.lua
============================================================================]]--

--[[

Clear operations for Nudger tool.
Resets note properties to blank state.

]]--

local Constants = require('core/constants')
local Validator = require('core/validator')
local ErrorHandler = require('core/error_handler')
local ConfigManager = require('core/config_manager')
local Context = require('renoise/context')
local PatternAccessor = require('renoise/pattern_accessor')
local PhraseAccessor = require('renoise/phrase_accessor')
local SelectionAccessor = require('renoise/selection_accessor')

local Clear = {}

-- ============================================================================
-- Helper Functions
-- ============================================================================

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

-- Clear effect column values
local function clear_effect_values(effect)
  effect.number_value = 0
  effect.amount_value = 0
end

-- ============================================================================
-- Clear Operations
-- ============================================================================

-- Clear current note or effect column
function Clear.clear()
  ErrorHandler.trace_enter("Clear.clear")

  -- Get context
  local context, err = Context.get_current()
  if not context then
    ErrorHandler.warn(err)
    return false, err
  end

  -- Clear based on column type
  if context.has_note_column then
    return Clear.clear_note()
  elseif context.has_effect_column then
    return Clear.clear_effect()
  else
    return false, "No column selected"
  end
end

-- Clear current note column
function Clear.clear_note()
  ErrorHandler.trace_enter("Clear.clear_note")

  -- Get context
  local context, err = Context.get_current()
  if not context then
    ErrorHandler.warn(err)
    return false, err
  end

  if not context.has_note_column then
    return false, "No note column selected"
  end

  -- Get current note
  local note, err
  if context.editor_type == Constants.EDITOR_CONTEXT.PHRASE then
    note, err = PhraseAccessor.get_current_note_column()
  else
    note, err = PatternAccessor.get_current_note_column()
  end

  if not note then
    ErrorHandler.warn(err)
    return false, err
  end

  -- Clear note
  clear_note_values(note)

  ErrorHandler.debug("Cleared note column")
  ErrorHandler.trace_exit("Clear.clear_note", true)
  return true, nil
end

-- Clear current effect column
function Clear.clear_effect()
  ErrorHandler.trace_enter("Clear.clear_effect")

  -- Get context
  local context, err = Context.get_current()
  if not context then
    ErrorHandler.warn(err)
    return false, err
  end

  if not context.has_effect_column then
    return false, "No effect column selected"
  end

  -- Get current effect column
  local effect, err
  if context.editor_type == Constants.EDITOR_CONTEXT.PHRASE then
    effect, err = PhraseAccessor.get_current_effect_column()
  else
    effect, err = PatternAccessor.get_current_effect_column()
  end

  if not effect then
    ErrorHandler.warn(err)
    return false, err
  end

  -- Clear effect
  clear_effect_values(effect)

  ErrorHandler.debug("Cleared effect column")
  ErrorHandler.trace_exit("Clear.clear_effect", true)
  return true, nil
end

-- ============================================================================
-- Selection Clear
-- ============================================================================

-- Clear all notes in selection
function Clear.clear_selection()
  ErrorHandler.trace_enter("Clear.clear_selection")

  -- Check if selection exists
  local success, err = Validator.validate_selection_in_pattern()
  if not success then
    ErrorHandler.warn(err)
    return false, err
  end

  local count = 0

  -- Use undo grouping for single undo action
  SelectionAccessor.with_undo_grouping("Clear Selection", function()
    -- Iterate and clear all note columns in selection
    SelectionAccessor.iterate_note_columns(function(note_column)
      clear_note_values(note_column)
      count = count + 1
    end)
  end)

  ErrorHandler.debug(string.format("Cleared %d notes in selection", count))
  ErrorHandler.trace_exit("Clear.clear_selection", true)
  return true, nil
end

return Clear
