--
-- BUMP UP
--

-- TODO
function bumpUp() 
   
    local song = renoise.song()
    if not song.selected_note_column then
      return
    end
    
    local note = get_current_note()
      
  end
  
--
-- BUMP DOWN
--
  function bumpDown() 
    local song = renoise.song()
    if not song.selected_note_column then
      return
    end
    
    
    local note = get_current_note()

  end