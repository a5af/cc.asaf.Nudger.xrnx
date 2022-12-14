function moveUp()
  local song = renoise.song()
  if not song.selected_note_column then
    return
  end
  local subcol, note, note_above = get_current_subcol(), get_current_note(), get_above_note()

  if note.note_value == 121 then
    return
  end

  note_above.note_value = note.note_value
  note_above.instrument_value = note.instrument_value
  note_above.volume_value = note.volume_value
  note_above.panning_value = note.panning_value
  note_above.delay_value = note.delay_value
  note_above.effect_number_value = note.effect_number_value
  note_above.effect_amount_value = note.effect_amount_value

  note.note_value = 121
  note.instrument_value = 255
  note.volume_value = 255
  note.panning_value = 255
  note.delay_value = 0
  note.effect_number_value = 0
  note.effect_amount_value = 0
end