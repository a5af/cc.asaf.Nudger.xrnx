--[[============================================================================
config.lua
============================================================================]]--

--[[

Default configuration for Nudger tool.
Users can create user_config.lua to override these settings.

]]--

return {
  -- ============================================================================
  -- General Settings
  -- ============================================================================

  -- Log level for console output
  -- Options: "DEBUG", "INFO", "WARN", "ERROR"
  -- DEBUG: Show everything (very verbose)
  -- INFO: Show informational messages
  -- WARN: Show warnings and errors only (recommended)
  -- ERROR: Show errors only
  log_level = "WARN",

  -- Show status messages in Renoise status bar
  -- Set to false for silent operation
  show_status_messages = true,

  -- ============================================================================
  -- Behavior Settings
  -- ============================================================================

  -- Wrap values at boundaries
  -- When true: reaching max value wraps to min (and vice versa)
  -- When false: values stop at min/max
  wrap_at_boundaries = {
    note_value = true,          -- Wrap note pitch
    instrument_value = true,    -- Wrap instrument number
    volume_value = false,       -- Don't wrap volume (stop at 0/127)
    panning_value = false,      -- Don't wrap panning (stop at 0/127)
    delay_value = true,         -- Wrap delay value
    effect_number = true,       -- Wrap effect commands (cycle through)
    effect_amount = true        -- Wrap effect amount
  },

  -- Auto-advance cursor after nudge operations
  -- When true: cursor moves to next line after nudging
  -- When false: cursor stays in place
  auto_advance_after_nudge = false,

  -- Auto-select cloned note after clone operation
  -- When true: cursor moves to the cloned note
  -- When false: cursor stays on original note (current behavior)
  auto_select_cloned_note = true,

  -- Blank note behavior
  -- When true: nudging a blank note sets it to default value
  -- When false: nudging a blank note does nothing
  nudge_blank_to_default = true,

  -- Default values when nudging blank notes
  default_values = {
    note_value = 48,      -- C-4
    instrument_value = 0, -- First instrument
    volume_value = 64,    -- Half volume
    panning_value = 64,   -- Center panning
    delay_value = 0       -- No delay
  },

  -- ============================================================================
  -- Input Tracking Settings
  -- ============================================================================

  -- Input mode for cursor vs selection operations
  -- Options:
  --   "AUTO": Automatically detect user intent based on last input
  --   "CURSOR_ONLY": Always use cursor operations (ignore selection)
  --   "SELECTION_ONLY": Always use selection operations when selection exists
  input_mode = "AUTO",

  -- How long to remember last input type (milliseconds)
  -- After this timeout, input type becomes unknown
  -- Recommended: 500-1000ms
  input_timeout_ms = 500,

  -- Auto-select moved notes after move selection
  -- When true: selection follows moved notes
  -- When false: selection stays in place
  auto_select_moved_notes = true,

  -- Auto-select cloned notes after clone selection
  -- When true: selection moves to cloned notes
  -- When false: selection stays on original notes
  auto_select_cloned_notes = true,

  -- ============================================================================
  -- OSC Network Settings
  -- ============================================================================

  -- Enable OSC server and client
  osc_enabled = false,

  -- OSC server settings (receive messages)
  osc_server = {
    ip = "0.0.0.0",     -- Listen on all interfaces
    port = 10000         -- Port to listen on
  },

  -- OSC client settings (send messages)
  osc_client = {
    ip = "127.0.0.1",   -- Localhost
    port = 10001         -- Port to send to
  },

  -- ============================================================================
  -- Advanced Settings
  -- ============================================================================

  -- Enable experimental features
  -- These features may be unstable or incomplete
  enable_experimental_features = false,

  -- Debug mode
  -- Enables additional logging and error checking
  debug_mode = false,

  -- Trace function calls (very verbose, DEBUG level only)
  -- Shows function enter/exit for debugging
  trace_function_calls = false,

  -- Use undo grouping for multi-note operations
  -- Requires Renoise 3.5+ (describe_batch_undo API)
  -- When true: selection operations become single undo action
  -- When false: each note is separate undo action
  use_undo_grouping = true,

  -- Performance settings
  performance = {
    -- Max notes to process in selection before showing progress
    show_progress_threshold = 50,

    -- Delay between processing large selections (ms)
    -- 0 = process immediately, >0 = allow UI updates
    large_selection_delay = 0
  }
}
