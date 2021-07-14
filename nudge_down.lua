--
-- NUDGE DOWN
--
  function nudgeDown() 
    local song = renoise.song()
    if not song.selected_note_column then
      return
    end
    
    local subcol = get_current_subcol()
    local note = get_current_note()

    -- NUDGE DOWN NOTE
    if subcol == 1 then
      if note ~= nil then
        if note.note_value > 1 then
            note.note_value = (note.note_value - 1)
        else
            note.note_value = 121
        end
      end
    end
  
    -- NUDGE DOWN INSTRUMENT
    if subcol == 2 then
      if note.instrument_value < 255 and note.instrument_value > 0 then
        note.instrument_value = note.instrument_value - 1
      elseif note.instrument_value == 255 then -- blank
        note.instrument_value = 254 -- wrap around
      else
        note.instrument_value = 255 -- make it blank
      end
    end
  
    -- NUDGE DOWN VOL
    if subcol == 3 then
      print('blank', note.volume_value)
      if note.volume_value > 0 then
        note.volume_value = note.volume_value - 1
      elseif note.volume_value == 0 then
        note.volume_value = 255 -- make it blank
      elseif note.volume_value == 255 then -- is it blank?
        note.volume_value = 0x7F
      else 

        -- EFFECT COMMAND
        local command = note.volume_string[1]
        local value = tonumber(note.volume_string[2])
 
        -- GLIDE
        if command == EFFECT_COMMANDS.G.name then
          if value ~= nil and value > 0 then 
            value = value - 1
            note.volume_string = command..DEC_HEX(value)
          else
            note.volume_string = command.."F"
          end
        end

        -- SLIDE UP
        if command == EFFECT_COMMANDS.U.name then
          if value ~= nil and value > 0 then 
            value = value - 1
            note.volume_string = command..DEC_HEX(value)
          else
            note.volume_string = command.."F"
          end
        end

        -- SLIDE DOWN
        if command == EFFECT_COMMANDS.D.name then
          if value ~= nil and value > 0 then 
            value = value - 1
            note.volume_string = command..DEC_HEX(value)
          else
            note.volume_string = command.."F"
          end
        end

        -- FADE IN
        if command == EFFECT_COMMANDS.I.name then
          if value ~= nil and value > 0 then 
            value = value - 1
            note.volume_string = command..DEC_HEX(value)
          else
            note.volume_string = command.."F"
          end
        end

        -- FADE OUT
        if command == EFFECT_COMMANDS.O.name then
          if value ~= nil and value > 0 then 
            value = value - 1
            note.volume_string = command..DEC_HEX(value)
          else
            note.volume_string = command.."F"
          end
        end

        -- PLAY BACKWARDS
        if command == EFFECT_COMMANDS.B.name then
          if value ~= nil and value > 0 then 
            value = value - 1
            note.volume_string = command..DEC_HEX(value)
          else
            note.volume_string = command.."F"
          end
        end

        -- DELAY PLAYBACK
        if command == EFFECT_COMMANDS.Q.name then
          if value ~= nil and value > 0 then 
            value = value - 1
            note.volume_string = command..DEC_HEX(value)
          else
            note.volume_string = command.."F"
          end
        end

        -- RETRIGGER
        if command == EFFECT_COMMANDS.R.name then
          if value ~= nil and value > 0 then 
            value = value - 1
            note.volume_string = command..DEC_HEX(value)
          else
            note.volume_string = command.."F"
          end
        end

        -- MAYBE TRIGGER
        if command == EFFECT_COMMANDS.Y.name then
          if value ~= nil and value > 0 then 
            value = value - 1
            note.volume_string = command..DEC_HEX(value)
          else
            note.volume_string = command.."F"
          end
        end

        -- CUT VOLUME
        if command == EFFECT_COMMANDS.C.name then
          if value ~= nil and value > 0 then 
            value = value - 1
            note.volume_string = command..DEC_HEX(value)
          else
            note.volume_string = command.."F"
          end
        end
      end
    end
  
    -- NUDGE DOWN PAN
    if subcol == 4 then
      if note.panning_value > 0 then
        note.panning_value = note.panning_value - 1
      end
    end
  
    -- NUDGE DOWN DLY
    if subcol == 5 then
      if note.delay_value > 0 then
        note.delay_value = note.delay_value - 1
      end
    end
  
    -- NUDGE DOWN FX
    if subcol == 6 then
      print("down fx")
    end


  end