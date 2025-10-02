--[[============================================================================
core/constants.lua
============================================================================]]--

--[[

All constants used throughout the Nudger tool.
Replaces magic numbers with named, documented constants.

]]--

local Constants = {}

-- ============================================================================
-- Note Values
-- ============================================================================

-- Note value represents pitch in tracker
-- Range: 0-121
-- Special values:
--   0: Empty/unused
--   1-119: Playable notes (C-0 to B-9)
--   120: Note-off
--   121: Blank/no note
Constants.NOTE = {
  MIN = 0,
  MAX = 119,
  NOTE_OFF = 120,
  BLANK = 121,
  DEFAULT = 48  -- C-4, common default note
}

-- ============================================================================
-- Instrument Values
-- ============================================================================

-- Instrument number
-- Range: 0-255
-- Special values:
--   0-254: Valid instrument indices
--   255: Blank/no instrument
Constants.INSTRUMENT = {
  MIN = 0,
  MAX = 254,
  BLANK = 255
}

-- ============================================================================
-- Volume Values
-- ============================================================================

-- Volume column can contain:
-- - Direct volume values: 0-127 (0x00-0x7F)
-- - Effect commands: 128-254 (0x80-0xFE)
-- - Blank: 255 (0xFF)
Constants.VOLUME = {
  MIN = 0,
  MAX = 127,
  MAX_HEX = 0x7F,
  BLANK = 255,
  BLANK_HEX = 0xFF,
  EFFECT_START = 128  -- Values >= 128 are effect commands
}

-- ============================================================================
-- Panning Values
-- ============================================================================

-- Panning column (same structure as volume)
-- - Direct panning values: 0-127 (0x00-0x7F)
-- - Effect commands: 128-254 (0x80-0xFE)
-- - Blank: 255 (0xFF)
Constants.PANNING = {
  MIN = 0,
  MAX = 127,
  MAX_HEX = 0x7F,
  BLANK = 255,
  BLANK_HEX = 0xFF,
  EFFECT_START = 128  -- Values >= 128 are effect commands
}

-- ============================================================================
-- Delay Values
-- ============================================================================

-- Note delay in ticks
-- Range: 0-255
Constants.DELAY = {
  MIN = 0,
  MAX = 255,
  MAX_HEX = 0xFF
}

-- ============================================================================
-- Effect Values
-- ============================================================================

-- Effect number and amount
-- Range: 0-255 for both
Constants.EFFECT = {
  NUMBER_MIN = 0,
  NUMBER_MAX = 255,
  AMOUNT_MIN = 0,
  AMOUNT_MAX = 255,
  AMOUNT_MAX_HEX = 0xFF
}

-- ============================================================================
-- Renoise Sub-Column Types
-- ============================================================================

-- Map to renoise.Song.SUB_COLUMN_* constants
-- These are used to detect which property the cursor is on
Constants.SUB_COLUMN = {
  NOTE = 1,                    -- renoise.Song.SUB_COLUMN_NOTE
  INSTRUMENT = 2,              -- renoise.Song.SUB_COLUMN_INSTRUMENT
  VOLUME = 3,                  -- renoise.Song.SUB_COLUMN_VOLUME
  PANNING = 4,                 -- renoise.Song.SUB_COLUMN_PANNING
  DELAY = 5,                   -- renoise.Song.SUB_COLUMN_DELAY
  SAMPLE_EFFECT_NUMBER = 6,    -- renoise.Song.SUB_COLUMN_SAMPLE_EFFECT_NUMBER
  SAMPLE_EFFECT_AMOUNT = 7,    -- renoise.Song.SUB_COLUMN_SAMPLE_EFFECT_AMOUNT
  EFFECT_NUMBER = 8,           -- renoise.Song.SUB_COLUMN_EFFECT_NUMBER
  EFFECT_AMOUNT = 9            -- renoise.Song.SUB_COLUMN_EFFECT_AMOUNT
}

-- ============================================================================
-- Effect Command Mappings
-- ============================================================================

-- Effect commands used in volume and panning columns
-- These are the valid command letters and their internal Renoise values

-- Valid volume commands: G U D I O B Q R Y C
-- Valid panning commands: G U D J K B Q R Y C

