require 'nudge/nudge_up'
require 'nudge/nudge_down'
require 'nudge/nudge_clear'

-- NUDGE UP
renoise.tool():add_keybinding {
  name = "Global:Tools:cc.asaf Nudge Up",
  invoke = function()
    nudgeUp()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:cc.asaf:Nudge Up",
  invoke = function()
    nudgeUp()
  end  
}

-- NUDGE DOWN
renoise.tool():add_keybinding {
  name = "Global:Tools:cc.asaf Nudge Down",
  invoke = function()
    nudgeDown()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:cc.asaf:Nudge Down",
  invoke = function()
    nudgeDown()
  end  
}

-- NUDGE CLEAR
renoise.tool():add_keybinding {
  name = "Global:Tools:cc.asaf Nudge Clear",
  invoke = function()
    nudgeClear()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:cc.asaf:Nudge Clear",
  invoke = function()
    nudgeClear()
  end  
}