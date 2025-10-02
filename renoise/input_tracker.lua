--[[============================================================================
renoise/input_tracker.lua

Tracks user input context (cursor vs selection) to determine operation intent.
============================================================================]]--

local Constants = require('core/constants')
local ErrorHandler = require('core/error_handler')
local ConfigManager = require('core/config_manager')

local InputTracker = {}

-- ============================================================================
-- State
-- ============================================================================

local state = {
  last_input_type = nil,      -- "CURSOR" or "SELECTION"
  last_input_time = 0,        -- os.clock() timestamp
  cursor_notifiers = {},      -- Observable notifiers
  selection_notifiers = {},   -- Observable notifiers
  initialized = false
}

-- Input types
InputTracker.INPUT_TYPE = {
  CURSOR = "CURSOR",
  SELECTION = "SELECTION",
  UNKNOWN = "UNKNOWN"
}

-- ============================================================================
-- Input Detection
-- ============================================================================

-- Called when cursor position changes
local function on_cursor_changed()
  ErrorHandler.debug("InputTracker: Cursor changed")
  state.last_input_type = InputTracker.INPUT_TYPE.CURSOR
  state.last_input_time = os.clock()
end

-- Called when selection changes
local function on_selection_changed()
  ErrorHandler.debug("InputTracker: Selection changed")
  state.last_input_type = InputTracker.INPUT_TYPE.SELECTION
  state.last_input_time = os.clock()
end

-- ============================================================================
-- Observable Management
-- ============================================================================

-- Add cursor observables
local function add_cursor_observables(song)
  -- Track line index changes (up/down navigation)
  if song.selected_line_index_observable and not song.selected_line_index_observable:has_notifier(on_cursor_changed) then
    song.selected_line_index_observable:add_notifier(on_cursor_changed)
    table.insert(state.cursor_notifiers, song.selected_line_index_observable)
  end

  -- Track note column changes (left/right navigation)
  if song.selected_note_column_index_observable and not song.selected_note_column_index_observable:has_notifier(on_cursor_changed) then
    song.selected_note_column_index_observable:add_notifier(on_cursor_changed)
    table.insert(state.cursor_notifiers, song.selected_note_column_index_observable)
  end

  -- Track track index changes
  if song.selected_track_index_observable and not song.selected_track_index_observable:has_notifier(on_cursor_changed) then
    song.selected_track_index_observable:add_notifier(on_cursor_changed)
    table.insert(state.cursor_notifiers, song.selected_track_index_observable)
  end

  -- Track pattern index changes
  if song.selected_pattern_index_observable and not song.selected_pattern_index_observable:has_notifier(on_cursor_changed) then
    song.selected_pattern_index_observable:add_notifier(on_cursor_changed)
    table.insert(state.cursor_notifiers, song.selected_pattern_index_observable)
  end

  -- Phrase editor cursor (Renoise 3.5+)
  if song.selected_phrase_line_observable and not song.selected_phrase_line_observable:has_notifier(on_cursor_changed) then
    song.selected_phrase_line_observable:add_notifier(on_cursor_changed)
    table.insert(state.cursor_notifiers, song.selected_phrase_line_observable)
  end

  if song.selected_phrase_note_column_observable and not song.selected_phrase_note_column_observable:has_notifier(on_cursor_changed) then
    song.selected_phrase_note_column_observable:add_notifier(on_cursor_changed)
    table.insert(state.cursor_notifiers, song.selected_phrase_note_column_observable)
  end
end

-- Add selection observables
local function add_selection_observables(song)
  -- Track selection changes
  if song.selection_in_pattern_observable and not song.selection_in_pattern_observable:has_notifier(on_selection_changed) then
    song.selection_in_pattern_observable:add_notifier(on_selection_changed)
    table.insert(state.selection_notifiers, song.selection_in_pattern_observable)
  end
end

