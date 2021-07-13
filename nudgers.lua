--
-- NUDGE UP
--

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
      print("up inst")
    end
  
    -- NUDGE UP VOL
    if subcol == 3 then
      if note.volume_value < 127 then
        note.volume_value = note.volume_value + 1
      else 
        note.volume_value = 1
      end
    end
  
    -- NUDGE UP PAN
    if subcol == 4 then
      if note.panning_value < 127 then
        note.panning_value = note.panning_value + 1
      end
    end
  
    -- NUDGE UP DLY
    if subcol == 5 then
      if note.delay_value < 127 then
        note.delay_value = note.delay_value + 1
      end
    end
  
    -- NUDGE UP FX
    if subcol == 6 then
      print("up fx")
    end
  end
  
--
-- NUDGE DOWN
--
  function nudgeDown() 
    local song = renoise.song()
    if not song.selected_note_column then
      return
    end
    
    local subcol = get_current_subcol()
    local note = get_current_note()

    -- NUDGE DOWN NOTE
    if subcol == 1 then
      if note ~= nil then
        if note.note_value > 1 then
            note.note_value = (note.note_value - 1)
        else
            note.note_value = 121
        end
      end
    end
  
    -- NUDGE DOWN INSTRUMENT
    if subcol == 2 then
      print("down inst")
    end
  
    -- NUDGE DOWN VOL
    if subcol == 3 then
    
      if (note.volume_value > 127) then
        print('effect command')
        local as_hex = DEC_HEX(note.volume_value)
        return
      end
    
      if note.volume_value > 0 then
        note.volume_value = note.volume_value - 1
      end
    end
  
    -- NUDGE DOWN PAN
    if subcol == 4 then
      if note.panning_value > 0 then
        note.panning_value = note.panning_value - 1
      end
    end
  
    -- NUDGE DOWN DLY
    if subcol == 5 then
      if note.delay_value > 0 then
        note.delay_value = note.delay_value - 1
      end

    end
  
    -- NUDGE DOWN FX
    if subcol == 6 then
      print("down fx")
    end
  end