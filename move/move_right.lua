function moveRight()
  local song = renoise.song()
  if not song.selected_note_column then
    return
  end
  
  local subcol = get_current_subcol()
  local note = get_current_note()
  local note_right = get_right_note()

  if note.note_value == 121 then
    return
  end

  note_right.note_value = note.note_value
  note.note_value = 121

  note_right.instrument_value = note.instrument_value
  note_right.volume_value = note.volume_value
  note_right.panning_value = note.panning_value
  note_right.delay_value = note.delay_value

  note.instrument_value = 255
  note.volume_value = 255
  note.panning_value = 255
  note.delay_value = 0

end