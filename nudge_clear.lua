--
-- NUDGE CLEAR
--

function nudgeClear() 
   
    local song = renoise.song()
    if not song.selected_note_column then
      return
    end
    local subcol = get_current_subcol()
    local note = get_current_note()
      
    -- NUDGE CLEAR NOTE
    if subcol == 1 then
      note.note_value = 121 -- make it blank
    end
  
    -- NUDGE CLEAR INST
    if subcol == 2 then
      note.instrument_value = 255
    end
  
    -- NUDGE CLEAR VOL
    if subcol == 3 then
      note.volume_value = 255 -- make it blank
    end

    -- NUDGE CLEAR PAN
    if subcol == 4 then
      note.panning_value = 255 -- make it blank
    end
  
    -- NUDGE CLEAR DLY
    if subcol == 5 then
      note.delay_value = 0
    end
  
    -- NUDGE CLEAR FX NUMBER
    if subcol == 6 then
      print("clear fx")
    end

    -- NUDGE CLEAR FX AMOUNT
    if subcol == 7 then
      note.effect_amount_value = 255
    end
  end
