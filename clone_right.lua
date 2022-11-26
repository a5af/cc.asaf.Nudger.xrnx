function cloneRight()
  local song = renoise.song()
  if not song.selected_note_column then
    return
  end
  local subcol = get_current_subcol()
  local note = get_current_note()
end