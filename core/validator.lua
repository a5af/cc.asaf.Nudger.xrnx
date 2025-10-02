--[[============================================================================
core/validator.lua
============================================================================]]--

--[[

Validation functions for Nudger tool.
Validates all inputs, state, and preconditions before operations.

All validation functions return (success, error_message):
- success: true if valid, false if invalid
- error_message: nil if valid, string describing error if invalid

]]--

local Constants = require('core/constants')

local Validator = {}

-- ============================================================================
-- Song State Validation
-- ============================================================================

-- Validate that a song is loaded
-- @return success, error_message
function Validator.validate_song_loaded()
  if not renoise or not renoise.song then
    return false, "Renoise API not available"
  end

  local song = renoise.song()
  if not song then
    return false, "No song loaded"
  end

  return true, nil
end

-- Validate that a pattern exists
-- @param pattern_index: Index of pattern to check
-- @return success, error_message
function Validator.validate_pattern_exists(pattern_index)
  local success, err = Validator.validate_song_loaded()
  if not success then return false, err end

  if type(pattern_index) ~= "number" then
    return false, string.format("Invalid pattern index type: %s", type(pattern_index))
  end

  local song = renoise.song()
  if not song.patterns[pattern_index] then
    return false, string.format("Pattern %d does not exist", pattern_index)
  end

  return true, nil
end

-- Validate that a track exists in a pattern
-- @param pattern_index: Index of pattern
-- @param track_index: Index of track to check
-- @return success, error_message
function Validator.validate_track_exists(pattern_index, track_index)
  local success, err = Validator.validate_pattern_exists(pattern_index)
  if not success then return false, err end

  if type(track_index) ~= "number" then
    return false, string.format("Invalid track index type: %s", type(track_index))
  end

  local song = renoise.song()
  local pattern = song.patterns[pattern_index]

  if not pattern.tracks[track_index] then
    return false, string.format("Track %d does not exist in pattern %d", track_index, pattern_index)
  end

  return true, nil
end

-- Validate that a line exists in a track
-- @param pattern_index: Index of pattern
-- @param track_index: Index of track
-- @param line_index: Index of line to check
-- @return success, error_message
function Validator.validate_line_exists(pattern_index, track_index, line_index)
  local success, err = Validator.validate_track_exists(pattern_index, track_index)
  if not success then return false, err end

  if type(line_index) ~= "number" then
    return false, string.format("Invalid line index type: %s", type(line_index))
  end

  local song = renoise.song()
  local pattern = song.patterns[pattern_index]
  local track = pattern.tracks[track_index]
  local line_count = #track.lines

  if line_index < 1 or line_index > line_count then
    return false, string.format("Line index %d out of range [1, %d]", line_index, line_count)
  end

  return true, nil
end

-- ============================================================================
-- Selection Validation
-- ============================================================================

-- Validate that a note column is selected
-- @return success, error_message
function Validator.validate_note_column_selected()
  local success, err = Validator.validate_song_loaded()
  if not success then return false, err end

  local song = renoise.song()
  if not song.selected_note_column then
    return false, "No note column selected"
  end

  return true, nil
end

-- Validate that an effect column is selected
-- @return success, error_message
function Validator.validate_effect_column_selected()
  local success, err = Validator.validate_song_loaded()
  if not success then return false, err end

  local song = renoise.song()
  if not song.selected_effect_column then
    return false, "No effect column selected"
  end

  return true, nil
end

-- Validate that either note or effect column is selected
-- @return success, error_message
function Validator.validate_column_selected()
  local success, err = Validator.validate_song_loaded()
  if not success then return false, err end

  local song = renoise.song()
  if not song.selected_note_column and not song.selected_effect_column then
    return false, "No note or effect column selected"
  end

  return true, nil
end

-- Validate that a selection exists in pattern
-- @return success, error_message
function Validator.validate_selection_in_pattern()
  local success, err = Validator.validate_song_loaded()
  if not success then return false, err end

  local song = renoise.song()
  if not song.selection_in_pattern then
    return false, "No selection in pattern"
  end

  return true, nil
end

-- Validate that a phrase is selected (Renoise 3.5+)
-- @return success, error_message
function Validator.validate_phrase_selected()
  local success, err = Validator.validate_song_loaded()
  if not success then return false, err end

  local song = renoise.song()

  -- Check if phrase editor API is available (Renoise 3.5+)
  if not song.selected_phrase_line then
    return false, "Phrase editor not supported (Renoise 3.5+ required)"
  end

  if not song.selected_phrase then
    return false, "No phrase selected"
  end

  return true, nil
end

-- ============================================================================
-- Value Validation
-- ============================================================================

-- Validate note value
-- @param value: Note value to check
-- @return success, error_message
function Validator.validate_note_value(value)
  if type(value) ~= "number" then
    return false, string.format("Note value must be a number, got %s", type(value))
  end

  if value < Constants.NOTE.MIN or value > Constants.NOTE.BLANK then
    return false, string.format("Note value %d out of range [%d, %d]",
      value, Constants.NOTE.MIN, Constants.NOTE.BLANK)
  end

  return true, nil
end

-- Validate instrument value
-- @param value: Instrument value to check
-- @return success, error_message
function Validator.validate_instrument_value(value)
  if type(value) ~= "number" then
    return false, string.format("Instrument value must be a number, got %s", type(value))
  end

  if value < Constants.INSTRUMENT.MIN or value > Constants.INSTRUMENT.BLANK then
    return false, string.format("Instrument value %d out of range [%d, %d]",
      value, Constants.INSTRUMENT.MIN, Constants.INSTRUMENT.BLANK)
  end

  return true, nil
