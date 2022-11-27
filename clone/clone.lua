require 'clone/clone_up'
require 'clone/clone_down'
require 'clone/clone_left'
require 'clone/clone_right'

-- CLONE UP
renoise.tool():add_keybinding {
  name = "Global:Tools:cc.asaf Clone Up",
  invoke = function()
    cloneUp()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:cc.asaf:Clone Up",
  invoke = function()
    cloneUp()
  end  
}

-- CLONE DOWN
renoise.tool():add_keybinding {
  name = "Global:Tools:cc.asaf Clone Down",
  invoke = function()
    cloneDown()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:cc.asaf:Clone Down",
  invoke = function()
    cloneDown()
  end  
}

-- CLONE LEFT
renoise.tool():add_keybinding {
  name = "Global:Tools:cc.asaf Clone Left",
  invoke = function()
    cloneLeft()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:cc.asaf:Clone Left",
  invoke = function()
    cloneLeft()
  end  
}

-- CLONE RIGHT
renoise.tool():add_keybinding {
  name = "Global:Tools:cc.asaf Clone Right",
  invoke = function()
    cloneRight()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:cc.asaf:Clone Right",
  invoke = function()
    cloneRight()
  end  
}