-- Remove all observables (for cleanup)
local function remove_all_observables()
  for _, observable in ipairs(state.cursor_notifiers) do
    if observable:has_notifier(on_cursor_changed) then
      observable:remove_notifier(on_cursor_changed)
    end
  end

  for _, observable in ipairs(state.selection_notifiers) do
    if observable:has_notifier(on_selection_changed) then
      observable:remove_notifier(on_selection_changed)
    end
  end

  state.cursor_notifiers = {}
  state.selection_notifiers = {}
end

-- ============================================================================
-- Public API
-- ============================================================================

-- Initialize input tracking
function InputTracker.initialize()
  if state.initialized then
    ErrorHandler.debug("InputTracker already initialized")
    return
  end

  local song = renoise.song()
  if not song then
    ErrorHandler.warn("Cannot initialize InputTracker: No song loaded")
    return false
  end

  ErrorHandler.debug("Initializing InputTracker")

  -- Add observables
  add_cursor_observables(song)
  add_selection_observables(song)

  state.initialized = true
  state.last_input_type = InputTracker.INPUT_TYPE.UNKNOWN
  state.last_input_time = os.clock()

  ErrorHandler.info("InputTracker initialized")
  return true
end

-- Cleanup (remove observables)
function InputTracker.cleanup()
  if not state.initialized then
    return
  end

  ErrorHandler.debug("Cleaning up InputTracker")
  remove_all_observables()
  state.initialized = false
  state.last_input_type = nil
  state.last_input_time = 0
end

-- Get current input type
function InputTracker.get_input_type()
  if not state.initialized then
    return InputTracker.INPUT_TYPE.UNKNOWN
  end

  -- Check if input has timed out
  local timeout = ConfigManager.get("input_timeout_ms", 500) / 1000.0
  local elapsed = os.clock() - state.last_input_time

  if elapsed > timeout then
    ErrorHandler.debug("Input timeout exceeded, returning UNKNOWN")
    return InputTracker.INPUT_TYPE.UNKNOWN
  end

  return state.last_input_type or InputTracker.INPUT_TYPE.UNKNOWN
end

-- Determine if selection should be used for operations
function InputTracker.should_use_selection()
  -- Check config override
  local input_mode = ConfigManager.get("input_mode", "AUTO")

  if input_mode == "CURSOR_ONLY" then
    return false
  end

  if input_mode == "SELECTION_ONLY" then
    local song = renoise.song()
    return song and song.selection_in_pattern ~= nil
  end

  -- AUTO mode: use input tracking
  local song = renoise.song()
  if not song or not song.selection_in_pattern then
    return false
  end

  local input_type = InputTracker.get_input_type()

  -- If last input was selection-related, use selection
  if input_type == InputTracker.INPUT_TYPE.SELECTION then
    ErrorHandler.debug("Using SELECTION (last input was selection)")
    return true
  end

  -- If last input was cursor-related, use cursor even if selection exists
  if input_type == InputTracker.INPUT_TYPE.CURSOR then
    ErrorHandler.debug("Using CURSOR (last input was cursor)")
    return false
  end

  -- Unknown input type: default behavior
  -- If selection exists and we don't know intent, prefer selection
  ErrorHandler.debug("Unknown input type, defaulting to selection")
  return true
end

-- Get debug info
function InputTracker.get_debug_info()
  return {
    initialized = state.initialized,
    last_input_type = state.last_input_type,
    last_input_time = state.last_input_time,
    time_since_input = os.clock() - state.last_input_time,
    cursor_notifiers = #state.cursor_notifiers,
    selection_notifiers = #state.selection_notifiers
  }
end

-- Force input type (for testing/debugging)
function InputTracker.set_input_type(input_type)
  if input_type == InputTracker.INPUT_TYPE.CURSOR or
     input_type == InputTracker.INPUT_TYPE.SELECTION then
    state.last_input_type = input_type
    state.last_input_time = os.clock()
    ErrorHandler.debug("Forced input type to: " .. input_type)
    return true
  end
  return false
end

return InputTracker
