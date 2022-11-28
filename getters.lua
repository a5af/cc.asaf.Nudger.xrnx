  function get_current_subcol()
    local song = renoise.song()
    if not song.selected_note_column then
      return
    end
    return song.selected_sub_column_type
  end
  
  
  function get_current_note()
    local song = renoise.song()
    if not song.selected_note_column then
      return
    end
    local cur_line = song.selected_line_index
    local cur_track = song.selected_track_index
    local cur_col = song.selected_note_column_index
    local cur_pattern = song.selected_pattern_index
    return song.patterns[cur_pattern].tracks[cur_track].lines[cur_line]:note_column(cur_col)
  end

  function get_left_note()
    local song = renoise.song()
    if not song.selected_note_column then
      return
    end
    local cur_line = song.selected_line_index
    local cur_track = song.selected_track_index
    local cur_col = song.selected_note_column_index
    local cur_pattern = song.selected_pattern_index
    if cur_col == 0 then
      if cur_track == 0 then
        return
      end
      cur_track = cur_track -1
    end


  end

  function get_right_note()
    local song = renoise.song()
    if not song.selected_note_column then
      return
    end
    local cur_line = song.selected_line_index
    local cur_track = song.selected_track_index
    local cur_col = song.selected_note_column_index
    local cur_pattern = song.selected_pattern_index
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

  function get_table_size(t)
    local count = 0
    for _, __ in pairs(t) do
        count = count + 1
    end
    return count
  end

  function get_line_count()
    local song = renoise.song()
    if not song.selected_note_column then
      return
    end
    local cur_line = song.selected_line_index
    local cur_track = song.selected_track_index
    local cur_col = song.selected_note_column_index
    local cur_pattern = song.selected_pattern_index
    return get_table_size(song.patterns[cur_pattern].tracks[cur_track].lines)
  end

  function get_track_count()
    local song = renoise.song()
    if not song.selected_note_column then
      return
    end
    local cur_line = song.selected_line_index
    local cur_track = song.selected_track_index
    local cur_col = song.selected_note_column_index
    local cur_pattern = song.selected_pattern_index
    return get_table_size(song.patterns[cur_pattern].tracks)
  end

  function get_col_count()
    local song = renoise.song()
    if not song.selected_note_column then
      return
    end
    local cur_line = song.selected_line_index
    local cur_track = song.selected_track_index
    local cur_col = song.selected_note_column_index
    local cur_pattern = song.selected_pattern_index
    return get_table_size(song.patterns[cur_pattern].tracks[cur_track].lines[cur_line].note_columns)
  end

  function get_below_note()
    local song = renoise.song()
    if not song.selected_note_column then
      return
    end
    local cur_line = song.selected_line_index
    local cur_track = song.selected_track_index
    local cur_col = song.selected_note_column_index
    local cur_pattern = song.selected_pattern_index

    local below_line = song.selected_line_index + 1
    if below_line >= get_line_count() then
      return
    end
    return song.patterns[cur_pattern].tracks[cur_track].lines[below_line]:note_column(cur_col)
  end


  function get_phrase()
    local song = renoise.song()

    local cur_phrase = song.selected_phrase_index
    print(cur_phrase)

  end
  