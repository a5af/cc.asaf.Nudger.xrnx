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

  function get_above_note()
    local song = renoise.song()
    if not song.selected_note_column then
      return
    end
    local cur_line = song.selected_line_index
    local cur_track = song.selected_track_index
    local cur_col = song.selected_note_column_index
    local cur_pattern = song.selected_pattern_index

    local above_line = song.selected_line_index - 1
    if above_line < 0 then
      return
    end

    return song.patterns[cur_pattern].tracks[cur_track].lines[above_line]:note_column(cur_col)
  end

  function get_below_note()
    local cur_line = song.selected_line_index
    local cur_track = song.selected_track_index
    local cur_col = song.selected_note_column_index
    local cur_pattern = song.selected_pattern_index

    local below_line = song.selected_line_index + 1
    if below_line > 0 then
      return
    end
    return song.patterns[cur_pattern].tracks[cur_track].lines[below_line]:note_column(cur_col)
  end


  function get_phrase()
    local song = renoise.song()

    local cur_phrase = song.selected_phrase_index
    print(cur_phrase)

  end
  