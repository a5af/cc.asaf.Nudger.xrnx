function DEC_HEX(IN)
  local B,K,OUT,I,D=16,"0123456789ABCDEF","",0
  while IN>0 do
      I=I+1
      IN,D=math.floor(IN/B),math.mod(IN,B)+1
      OUT=string.sub(K,D,D)..OUT
  end
  return OUT
end

renoise.tool():add_keybinding {
    name = "Global:Tools:Note Properties",
    invoke = function()
        main()
    end
}

renoise.tool():add_keybinding {
  name = "Global:Tools:Nudge Up",
  invoke = function()
      nudgeUp()
  end
}

renoise.tool():add_keybinding {
  name = "Global:Tools:Nudge Down",
  invoke = function()
      nudgeDown()
  end
}

function nudgeUp() 
  local subcol = get_current_subcol()
  if subcol == 1 then
    increaseST(nil)()
  end
  if subcol == 2 then
    increaseInst()
  end
  if subcol == 3 then
    increaseVol()
  end
  if subcol == 4 then
    increasePan()
  end
  if subcol == 5 then
    increaseDly()
  end
  if subcol == 6 then
    increaseFx()
  end
end

function nudgeDown() 
  local subcol = get_current_subcol()
  if subcol == 1 then
    decreaseST(nil)()
  end
  if subcol == 2 then
    decreaseInst()
  end
  if subcol == 3 then
    decreaseVol()
  end
  if subcol == 4 then
    decreasePan()
  end
  if subcol == 5 then
    decreaseDly()
  end
  if subcol == 6 then
    decreaseFx()
  end
end

local updating_gui = false
local not_called_by_nudge = true
local my_dialog = nil

local note_strings = {
    "C-",
    "C#",
    "D-",
    "D#",
    "E-",
    "F-",
    "F#",
    "G-",
    "G#",
    "A-",
    "A#",
    "B-"
}
--create and populate note_table containing all the note strings available in renoise
local note_table = {"---"}
local counter = 1 --start after "---" empty note

for octave = 1, 10 do
    for notes = 1, 12 do
        note_table[counter] = note_strings[notes] .. tostring(octave - 1)
        counter = counter + 1
    end
end

--add NOTE-OFF and empty note values to osition 121 and 122 in table
table.insert(note_table, "OFF")
table.insert(note_table, "---")

--create a reversed note table for the dropdown
local note_table_reversed = {}
for i = #note_table, 1, -1 do
    table.insert(note_table_reversed, note_table[i])
end

function convert_note_value_forward_reverse_table(value)
    if value == 1 then
        value = 122
        return value
    end
end

  --get initial note value for GUI
function get_initial_note_value(cur_note)
  if cur_note ~= nil then
      return (cur_note.note_value + 1)
  else
      return 1
    end
end

  --get initial delay value for GUI
function get_initial_delay_value(cur_note)
    if cur_note ~= nil then
        return (cur_note.delay_value)
    else
        return 1
    end
end

function get_current_subcol()
  local song = renoise.song()

  --are we in a note column
  if not song.selected_note_column then
      return
  end

  return song.selected_sub_column_type
end

function get_current_note()
  local song = renoise.song()

  --are we in a note column
  if not song.selected_note_column then
      return
  end

  --get current note properties
  local cur_line = song.selected_line_index
  local cur_track = song.selected_track_index
  local cur_col = song.selected_note_column_index
  local cur_pattern = song.selected_pattern_index

  return song.patterns[cur_pattern].tracks[cur_track].lines[cur_line]:note_column(cur_col)
end

-- PITCH
function decreaseST()
  local cur_note = get_current_note()
  --Max is 119 B-9
  return function()
    if cur_note ~= nil then
      if cur_note.note_value > 1 then
          cur_note.note_value = (cur_note.note_value - 1)
      else
          cur_note.note_value = 121
      end
    end
  end
end

function increaseST()
  local cur_note = get_current_note()
  --Max is 119 B-9
  return function()
    if cur_note ~= nil then
      if cur_note.note_value < 121 then
        cur_note.note_value = (cur_note.note_value + 1)
        --value inverted and adjusted as note_table reversed
      else
        cur_note.note_value = 1
      end
    end
  end
end

-- INSTRUMENT
function decreaseInst()
  print("decrease inst")
end

function increaseInst()
  print("increase inst")
end

-- VOLUME
function decreaseVol()
  local song = renoise.song()
  if not song.selected_note_column then
      return
  end
  local note = get_current_note()

  print(note.volume_value)
  if (note.volume_value > 127) then
    print('effect command')
    local as_hex = DEC_HEX(note.volume_value)


    return
  end

  if note.volume_value > 0 then
    note.volume_value = note.volume_value - 1
  end
end

function increaseVol()
  local song = renoise.song()
  if not song.selected_note_column then
      return
  end
  local note = get_current_note()
  if note.volume_value < 127 then
    note.volume_value = note.volume_value + 1
  else 
    note.volume_value = 1
  end
end

-- PAN
function decreasePan()
  local song = renoise.song()
  if not song.selected_note_column then
      return
  end
  local note = get_current_note()
  if note.panning_value > 0 then
    note.panning_value = note.panning_value - 1
  end
