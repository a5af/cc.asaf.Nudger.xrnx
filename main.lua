require 'utils'
require 'getters'
require 'nudge/nudge'
require 'move/move'
require 'clone/clone'
require 'enums'

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
