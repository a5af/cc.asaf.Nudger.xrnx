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
