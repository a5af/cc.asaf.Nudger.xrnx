--
-- NUDGE UP
--

function nudgeUp() 
    local subcol = get_current_subcol()
    
    -- NUDGE UP NOTE
    if subcol == 1 then
      local cur_note = get_current_note()
      --Max is 119 B-9
      if cur_note ~= nil then
        if cur_note.note_value < 121 then
          cur_note.note_value = (cur_note.note_value + 1)
          --value inverted and adjusted as note_table reversed
        else
          cur_note.note_value = 48
        end
      end
    end
  
    -- NUDGE UP INST
    if subcol == 2 then
      print("up inst")
    end
  
    -- NUDGE UP VOL
    if subcol == 3 then
      local song = renoise.song()
      if not song.selected_note_column then
        return
      end
      local note = get_current_note()
      if note.volume_value < 127 then
        note.volume_value = note.volume_value + 1
      else 
        note.volume_value = 1
      end
    end
  
    -- NUDGE UP PAN
    if subcol == 4 then
      local song = renoise.song()
      if not song.selected_note_column then
        return
      end
      local note = get_current_note()
      if note.panning_value < 127 then
        note.panning_value = note.panning_value + 1
      end
    end
  
    -- NUDGE UP DLY
    if subcol == 5 then
      local song = renoise.song()
      if not song.selected_note_column then
        return
      end
      local note = get_current_note()
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
    local subcol = get_current_subcol()
    
    -- NUDGE DOWN NOTE
    if subcol == 1 then
      local cur_note = get_current_note()
      --Max is 119 B-9
      if cur_note ~= nil then
        if cur_note.note_value > 1 then
            cur_note.note_value = (cur_note.note_value - 1)
        else
            cur_note.note_value = 121
        end
      end
    end
  
    -- NUDGE DOWN INSTRUMENT
    if subcol == 2 then
      print("down inst")
    end
  
    -- NUDGE DOWN VOL
    if subcol == 3 then
      local song = renoise.song()
      if not song.selected_note_column then
          return
      end
      local note = get_current_note()
    
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
      local song = renoise.song()
      if not song.selected_note_column then
          return
      end
      
      local note = get_current_note()

      if note.panning_value > 0 then
        note.panning_value = note.panning_value - 1
      end
    end
  
    -- NUDGE DOWN DLY
    if subcol == 5 then
      
        local song = renoise.song()
      if not song.selected_note_column then
          return
      end

      local note = get_current_note()
      if note.delay_value > 0 then
        note.delay_value = note.delay_value - 1
      end

    end
  
    -- NUDGE DOWN FX
    if subcol == 6 then
      print("down fx")
    end
  end