-- VALID VOLUME COMMANDS:  G U D I O B Q R Y C
-- VALID PAN COMMANDS: G U D J K B Q R Y C
LINE_FIELDS = enum({"NOTE", "INST", "VOL", "PAN", "DLY", "FX_NUM", "FX_AMT"});

SUBCOL = {NOTE = 1, INST = 2, VOL = 3, PAN = 4, DLY = 5, FX_NUM = 6, FX_AMT = 7}

EFFECT_COMMANDS = enum({

  -- PAN AND VOLUME
  "G", -- GLIDE         
  "U", -- SLIDE_UP      
  "D", -- SLIDE_DOWN    
  "B", -- PLAY_BACKWARDS
  "Q", -- DELAY_PLAYBACK
  "R", -- RETRIGGER      
  "Y", -- MAYBE_TRIGGER 
  "C", -- CUT_VOLUME
  -- PAN ONLY
  "J", -- SLIDE_LEFT
  "K", -- SLIDE_RIGHT
  -- VOLUME ONLY
  "I", -- FADE_IN       
  "O" -- FADE_OUT      

});

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
