function moveLeft()
  local song = renoise.song()
  if not song.selected_note_column then
    return
  end
  local subcol = get_current_subcol()
  local note = get_current_note()

  local col_cnt = get_col_count()
  print("col_cnt", col_cnt)
  print("cur_subcol", subcol)

  if note.note_value == 121 then
    return
  end

  note_below.note_value = note.note_value
  note.note_value = 121

  note_below.instrument_value = note.instrument_value
  note_below.volume_value = note.volume_value
  note_below.panning_value = note.panning_value
  note_below.delay_value = note.delay_value

  note.instrument_value = 255
  note.volume_value = 255
  note.panning_value = 255
  note.delay_value = 0
end