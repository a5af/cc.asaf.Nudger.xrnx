--get initial note value for GUI
function get_initial_note_value(cur_note)
    if cur_note ~= nil then
        return (cur_note.note_value + 1)
    else
        return 1
    end
  end
  
    --get initial delay value for GUI
  function get_initial_delay_value(cur_note)
      if cur_note ~= nil then
          return (cur_note.delay_value)
      else
          return 1
      end
  end
  
  function get_current_subcol()
    local song = renoise.song()
  
    --are we in a note column
    if not song.selected_note_column then
        return
    end
  
    return song.selected_sub_column_type
  end
  
  function get_current_note()
    local song = renoise.song()
  
    --are we in a note column
    if not song.selected_note_column then
        return
    end
  
    --get current note properties
    local cur_line = song.selected_line_index
    local cur_track = song.selected_track_index
    local cur_col = song.selected_note_column_index
    local cur_pattern = song.selected_pattern_index
  
    return song.patterns[cur_pattern].tracks[cur_track].lines[cur_line]:note_column(cur_col)
  end
  