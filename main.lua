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
-- Legacy Code (to be removed in future phases)
-- ============================================================================

require 'utils'
function get_current_subcol()
  local song = renoise.song()
  if not song.selected_note_column then return end
  return song.selected_sub_column_type
end

function get_next_effect_number(effect_number)
  return Constants.get_next_effect_number(effect_number)
end

function get_prev_effect_number(effect_number)
  return Constants.get_prev_effect_number(effect_number)
end

function get_cur_line_track_col_pattern_inst_phrase()
  local song = renoise.song()
  return {
    line = song.selected_line_index,
    track = song.selected_track_index,
    note_col = song.selected_note_column_index,
    effect_col = song.selected_effect_column_index,
    pattern = song.selected_pattern_index,
    inst = song.selected_instrument_index,
    phrase = song.selected_phrase_index
  }
end

function get_current_note()
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  return
    renoise.song().patterns[cur.pattern].tracks[cur.track].lines[cur.line]:note_column(
      cur.note_col)
end

function get_current_selected()
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  if renoise.song().selected_note_column then
    return
      renoise.song().patterns[cur.pattern].tracks[cur.track].lines[cur.line]:note_column(
        cur.note_col)
  end
  if renoise.song().selected_effect_column then
    return
      renoise.song().patterns[cur.pattern].tracks[cur.track].lines[cur.line]:effect_column(
        cur.effect_col)
  end
end

function get_left_note()
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  if cur.note_col == 0 then
    if cur.track == 0 then return end
    cur.track = cur.track - 1
  else
    cur.note_col = cur.note_col - 1
  end
  return
    renoise.song().patterns[cur.pattern].tracks[cur.track].lines[cur.line]:note_column(
      cur.note_col)
end

function get_right_note()
  if not renoise.song().selected_note_column then return end
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  if cur.note_col == get_col_count() - 1 then
    if cur.track == get_track_count() - 1 then return end
    cur.track = cur.track - 1
  else
    cur.note_col = cur.note_col - 1
  end
  return
    renoise.song().patterns[cur.pattern].tracks[cur.track].lines[cur.line]:note_column(
      cur.note_col)

end

function get_above_note()
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  local line_above = get_above_line()
  return line_above:note_column(cur.note_col)
end

function get_above_line()
  if not renoise.song().selected_note_column then return end
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  local above_line_idx = renoise.song().selected_line_index - 1
  return
    renoise.song().patterns[cur.pattern].tracks[cur.track].lines[above_line_idx]
end

function get_line_count()
  if not renoise.song().selected_note_column then return end
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  return get_table_size(renoise.song().patterns[cur.pattern].tracks[cur.track]
                          .lines)
end

function get_track_count()

  if not renoise.song().selected_note_column then return end
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  return get_table_size(renoise.song().patterns[cur.pattern].tracks)
end

function get_col_count()

  if not renoise.song().selected_note_column then return end
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  return get_table_size(renoise.song().patterns[cur.pattern].tracks[cur.track]
                          .lines[cur.line].note_columns)
end

function get_below_note()
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  local line_below = get_below_line()
  return line_below:note_column(cur.note_col)
end

function get_below_line()
  if not renoise.song().selected_note_column then return end
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  local below_line = renoise.song().selected_line_index + 1
  return
    renoise.song().patterns[cur.pattern].tracks[cur.track].lines[below_line]
end

