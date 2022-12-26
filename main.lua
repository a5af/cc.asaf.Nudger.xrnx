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
    col = song.selected_note_column_index,
    pattern = song.selected_pattern_index,
    inst = song.selected_instrument_index,
    phrase = song.selected_phrase_index
  }
end

function get_current_note()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  return
    song.patterns[cur.pattern].tracks[cur.track].lines[cur.line]:note_column(
      cur.col)
end

function get_left_note()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  if cur.col == 0 then
    if cur.track == 0 then return end
    cur.track = cur.track - 1
  else
    cur.col = cur.col - 1
  end
  return
    song.patterns[cur.pattern].tracks[cur.track].lines[cur.line]:note_column(
      cur.col)
end

function get_right_note()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local cur = get_cur_line_track_col_pattern_inst_phrase()

  if cur.col == get_col_count() - 1 then
    if cur.track == get_track_count() - 1 then return end
    cur.track = cur.track - 1
  else
    cur.col = cur.col - 1
  end
  return
    song.patterns[cur.pattern].tracks[cur.track].lines[cur.line]:note_column(
      cur.col)

end

function get_above_note()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local cur = get_cur_line_track_col_pattern_inst_phrase()
  local above_line = song.selected_line_index - 1
  if above_line < 0 then return end
  return
    song.patterns[cur.pattern].tracks[cur.track].lines[above_line]:note_column(
      cur.col)
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
      cur.col)
end

function get_phrase()
  local song = renoise.song()

  local cur = get_cur_line_track_col_pattern_inst_phrase()

  -- for (k, v) in 
  -- renoise.song().patterns[].tracks[].lines[].effect_columns[].is_selected
  -- renoise.song().patterns[].tracks[].lines[].note_columns[].is_selected
  -- print(Y)

  -- oprint(cur_phrase)
  print('cur phrase', cur.phrase)
  print('cur inst', cur.inst)
  local phrase = song.instruments[cur.inst]:phrase(cur.phrase)

  print('phrase editor visibile',
        song.instruments[cur.inst].phrase_editor_visible)
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
  if not song.selected_note_column then return end
  local subcol = get_current_subcol()
  local note = get_current_note()

  if subcol == SUBCOL.NOTE then
    -- Max is 119 B-9
    if note ~= nil then
      if note.note_value < 121 then
        note.note_value = (note.note_value + 1)
      else
        note.note_value = 48 -- C-4
      end
    end
  end

  -- NUDGE UP INST
  if subcol == 2 then
    if note.instrument_value < 255 then
      note.instrument_value = note.instrument_value + 1
    else
      note.instrument_value = 0
    end
  end

  -- NUDGE UP VOL
  if subcol == 3 then
    if note.volume_value < 127 then
      note.volume_value = note.volume_value + 1
    elseif note.volume_value == 0x7F then
      note.volume_value = 255 -- make it blank
    elseif note.volume_value == 255 then -- is it blank?
      note.volume_value = 0
    else
      -- EFFECT COMMAND
      local command = note.volume_string[1]
      local value = tonumber(note.volume_string[2])

      if value ~= nil and value < 16 then
        value = value + 1
        note.volume_string = command .. DEC_HEX(value)
      else
        note.volume_string = command .. "0"
      end
    end
  end

  -- NUDGE UP PAN
  if subcol == 4 then
    if note.panning_value < 127 then
      note.panning_value = note.panning_value + 1
    elseif note.panning_value == 0x7F then
      note.panning_value = 255 -- make it blank
    elseif note.panning_value == 255 then -- is it blank?
      note.panning_value = 0
    else
      -- EFFECT COMMAND
      local command = note.panning_string[1]
      local value = tonumber(note.panning_string[2])

      if value ~= nil and value < 16 then
        value = value + 1
        note.panning_string = command .. DEC_HEX(value)
      else
        note.panning_string = command .. "0"
      end
    end
  end

  -- NUDGE UP DLY
  if subcol == 5 then
    if note.delay_value < 0xFF then
      note.delay_value = note.delay_value + 1
    else
      note.delay_value = 0
    end
  end

  -- NUDGE UP FX NUMBER
  if subcol == 6 then
    note.effect_number_value = get_next_effect_number(note.effect_number_value)
  end

  -- NUDGE UP FX AMOUNT
  if subcol == 7 then
    if note.effect_amount_value < 0xFF then
      note.effect_amount_value = note.effect_amount_value + 1
    else
      note.effect_amount_value = 0
    end
  end
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
  local song = renoise.song()
  get_phrase()

  if not song.selected_note_column then return end

  local subcol = get_current_subcol()
  local note = get_current_note()

  if subcol == renoise.Song.SUB_COLUMN_NOTE then
    if note ~= nil then
      if note.note_value > 1 then
        note.note_value = (note.note_value - 1)
      else
        note.note_value = 121
      end
    end
  end

  if subcol == renoise.Song.SUB_COLUMN_INSTRUMENT then
    if note.instrument_value < 255 and note.instrument_value > 0 then
      note.instrument_value = note.instrument_value - 1
    elseif note.instrument_value == 255 then -- blank
      note.instrument_value = 254 -- wrap around
    else
      note.instrument_value = 255 -- make it blank
    end
  end

  if subcol == SUBCOL.VOL then
    if note.volume_value == 0xFF then -- is it blank?
      note.volume_value = 0x7F
    elseif note.volume_value == 0 then
      note.volume_value = 0xFF -- make it blank
    elseif note.volume_value > 0 and note.volume_value < 128 then
      note.volume_value = note.volume_value - 1
    else

      -- EFFECT COMMAND
      local command = note.volume_string[1]
      local value = tonumber(note.volume_string[2])

      if value ~= nil and value > 0 then
        value = value - 1
        note.volume_string = command .. DEC_HEX(value)
      else
        note.volume_string = command .. "F"
      end
    end
  end

  if subcol == SUBCOL.PAN then
    if note.panning_value == 0xFF then -- is it blank?
      note.panning_value = 0x7F
    elseif note.panning_value == 0 then
      note.panning_value = 0xFF -- make it blank
    elseif note.panning_value > 0 and note.panning_value < 128 then
      note.panning_value = note.panning_value - 1
    else

      -- EFFECT COMMAND
      local command = note.panning_string[1]
      local value = tonumber(note.panning_string[2])

      if value ~= nil and value > 0 then
        value = value - 1
        if value == 0 then
          note.panning_string = command .. "0"
        else
          note.panning_string = command .. DEC_HEX(value)
        end
      else
        note.panning_string = command .. "F"
      end
    end

  end

  if subcol == SUBCOL.DLY then
    if note.delay_value > 0 then
      note.delay_value = note.delay_value - 1
    else
      note.delay_value = 0xFF
    end
  end

  if subcol == SUBCOL.FX_NUM then
    note.effect_number_value = get_next_effect_number(note.effect_number_value)
  end

  if subcol == SUBCOL.FX_AMT then
    if note.effect_amount_value > 0 then
      note.effect_amount_value = note.effect_amount_value - 1
    else
      note.effect_amount_value = 0xFF
    end
  end
end

require 'clear'
require 'move'
require 'clone'
require 'constants'

require 'osc_client'
require 'osc_server'

-- init_osc_server()
-- init_osc_client()

