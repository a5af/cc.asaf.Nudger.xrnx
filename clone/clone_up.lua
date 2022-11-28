function cloneUp()
  local song = renoise.song()
  if not song.selected_note_column then
    return
  end
  local subcol = get_current_subcol()
  local note = get_current_note()
  -- NOTE
  if subcol == 1 then
      
  end

  -- INST
  if subcol == 2 then
    note.instrument_value = 255
  end

  -- VOL
  if subcol == 3 then
    note.volume_value = 255
  end

  -- PAN
  if subcol == 4 then
    note.panning_value = 255
  end

  -- DLY
  if subcol == 5 then
    note.delay_value = 0
  end

  -- FX NUMBER
  if subcol == 6 then
    print("clear fx")
  end

  -- FX AMOUNT
  if subcol == 7 then
    note.effect_amount_value = 255
  end
end