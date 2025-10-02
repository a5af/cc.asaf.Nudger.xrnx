--[[============================================================================
tests/spec/operations/clone_spec.lua

Tests for operations/clone module
============================================================================]]--

local MockRenoise = require('tests/spec/helpers/mock_renoise')

describe("Clone Operations", function()
  local Clone, song, pattern

  before_each(function()
    MockRenoise.setup_global()

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

    Clone = require('operations/clone')
  end)

  after_each(function()
    MockRenoise.teardown_global()
    package.loaded['operations/clone'] = nil
  end)

  describe("Single Note Clone", function()
    describe("clone_up", function()
      it("should clone note to line above", function()
        local source_note = pattern.tracks[1].lines[8]:note_column(1)
        source_note.note_value = 48
        source_note.instrument_value = 1

        Clone.clone_up()

        -- Destination should have cloned note
        local dest_note = pattern.tracks[1].lines[7]:note_column(1)
        assert.equals(48, dest_note.note_value)
        assert.equals(1, dest_note.instrument_value)

        -- Source should still have original note
        assert.equals(48, source_note.note_value)
        assert.equals(1, source_note.instrument_value)
      end)

      it("should move cursor to cloned note when configured", function()
        pattern.tracks[1].lines[8]:note_column(1).note_value = 48

        Clone.clone_up()

        -- Cursor should move to cloned note (line 7)
        assert.equals(7, song.selected_line_index)
      end)
    end)

    describe("clone_down", function()
      it("should clone note to line below", function()
        local source_note = pattern.tracks[1].lines[8]:note_column(1)
        source_note.note_value = 48

        Clone.clone_down()

        local dest_note = pattern.tracks[1].lines[9]:note_column(1)
        assert.equals(48, dest_note.note_value)
        assert.equals(48, source_note.note_value)
      end)

      it("should preserve all note properties", function()
        local source_note = pattern.tracks[1].lines[8]:note_column(1)
        source_note.note_value = 48
        source_note.instrument_value = 5
        source_note.volume_value = 80
        source_note.panning_value = 64
        source_note.delay_value = 10

        Clone.clone_down()

        local dest_note = pattern.tracks[1].lines[9]:note_column(1)
        assert.equals(48, dest_note.note_value)
        assert.equals(5, dest_note.instrument_value)
        assert.equals(80, dest_note.volume_value)
        assert.equals(64, dest_note.panning_value)
        assert.equals(10, dest_note.delay_value)
      end)
    end)

    describe("clone_left", function()
      it("should clone note to column on left", function()
        song.selected_note_column_index = 2
        local source_note = pattern.tracks[1].lines[8]:note_column(2)
        source_note.note_value = 48

        Clone.clone_left()

        local dest_note = pattern.tracks[1].lines[8]:note_column(1)
        assert.equals(48, dest_note.note_value)
        assert.equals(48, source_note.note_value)  -- Source preserved
      end)

      it("should clone to previous track when at first column", function()
        song.selected_track_index = 2
        song.selected_note_column_index = 1
        local source_note = pattern.tracks[2].lines[8]:note_column(1)
        source_note.note_value = 48

        Clone.clone_left()

        -- Should clone to track 1, last visible column
        local dest_note = pattern.tracks[1].lines[8]:note_column(12)
        assert.equals(48, dest_note.note_value)
      end)
    end)

    describe("clone_right", function()
      it("should clone note to column on right", function()
        local source_note = pattern.tracks[1].lines[8]:note_column(1)
        source_note.note_value = 48

        Clone.clone_right()

        local dest_note = pattern.tracks[1].lines[8]:note_column(2)
        assert.equals(48, dest_note.note_value)
        assert.equals(48, source_note.note_value)
      end)

      it("should respect visible_note_columns", function()
        song.tracks[1].visible_note_columns = 1
        song.selected_note_column_index = 1
        pattern.tracks[1].lines[8]:note_column(1).note_value = 48

        Clone.clone_right()

        -- Should clone to next track when at last visible column
        assert.equals(2, song.selected_track_index)
        assert.equals(1, song.selected_note_column_index)
        assert.equals(48, pattern.tracks[2].lines[8]:note_column(1).note_value)
      end)
    end)
  end)

  describe("Selection Clone", function()
    describe("clone_selection_up", function()
      it("should clone all notes in selection up", function()
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

        Clone.clone_selection_up()

        -- Destination should have cloned notes
        assert.equals(48, pattern.tracks[1].lines[7]:note_column(1).note_value)
        assert.equals(50, pattern.tracks[1].lines[7]:note_column(2).note_value)
        assert.equals(52, pattern.tracks[1].lines[8]:note_column(1).note_value)
        assert.equals(53, pattern.tracks[1].lines[8]:note_column(2).note_value)

        -- Source should be preserved
        assert.equals(52, pattern.tracks[1].lines[9]:note_column(1).note_value)
        assert.equals(53, pattern.tracks[1].lines[9]:note_column(2).note_value)
      end)

      it("should update selection to cloned area when configured", function()
        song.selection_in_pattern = {
          start_line = 8,
          end_line = 9,
          start_track = 1,
          end_track = 1,
          start_column = 1,
          end_column = 1
        }

        Clone.clone_selection_up()

        -- Selection should move to cloned area
        assert.equals(7, song.selection_in_pattern.start_line)
        assert.equals(8, song.selection_in_pattern.end_line)
      end)
    end)

    describe("clone_selection_down", function()
      it("should clone all notes in selection down", function()
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

        Clone.clone_selection_down()

        -- Cloned notes
        assert.equals(48, pattern.tracks[1].lines[9]:note_column(1).note_value)
        assert.equals(50, pattern.tracks[1].lines[10]:note_column(1).note_value)

        -- Source preserved
        assert.equals(48, pattern.tracks[1].lines[8]:note_column(1).note_value)
      end)
    end)

    describe("clone_selection_left", function()
      it("should clone all notes in selection left", function()
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

        Clone.clone_selection_left()

        -- Cloned one column left
        assert.equals(48, pattern.tracks[1].lines[8]:note_column(1).note_value)
        assert.equals(50, pattern.tracks[1].lines[8]:note_column(2).note_value)
        assert.equals(52, pattern.tracks[1].lines[9]:note_column(1).note_value)
        assert.equals(53, pattern.tracks[1].lines[9]:note_column(2).note_value)

        -- Source preserved
        assert.equals(50, pattern.tracks[1].lines[8]:note_column(3).note_value)
        assert.equals(53, pattern.tracks[1].lines[9]:note_column(3).note_value)
      end)
    end)

    describe("clone_selection_right", function()
      it("should clone all notes in selection right", function()
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

        Clone.clone_selection_right()

        -- Cloned one column right
        assert.equals(48, pattern.tracks[1].lines[8]:note_column(2).note_value)
        assert.equals(50, pattern.tracks[1].lines[8]:note_column(3).note_value)
        assert.equals(52, pattern.tracks[1].lines[9]:note_column(2).note_value)

        -- Source preserved
        assert.equals(48, pattern.tracks[1].lines[8]:note_column(1).note_value)
      end)
    end)
  end)

  describe("Boundary Conditions", function()
    it("should not clone from first line up", function()
      song.selected_line_index = 1
      pattern.tracks[1].lines[1]:note_column(1).note_value = 48

      local success, err = Clone.clone_up()

      assert.is_false(success)
      assert.matches("first line", err)
    end)

    it("should not clone from last line down", function()
      song.selected_line_index = 16
      pattern.tracks[1].lines[16]:note_column(1).note_value = 48

      local success, err = Clone.clone_down()

      assert.is_false(success)
      assert.matches("last line", err)
    end)

    it("should handle blank notes", function()
      local source_note = pattern.tracks[1].lines[8]:note_column(1)
      assert.equals(121, source_note.note_value)  -- Blank

      Clone.clone_down()

      -- Both should be blank
      assert.equals(121, source_note.note_value)
      assert.equals(121, pattern.tracks[1].lines[9]:note_column(1).note_value)
    end)
  end)

  describe("Configuration", function()
    pending("should respect auto_select_cloned_note config", function()
      -- TODO: Test with config.auto_select_cloned_note = false
      -- Cursor should not move
    end)

    pending("should respect selection auto-select config", function()
      -- TODO: Test selection clone with auto-select disabled
      -- Selection should not move to cloned area
    end)
  end)
end)
