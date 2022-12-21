-- CLONE UP
renoise.tool():add_keybinding{
  name = "Global:Tools:cc.asaf Clone Up",
  invoke = function() cloneUp() end
}

renoise.tool():add_menu_entry{
  name = "Main Menu:Tools:cc.asaf:Clone Up",
  invoke = function() cloneUp() end
}

-- CLONE DOWN
renoise.tool():add_keybinding{
  name = "Global:Tools:cc.asaf Clone Down",
  invoke = function() cloneDown() end
}

renoise.tool():add_menu_entry{
  name = "Main Menu:Tools:cc.asaf:Clone Down",
  invoke = function() cloneDown() end
}

-- CLONE LEFT
renoise.tool():add_keybinding{
  name = "Global:Tools:cc.asaf Clone Left",
  invoke = function() cloneLeft() end
}

renoise.tool():add_menu_entry{
  name = "Main Menu:Tools:cc.asaf:Clone Left",
  invoke = function() cloneLeft() end
}

-- CLONE RIGHT
renoise.tool():add_keybinding{
  name = "Global:Tools:cc.asaf Clone Right",
  invoke = function() cloneRight() end
}

renoise.tool():add_menu_entry{
  name = "Main Menu:Tools:cc.asaf:Clone Right",
  invoke = function() cloneRight() end
}

function cloneUp()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local subcol, note, note_above = get_current_subcol(), get_current_note(),
                                   get_above_note()

  if note.note_value == 121 then return end

  copy_note_values(note, note_above)
  song.selected_line_index = song.selected_line_index - 1
end

function cloneRight()
  -- to do
end

function cloneLeft()
  -- to do
end

function cloneDown()
  local song = renoise.song()
  if not song.selected_note_column then return end

  local subcol = get_current_subcol()
  local note = get_current_note()
  local note_below = get_below_note()

  if note.note_value == 121 then return end
  copy_note_values(note, note_below)

  song.selected_line_index = song.selected_line_index + 1

end
