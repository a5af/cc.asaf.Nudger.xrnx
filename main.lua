require 'utils'
require 'getters'
require 'nudge_up'
require 'nudge_down'
require 'enums'

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

-- NUDGE DOWN
renoise.tool():add_keybinding {
  name = "Global:Tools:cc.asaf Nudge Down",
  invoke = function()
    nudgeDown()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:cc.asaf:Nudge Down",
  invoke = function()
    nudgeDown()
  end  
}

-------------------------------------------------------------------------------------------
--Main
-------------------------------------------------------------------------------------------
function main()
    
    local song = renoise.song()

    --get current note properties
    local cur_line = song.selected_line_index
    local cur_track = song.selected_track_index
    local cur_col = song.selected_note_column_index

    local cur_note = get_current_note()


end