end

-- Validate volume value
-- @param value: Volume value to check
-- @return success, error_message
function Validator.validate_volume_value(value)
  if type(value) ~= "number" then
    return false, string.format("Volume value must be a number, got %s", type(value))
  end

  if value < Constants.VOLUME.MIN or value > Constants.VOLUME.BLANK then
    return false, string.format("Volume value %d out of range [%d, %d]",
      value, Constants.VOLUME.MIN, Constants.VOLUME.BLANK)
  end

  return true, nil
end

-- Validate panning value
-- @param value: Panning value to check
-- @return success, error_message
function Validator.validate_panning_value(value)
  if type(value) ~= "number" then
    return false, string.format("Panning value must be a number, got %s", type(value))
  end

  if value < Constants.PANNING.MIN or value > Constants.PANNING.BLANK then
    return false, string.format("Panning value %d out of range [%d, %d]",
      value, Constants.PANNING.MIN, Constants.PANNING.BLANK)
  end

  return true, nil
end

-- Validate delay value
-- @param value: Delay value to check
-- @return success, error_message
function Validator.validate_delay_value(value)
  if type(value) ~= "number" then
    return false, string.format("Delay value must be a number, got %s", type(value))
  end

  if value < Constants.DELAY.MIN or value > Constants.DELAY.MAX then
    return false, string.format("Delay value %d out of range [%d, %d]",
      value, Constants.DELAY.MIN, Constants.DELAY.MAX)
  end

  return true, nil
end

-- Validate effect number value
-- @param value: Effect number to check
-- @return success, error_message
function Validator.validate_effect_number(value)
  if type(value) ~= "number" then
    return false, string.format("Effect number must be a number, got %s", type(value))
  end

  if value < Constants.EFFECT.NUMBER_MIN or value > Constants.EFFECT.NUMBER_MAX then
    return false, string.format("Effect number %d out of range [%d, %d]",
      value, Constants.EFFECT.NUMBER_MIN, Constants.EFFECT.NUMBER_MAX)
  end

  return true, nil
end

-- Validate effect amount value
-- @param value: Effect amount to check
-- @return success, error_message
function Validator.validate_effect_amount(value)
  if type(value) ~= "number" then
    return false, string.format("Effect amount must be a number, got %s", type(value))
  end

  if value < Constants.EFFECT.AMOUNT_MIN or value > Constants.EFFECT.AMOUNT_MAX then
    return false, string.format("Effect amount %d out of range [%d, %d]",
      value, Constants.EFFECT.AMOUNT_MIN, Constants.EFFECT.AMOUNT_MAX)
  end

  return true, nil
end

-- ============================================================================
-- Direction Validation
-- ============================================================================

-- Validate direction parameter
-- @param direction: Direction string to check
-- @return success, error_message
function Validator.validate_direction(direction)
  if type(direction) ~= "string" then
    return false, string.format("Direction must be a string, got %s", type(direction))
  end

  local valid_directions = {
    [Constants.DIRECTION.UP] = true,
    [Constants.DIRECTION.DOWN] = true,
    [Constants.DIRECTION.LEFT] = true,
    [Constants.DIRECTION.RIGHT] = true
  }

  if not valid_directions[direction] then
    return false, string.format("Invalid direction: %s", direction)
  end

  return true, nil
end

-- ============================================================================
-- Parameter Type Validation
-- ============================================================================

-- Validate that a parameter is a number
-- @param value: Value to check
-- @param param_name: Name of parameter (for error message)
-- @return success, error_message
function Validator.validate_number(value, param_name)
  param_name = param_name or "parameter"

  if type(value) ~= "number" then
    return false, string.format("%s must be a number, got %s", param_name, type(value))
  end

  return true, nil
end

-- Validate that a parameter is a string
-- @param value: Value to check
-- @param param_name: Name of parameter (for error message)
-- @return success, error_message
function Validator.validate_string(value, param_name)
  param_name = param_name or "parameter"

  if type(value) ~= "string" then
    return false, string.format("%s must be a string, got %s", param_name, type(value))
  end

  return true, nil
end

-- Validate that a parameter is a table
-- @param value: Value to check
-- @param param_name: Name of parameter (for error message)
-- @return success, error_message
function Validator.validate_table(value, param_name)
  param_name = param_name or "parameter"

  if type(value) ~= "table" then
    return false, string.format("%s must be a table, got %s", param_name, type(value))
  end

  return true, nil
end

-- Validate that a parameter is a function
-- @param value: Value to check
-- @param param_name: Name of parameter (for error message)
-- @return success, error_message
function Validator.validate_function(value, param_name)
  param_name = param_name or "parameter"

  if type(value) ~= "function" then
    return false, string.format("%s must be a function, got %s", param_name, type(value))
  end

  return true, nil
end

-- ============================================================================
-- Composite Validation
-- ============================================================================

-- Validate all preconditions for note column operations
-- @return success, error_message
function Validator.validate_note_operation_preconditions()
  local success, err = Validator.validate_song_loaded()
  if not success then return false, err end

  success, err = Validator.validate_note_column_selected()
  if not success then return false, err end

  return true, nil
end

-- Validate all preconditions for effect column operations
-- @return success, error_message
function Validator.validate_effect_operation_preconditions()
  local success, err = Validator.validate_song_loaded()
  if not success then return false, err end

  success, err = Validator.validate_effect_column_selected()
  if not success then return false, err end

  return true, nil
end

return Validator
