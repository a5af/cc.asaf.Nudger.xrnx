-- NUDGE CLEAR
renoise.tool():add_keybinding {
  name = "Global:Tools:cc.asaf Clear",
  invoke = function()
    clear()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:cc.asaf:Clear",
  invoke = function()
    clear()
  end  
}

function clear() 
   
    local song = renoise.song()
    if not song.selected_note_column then
      return
    end
    local subcol = get_current_subcol()
    local note = get_current_note()
      
  
    note.note_value = 121 -- make it blank
    note.instrument_value = 255
    note.volume_value = 255 -- make it blank
    note.panning_value = 255 -- make it blank
    note.delay_value = 0
    note.effect_number_value = 0
    note.effect_amount_value = 0
  end
