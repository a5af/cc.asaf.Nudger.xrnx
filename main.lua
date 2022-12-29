_AUTO_RELOAD_DEBUG = function() print("tools reloaded") end

require 'utils'

function get_current_subcol()
  local song = renoise.song()
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
  local song = renoise.song()
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  return
    song.patterns[cur.pattern].tracks[cur.track].lines[cur.line]:note_column(
      cur.note_col)
end

function get_current_selected()
  local song = renoise.song()
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
  local song = renoise.song()
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
  local song = renoise.song()
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
  local song = renoise.song()
  if not song.selected_note_column then return end
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  local above_line = song.selected_line_index - 1
  if above_line < 0 then return end
  return
    song.patterns[cur.pattern].tracks[cur.track].lines[above_line]:note_column(
      cur.note_col)
end

function get_line_count()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  return get_table_size(song.patterns[cur.pattern].tracks[cur.track].lines)
end

function get_track_count()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  return get_table_size(song.patterns[cur.pattern].tracks)
end

function get_col_count()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  return get_table_size(
           song.patterns[cur.pattern].tracks[cur.track].lines[cur.line]
             .note_columns)
end

function get_below_note()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local cur = get_cur_line_track_col_pattern_inst_phrase()

  local below_line = song.selected_line_index + 1
  if below_line >= get_line_count() then return end
  return
    song.patterns[cur.pattern].tracks[cur.track].lines[below_line]:note_column(
      cur.note_col)
end

function get_phrase()
  local song = renoise.song()

  -- local cur = get_cur_line_track_col_pattern_inst_phrase()

  -- for (k, v) in 
  -- renoise.song().patterns[].tracks[].lines[].effect_columns[].is_selected
  -- renoise.song().patterns[].tracks[].lines[].note_columns[].is_selected
  -- print(Y)

  -- oprint(cur_phrase)
  -- print('cur phrase', cur.phrase)
  -- print('cur inst', cur.inst)
  -- local phrase = song.instruments[cur.inst]:phrase(cur.phrase)

  -- print('phrase editor visibile',
  --       song.instruments[cur.inst].phrase_editor_visible)
  -- oprint(phrase)
  -- song.tracks[cur_track].panning_column_visible_observable:add_notifier(
  --   function() print('dd') end)

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

  local song = renoise.song()
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

function isNoteOrEffectCol()
  local song = renoise.song()
  return song.selected_note_column ~= 0 or song.selected_effect_column ~= 0
end

function nudgeDown()
  local song = renoise.song()
  get_phrase()

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

renoise.tool():add_menu_entry{
  name = "Main Menu:Tools:cc.asaf:Clear",
  invoke = function() clear() end
}

function clear()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local subcol = get_current_subcol()
  local note = get_current_note()
  clear_row(note)
end

-- MOVE UP
renoise.tool():add_keybinding{
  name = "Global:Tools:cc.asaf Move Up",
  invoke = function()
    local s = renoise.song().selection_in_pattern
    if s.start_line ~= s.end_line then return selectionMoveUp() end
    moveUp()
  end
}

renoise.tool():add_menu_entry{
  name = "Main Menu:Tools:cc.asaf:Move Up",
  invoke = function() moveUp() end
}

-- MOVE DOWN
renoise.tool():add_keybinding{
  name = "Global:Tools:cc.asaf Move Down",
  invoke = function()
    local s = renoise.song().selection_in_pattern
    if s.start_line ~= s.end_line then return selectionMoveDown() end
    moveDown()
  end
}

renoise.tool():add_menu_entry{
  name = "Main Menu:Tools:cc.asaf:Move Down",
  invoke = function() moveDown() end
}

-- MOVE LEFT
renoise.tool():add_keybinding{
  name = "Global:Tools:cc.asaf Move Left",
  invoke = function() moveLeft() end
}

renoise.tool():add_menu_entry{
  name = "Main Menu:Tools:cc.asaf:Move Left",
  invoke = function() moveLeft() end
}

-- MOVE RIGHT
renoise.tool():add_keybinding{
  name = "Global:Tools:cc.asaf Move Right",
  invoke = function() moveRight() end
}

renoise.tool():add_menu_entry{
  name = "Main Menu:Tools:cc.asaf:Move Right",
  invoke = function() moveRight() end
}

function moveUp()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local subcol, note, note_above = get_current_subcol(), get_current_note(),
                                   get_above_note()
  if note.note_value == 121 then return end
  copy_note_values(note, note_above)
  clear_row(note)
  song.selected_line_index = song.selected_line_index - 1
end

function moveDown()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local subcol = get_current_subcol()
  local note = get_current_note()
  local note_below = get_below_note()

  if note.note_value == 121 then return end

  copy_note_values(note, note_below)
  clear_row(note)
  song.selected_line_index = song.selected_line_index + 1

end

function selectionMoveDown()
  local song = renoise.song()
  song.selection_in_pattern = move_selection(1)
end

function move_selection(incr)
  local song = renoise.song()
  local sp = song.selection_in_pattern
  return {
    start_line = sp.start_line + incr,
    end_line = sp.end_line + incr,
    start_track = sp.start_track,
    end_track = sp.end_track
  }
end

function selectionMoveUp()
  local song = renoise.song()
  song.selection_in_pattern = move_selection(-1)

  local sp = song.selection_in_pattern
  local cur = get_cur_line_track_col_pattern_inst_phrase()

  local first_line =
    song.patterns[cur.pattern].tracks[cur.track].lines[sp.start_line]

  for l in range(sp.start_line + 1, sp.end_line) do
    song.patterns[cur.pattern].tracks[cur.track].lines[sp.start_line] =
      song.patterns[cur.pattern].tracks[cur.track].lines[l]
  end

  song.patterns[cur.pattern].tracks[cur.track].lines[sp.end_line] =
    song.patterns[cur.pattern].tracks[cur.track].lines[sp.end_line - 1]

end

function moveRight()

  local song = renoise.song()
  if not song.selected_note_column then return end

  local subcol = get_current_subcol()
  local note = get_current_note()
  local note_right = get_right_note()

  if note.note_value == 121 then return end
  copy_note_values(note, note_right)
  clear_row(note)

end

function moveLeft()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local subcol = get_current_subcol()
  local note = get_current_note()
  local note_left = get_left_note()

  if note.note_value == 121 then return end

  copy_note_values(note, note_left)
  clear_row(note)
end

require 'clone'
require 'constants'

require 'osc_client'
require 'osc_server'

-- init_osc_server()
-- init_osc_client()

