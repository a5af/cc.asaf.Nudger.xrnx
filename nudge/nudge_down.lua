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

  if subcol == SUBCOL.NOTE then
    if note ~= nil then
      if note.note_value > 1 then
        note.note_value = (note.note_value - 1)
      else
        note.note_value = 121
      end
    end
  end

  if subcol == SUBCOL.INST then
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
