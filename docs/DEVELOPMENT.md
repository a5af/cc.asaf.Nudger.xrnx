# Note Properties (Nudger) - Developer Guide

## Table of Contents
- [Architecture Overview](#architecture-overview)
- [Development Setup](#development-setup)
- [Code Structure](#code-structure)
- [Adding Features](#adding-features)
- [Testing](#testing)
- [Contributing](#contributing)

## Architecture Overview

### Design Principles

1. **Separation of Concerns**: Each module has one clear responsibility
2. **Layered Architecture**: Operations → Accessors → Renoise API
3. **Defensive Programming**: Validate all inputs, handle all errors
4. **Configuration Over Code**: User preferences in config files
5. **Testability**: Abstract dependencies to enable testing

### Module Layers

```
┌─────────────────────────────────────┐
│     UI Layer (keybindings, menu)     │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│   Operations (nudge, move, clone)   │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│ Accessors (pattern, phrase, select) │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│         Renoise API (song())         │
└─────────────────────────────────────┘

        ┌────────────────────┐
        │  Core (validation,  │
        │  error, config)     │
        └────────────────────┘
```

## Development Setup

### Prerequisites

- Renoise 3.4.0+ (3.5.0+ recommended)
- Text editor with Lua support
- Git for version control

### Installation for Development

1. Clone the repository:
```bash
git clone https://github.com/yourname/cc.asaf.Nudger.xrnx.git
cd cc.asaf.Nudger.xrnx
```

2. Symlink to Renoise tools directory:

**Windows** (PowerShell as Administrator):
```powershell
New-Item -ItemType SymbolicLink -Path "$env:APPDATA\Renoise\V3.5.0\Scripts\Tools\cc.asaf.Nudger.xrnx" -Target "$(Get-Location)"
```

**macOS/Linux**:
```bash
ln -s "$(pwd)" ~/Library/Preferences/Renoise/V3.5.0/Scripts/Tools/cc.asaf.Nudger.xrnx
# or for Linux:
ln -s "$(pwd)" ~/.renoise/V3.5.0/Scripts/Tools/cc.asaf.Nudger.xrnx
```

3. Enable auto-reload in Renoise:
   - Add `_AUTO_RELOAD_DEBUG = function() print("tools reloaded") end` (already present in `main.lua`)
   - Renoise will auto-reload on file changes

### IDE Setup

**VS Code** (recommended):
1. Install "Lua" extension by sumneko
2. Install "Renoise Lua API" extension (if available)
3. Configure Lua language server:

Create `.vscode/settings.json`:
```json
{
  "Lua.diagnostics.globals": [
    "renoise",
    "rprint",
    "oprint"
  ],
  "Lua.workspace.library": [
    "/path/to/renoise/api/stubs"
  ]
}
```

## Code Structure

### Core Modules

**`core/constants.lua`**
- All magic numbers and enumerations
- Effect command mappings
- Value range definitions

**`core/error_handler.lua`**
- Logging system (DEBUG, INFO, WARN, ERROR)
- Safe execution wrappers
- User-facing error messages

**`core/validator.lua`**
- Input validation functions
- State validation
- Precondition checks

**`core/config_manager.lua`**
- Configuration loading
- User config merging
- Runtime get/set

### Accessor Modules

**`renoise/context.lua`**
- Editor type detection (pattern vs phrase)
- Context information retrieval
- Column type detection

**`renoise/pattern_accessor.lua`**
- Pattern editor API abstraction
- Note/effect column access
- Navigation helpers

**`renoise/phrase_accessor.lua`**
- Phrase editor API abstraction (Renoise 3.5+)
- Same interface as pattern accessor
- Renoise 3.5 feature detection

**`renoise/selection_accessor.lua`**
- Selection information and bounds
- Selection iteration
- Undo grouping support

### Operation Modules

**`operations/nudge.lua`**
- Unified nudge implementation
- Property-based nudging
- Configurable wrapping

**`operations/move.lua`**
- Note relocation
- Selection movement
- Boundary validation

**`operations/clone.lua`**
- Note duplication
- All four directions
- Configurable cursor movement

**`operations/clear.lua`**
- Single note clearing
- Selection clearing with undo grouping

## Adding Features

### Adding a New Operation

1. **Create Operation Module**:
```lua
-- operations/my_operation.lua
local Constants = require('core/constants')
local Validator = require('core/validator')
local ErrorHandler = require('core/error_handler')
local Context = require('renoise/context')

local MyOperation = {}

function MyOperation.do_something()
  ErrorHandler.trace_enter("MyOperation.do_something")

  -- Validate
  local context, err = Context.get_current()
  if not context then
    ErrorHandler.warn(err)
    return false, err
  end

  -- Perform operation
  -- ...

  ErrorHandler.trace_exit("MyOperation.do_something", true)
  return true, nil
end

return MyOperation
```

2. **Register in main.lua**:
```lua
local MyOperation = require('operations/my_operation')

function doSomething()
  return MyOperation.do_something()
end
```

3. **Add Keybinding**:
```lua
renoise.tool():add_keybinding{
  name = "Global:Tools:cc.asaf Do Something",
  invoke = function() doSomething() end
}
```

### Adding Configuration Options

1. **Add to `config.lua`**:
```lua
return {
  my_new_setting = true,
  my_value = 42
}
```

2. **Access in Code**:
```lua
local ConfigManager = require('core/config_manager')
local value = ConfigManager.get("my_new_setting", false)
```

### Adding Accessor Functionality

1. **Add Function to Accessor**:
```lua
-- renoise/pattern_accessor.lua
function PatternAccessor.my_new_accessor(context)
  local success, err = Validator.validate_line_exists(
    context.pattern, context.track, context.line
  )
  if not success then
    return nil, err
  end

  -- Perform access
  return result, nil
end
```

2. **Mirror in Phrase Accessor** (if applicable):
```lua
-- renoise/phrase_accessor.lua
function PhraseAccessor.my_new_accessor(context)
  -- Same interface, different implementation
end
```

## Testing

### Manual Testing Checklist

**Pattern Editor**:
- [ ] Nudge up/down on each property type
- [ ] Move in all four directions
- [ ] Clone in all four directions
- [ ] Clear single note
- [ ] Selection move
- [ ] Selection clear

**Phrase Editor** (Renoise 3.5+):
- [ ] All operations from pattern editor
- [ ] Verify same behavior

**Boundary Conditions**:
- [ ] First line of pattern
- [ ] Last line of pattern
- [ ] First track
- [ ] Last track
- [ ] Empty notes

**Error Handling**:
- [ ] No song loaded
- [ ] No selection
- [ ] Invalid cursor position

### Debugging

**Enable Debug Logging**:
```lua
-- In user_config.lua
return {
  log_level = "DEBUG",
  debug_mode = true,
  trace_function_calls = true
}
```

**Check Console Output**:
- Renoise > View > Scripting Terminal
- Look for [DEBUG], [INFO], [WARN], [ERROR] messages

**Common Issues**:
- Check for nil values
- Verify context type (pattern vs phrase)
- Confirm selection state
- Validate boundary conditions

## Contributing

### Code Style

**Naming Conventions**:
- Modules: PascalCase (e.g., `PatternAccessor`)
- Functions: snake_case (e.g., `get_current_note`)
- Constants: UPPER_SNAKE_CASE (e.g., `BLANK_VALUE`)
- Local variables: snake_case

**Module Structure**:
```lua
-- Header comment
local ModuleName = {}

-- Dependencies
local Dependency = require('path/to/dependency')

-- Private functions
local function private_helper()
end

-- Public functions
function ModuleName.public_function()
end

return ModuleName
```

**Error Handling**:
- Always validate inputs
- Return (result, error) tuples
- Use ErrorHandler for logging
- Provide user-friendly messages

**Documentation**:
- Document all public functions
- Include parameter types and descriptions
- Describe return values
- Note side effects

### Pull Request Process

1. **Fork and Branch**:
```bash
git checkout -b feature/my-feature
```

2. **Make Changes**:
- Follow code style
- Add validation and error handling
- Update documentation

3. **Test Thoroughly**:
- Test in pattern editor
- Test in phrase editor (if applicable)
- Test boundary conditions
- Test error cases

4. **Commit**:
```bash
git commit -m "feature: Add new operation

- Description of changes
- Any breaking changes
- Related issue numbers"
```

5. **Push and PR**:
```bash
git push origin feature/my-feature
```
- Create pull request on GitHub
- Describe changes and testing performed

### Reporting Issues

**Include**:
- Renoise version
- Operating system
- Steps to reproduce
- Expected vs actual behavior
- Console output (if any errors)

## Architecture Decisions

### Why Accessor Layer?

**Problem**: Direct `renoise.song()` calls make testing impossible and create tight coupling.

**Solution**: Accessor layer abstracts API access, enables mocking, adds validation.

### Why Unified Operations?

**Problem**: `nudgeUp()` and `nudgeDown()` had 180 lines of duplicated code.

**Solution**: Single `nudge(direction)` function with property specs reduces code by 60%.

### Why Configuration System?

**Problem**: Hardcoded values forced code changes for user preferences.

**Solution**: External config files allow customization without programming.

## See Also

- [User Guide](USER_GUIDE.md) - End user documentation
- [Examples](EXAMPLES.md) - Common use cases
- [Architecture Overhaul](../ARCHITECTURE_OVERHAUL.md) - Detailed architectural plan