end

function increasePan()
  local song = renoise.song()
  if not song.selected_note_column then
      return
  end
  local note = get_current_note()
  if note.panning_value < 127 then
    note.panning_value = note.panning_value + 1
  end
end

-- DELAY
function decreaseDly()
  local song = renoise.song()
  if not song.selected_note_column then
      return
  end
  local note = get_current_note()
  if note.delay_value > 0 then
    note.delay_value = note.delay_value - 1
  end
end

function increaseDly()
  local song = renoise.song()
  if not song.selected_note_column then
      return
  end
  local note = get_current_note()
  if note.delay_value < 127 then
    note.delay_value = note.delay_value + 1
  end
end

-- FX
function increaseFx()
  print("increase fx")
end

function decreaseFx()
  print("decrease fx")
end
-------------------------------------------------------------------------------------------
--Main
-------------------------------------------------------------------------------------------
function main()
    --turns keybinding into toggle for GUI
    if (my_dialog and my_dialog.visible) then -- only allows one dialog instance
        my_dialog:close()
        return
    end

    local song = renoise.song()

    --create a table holding string for each row number
    local pat_length = song.selected_pattern.number_of_lines
    local pat_length_tab = {}
    for i = 1, pat_length do
        pat_length_tab[i] = tostring(i - 1)
        --add leading zeros for sub 10 values
        if #pat_length_tab[i] < 2 then
            pat_length_tab[i] = "0" .. pat_length_tab[i]
        end
    end

    --get current note properties
    local cur_line = song.selected_line_index
    local cur_track = song.selected_track_index
    local cur_col = song.selected_note_column_index

    local cur_note = get_current_note()

    ----------------------------------------- --------------------------------------------
    --update tools GUI values with currently selected note values vol pan delay pitch etc.
    --------------------------------------------------------------------------------------
    local function timer_calls_this()
        --see if GUI has closed, if it has then remove timer
        if not (my_dialog and my_dialog.visible) then
            --remove this timer
            if renoise.tool():has_timer(timer_calls_this) then
                renoise.tool():remove_timer(timer_calls_this)
                return
            end
        end

        local song = renoise.song()

        --get current note properties
        local cur_line_new = song.selected_line_index
        local cur_track_new = song.selected_track_index
        local cur_col_new = song.selected_note_column_index
        local cur_pattern_new = song.selected_pattern_index

        --are we in a note column? if not return
        if not song.selected_note_column then
            return
        end

        local cur_note_new =
            song.patterns[cur_pattern_new].tracks[cur_track_new].lines[cur_line_new]:note_column(cur_col_new)
        -- has selected note changed?
        -- return early if line and column has not changed and function has not been called by delay "nudge" buttons notifiers
        if
            (cur_line == cur_line_new) and (cur_col == cur_col_new) and (cur_track == cur_track_new) and
                not_called_by_nudge
         then
            return
        end

        --set flag that GUI is updating
        updating_gui = true

        --set current line (from main) to current_line new
        cur_line = cur_line_new

        --reset flags
        updating_gui = false
        not_called_by_nudge = true
    end
    ----------------------------------------------------------
    --add timer to update the tool GUI every (50) milliseconds
    ----------------------------------------------------------
    if not renoise.tool():has_timer(timer_calls_this) then
        renoise.tool():add_timer(timer_calls_this, 50)
    end

    --key Handler
    local function my_keyhandler_func(dialog, key)
        --hack: toggle keyboard  lock state to allow pattern ed to receive key input
        renoise.app().window.lock_keyboard_focus = not renoise.app().window.lock_keyboard_focus
        renoise.app().window.lock_keyboard_focus = not renoise.app().window.lock_keyboard_focus

        --if escape pressed then close the dialog else return key to renoise
        if not (key.modifiers == "" and key.name == "esc") then
            return key
        else
            dialog:close()
        end
    end

    ------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------
    --Initialise Script dialog
    my_dialog = renoise.app():show_custom_dialog("Note Properties", dialog_content, my_keyhandler_func)

    --close dialog function --for releasing app
    local function closer(d)
        if d and d.visible then
            d:close()
        end
    end

    --notifier to close dialog on load new song
    renoise.tool().app_release_document_observable:add_notifier(closer, my_dialog)
end --end of main

renoise.tool():add_midi_mapping {
    name = "Ledger.scripts.NoteProperties:Ledger",
    invoke = function(message)
        --return early if on fx track

        local song = renoise.song()
        --do nothing if called by GUI update/timer
        if updating_gui then
            return
        end

        --are we in a note column
        if not song.selected_note_column then
            return
        end
        --show column if hidden
        song.tracks[song.selected_track_index].volume_column_visible = true
        --write rotary value to pattern

        --are we in a note column
        if not song.selected_note_column then
            return
        end

        --get current note properties
        local cur_line = song.selected_line_index
        local cur_track = song.selected_track_index
        local cur_col = song.selected_note_column_index
        local cur_pattern = song.selected_pattern_index

        -- oprint(message)
        -- print(message.int_value)
        song.patterns[cur_pattern].tracks[cur_track].lines[cur_line]:note_column(cur_col).volume_value =
            message.int_value
    end
}

