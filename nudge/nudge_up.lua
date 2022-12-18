-- NUDGE UP
renoise.tool():add_keybinding {
  name = "Global:Tools:cc.asaf Nudge Up",
  invoke = function()
    nudgeUp()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:cc.asaf:Nudge Up",
  invoke = function()
    nudgeUp()
  end  
}
function nudgeUp() 
   
    local song = renoise.song()
    if not song.selected_note_column then
      return
    end
    local subcol = get_current_subcol()
    local note = get_current_note()
      
    -- NUDGE UP NOTE
    if subcol == 1 then
      --Max is 119 B-9
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
          note.volume_string = command..DEC_HEX(value)
        else
          note.volume_string = command.."0"
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
          note.panning_string = command..DEC_HEX(value)
        else
          note.panning_string = command.."0"
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
