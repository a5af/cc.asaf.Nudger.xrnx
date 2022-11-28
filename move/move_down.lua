function moveDown()
  local song = renoise.song()
  if not song.selected_note_column then
    return
  end
  local subcol = get_current_subcol()
  local note = get_current_note()
  local note_below = get_below_note()

  print(note_below)

-- MOVE DOWN NOTE
  if subcol == 1 then
    if note ~= nil then
      note_below.note_value = 11
    else 
      note_below.note_value = 22
    end
  end


  
  if note_below ~= nil then
    
  else

  end
end