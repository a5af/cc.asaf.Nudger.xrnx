--[[============================================================================
core/config_manager.lua
============================================================================]]--

--[[

Configuration management for Nudger tool.
Loads default config, merges user config, provides access to settings.

]]--

local ConfigManager = {}

-- ============================================================================
-- State
-- ============================================================================

local default_config = nil
local user_config = {}
local merged_config = {}
local config_loaded = false

-- ============================================================================
-- Helper Functions
-- ============================================================================

-- Deep merge two tables (user values override defaults)
-- @param default_table: Default configuration table
-- @param user_table: User configuration table
-- @return merged table
local function deep_merge(default_table, user_table)
  local result = {}

  -- Copy all default values
  for key, value in pairs(default_table) do
    if type(value) == "table" then
      result[key] = deep_merge(value, {})
    else
      result[key] = value
    end
  end

  -- Override with user values
  for key, value in pairs(user_table) do
    if type(value) == "table" and type(result[key]) == "table" then
      result[key] = deep_merge(result[key], value)
    else
      result[key] = value
    end
  end

  return result
end

-- Serialize a table to Lua code string
-- @param tbl: Table to serialize
-- @param indent: Current indentation level (for recursion)
-- @return string: Lua code representation
local function serialize_table(tbl, indent)
  indent = indent or 0
  local indent_str = string.rep("  ", indent)
  local result = "{\n"

  for key, value in pairs(tbl) do
    local key_str
    if type(key) == "string" then
      key_str = string.format('["%s"]', key)
    else
      key_str = string.format("[%s]", tostring(key))
    end

    if type(value) == "table" then
      result = result .. indent_str .. "  " .. key_str .. " = " .. serialize_table(value, indent + 1) .. ",\n"
    elseif type(value) == "string" then
      result = result .. indent_str .. "  " .. key_str .. string.format(' = "%s",\n', value)
    elseif type(value) == "boolean" then
      result = result .. indent_str .. "  " .. key_str .. " = " .. tostring(value) .. ",\n"
    else
      result = result .. indent_str .. "  " .. key_str .. " = " .. tostring(value) .. ",\n"
    end
  end

  result = result .. indent_str .. "}"
  return result
end

-- ============================================================================
-- Configuration Loading
-- ============================================================================

-- Load configuration (call on tool startup)
function ConfigManager.load()
  if config_loaded then
    return true
  end

  -- Load default config
  local success, result = pcall(function()
    return require('config')
  end)

  if not success then
    print("[ERROR] ConfigManager: Failed to load default config:", result)
    default_config = {}
  else
    default_config = result
  end

  -- Try to load user config
  if renoise and renoise.tool and renoise.tool() and renoise.tool().bundle_path then
    local user_config_path = renoise.tool().bundle_path .. "user_config.lua"

    -- Check if user config exists
    local file = io.open(user_config_path, "r")
    if file then
      file:close()

      -- Load user config
      success, result = pcall(function()
        return dofile(user_config_path)
      end)

      if success then
        user_config = result or {}
        print("[INFO] ConfigManager: Loaded user config from", user_config_path)
      else
        print("[WARN] ConfigManager: Failed to load user config:", result)
        user_config = {}
      end
    else
      -- No user config file, use defaults
      user_config = {}
    end
  end

  -- Merge configs
  merged_config = deep_merge(default_config, user_config)
  config_loaded = true

  return true
end

-- Reload configuration (reloads both default and user config)
function ConfigManager.reload()
  config_loaded = false
  -- Clear cached modules
  package.loaded['config'] = nil
  return ConfigManager.load()
end

-- ============================================================================
-- Configuration Access
-- ============================================================================

-- Get a configuration value
-- @param key_path: Dot-separated path to config value (e.g., "osc_server.port")
-- @param default_value: Value to return if key not found
-- @return configuration value or default_value
function ConfigManager.get(key_path, default_value)
  if not config_loaded then
    ConfigManager.load()
  end

  -- Split key path
  local keys = {}
  for key in string.gmatch(key_path, "[^.]+") do
    table.insert(keys, key)
  end

  -- Navigate to value
  local value = merged_config
  for _, key in ipairs(keys) do
    if type(value) ~= "table" then
      return default_value
    end
    value = value[key]
    if value == nil then
      return default_value
    end
  end

  return value
