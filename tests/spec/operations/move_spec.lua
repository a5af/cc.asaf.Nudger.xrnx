--[[============================================================================
tests/spec/operations/move_spec.lua

Tests for operations/move module
============================================================================]]--

local MockRenoise = require('tests/spec/helpers/mock_renoise')

describe("Move Operations", function()
  local Move, song, pattern, track, line

  before_each(function()
    -- Setup mock Renoise
    MockRenoise.setup_global()

    -- Create mock song and pattern
    song = MockRenoise.create_mock_song()
    pattern = MockRenoise.create_mock_pattern(4, 16)
    song.patterns[1] = pattern
    song.tracks[1] = {visible_note_columns = 12}
    song.tracks[2] = {visible_note_columns = 12}
    song.selected_pattern_index = 1
    song.selected_track_index = 1
    song.selected_line_index = 8
    song.selected_note_column_index = 1

    MockRenoise.set_song(song)

    -- Load module after mock is set up
    Move = require('operations/move')
  end)

  after_each(function()
    MockRenoise.teardown_global()
    package.loaded['operations/move'] = nil
  end)

  describe("Single Note Move", function()
    describe("move_up", function()
      it("should move note up one line", function()
        -- Setup: Note at line 8
        local source_note = pattern.tracks[1].lines[8]:note_column(1)
        source_note.note_value = 48  -- C-4
        source_note.instrument_value = 1

        -- Action
        Move.move_up()

        -- Assert: Note moved to line 7, source cleared
        local dest_note = pattern.tracks[1].lines[7]:note_column(1)
        assert.equals(48, dest_note.note_value)
        assert.equals(1, dest_note.instrument_value)
        assert.equals(121, source_note.note_value)  -- Blank
      end)

      it("should update cursor position", function()
        pattern.tracks[1].lines[8]:note_column(1).note_value = 48

        Move.move_up()

        assert.equals(7, song.selected_line_index)
      end)

      it("should not move from first line", function()
        song.selected_line_index = 1
        pattern.tracks[1].lines[1]:note_column(1).note_value = 48

        local success, err = Move.move_up()

        assert.is_false(success)
        assert.equals("Already at first line", err)
      end)
    end)

    describe("move_down", function()
      it("should move note down one line", function()
        local source_note = pattern.tracks[1].lines[8]:note_column(1)
        source_note.note_value = 48

        Move.move_down()

        local dest_note = pattern.tracks[1].lines[9]:note_column(1)
        assert.equals(48, dest_note.note_value)
        assert.equals(121, source_note.note_value)
      end)

      it("should not move from last line", function()
        song.selected_line_index = 16
        pattern.tracks[1].lines[16]:note_column(1).note_value = 48

        local success, err = Move.move_down()

        assert.is_false(success)
        assert.matches("last line", err)
      end)
    end)

    describe("move_left", function()
      it("should move note left within same track", function()
        song.selected_note_column_index = 2
        local source_note = pattern.tracks[1].lines[8]:note_column(2)
        source_note.note_value = 48

        Move.move_left()

        local dest_note = pattern.tracks[1].lines[8]:note_column(1)
        assert.equals(48, dest_note.note_value)
        assert.equals(121, source_note.note_value)
      end)

      it("should move to previous track when at first column", function()
        song.selected_track_index = 2
        song.selected_note_column_index = 1
        local source_note = pattern.tracks[2].lines[8]:note_column(1)
        source_note.note_value = 48

        Move.move_left()

        -- Should move to track 1, last visible column
        local dest_note = pattern.tracks[1].lines[8]:note_column(12)
        assert.equals(48, dest_note.note_value)
        assert.equals(1, song.selected_track_index)
        assert.equals(12, song.selected_note_column_index)
      end)

      it("should not move from first track, first column", function()
        song.selected_track_index = 1
        song.selected_note_column_index = 1
        pattern.tracks[1].lines[8]:note_column(1).note_value = 48

        local success, err = Move.move_left()

        assert.is_false(success)
        assert.matches("leftmost", err)
      end)
    end)

    describe("move_right", function()
      it("should move note right within same track", function()
        song.selected_note_column_index = 1
        local source_note = pattern.tracks[1].lines[8]:note_column(1)
        source_note.note_value = 48

        Move.move_right()

        local dest_note = pattern.tracks[1].lines[8]:note_column(2)
        assert.equals(48, dest_note.note_value)
        assert.equals(2, song.selected_note_column_index)
      end)

      it("should respect visible_note_columns", function()
        song.tracks[1].visible_note_columns = 2
        song.selected_note_column_index = 2
        pattern.tracks[1].lines[8]:note_column(2).note_value = 48

        Move.move_right()

        -- Should move to next track since at last visible column
        assert.equals(2, song.selected_track_index)
        assert.equals(1, song.selected_note_column_index)
      end)
    end)
  end)

  describe("Selection Move", function()
    describe("move_selection_up", function()
      it("should move all notes in selection up one line", function()
        -- Setup: 2x2 selection with notes
        song.selection_in_pattern = {
          start_line = 8,
          end_line = 9,
          start_track = 1,
          end_track = 1,
          start_column = 1,
          end_column = 2
        }

        pattern.tracks[1].lines[8]:note_column(1).note_value = 48
        pattern.tracks[1].lines[8]:note_column(2).note_value = 50
        pattern.tracks[1].lines[9]:note_column(1).note_value = 52
        pattern.tracks[1].lines[9]:note_column(2).note_value = 53

        -- Action
        Move.move_selection_up()

        -- Assert: All notes moved up, source cleared
        assert.equals(48, pattern.tracks[1].lines[7]:note_column(1).note_value)
        assert.equals(50, pattern.tracks[1].lines[7]:note_column(2).note_value)
        assert.equals(52, pattern.tracks[1].lines[8]:note_column(1).note_value)
        assert.equals(53, pattern.tracks[1].lines[8]:note_column(2).note_value)

        -- Source should be cleared (line 9 now)
        assert.equals(121, pattern.tracks[1].lines[9]:note_column(1).note_value)
        assert.equals(121, pattern.tracks[1].lines[9]:note_column(2).note_value)
      end)

      it("should update selection bounds", function()
        song.selection_in_pattern = {
          start_line = 8,
          end_line = 9,
          start_track = 1,
          end_track = 1,
          start_column = 1,
          end_column = 2
        }

        Move.move_selection_up()

        -- Selection should move up
        assert.equals(7, song.selection_in_pattern.start_line)
        assert.equals(8, song.selection_in_pattern.end_line)
      end)

      it("should not move selection from first line", function()
        song.selection_in_pattern = {
          start_line = 1,
          end_line = 2,
          start_track = 1,
          end_track = 1,
          start_column = 1,
          end_column = 1
        }

        local success, err = Move.move_selection_up()

        assert.is_false(success)
        assert.matches("first line", err)
      end)
    end)

    describe("move_selection_down", function()
      it("should move all notes in selection down", function()
        song.selection_in_pattern = {
          start_line = 8,
          end_line = 9,
          start_track = 1,
          end_track = 1,
          start_column = 1,
          end_column = 1
        }

        pattern.tracks[1].lines[8]:note_column(1).note_value = 48
        pattern.tracks[1].lines[9]:note_column(1).note_value = 50

        Move.move_selection_down()

        assert.equals(48, pattern.tracks[1].lines[9]:note_column(1).note_value)
        assert.equals(50, pattern.tracks[1].lines[10]:note_column(1).note_value)
        assert.equals(121, pattern.tracks[1].lines[8]:note_column(1).note_value)
      end)
    end)

    describe("move_selection_left", function()
      it("should move all notes in selection left", function()
        song.selection_in_pattern = {
          start_line = 8,
          end_line = 9,
          start_track = 1,
          end_track = 1,
          start_column = 2,
          end_column = 3
        }

        pattern.tracks[1].lines[8]:note_column(2).note_value = 48
        pattern.tracks[1].lines[8]:note_column(3).note_value = 50
        pattern.tracks[1].lines[9]:note_column(2).note_value = 52
        pattern.tracks[1].lines[9]:note_column(3).note_value = 53

        Move.move_selection_left()

        -- All notes should move left by one column
        assert.equals(48, pattern.tracks[1].lines[8]:note_column(1).note_value)
        assert.equals(50, pattern.tracks[1].lines[8]:note_column(2).note_value)
        assert.equals(52, pattern.tracks[1].lines[9]:note_column(1).note_value)
        assert.equals(53, pattern.tracks[1].lines[9]:note_column(2).note_value)

        -- Source columns should be cleared
        assert.equals(121, pattern.tracks[1].lines[8]:note_column(3).note_value)
        assert.equals(121, pattern.tracks[1].lines[9]:note_column(3).note_value)
      end)
    end)

    describe("move_selection_right", function()
      it("should move all notes in selection right", function()
        song.selection_in_pattern = {
          start_line = 8,
          end_line = 9,
          start_track = 1,
          end_track = 1,
          start_column = 1,
          end_column = 2
        }

        pattern.tracks[1].lines[8]:note_column(1).note_value = 48
        pattern.tracks[1].lines[8]:note_column(2).note_value = 50

        Move.move_selection_right()

        assert.equals(48, pattern.tracks[1].lines[8]:note_column(2).note_value)
        assert.equals(50, pattern.tracks[1].lines[8]:note_column(3).note_value)
        assert.equals(121, pattern.tracks[1].lines[8]:note_column(1).note_value)
      end)

      it("should respect visible_note_columns when moving right", function()
        song.tracks[1].visible_note_columns = 3
        song.selection_in_pattern = {
          start_line = 8,
          end_line = 8,
          start_track = 1,
          end_track = 1,
          start_column = 2,
          end_column = 3
        }

        pattern.tracks[1].lines[8]:note_column(2).note_value = 48
        pattern.tracks[1].lines[8]:note_column(3).note_value = 50

        -- Should not be able to move right (at boundary)
        local success, err = Move.move_selection_right()

        -- Depending on implementation, might fail or move to next track
        -- TODO: Define expected behavior
      end)
    end)

    describe("multi-track selection", function()
      pending("should move notes across multiple tracks", function()
        song.selection_in_pattern = {
          start_line = 8,
          end_line = 9,
          start_track = 1,
          end_track = 2,
          start_column = 1,
          end_column = 1
        }

        -- TODO: Define expected behavior for multi-track selections
      end)
    end)
  end)

  describe("Boundary Conditions", function()
    it("should handle blank notes", function()
      -- Moving a blank note should work but effectively do nothing
      local source_note = pattern.tracks[1].lines[8]:note_column(1)
      assert.equals(121, source_note.note_value)  -- Blank

      Move.move_down()

      -- Both source and dest should be blank
      assert.equals(121, source_note.note_value)
      assert.equals(121, pattern.tracks[1].lines[9]:note_column(1).note_value)
    end)

    it("should preserve all note properties", function()
      local source_note = pattern.tracks[1].lines[8]:note_column(1)
      source_note.note_value = 48
      source_note.instrument_value = 5
      source_note.volume_value = 80
      source_note.panning_value = 64
      source_note.delay_value = 10
      source_note.effect_number_value = 12
      source_note.effect_amount_value = 255

      Move.move_down()

      local dest_note = pattern.tracks[1].lines[9]:note_column(1)
      assert.equals(48, dest_note.note_value)
      assert.equals(5, dest_note.instrument_value)
      assert.equals(80, dest_note.volume_value)
      assert.equals(64, dest_note.panning_value)
      assert.equals(10, dest_note.delay_value)
      assert.equals(12, dest_note.effect_number_value)
      assert.equals(255, dest_note.effect_amount_value)
    end)
  end)
end)
