function get_current_subcol()
  local song = renoise.song()
  if not song.selected_note_column then return end
  return song.selected_sub_column_type
end

-- A = 10 = 1 = 10
-- U = 30 = 2 = 30
-- D = 13 = 3 = 13
-- G = 16 = 4 = 16
-- V = 31 = 5 = 31
-- I = 18 = 6 = 18
-- O = 24 = 7 = 24
-- T = 29 = 8 = 29
-- C = 12 = 9 = 12
-- M = 22 = 10 = 22
-- L = 21 = 11 = 21
-- S = 28 = 12 = 28
-- B = 11 = 13 = 11
-- E = 14 = 14 = 14
-- Q = 26 = 15 = 26
-- R = 27 = 16 = 27
-- Y = 34 = 17 = 34
-- N = 23 = 18 = 23
-- P = 25 = 19 = 25
-- W = 32 = 20 = 32
-- X = 33 = 21 = 33
-- Z = 35 = 22 = 35
-- J = 19 = 23 = 19
-- ZT
-- ZL
-- ZK
-- ZG
-- ZB
-- ZD

cmd_to_cardinal = {}
cmd_to_cardinal[10] = 1
cmd_to_cardinal[30] = 2
cmd_to_cardinal[13] = 3
cmd_to_cardinal[16] = 4
cmd_to_cardinal[31] = 5
cmd_to_cardinal[18] = 6
cmd_to_cardinal[24] = 7
cmd_to_cardinal[29] = 8
cmd_to_cardinal[12] = 9
cmd_to_cardinal[22] = 10
cmd_to_cardinal[21] = 11
cmd_to_cardinal[28] = 12
cmd_to_cardinal[11] = 13
cmd_to_cardinal[14] = 14
cmd_to_cardinal[26] = 15
cmd_to_cardinal[27] = 16
cmd_to_cardinal[34] = 17
cmd_to_cardinal[23] = 18
cmd_to_cardinal[25] = 19
cmd_to_cardinal[32] = 20
cmd_to_cardinal[33] = 21
cmd_to_cardinal[35] = 22
cmd_to_cardinal[19] = 23

cardinal_to_cmd = {}
cardinal_to_cmd[1] = 10
cardinal_to_cmd[2] = 30
cardinal_to_cmd[3] = 13
cardinal_to_cmd[4] = 16
cardinal_to_cmd[5] = 31
cardinal_to_cmd[6] = 18
cardinal_to_cmd[7] = 24
cardinal_to_cmd[8] = 29
cardinal_to_cmd[9] = 12
cardinal_to_cmd[10] = 22
cardinal_to_cmd[11] = 21
cardinal_to_cmd[12] = 28
cardinal_to_cmd[13] = 11
cardinal_to_cmd[14] = 14
cardinal_to_cmd[15] = 26
cardinal_to_cmd[16] = 27
cardinal_to_cmd[17] = 34
cardinal_to_cmd[18] = 23
cardinal_to_cmd[19] = 25
cardinal_to_cmd[20] = 32
cardinal_to_cmd[21] = 33
cardinal_to_cmd[22] = 35
cardinal_to_cmd[23] = 19

fxcmds = {
  A = 10,
  U = 30,
  D = 13,
  G = 16,
  V = 31,
  I = 18,
  O = 24,
  T = 29,
  C = 12,
  M = 22,
  L = 21,
  S = 28,
  B = 11,
  E = 14,
  Q = 26,
  R = 27,
  Y = 34,
  N = 23,
  P = 25,
  W = 32,
  X = 33,
  Z = 35,
  J = 19
}
fxarr = {
  10, 30, 13, 16, 31, 18, 24, 29, 12, 22, 21, 28, 11, 14, 26, 27, 34, 23, 25,
  32, 33, 35, 19
}

function get_next_effect_number(effect_number)
  local cur_cmd = cmd_to_cardinal[effect_number]
  if not cur_cmd then return cardinal_to_cmd[1] end
  local cardinal = cur_cmd + 1
  if cardinal > #cardinal_to_cmd then cardinal = 1 end
  return cardinal_to_cmd[cardinal]
end

function get_prev_effect_number(effect_number)
  local cur_cmd = cmd_to_cardinal[effect_number]
  if not cur_cmd then return cardinal_to_cmd[#cardinal_to_cmd] end
  local cardinal = cur_cmd - 1
  if cardinal < 1 then cardinal = #cardinal_to_cmd end
  return cardinal_to_cmd[cardinal]
end

function get_cur_line_track_col_pattern()
  local song = renoise.song()
  return {
    line = song.selected_line_index,
    track = song.selected_track_index,
    col = song.selected_note_column_index,
    pattern = song.selected_pattern_index
  }
end

function get_current_note()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local cur = get_cur_line_track_col_pattern()
  return
    song.patterns[cur.pattern].tracks[cur.track].lines[cur.line]:note_column(
      cur.col)
end

function get_left_note()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local cur = get_cur_line_track_col_pattern()
  if cur.col == 0 then
    if cur.track == 0 then return end
    cur.track = cur.track - 1
  else
    cur.col = cur.col - 1
  end
  return
    song.patterns[cur.pattern].tracks[cur.track].lines[cur.line]:note_column(
      cur.col)
end

function get_right_note()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local cur = get_cur_line_track_col_pattern()

  if cur.col == get_col_count() - 1 then
    if cur.track == get_track_count() - 1 then return end
    cur.track = cur.track - 1
  else
    cur.col = cur.col - 1
  end
  return
    song.patterns[cur.pattern].tracks[cur.track].lines[cur.line]:note_column(
      cur.col)

end

function get_above_note()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local cur = get_cur_line_track_col_pattern()
  local above_line = song.selected_line_index - 1
  if above_line < 0 then return end
  return
    song.patterns[cur.pattern].tracks[cur.track].lines[above_line]:note_column(
      cur.col)
end

function get_line_count()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local cur = get_cur_line_track_col_pattern()
  return get_table_size(song.patterns[cur.pattern].tracks[cur.track].lines)
end

function get_track_count()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local cur = get_cur_line_track_col_pattern()
  return get_table_size(song.patterns[cur.pattern].tracks)
end

function get_col_count()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local cur = get_cur_line_track_col_pattern()
  return get_table_size(
           song.patterns[cur.pattern].tracks[cur.track].lines[cur.line]
             .note_columns)
end

function get_below_note()
  local song = renoise.song()
  if not song.selected_note_column then return end
  local cur = get_cur_line_track_col_pattern()

  local below_line = song.selected_line_index + 1
  if below_line >= get_line_count() then return end
  return
    song.patterns[cur.pattern].tracks[cur.track].lines[below_line]:note_column(
      cur.col)
end

function get_phrase()
  local song = renoise.song()

  local cur_instrument = song.selected_instrument_index
  local cur_phrase = song.selected_phrase_index

  local Y = renoise.app().window.instrument_box_is_visible
  print(Y)

  -- oprint(cur_phrase)
  local phrase = song.instruments[cur_instrument]:phrase(cur_phrase)
  -- oprint(phrase)

end
