require 'utils'
require 'getters'
require 'nudgers'

renoise.tool():add_keybinding {
  name = "Global:Tools:Nudge Up",
  invoke = function()
    nudgeUp()
  end
}

renoise.tool():add_keybinding {
  name = "Global:Tools:Nudge Down",
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
