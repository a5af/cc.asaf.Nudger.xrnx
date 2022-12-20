-- MOVE UP
renoise.tool():add_keybinding{
  name = "Global:Tools:cc.asaf Move Up",
  invoke = function()
    local s = renoise.song().selection_in_pattern
    if s.start_line ~= s.end_line then return selectionMoveUp() end
    moveUp()
  end
}

renoise.tool():add_menu_entry{
  name = "Main Menu:Tools:cc.asaf:Move Up",
  invoke = function() moveUp() end
}

-- MOVE DOWN
renoise.tool():add_keybinding{
  name = "Global:Tools:cc.asaf Move Down",
  invoke = function()
    local s = renoise.song().selection_in_pattern
    if s.start_line ~= s.end_line then return selectionMoveDown() end
    moveDown()
  end
}

renoise.tool():add_menu_entry{
  name = "Main Menu:Tools:cc.asaf:Move Down",
  invoke = function() moveDown() end
}

-- MOVE LEFT
renoise.tool():add_keybinding{
  name = "Global:Tools:cc.asaf Move Left",
  invoke = function() moveLeft() end
}

renoise.tool():add_menu_entry{
  name = "Main Menu:Tools:cc.asaf:Move Left",
  invoke = function() moveLeft() end
}

-- MOVE RIGHT
renoise.tool():add_keybinding{
  name = "Global:Tools:cc.asaf Move Right",
  invoke = function() moveRight() end
}

renoise.tool():add_menu_entry{
  name = "Main Menu:Tools:cc.asaf:Move Right",
  invoke = function() moveRight() end
}

function moveUp()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local subcol, note, note_above = get_current_subcol(), get_current_note(),
                                   get_above_note()
  if note.note_value == 121 then return end
  copy_note_values(note, note_above)
  clear_row(note)
end

function moveDown()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local subcol = get_current_subcol()
  local note = get_current_note()
  local note_below = get_below_note()

  if note.note_value == 121 then return end

  copy_note_values(note, note_below)
  clear_row(note)

end

function selectionMoveDown()
  local song = renoise.song()
  song.selection_in_pattern = move_selection(1)
end

function move_selection(incr)
  local song = renoise.song()
  local sp = song.selection_in_pattern
  return {
    start_line = sp.start_line + incr,
    end_line = sp.end_line + incr,
    start_track = sp.start_track,
    end_track = sp.end_track
  }
end

function selectionMoveUp()
  local song = renoise.song()
  song.selection_in_pattern = move_selection(-1)
end

function moveRight()
  local song = renoise.song()
  if not song.selected_note_column then return end

  local subcol = get_current_subcol()
  local note = get_current_note()
  local note_right = get_right_note()

  if note.note_value == 121 then return end

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

function moveLeft()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local subcol = get_current_subcol()
  local note = get_current_note()
  local note_left = get_left_note()

  if note.note_value == 121 then return end

  note_left.note_value = note.note_value
  note.note_value = 121

  note_left.instrument_value = note.instrument_value
  note_left.volume_value = note.volume_value
  note_left.panning_value = note.panning_value
  note_left.delay_value = note.delay_value

  note.instrument_value = 255
  note.volume_value = 255
  note.panning_value = 255
  note.delay_value = 0
end
