--[[============================================================================
core/error_handler.lua
============================================================================]]--

--[[

Error handling and logging system for Nudger tool.
Provides consistent error handling, logging, and user feedback.

]]--

local ErrorHandler = {}

-- ============================================================================
-- Log Levels
-- ============================================================================

ErrorHandler.LOG_LEVEL = {
  DEBUG = 1,    -- Detailed information for debugging
  INFO = 2,     -- General informational messages
  WARN = 3,     -- Warning messages for unexpected but handled situations
  ERROR = 4     -- Error messages for failures
}

-- ============================================================================
-- State
-- ============================================================================

-- Current log level (set by config)
local current_log_level = ErrorHandler.LOG_LEVEL.WARN

-- Log level names for display
local log_level_names = {
  [ErrorHandler.LOG_LEVEL.DEBUG] = "DEBUG",
  [ErrorHandler.LOG_LEVEL.INFO] = "INFO",
  [ErrorHandler.LOG_LEVEL.WARN] = "WARN",
  [ErrorHandler.LOG_LEVEL.ERROR] = "ERROR"
}

-- ============================================================================
-- Configuration
-- ============================================================================

-- Set the current log level
-- Messages below this level will not be logged
function ErrorHandler.set_log_level(level)
  if type(level) ~= "number" then
    print("[ERROR] ErrorHandler: Invalid log level type, expected number")
    return
  end

  if level < ErrorHandler.LOG_LEVEL.DEBUG or level > ErrorHandler.LOG_LEVEL.ERROR then
    print("[ERROR] ErrorHandler: Invalid log level value:", level)
    return
  end

  current_log_level = level
end

-- Get the current log level
function ErrorHandler.get_log_level()
  return current_log_level
end

-- ============================================================================
-- Logging Functions
-- ============================================================================

-- Log a message with given level
-- @param level: Log level (DEBUG, INFO, WARN, ERROR)
-- @param message: Message string
-- @param context: Optional table with additional context information
function ErrorHandler.log(level, message, context)
  -- Filter by log level
  if level < current_log_level then
    return
  end

  -- Build log message
  local level_name = log_level_names[level] or "UNKNOWN"
  local prefix = string.format("[%s] Nudger:", level_name)

  -- Log message
  if context and type(context) == "table" then
    print(prefix, message)
    -- Use rprint if available (Renoise provides this)
    if rprint then
      rprint(context)
    else
      -- Fallback to simple print
      print("Context:", tostring(context))
    end
  else
    print(prefix, message)
  end
end

-- Convenience logging functions
function ErrorHandler.debug(message, context)
  ErrorHandler.log(ErrorHandler.LOG_LEVEL.DEBUG, message, context)
end

function ErrorHandler.info(message, context)
  ErrorHandler.log(ErrorHandler.LOG_LEVEL.INFO, message, context)
end

function ErrorHandler.warn(message, context)
  ErrorHandler.log(ErrorHandler.LOG_LEVEL.WARN, message, context)
end

function ErrorHandler.error(message, context)
  ErrorHandler.log(ErrorHandler.LOG_LEVEL.ERROR, message, context)
end

-- ============================================================================
-- Error Handling Functions
-- ============================================================================

-- Handle an error by logging and optionally showing user message
-- @param error_message: Technical error message for logs
-- @param context: Optional context table for debugging
-- @param user_message: Optional user-friendly message to display
function ErrorHandler.handle_error(error_message, context, user_message)
  -- Always log the error
  ErrorHandler.log(ErrorHandler.LOG_LEVEL.ERROR, error_message, context)

  -- Show user message if provided
  if user_message and renoise and renoise.app then
    renoise.app():show_warning(
      string.format("Note Properties Error:\n%s", user_message)
    )
  end
end