function nudgeUp()
  local subcol = renoise.song().selected_sub_column_type
  local sel = get_current_selected()

  if subcol == renoise.Song.SUB_COLUMN_NOTE then
    -- Max is 119 B-9
    if sel ~= nil then
      if sel.note_value < 121 then
        sel.note_value = (sel.note_value + 1)
      else
        sel.note_string = 'C-4'
      end
    end
  end

  if subcol == renoise.Song.SUB_COLUMN_INSTRUMENT then
    if sel.instrument_value < 255 then
      sel.instrument_value = sel.instrument_value + 1
    else
      sel.instrument_value = 0
    end
  end

  if subcol == renoise.Song.SUB_COLUMN_VOLUME then
    if sel.volume_value < 127 then
      sel.volume_value = sel.volume_value + 1
    elseif sel.volume_value == 0x7F then
      sel.volume_value = 255 -- make it blank
    elseif sel.volume_value == 255 then -- is it blank?
      sel.volume_value = 0
    else
      -- EFFECT COMMAND
      local command = sel.volume_string[1]
      local value = tonumber(sel.volume_string[2])

      if value ~= nil and value < 16 then
        value = value + 1
        sel.volume_string = command .. DEC_HEX(value)
      else
        sel.volume_string = command .. "0"
      end
    end
  end

  if subcol == renoise.Song.SUB_COLUMN_PANNING then
    if sel.panning_value < 127 then
      sel.panning_value = sel.panning_value + 1
    elseif sel.panning_value == 0x7F then
      sel.panning_value = 255 -- make it blank
    elseif sel.panning_value == 255 then -- is it blank?
      sel.panning_value = 0
    else
      -- EFFECT COMMAND
      local command = sel.panning_string[1]
      local value = tonumber(sel.panning_string[2])

      if value ~= nil and value < 16 then
        value = value + 1
        sel.panning_string = command .. DEC_HEX(value)
      else
        sel.panning_string = command .. "0"
      end
    end
  end

  if subcol == renoise.Song.SUB_COLUMN_DELAY then
    if sel.delay_value < 0xFF then
      sel.delay_value = sel.delay_value + 1
    else
      sel.delay_value = 0
    end
  end

  if subcol == renoise.Song.SUB_COLUMN_SAMPLE_EFFECT_NUMBER then
    sel.effect_number_value = get_next_effect_number(sel.effect_number_value)
  end

  if subcol == renoise.Song.SUB_COLUMN_SAMPLE_EFFECT_AMOUNT then
    if sel.effect_amount_value < 0xFF then
      sel.effect_amount_value = sel.effect_amount_value + 1
    else
      sel.effect_amount_value = 0
    end
  end

  if subcol == renoise.Song.SUB_COLUMN_EFFECT_NUMBER then print('fx num') end
  if subcol == renoise.Song.SUB_COLUMN_EFFECT_AMOUNT then print('fx amt') end
end

function nudgeDown()
  local subcol = renoise.song().selected_sub_column_type
  local sel = get_current_selected()

  if subcol == renoise.Song.SUB_COLUMN_NOTE then
    if sel ~= nil then
      if sel.note_value > 1 then
        sel.note_value = (sel.note_value - 1)
      else
        sel.note_value = 121
      end
    end
  end

  if subcol == renoise.Song.SUB_COLUMN_INSTRUMENT then
    if sel.instrument_value < 255 and sel.instrument_value > 0 then
      sel.instrument_value = sel.instrument_value - 1
    elseif sel.instrument_value == 255 then -- blank
      sel.instrument_value = 254 -- wrap around
    else
      sel.instrument_value = 255 -- make it blank
    end
  end

  if subcol == renoise.Song.SUB_COLUMN_VOLUME then
    if sel.volume_value == 0xFF then -- is it blank?
      sel.volume_value = 0x7F
    elseif sel.volume_value == 0 then
      sel.volume_value = 0xFF -- make it blank
    elseif sel.volume_value > 0 and sel.volume_value < 128 then
      sel.volume_value = sel.volume_value - 1
    else

      -- EFFECT COMMAND
      local command = sel.volume_string[1]
      local value = tonumber(sel.volume_string[2])

      if value ~= nil and value > 0 then
        value = value - 1
        sel.volume_string = command .. DEC_HEX(value)
      else
        sel.volume_string = command .. "F"
      end
    end
  end

  if subcol == renoise.Song.SUB_COLUMN_PANNING then
    if sel.panning_value == 0xFF then -- is it blank?
      sel.panning_value = 0x7F
    elseif sel.panning_value == 0 then
      sel.panning_value = 0xFF -- make it blank
    elseif sel.panning_value > 0 and sel.panning_value < 128 then
      sel.panning_value = sel.panning_value - 1
    else

      -- EFFECT COMMAND
      local command = sel.panning_string[1]
      local value = tonumber(sel.panning_string[2])
      if value ~= nil and value > 0 then
        value = value - 1
        if value == 0 then
          sel.panning_string = command .. "0"
        else
          sel.panning_string = command .. DEC_HEX(value)
        end
      else
        sel.panning_string = command .. "F"
      end
    end
  end

  if subcol == renoise.Song.SUB_COLUMN_DELAY then
    if sel.delay_value > 0 then
      sel.delay_value = sel.delay_value - 1
    else
      sel.delay_value = 0xFF
    end
  end
  if subcol == renoise.Song.SUB_COLUMN_SAMPLE_EFFECT_NUMBER then
    sel.effect_number_value = get_next_effect_number(sel.effect_number_value)
  end
  if subcol == renoise.Song.SUB_COLUMN_SAMPLE_EFFECT_AMOUNT then
    if sel.effect_amount_value > 0 then
      sel.effect_amount_value = sel.effect_amount_value - 1
    else
      sel.effect_amount_value = 0xFF
    end
  end
  if subcol == renoise.Song.SUB_COLUMN_EFFECT_NUMBER then print('fx num') end
  if subcol == renoise.Song.SUB_COLUMN_EFFECT_AMOUNT then print('fx amt') end
