_AUTO_RELOAD_DEBUG = function() print("tools reloaded") end

-- ============================================================================
-- Initialize Core Modules (Phase 1: Foundation)
-- ============================================================================

local Constants = require('core/constants')
local ErrorHandler = require('core/error_handler')
local Validator = require('core/validator')
local ConfigManager = require('core/config_manager')

-- Load configuration
ConfigManager.load()

-- Set log level from config
ErrorHandler.set_log_level(ConfigManager.get_log_level_number())

-- Log startup
ErrorHandler.info("Nudger tool initialized")
ErrorHandler.debug("Configuration loaded", {
  log_level = ConfigManager.get_log_level(),
  debug_mode = ConfigManager.is_debug_mode(),
  osc_enabled = ConfigManager.is_osc_enabled()
})

-- ============================================================================
-- Phase 3: Operation Modules
-- ============================================================================

local Nudge = require('operations/nudge')
local Move = require('operations/move')
local Clone = require('operations/clone')
local Clear = require('operations/clear')

-- Wrapper functions for keybindings (maintaining backward compatibility)
function nudgeUp()
  return Nudge.nudge_up()
end

function nudgeDown()
  return Nudge.nudge_down()
end

function moveUp()
  return Move.move_up()
end

function moveDown()
  return Move.move_down()
end

function moveLeft()
  return Move.move_left()
end

function moveRight()
  return Move.move_right()
end

function selectionMoveUp()
  return Move.move_selection_up()
end

function selectionMoveDown()
  return Move.move_selection_down()
end

function selectionMoveLeft()
  return Move.move_selection_left()
end

function selectionMoveRight()
  return Move.move_selection_right()
end

function cloneUp()
  return Clone.clone_up()
end

function cloneDown()
  return Clone.clone_down()
end

function cloneLeft()
  return Clone.clone_left()
end

function cloneRight()
  return Clone.clone_right()
end

function clear()
  return Clear.clear()
end

function clearSelection()
  return Clear.clear_selection()
end

-- ============================================================================
-- Keybinding and Menu Registration
-- ============================================================================

function init_keybindings()
  -- CLEAR
  renoise.tool():add_keybinding{
    name = "Global:Tools:cc.asaf Clear",
    invoke = function() clear() end
  }

  -- NUDGE DOWN
  renoise.tool():add_keybinding{
    name = "Global:Tools:cc.asaf Nudge Down",
    invoke = function() nudgeDown() end
  }

  renoise.tool():add_menu_entry{
    name = "Main Menu:Tools:cc.asaf:Nudge Down",
    invoke = function() nudgeDown() end
  }

  -- NUDGE UP
  renoise.tool():add_keybinding{
    name = "Global:Tools:cc.asaf Nudge Up",
    invoke = function() nudgeUp() end
  }

  renoise.tool():add_menu_entry{
    name = "Main Menu:Tools:cc.asaf:Nudge Up",
    invoke = function() nudgeUp() end
  }

  -- MOVE UP
  renoise.tool():add_keybinding{
    name = "Global:Tools:cc.asaf Move Up",
    invoke = function()
      local s = renoise.song().selection_in_pattern
      if s ~= nil then return selectionMoveUp() end
      moveUp()
    end
  }

  -- MOVE DOWN
  renoise.tool():add_keybinding{
    name = "Global:Tools:cc.asaf Move Down",
    invoke = function()
      local s = renoise.song().selection_in_pattern
      if s ~= nil then return selectionMoveDown() end
      moveDown()
    end
  }

  -- MOVE LEFT
  renoise.tool():add_keybinding{
    name = "Global:Tools:cc.asaf Move Left",
    invoke = function()
      local s = renoise.song().selection_in_pattern
      if s ~= nil then return selectionMoveLeft() end
      moveLeft()
    end
  }

  -- MOVE RIGHT
  renoise.tool():add_keybinding{
    name = "Global:Tools:cc.asaf Move Right",
    invoke = function()
      local s = renoise.song().selection_in_pattern
      if s ~= nil then return selectionMoveRight() end
      moveRight()
    end
  }
end

-- ============================================================================
-- Load Additional Modules and Initialize
-- ============================================================================

require 'osc_client'
require 'osc_server'

init_keybindings()
-- init_osc_server()
-- init_osc_client()

