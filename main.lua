_AUTO_RELOAD_DEBUG = function() print("tools reloaded") end

require 'utils'
local song
function initSongRef() if renoise and renoise.song then song = renoise.song() end end
initSongRef()

function get_current_subcol()
  if not song.selected_note_column then return end
  return song.selected_sub_column_type
end

function get_next_effect_number(effect_number)
  local cur_cmd = cmd_to_cardinal[effect_number]
  if not cur_cmd then return cardinal_to_cmd[1] end
  local cardinal = cur_cmd + 1
  if cardinal > #cardinal_to_cmd then cardinal = 1 end
  return cardinal_to_cmd[cardinal]
end

function get_prev_effect_number(effect_number)
  local cur_cmd = cmd_to_cardinal[effect_number]
  if not cur_cmd then return cardinal_to_cmd[#cardinal_to_cmd] end
  local cardinal = cur_cmd - 1
  if cardinal < 1 then cardinal = #cardinal_to_cmd end
  return cardinal_to_cmd[cardinal]
end

function get_cur_line_track_col_pattern_inst_phrase()
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
    song.patterns[cur.pattern].tracks[cur.track].lines[cur.line]:note_column(
      cur.note_col)
end

function get_current_selected()
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  if song.selected_note_column then
    return
      song.patterns[cur.pattern].tracks[cur.track].lines[cur.line]:note_column(
        cur.note_col)
  end
  if song.selected_effect_column then
    return
      song.patterns[cur.pattern].tracks[cur.track].lines[cur.line]:effect_column(
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
    song.patterns[cur.pattern].tracks[cur.track].lines[cur.line]:note_column(
      cur.note_col)
end

function get_right_note()
  if not song.selected_note_column then return end
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  if cur.note_col == get_col_count() - 1 then
    if cur.track == get_track_count() - 1 then return end
    cur.track = cur.track - 1
  else
    cur.note_col = cur.note_col - 1
  end
  return
    song.patterns[cur.pattern].tracks[cur.track].lines[cur.line]:note_column(
      cur.note_col)

end

function get_above_note()
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  local line_above = get_above_line()
  return line_above:note_column(cur.note_col)
end

function get_above_line()
  if not song.selected_note_column then return end
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  local above_line_idx = song.selected_line_index - 1
  return song.patterns[cur.pattern].tracks[cur.track].lines[above_line_idx]
end

function get_line_count()
  if not song.selected_note_column then return end
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  return get_table_size(song.patterns[cur.pattern].tracks[cur.track].lines)
end

function get_track_count()

  if not song.selected_note_column then return end
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  return get_table_size(song.patterns[cur.pattern].tracks)
end

function get_col_count()

  if not song.selected_note_column then return end
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  return get_table_size(
           song.patterns[cur.pattern].tracks[cur.track].lines[cur.line]
             .note_columns)
end

function get_below_note()
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  local line_below = get_below_line()
  return line_below:note_column(cur.note_col)
end

function get_below_line()
  if not song.selected_note_column then return end
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  local below_line = song.selected_line_index + 1
  return song.patterns[cur.pattern].tracks[cur.track].lines[below_line]
end

-- NUDGE UP
renoise.tool():add_keybinding{
  name = "Global:Tools:cc.asaf Nudge Up",
  invoke = function() nudgeUp() end
}

renoise.tool():add_menu_entry{
  name = "Main Menu:Tools:cc.asaf:Nudge Up",
  invoke = function() nudgeUp() end
}
function nudgeUp()
  local subcol = song.selected_sub_column_type
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

-- NUDGE DOWN
renoise.tool():add_keybinding{
  name = "Global:Tools:cc.asaf Nudge Down",
  invoke = function() nudgeDown() end
}

renoise.tool():add_menu_entry{
  name = "Main Menu:Tools:cc.asaf:Nudge Down",
  invoke = function() nudgeDown() end
}

function nudgeDown()
  local subcol = song.selected_sub_column_type
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

-- CLEAR
renoise.tool():add_keybinding{
  name = "Global:Tools:cc.asaf Clear",
  invoke = function() clear() end
}

function clear()
  if not song.selected_note_column then return end
  local subcol = get_current_subcol()
  local note = get_current_note()
  clear_note_values(note)
end

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

function moveUp()
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  if cur.line < 2 then return end
  if song.selected_note_column then moveUpNote() end
  if song.selected_effect_column then moveUpEffect() end
end

function moveUpNote()
  local subcol, note, note_above = get_current_subcol(), get_current_note(),
                                   get_above_note()
  if note.note_value == 121 then return end
  moveUpIntoLeftmostEmptyColumn(note)
end

function moveUpIntoLeftmostEmptyColumn(src_note)
  local line_above = get_above_line()
  local insertIntoCol
  for k, v in pairs(line_above.note_columns) do
    if is_note_col_blank(v) then
      insertIntoCol = k
      break
    end
  end
  local note_above = line_above.note_columns[insertIntoCol]
  copy_note_values(src_note, note_above)
  clear_note_values(src_note)
  song.selected_line_index = song.selected_line_index - 1
  song.selected_note_column_index = insertIntoCol
end

function moveUpEffect()
  -- todo 
end

function moveUpAllNotesAndEffects()
  -- todo 
end

function moveDown()
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  if cur.line >= get_line_count() then return end
  if song.selected_note_column then moveDownNote() end
  if song.selected_effect_column then moveDownEffect() end
end

function moveDownNote()
  local subcol = get_current_subcol()
  local note = get_current_note()
  local note_below = get_below_note()
  if note.note_value == 121 then return end
  moveDownIntoLeftmostEmptyColumn(note)
end

function moveDownIntoLeftmostEmptyColumn(src_note)
  local line_below = get_below_line()
  local insertIntoCol
  for k, v in pairs(line_below.note_columns) do
    if is_note_col_blank(v) then
      insertIntoCol = k
      break
    end
  end
  local note_below = line_below.note_columns[insertIntoCol]
  copy_note_values(src_note, note_below)
  clear_note_values(src_note)
  song.selected_line_index = song.selected_line_index + 1
  song.selected_note_column_index = insertIntoCol
end

function moveDownEffect()
  -- todo 
end

function moveDownAllNotesAndEffects()
  -- todo 
end

function selectionMoveDown()
  local sp = song.selection_in_pattern
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  local num_lines = song.patterns[cur.pattern].number_of_lines
  print(sp.end_line, num_lines)
  if sp.end_line > num_lines - 1 then
    print('too big')
    return
  end
  song.selection_in_pattern = move_selection(0, 1)
end

function selectionMoveUp()
  local sp = song.selection_in_pattern
  if sp.start_line < 2 then
    print('too small')
    return
  end
  song.selection_in_pattern = move_selection(0, -1)
  print(sp.start_line)
end

function selectionMoveLeft()
  local sp = song.selection_in_pattern
  if sp.start_column < 2 then
    print('too small')

    return
  end
  song.selection_in_pattern = move_selection(-1, 0)
  print(sp.start_line)
end

function selectionMoveRight()
  local sp = song.selection_in_pattern
  print('col count', get_col_count())
  if sp.start_column > get_col_count() then
    print('too large')
    return
  end
  song.selection_in_pattern = move_selection(1, 0)
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
  if not song.selected_note_column then return end
  local subcol = get_current_subcol()
  local note = get_current_note()
  local note_left = get_left_note()
  if note.note_value == 121 then return end
  copy_note_values(note, note_left)
  clear_note_values(note)
end

require 'clone'
require 'constants'

require 'osc_client'
require 'osc_server'

-- init_osc_server()
-- init_osc_client()

