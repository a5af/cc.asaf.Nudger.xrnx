--[[============================================================================
operations/nudge.lua
============================================================================]]--

--[[

Unified nudge operations for Nudger tool.
Consolidates nudgeUp/nudgeDown into single parameterized implementation.

]]--

local Constants = require('core/constants')
local Validator = require('core/validator')
local ErrorHandler = require('core/error_handler')
local ConfigManager = require('core/config_manager')
local Context = require('renoise/context')
local PatternAccessor = require('renoise/pattern_accessor')
local PhraseAccessor = require('renoise/phrase_accessor')

local Nudge = {}

-- ============================================================================
-- Property Definitions
-- ============================================================================

-- Define nudge behavior for each property type
local PROPERTY_SPECS = {
  [renoise.Song.SUB_COLUMN_NOTE] = {
    name = "note_value",
    field = "note_value",
    min = Constants.NOTE.MIN,
    max = Constants.NOTE.MAX,
    blank = Constants.NOTE.BLANK,
    wrap = true,  -- Can be overridden by config
    default = Constants.NOTE.DEFAULT
  },

  [renoise.Song.SUB_COLUMN_INSTRUMENT] = {
    name = "instrument_value",
    field = "instrument_value",
    min = Constants.INSTRUMENT.MIN,
    max = Constants.INSTRUMENT.MAX,
    blank = Constants.INSTRUMENT.BLANK,
    wrap = true,
    default = 0
  },

  [renoise.Song.SUB_COLUMN_VOLUME] = {
    name = "volume_value",
    field = "volume_value",
    min = Constants.VOLUME.MIN,
    max = Constants.VOLUME.MAX,
    blank = Constants.VOLUME.BLANK,
    wrap = false,
    default = 64,
    is_effect_value = true
  },

  [renoise.Song.SUB_COLUMN_PANNING] = {
    name = "panning_value",
    field = "panning_value",
    min = Constants.PANNING.MIN,
    max = Constants.PANNING.MAX,
    blank = Constants.PANNING.BLANK,
    wrap = false,
    default = 64,
    is_effect_value = true
  },

  [renoise.Song.SUB_COLUMN_DELAY] = {
    name = "delay_value",
    field = "delay_value",
    min = Constants.DELAY.MIN,
    max = Constants.DELAY.MAX,
    blank = nil,  -- No blank value for delay
    wrap = true,
    default = 0
  },

  [renoise.Song.SUB_COLUMN_SAMPLE_EFFECT_NUMBER] = {
    name = "effect_number_value",
    field = "effect_number_value",
    is_effect_command = true
  },

  [renoise.Song.SUB_COLUMN_SAMPLE_EFFECT_AMOUNT] = {
    name = "effect_amount_value",
    field = "effect_amount_value",
    min = Constants.EFFECT.AMOUNT_MIN,
    max = Constants.EFFECT.AMOUNT_MAX,
    blank = nil,
    wrap = true,
    default = 0
  },

  -- Track effect columns
  [renoise.Song.SUB_COLUMN_EFFECT_NUMBER] = {
    name = "number_value",
    field = "number_value",
    min = Constants.EFFECT.NUMBER_MIN,
    max = Constants.EFFECT.NUMBER_MAX,
    blank = nil,
    wrap = true,
    default = 0
  },

  [renoise.Song.SUB_COLUMN_EFFECT_AMOUNT] = {
    name = "amount_value",
    field = "amount_value",
    min = Constants.EFFECT.AMOUNT_MIN,
    max = Constants.EFFECT.AMOUNT_MAX,
    blank = nil,
    wrap = true,
    default = 0
  }
}

-- ============================================================================
-- Nudge Calculation
-- ============================================================================