-- Command name to Renoise internal value
Constants.EFFECT_COMMANDS = {
  A = 10,   -- Arpeggio
  U = 30,   -- Slide Up
  D = 13,   -- Slide Down
  G = 16,   -- Glide
  V = 31,   -- Vibrato
  I = 18,   -- Fade In (volume only)
  O = 24,   -- Fade Out (volume only)
  T = 29,   -- Tremolo
  C = 12,   -- Cut Volume
  M = 22,   -- Set Master Volume
  L = 21,   -- Set Track Level
  S = 28,   -- Set Send Amount
  B = 11,   -- Play Backwards
  E = 14,   -- Set Track Effect
  Q = 26,   -- Delay Playback
  R = 27,   -- Retrigger
  Y = 34,   -- Maybe Trigger
  N = 23,   -- Set Panning
  P = 25,   -- Set Panning Slide
  W = 32,   -- Set Panning Width
  X = 33,   -- Stop All Notes
  Z = 35,   -- Line Sync
  J = 19    -- Panning Slide Left (panning only)
  -- K would be Panning Slide Right but not in original mapping
}

-- Mapping from Renoise command value to sequential cardinal number
-- Used for cycling through effect commands
Constants.CMD_TO_CARDINAL = {
  [10] = 1,   -- A
  [30] = 2,   -- U
  [13] = 3,   -- D
  [16] = 4,   -- G
  [31] = 5,   -- V
  [18] = 6,   -- I
  [24] = 7,   -- O
  [29] = 8,   -- T
  [12] = 9,   -- C
  [22] = 10,  -- M
  [21] = 11,  -- L
  [28] = 12,  -- S
  [11] = 13,  -- B
  [14] = 14,  -- E
  [26] = 15,  -- Q
  [27] = 16,  -- R
  [34] = 17,  -- Y
  [23] = 18,  -- N
  [25] = 19,  -- P
  [32] = 20,  -- W
  [33] = 21,  -- X
  [35] = 22,  -- Z
  [19] = 23   -- J
}

-- Reverse mapping: cardinal number to Renoise command value
-- Used for getting next/previous effect command
Constants.CARDINAL_TO_CMD = {
  [1] = 10,   -- A
  [2] = 30,   -- U
  [3] = 13,   -- D
  [4] = 16,   -- G
  [5] = 31,   -- V
  [6] = 18,   -- I
  [7] = 24,   -- O
  [8] = 29,   -- T
  [9] = 12,   -- C
  [10] = 22,  -- M
  [11] = 21,  -- L
  [12] = 28,  -- S
  [13] = 11,  -- B
  [14] = 14,  -- E
  [15] = 26,  -- Q
  [16] = 27,  -- R
  [17] = 34,  -- Y
  [18] = 23,  -- N
  [19] = 25,  -- P
  [20] = 32,  -- W
  [21] = 33,  -- X
  [22] = 35,  -- Z
  [23] = 19   -- J
}

-- Total number of effect commands for cycling
Constants.EFFECT_COMMAND_COUNT = 23

-- ============================================================================
-- Direction Constants
-- ============================================================================

Constants.DIRECTION = {
  UP = "up",
  DOWN = "down",
  LEFT = "left",
  RIGHT = "right"
}

-- ============================================================================
-- Editor Context Types
-- ============================================================================

Constants.EDITOR_CONTEXT = {
  PATTERN = "pattern",
  PHRASE = "phrase",
  UNKNOWN = "unknown"
}

-- ============================================================================
-- Column Types
-- ============================================================================

Constants.COLUMN_TYPE = {
  NOTE = "note_column",
  EFFECT = "effect_column"
}

-- ============================================================================
-- Helper Functions
-- ============================================================================

-- Get next effect command number (cycling forward)
function Constants.get_next_effect_number(current_number)
  local cardinal = Constants.CMD_TO_CARDINAL[current_number]
  if not cardinal then
    return Constants.CARDINAL_TO_CMD[1]
  end

  cardinal = cardinal + 1
  if cardinal > Constants.EFFECT_COMMAND_COUNT then
    cardinal = 1
  end

  return Constants.CARDINAL_TO_CMD[cardinal]
end

-- Get previous effect command number (cycling backward)
function Constants.get_prev_effect_number(current_number)
  local cardinal = Constants.CMD_TO_CARDINAL[current_number]
  if not cardinal then
    return Constants.CARDINAL_TO_CMD[Constants.EFFECT_COMMAND_COUNT]
  end

  cardinal = cardinal - 1
  if cardinal < 1 then
    cardinal = Constants.EFFECT_COMMAND_COUNT
  end

  return Constants.CARDINAL_TO_CMD[cardinal]
end

-- Check if value represents a blank/empty state for given property type
function Constants.is_blank(value, property_type)
  if property_type == "note_value" then
    return value == Constants.NOTE.BLANK
  elseif property_type == "instrument_value" then
    return value == Constants.INSTRUMENT.BLANK
  elseif property_type == "volume_value" or property_type == "panning_value" then
    return value == Constants.VOLUME.BLANK  -- Same as PANNING.BLANK
  else
    return false
  end
end

return Constants