-- Execute a function safely with error handling
-- @param fn: Function to execute
-- @param error_message: Message to log on error (optional)
-- @param user_message: Message to show user on error (optional)
-- @return result, error: Function result or nil, error message or nil
function ErrorHandler.safe_execute(fn, error_message, user_message)
  -- Validate input
  if type(fn) ~= "function" then
    ErrorHandler.error("safe_execute called with non-function argument")
    return nil, "Invalid function argument"
  end

  -- Execute function in protected mode
  local success, result = pcall(fn)

  if not success then
    -- Error occurred
    local error_msg = error_message or "Operation failed"
    ErrorHandler.handle_error(
      error_msg,
      { error = result },
      user_message or "An error occurred. Check console for details."
    )
    return nil, result
  end

  -- Success
  return result, nil
end

-- Execute a function with retry logic
-- @param fn: Function to execute
-- @param max_retries: Maximum number of retry attempts (default 3)
-- @param error_message: Message to log on error
-- @param user_message: Message to show user on final failure
-- @return result, error: Function result or nil, error message or nil
function ErrorHandler.safe_execute_with_retry(fn, max_retries, error_message, user_message)
  max_retries = max_retries or 3

  for attempt = 1, max_retries do
    local result, err = ErrorHandler.safe_execute(fn, error_message, nil)

    if result ~= nil then
      -- Success
      if attempt > 1 then
        ErrorHandler.debug(string.format("Operation succeeded on attempt %d", attempt))
      end
      return result, nil
    end

    -- Failed, log and retry if not final attempt
    if attempt < max_retries then
      ErrorHandler.warn(string.format("Attempt %d failed, retrying...", attempt))
    end
  end

  -- All attempts failed
  ErrorHandler.handle_error(
    error_message or "Operation failed after retries",
    { max_retries = max_retries },
    user_message or "Operation failed. Please try again."
  )

  return nil, "Max retries exceeded"
end

-- ============================================================================
-- Assertion Functions
-- ============================================================================

-- Assert a condition, handle error if false
-- @param condition: Boolean condition to check
-- @param error_message: Message to log if condition is false
-- @param user_message: Optional message to show user
-- @return true if condition is true, nil otherwise
function ErrorHandler.assert(condition, error_message, user_message)
  if not condition then
    ErrorHandler.handle_error(
      error_message or "Assertion failed",
      nil,
      user_message
    )
    return nil
  end
  return true
end

-- ============================================================================
-- Status Messages
-- ============================================================================

-- Show a status message to the user (non-error feedback)
-- @param message: Message to display
function ErrorHandler.show_status(message)
  if renoise and renoise.app then
    renoise.app():show_status(message)
  else
    print("[STATUS]", message)
  end
end

-- Show a prompt to the user
-- @param title: Dialog title
-- @param message: Dialog message
-- @param buttons: Array of button labels (default: {"OK"})
-- @return selected button text or nil
function ErrorHandler.show_prompt(title, message, buttons)
  if not renoise or not renoise.app then
    print("[PROMPT]", title, message)
    return "OK"
  end

  buttons = buttons or {"OK"}
  return renoise.app():show_prompt(title, message, buttons)
end

-- ============================================================================
-- Debug Helpers
-- ============================================================================

-- Log a function entry (for tracing execution flow)
-- @param function_name: Name of the function being entered
-- @param params: Optional parameters table to log
function ErrorHandler.trace_enter(function_name, params)
  if current_log_level <= ErrorHandler.LOG_LEVEL.DEBUG then
    if params then
      ErrorHandler.debug(string.format("→ Entering %s", function_name), params)
    else
      ErrorHandler.debug(string.format("→ Entering %s", function_name))
    end
  end
end

-- Log a function exit (for tracing execution flow)
-- @param function_name: Name of the function being exited
-- @param result: Optional result to log
function ErrorHandler.trace_exit(function_name, result)
  if current_log_level <= ErrorHandler.LOG_LEVEL.DEBUG then
    if result ~= nil then
      ErrorHandler.debug(string.format("← Exiting %s", function_name), { result = result })
    else
      ErrorHandler.debug(string.format("← Exiting %s", function_name))
    end
  end
end

return ErrorHandler