end

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

function clear()
  if not renoise.song().selected_note_column then return end
  local subcol = get_current_subcol()
  local note = get_current_note()
  clear_note_values(note)
end

function moveUp()
  local song = renoise.song()
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  if cur.line < 2 then return end
  if song.selected_note_column then moveUpNote() end
  if song.selected_effect_column then moveUpEffect() end
end

function moveUpNote()
  local subcol, note, note_above = get_current_subcol(), get_current_note(),
                                   get_above_note()
  if note.note_value == 121 then return end
  local song = renoise.song()
  local line_above = get_above_line()
  local insertIntoCol
  for k, v in pairs(line_above.note_columns) do
    if is_note_col_blank(v) then
      insertIntoCol = k
      break
    end
  end
  local note_above = line_above.note_columns[insertIntoCol]
  copy_note_values(note, note_above)
  clear_note_values(note)
  song.selected_line_index = song.selected_line_index - 1
  song.selected_note_column_index = insertIntoCol
end

function moveUpEffect()
  -- todo 
end

function moveDown()
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  local song = renoise.song()
  if cur.line >= get_line_count() then return end
  if song.selected_note_column then moveDownNote() end
  if song.selected_effect_column then moveDownEffect() end
end

function moveDownNote()
  local subcol = get_current_subcol()
  local note = get_current_note()
  local note_below = get_below_note()
  if note.note_value == 121 then return end
  local song = renoise.song()
  local line_below = get_below_line()
  local insertIntoCol
  for k, v in pairs(line_below.note_columns) do
    if is_note_col_blank(v) then
      insertIntoCol = k
      break
    end
  end
  local note_below = line_below.note_columns[insertIntoCol]
  copy_note_values(note, note_below)
  clear_note_values(note)
  song.selected_line_index = song.selected_line_index + 1
  song.selected_note_column_index = insertIntoCol

end

function moveDownEffect()
  -- todo 
end

function selectionMoveDown()
  local song = renoise.song()
  local sp = song.selection_in_pattern
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  local num_lines = song.patterns[cur.pattern].number_of_lines
  if sp.end_line > num_lines - 1 then return end
  move_selection(0, 1, sp)
end

function selectionMoveUp()
  local song = renoise.song()
  local sp = song.selection_in_pattern
  if sp.start_line < 2 then return end
  move_selection(0, -1, sp)
  print(sp.start_line)
end

function selectionMoveLeft()
  local sp = renoise.song().selection_in_pattern
  if sp.start_column < 2 then
    print('too small')
    return
  end
  move_selection(-1, 0, sp)
  print(sp.start_line)
end

function selectionMoveRight()
  local sp = renoise.song().selection_in_pattern
  print('col count', get_col_count())
  if sp.start_column > get_col_count() then
    print('too large')
    return
  end
  move_selection(1, 0, sp)
  print(sp.start_line)
end

function moveRight()
  local subcol = get_current_subcol()
  local note = get_current_note()
  local note_right = get_right_note()
  if note.note_value == 121 then return end
  copy_note_values(note, note_right)
  clear_note_values(note)
end

function moveLeft()
  if not renoise.song().selected_note_column then return end
  local subcol = get_current_subcol()
  local note = get_current_note()
  local note_left = get_left_note()
  if note.note_value == 121 then return end
  copy_note_values(note, note_left)
  clear_note_values(note)
end

require 'clone'
-- Old constants.lua replaced by core/constants.lua (loaded at top)

require 'osc_client'
require 'osc_server'

init_keybindings()
-- init_osc_server()
-- init_osc_client()

