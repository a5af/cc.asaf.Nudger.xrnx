-- NUDGE CLEAR
renoise.tool():add_keybinding{
  name = "Global:Tools:cc.asaf Clear",
  invoke = function() clear() end
}

renoise.tool():add_menu_entry{
  name = "Main Menu:Tools:cc.asaf:Clear",
  invoke = function() clear() end
}

function clear()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local subcol = get_current_subcol()
  local note = get_current_note()
  clear_row(note)
end
