-- CLONE UP
renoise.tool():add_keybinding {
  name = "Global:Tools:cc.asaf Clone Up",
  invoke = function()
    cloneUp()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:cc.asaf:Clone Up",
  invoke = function()
    cloneUp()
  end  
}

-- CLONE DOWN
renoise.tool():add_keybinding {
  name = "Global:Tools:cc.asaf Clone Down",
  invoke = function()
    cloneDown()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:cc.asaf:Clone Down",
  invoke = function()
    cloneDown()
  end  
}

-- CLONE LEFT
renoise.tool():add_keybinding {
  name = "Global:Tools:cc.asaf Clone Left",
  invoke = function()
    cloneLeft()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:cc.asaf:Clone Left",
  invoke = function()
    cloneLeft()
  end  
}

-- CLONE RIGHT
renoise.tool():add_keybinding {
  name = "Global:Tools:cc.asaf Clone Right",
  invoke = function()
    cloneRight()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:cc.asaf:Clone Right",
  invoke = function()
    cloneRight()
  end  
}

function cloneUp()
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
end

function cloneRight()
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

function cloneLeft()
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

function cloneDown()
  local song = renoise.song()
  if not song.selected_note_column then
    print('not selected')
    return
  end
  
  print('selected', song.selected_phrase_index)

  local subcol = get_current_subcol()
  local note = get_current_note()
  local note_below = get_below_note()

  if note.note_value == 121 then
    return
  end
  
  note_below.note_value = note.note_value
  note_below.instrument_value = note.instrument_value
  note_below.volume_value = note.volume_value
  note_below.panning_value = note.panning_value
  note_below.delay_value = note.delay_value
  note_below.effect_number_value = note.effect_number_value
  note_below.effect_amount_value = note.effect_amount_value
  
end