end

-- Set a configuration value (runtime only, not saved)
-- @param key_path: Dot-separated path to config value
-- @param value: Value to set
function ConfigManager.set(key_path, value)
  if not config_loaded then
    ConfigManager.load()
  end

  -- Split key path
  local keys = {}
  for key in string.gmatch(key_path, "[^.]+") do
    table.insert(keys, key)
  end

  -- Navigate to parent and set value
  local current = merged_config
  for i = 1, #keys - 1 do
    local key = keys[i]
    if type(current[key]) ~= "table" then
      current[key] = {}
    end
    current = current[key]
  end

  current[keys[#keys]] = value
end

-- ============================================================================
-- User Configuration Persistence
-- ============================================================================

-- Save current configuration to user_config.lua
-- @return success, error_message
function ConfigManager.save()
  if not renoise or not renoise.tool or not renoise.tool() or not renoise.tool().bundle_path then
    return false, "Renoise tool API not available"
  end

  local user_config_path = renoise.tool().bundle_path .. "user_config.lua"

  -- Serialize merged config
  local config_str = "-- User configuration for Nudger\n"
  config_str = config_str .. "-- This file overrides settings in config.lua\n\n"
  config_str = config_str .. "return " .. serialize_table(merged_config, 0)

  -- Write to file
  local file, err = io.open(user_config_path, "w")
  if not file then
    return false, string.format("Failed to open file: %s", err or "unknown error")
  end

  file:write(config_str)
  file:close()

  print("[INFO] ConfigManager: Saved user config to", user_config_path)
  return true, nil
end

-- Reset to default configuration (deletes user config file)
-- @return success, error_message
function ConfigManager.reset()
  if not renoise or not renoise.tool or not renoise.tool() or not renoise.tool().bundle_path then
    return false, "Renoise tool API not available"
  end

  local user_config_path = renoise.tool().bundle_path .. "user_config.lua"

  -- Delete user config file if it exists
  local success, err = pcall(function()
    os.remove(user_config_path)
  end)

  if success then
    -- Reload to use defaults
    user_config = {}
    ConfigManager.reload()
    print("[INFO] ConfigManager: Reset to default configuration")
    return true, nil
  else
    return false, string.format("Failed to delete user config: %s", err or "unknown error")
  end
end

-- ============================================================================
-- Convenience Getters
-- ============================================================================

-- Get log level as string
function ConfigManager.get_log_level()
  return ConfigManager.get("log_level", "WARN")
end

-- Get log level as number (for ErrorHandler)
function ConfigManager.get_log_level_number()
  local ErrorHandler = require('core/error_handler')
  local level_str = ConfigManager.get_log_level()

  local level_map = {
    DEBUG = ErrorHandler.LOG_LEVEL.DEBUG,
    INFO = ErrorHandler.LOG_LEVEL.INFO,
    WARN = ErrorHandler.LOG_LEVEL.WARN,
    ERROR = ErrorHandler.LOG_LEVEL.ERROR
  }

  return level_map[level_str] or ErrorHandler.LOG_LEVEL.WARN
end

-- Check if status messages are enabled
function ConfigManager.show_status_messages()
  return ConfigManager.get("show_status_messages", true)
end

-- Check if wrapping is enabled for a property
-- @param property: Property name (e.g., "note_value")
function ConfigManager.wrap_enabled(property)
  return ConfigManager.get("wrap_at_boundaries." .. property, false)
end

-- Get default value for a property
-- @param property: Property name (e.g., "note_value")
function ConfigManager.get_default_value(property)
  return ConfigManager.get("default_values." .. property, 0)
end

-- Check if OSC is enabled
function ConfigManager.is_osc_enabled()
  return ConfigManager.get("osc_enabled", false)
end

-- Check if debug mode is enabled
function ConfigManager.is_debug_mode()
  return ConfigManager.get("debug_mode", false)
end

-- Check if undo grouping is enabled
function ConfigManager.use_undo_grouping()
  return ConfigManager.get("use_undo_grouping", true)
end

return ConfigManager
