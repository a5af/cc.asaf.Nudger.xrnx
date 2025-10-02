--[[============================================================================
tests/spec/core/constants_spec.lua

Tests for core/constants module
============================================================================]]--

describe("Constants", function()
  local Constants

  setup(function()
    -- Mock renoise global
    _G.renoise = {
      Song = {
        SUB_COLUMN_NOTE = 1,
        SUB_COLUMN_INSTRUMENT = 2,
        SUB_COLUMN_VOLUME = 3,
        SUB_COLUMN_PANNING = 4,
        SUB_COLUMN_DELAY = 5,
        SUB_COLUMN_EFFECT_NUMBER = 6,
        SUB_COLUMN_EFFECT_AMOUNT = 7
      }
    }

    Constants = require('core/constants')
  end)

  teardown(function()
    _G.renoise = nil
  end)

  describe("NOTE constants", function()
    it("should have correct note value ranges", function()
      assert.equals(0, Constants.NOTE.MIN)
      assert.equals(119, Constants.NOTE.MAX)
      assert.equals(120, Constants.NOTE.NOTE_OFF)
      assert.equals(121, Constants.NOTE.BLANK)
      assert.equals(48, Constants.NOTE.DEFAULT)  -- C-4
    end)
  end)

  describe("INSTRUMENT constants", function()
    it("should have correct instrument value ranges", function()
      assert.equals(0, Constants.INSTRUMENT.MIN)
      assert.equals(254, Constants.INSTRUMENT.MAX)
      assert.equals(255, Constants.INSTRUMENT.BLANK)
      assert.equals(0, Constants.INSTRUMENT.DEFAULT)
    end)
  end)

  describe("VOLUME constants", function()
    it("should have correct volume value ranges", function()
      assert.equals(0, Constants.VOLUME.MIN)
      assert.equals(127, Constants.VOLUME.MAX)
      assert.equals(255, Constants.VOLUME.BLANK)
      assert.equals(64, Constants.VOLUME.DEFAULT)  -- Half volume
    end)
  end)

  describe("PANNING constants", function()
    it("should have correct panning value ranges", function()
      assert.equals(0, Constants.PANNING.MIN)
      assert.equals(127, Constants.PANNING.MAX)
      assert.equals(255, Constants.PANNING.BLANK)
      assert.equals(64, Constants.PANNING.DEFAULT)  -- Center
    end)
  end)

  describe("DELAY constants", function()
    it("should have correct delay value ranges", function()
      assert.equals(0, Constants.DELAY.MIN)
      assert.equals(255, Constants.DELAY.MAX)
      assert.equals(0, Constants.DELAY.DEFAULT)
    end)
  end)

  describe("EDITOR_CONTEXT", function()
    it("should define editor types", function()
      assert.equals("PATTERN", Constants.EDITOR_CONTEXT.PATTERN)
      assert.equals("PHRASE", Constants.EDITOR_CONTEXT.PHRASE)
    end)
  end)

  describe("Effect command mappings", function()
    it("should map cardinal to command", function()
      local cmd = Constants.CARDINAL_TO_CMD[0]
      assert.is_not_nil(cmd)
      assert.equals("0", cmd)
    end)

    it("should map command to cardinal", function()
      local cardinal = Constants.CMD_TO_CARDINAL["0"]
      assert.is_not_nil(cardinal)
      assert.equals(0, cardinal)
    end)

    it("should have reverse mappings", function()
      -- Test a few mappings
      assert.equals(0, Constants.CMD_TO_CARDINAL[Constants.CARDINAL_TO_CMD[0]])
      assert.equals(1, Constants.CMD_TO_CARDINAL[Constants.CARDINAL_TO_CMD[1]])
      assert.equals(35, Constants.CMD_TO_CARDINAL[Constants.CARDINAL_TO_CMD[35]])
    end)
  end)

  describe("get_next_effect_cmd", function()
    it("should cycle to next effect command", function()
      local next_cmd = Constants.get_next_effect_cmd(0)
      assert.equals(1, next_cmd)
    end)

    it("should wrap around at max", function()
      local max = 35  -- Z command
      local next_cmd = Constants.get_next_effect_cmd(max)
      assert.equals(0, next_cmd)
    end)
  end)

  describe("get_prev_effect_cmd", function()
    it("should cycle to previous effect command", function()
      local prev_cmd = Constants.get_prev_effect_cmd(1)
      assert.equals(0, prev_cmd)
    end)

    it("should wrap around at min", function()
      local prev_cmd = Constants.get_prev_effect_cmd(0)
      assert.equals(35, prev_cmd)
    end)
  end)
end)
