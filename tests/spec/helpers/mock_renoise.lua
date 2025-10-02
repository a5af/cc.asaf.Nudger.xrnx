--[[============================================================================
tests/spec/helpers/mock_renoise.lua

Mock Renoise API for testing
============================================================================]]--

local MockRenoise = {}

-- Mock song structure
function MockRenoise.create_mock_song()
  return {
    patterns = {},
    tracks = {},
    instruments = {},
    selected_line_index = 1,
    selected_track_index = 1,
    selected_note_column_index = 1,
    selected_pattern_index = 1,
    selection_in_pattern = nil,
    selected_phrase = nil,
    selected_phrase_line = nil,
    selected_phrase_note_column = nil
  }
end

-- Mock pattern
function MockRenoise.create_mock_pattern(track_count, line_count)
  track_count = track_count or 8
  line_count = line_count or 64

  local pattern = {
    tracks = {}
  }

  for i = 1, track_count do
    pattern.tracks[i] = MockRenoise.create_mock_track(line_count)
  end

  return pattern
end

-- Mock track
function MockRenoise.create_mock_track(line_count, note_col_count)
  line_count = line_count or 64
  note_col_count = note_col_count or 12

  local track = {
    lines = {},
    visible_note_columns = note_col_count
  }

  for i = 1, line_count do
    track.lines[i] = MockRenoise.create_mock_line(note_col_count)
  end

  return track
end

-- Mock line
function MockRenoise.create_mock_line(note_col_count)
  note_col_count = note_col_count or 12

  local line = {
    note_columns = {},
    effect_columns = {}
  }

  for i = 1, note_col_count do
    line.note_columns[i] = MockRenoise.create_mock_note_column()
  end

  -- Mock note_column() accessor
  function line:note_column(idx)
    return self.note_columns[idx]
  end

  function line:effect_column(idx)
    return self.effect_columns[idx]
  end

  return line
end

-- Mock note column
function MockRenoise.create_mock_note_column()
  return {
    note_value = 121,  -- blank
    instrument_value = 255,  -- blank
    volume_value = 255,  -- blank
    panning_value = 255,  -- blank
    delay_value = 0,
    effect_number_value = 0,
    effect_amount_value = 0
  }
end

-- Mock phrase
function MockRenoise.create_mock_phrase(line_count, note_col_count)
  line_count = line_count or 16
  note_col_count = note_col_count or 8

  local phrase = {
    number_of_lines = line_count,
    visible_note_columns = note_col_count,
    lines = {}
  }

  for i = 1, line_count do
    phrase.lines[i] = MockRenoise.create_mock_line(note_col_count)
  end

  return phrase
end

-- Mock renoise global
function MockRenoise.setup_global()
  _G.renoise = {
    song = function()
      return MockRenoise._current_song or MockRenoise.create_mock_song()
    end,

    Song = {
      SUB_COLUMN_NOTE = 1,
      SUB_COLUMN_INSTRUMENT = 2,
      SUB_COLUMN_VOLUME = 3,
      SUB_COLUMN_PANNING = 4,
      SUB_COLUMN_DELAY = 5,
      SUB_COLUMN_EFFECT_NUMBER = 6,
      SUB_COLUMN_EFFECT_AMOUNT = 7
    },

    tool = function()
      return {
        add_keybinding = function() end,
        add_menu_entry = function() end
      }
    end
  }
end

-- Set current mock song
function MockRenoise.set_song(song)
  MockRenoise._current_song = song
end

-- Clear mock
function MockRenoise.teardown_global()
  _G.renoise = nil
  MockRenoise._current_song = nil
end

return MockRenoise
