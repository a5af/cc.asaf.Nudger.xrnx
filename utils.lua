function DEC_HEX(IN)
  local B, K, OUT, I, D = 16, "0123456789ABCDEF", "", 0
  while IN > 0 do
    I = I + 1
    IN, D = math.floor(IN / B), math.mod(IN, B) + 1
    OUT = string.sub(K, D, D) .. OUT
  end
  return OUT
end

function enum(names, offset)
  offset = offset or 1
  local objects = {}
  local size = 0
  for idr, name in pairs(names) do
    local id = idr + offset - 1
    local obj = {
      id = id, -- id
      idr = idr, -- 1-based relative id, without offset being added
      name = name -- name of the object
    }
    objects[name] = obj
    objects[id] = obj
    size = size + 1
  end
  objects.idstart = offset -- start of the id range being used
  objects.idend = offset + size - 1 -- end of the id range being used
  objects.size = size
  objects.all = function()
    local list = {}
    for _, name in pairs(names) do add(list, objects[name]) end
    local i = 0
    return function()
      i = i + 1
      if i <= #list then return list[i] end
    end
  end
  return objects
end

function map(t, f)
  local t1 = {}
  local t_len = #t
  for i = 1, t_len do t1[i] = f(t[i], i) end
  return t1
end

-- Implements integer indexing into a string, ie mystring[1] gets first char of mystring
local string_meta = getmetatable('')

function string_meta:__index(key)
  local val = string[key]
  if (val) then
    return val
  elseif (tonumber(key)) then
    return self:sub(key, key)
  else
    error("attempt to index a string value with bad key ('" .. tostring(key) ..
            "' is not part of the string library)", 2)
  end
end

function copy_note_values(src, dest)
  dest.note_value = src.note_value
  dest.instrument_value = src.instrument_value
  dest.volume_value = src.volume_value
  dest.panning_value = src.panning_value
  dest.delay_value = src.delay_value
  dest.effect_number_value = src.effect_number_value
  dest.effect_amount_value = src.effect_amount_value
end

function cache_note(note) CACHE_note = note end

function clear_note_values(dest)
  dest.note_value = 121
  dest.instrument_value = 255
  dest.volume_value = 255
  dest.panning_value = 255
  dest.delay_value = 0
  dest.effect_number_value = 0
  dest.effect_amount_value = 0
end

function move_selection(x, y)
  local song = renoise.song()
  local sp = song.selection_in_pattern
  return {
    start_line = sp.start_line + y,
    end_line = sp.end_line + y,
    start_track = sp.start_track,
    end_track = sp.end_track,
    start_column = sp.start_column + x,
    end_column = sp.end_column + x
  }
end

function get_table_size(t)
  local count = 0
  for _, __ in pairs(t) do count = count + 1 end
  return count
end

function is_note_col_blank(note_col)
  return note_col.note_value == 121 and note_col.instrument_value == 255 and
           note_col.volume_value == 255 and note_col.panning_value == 255 and
           note_col.delay_value == 0 and note_col.effect_number_value == 0 and
           note_col.effect_amount_value == 0
end

-- USAGE
-- range(a) returns an iterator from 1 to a (step = 1)
-- range(a, b) returns an iterator from a to b (step = 1)
-- range(a, b, step) returns an iterator from a to b, counting by step.
function range(a, b, step)
  if not b then
    b = a
    a = 1
  end
  step = step or 1
  local f = step > 0 and function(_, lastvalue)
    local nextvalue = lastvalue + step
    if nextvalue <= b then return nextvalue end
  end or step < 0 and function(_, lastvalue)
    local nextvalue = lastvalue + step
    if nextvalue >= b then return nextvalue end
  end or function(_, lastvalue) return lastvalue end
  return f, nil, a - step
end
