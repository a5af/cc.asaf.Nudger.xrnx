-- VALID VOLUME COMMANDS:  G U D I O B Q R Y C
-- VALID PAN COMMANDS: G U D J K B Q R Y C

      -- TODO: implement enums
LINE_FIELDS = enum({
    "NOTE",
    "INST", 
    "VOL",
    "PAN",
    "DLY",
    "FX",
  });
  

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
    "O", -- FADE_OUT      
    
});