-- Calculate new value after nudge
-- @param current_value: Current property value
-- @param direction: Constants.DIRECTION.UP or DOWN
-- @param spec: Property specification
-- @return new_value
local function calculate_nudged_value(current_value, direction, spec)
  -- Handle effect commands (special case)
  if spec.is_effect_command then
    if direction == Constants.DIRECTION.UP then
      return Constants.get_next_effect_number(current_value)
    else
      return Constants.get_prev_effect_number(current_value)
    end
  end

  -- Handle volume/panning effect commands
  if spec.is_effect_value and current_value >= Constants.VOLUME.EFFECT_START and current_value < spec.blank then
    -- This is an effect command value, nudge differently
    local effect_char = string.char(current_value)
    -- For now, just cycle through effect commands
    -- TODO: Implement proper effect value nudging
    return current_value
  end

  -- Calculate delta
  local delta = (direction == Constants.DIRECTION.UP) and 1 or -1
  local new_value = current_value + delta

  -- Check for blank value
  if spec.blank then
    -- Handle blank transitions
    if current_value == spec.blank then
      -- Nudging from blank
      if ConfigManager.get("nudge_blank_to_default", true) then
        return spec.default or spec.min
      else
        return spec.blank
      end
    end

    -- Check if we would wrap to blank
    if new_value > spec.max then
      local wrap = ConfigManager.wrap_enabled(spec.name)
      return wrap and spec.min or spec.max
    elseif new_value < spec.min then
      local wrap = ConfigManager.wrap_enabled(spec.name)
      return wrap and spec.max or spec.min
    end
  else
    -- No blank value, just wrap/clamp
    if new_value > spec.max then
      local wrap = ConfigManager.wrap_enabled(spec.name)
      return wrap and spec.min or spec.max
    elseif new_value < spec.min then
      local wrap = ConfigManager.wrap_enabled(spec.name)
      return wrap and spec.max or spec.min
    end
  end

  return new_value
end

-- ============================================================================
-- Nudge Operations
-- ============================================================================

-- Nudge current property in given direction
-- @param direction: Constants.DIRECTION.UP or DOWN
-- @return success, error_message
function Nudge.nudge(direction)
  ErrorHandler.trace_enter("Nudge.nudge", { direction = direction })

  -- Validate direction
  local success, err = Validator.validate_direction(direction)
  if not success then
    ErrorHandler.warn(err)
    return false, err
  end

  -- Get context
  local context, err = Context.get_current()
  if not context then
    ErrorHandler.warn(err)
    return false, err
  end

  -- Get property spec for current sub-column
  local spec = PROPERTY_SPECS[context.sub_column_type]
  if not spec then
    local msg = string.format("No nudge spec for sub-column type: %s", tostring(context.sub_column_type))
    ErrorHandler.warn(msg)
    return false, msg
  end

  -- Get current note or effect column
  local column, err
  if context.has_note_column then
    if context.editor_type == Constants.EDITOR_CONTEXT.PHRASE then
      column, err = PhraseAccessor.get_current_note_column()
    else
      column, err = PatternAccessor.get_current_note_column()
    end
  elseif context.has_effect_column then
    if context.editor_type == Constants.EDITOR_CONTEXT.PHRASE then
      column, err = PhraseAccessor.get_current_effect_column()
    else
      column, err = PatternAccessor.get_current_effect_column()
    end
  else
    return false, "No column selected"
  end

  if not column then
    ErrorHandler.warn(err)
    return false, err
  end

  -- Get current value
  local current_value = column[spec.field]

  -- Calculate new value
  local new_value = calculate_nudged_value(current_value, direction, spec)

  -- Apply new value
  column[spec.field] = new_value

  -- Log change
  ErrorHandler.debug(string.format("Nudged %s from %s to %s", spec.name, current_value, new_value))

  -- Auto-advance if configured
  if ConfigManager.get("auto_advance_after_nudge", false) then
    -- Move to next line
    local song = renoise.song()
    if context.editor_type == Constants.EDITOR_CONTEXT.PHRASE then
      if song.selected_phrase_line < context.phrase.number_of_lines then
        song.selected_phrase_line = song.selected_phrase_line + 1
      end
    else
      local line_count = PatternAccessor.get_line_count(context)
      if song.selected_line_index < line_count then
        song.selected_line_index = song.selected_line_index + 1
      end
    end
  end

  ErrorHandler.trace_exit("Nudge.nudge", true)
  return true, nil
end

-- Convenience functions for up/down
function Nudge.nudge_up()
  return Nudge.nudge(Constants.DIRECTION.UP)
end

function Nudge.nudge_down()
  return Nudge.nudge(Constants.DIRECTION.DOWN)
end

return Nudge
