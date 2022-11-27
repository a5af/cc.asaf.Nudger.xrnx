require 'move/move_up'
require 'move/move_down'
require 'move/move_left'
require 'move/move_right'

-- MOVE UP
renoise.tool():add_keybinding {
  name = "Global:Tools:cc.asaf Move Up",
  invoke = function()
    moveUp()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:cc.asaf:Move Up",
  invoke = function()
    moveUp()
  end  
}

-- MOVE DOWN
renoise.tool():add_keybinding {
  name = "Global:Tools:cc.asaf Move Down",
  invoke = function()
    moveDown()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:cc.asaf:Move Down",
  invoke = function()
    moveDown()
  end  
}

-- MOVE LEFT
renoise.tool():add_keybinding {
  name = "Global:Tools:cc.asaf Move Left",
  invoke = function()
    moveLeft()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:cc.asaf:Move Left",
  invoke = function()
    moveLeft()
  end  
}

-- MOVE RIGHT
renoise.tool():add_keybinding {
  name = "Global:Tools:cc.asaf Move Right",
  invoke = function()
    moveRight()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:cc.asaf:Move Right",
  invoke = function()
    moveRight()
  end  
}