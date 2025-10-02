# Note Properties (Nudger) - User Guide

## Table of Contents
- [Introduction](#introduction)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Operations](#operations)
- [Configuration](#configuration)
- [Tips & Tricks](#tips--tricks)
- [Troubleshooting](#troubleshooting)

## Introduction

Note Properties (Nudger) is a Renoise tool that enables precise keyboard-based manipulation of note properties in both pattern and phrase editors. It's designed for trackers who prefer keyboard-centric workflows and need quick, repeatable adjustments to notes.

### Key Features

- **Nudge**: Increment/decrement any note property with a single keystroke
- **Move**: Relocate notes between lines and columns
- **Clone**: Duplicate notes to adjacent positions
- **Clear**: Reset note properties to blank state
- **Pattern & Phrase**: Works identically in both editors
- **Selections**: Operate on multiple notes simultaneously
- **Configurable**: Customize wrapping, defaults, and behavior

## Installation

### Step 1: Download

Download the latest `.xrnx` file from the releases page or build from source.

### Step 2: Locate Tools Directory

Find your Renoise tools directory based on your operating system:

**Windows**:
```
%APPDATA%\Renoise\V3.5.0\Scripts\Tools\
```
Full path example: `C:\Users\YourName\AppData\Roaming\Renoise\V3.5.0\Scripts\Tools\`

**macOS**:
```
~/Library/Preferences/Renoise/V3.5.0/Scripts/Tools/
```

**Linux**:
```
~/.renoise/V3.5.0/Scripts/Tools/
```

### Step 3: Install

1. Copy the `.xrnx` file to the tools directory
2. Restart Renoise
3. Verify installation: Check `Tools > Note Properties` menu

## Quick Start

### Basic Workflow

1. **Position cursor** on a note property you want to modify
2. **Press keybinding** to perform operation
3. **Repeat** as needed

### Recommended Keybindings

Configure in `Preferences > Keys > Tools > cc.asaf`:

| Operation | Suggested Keys (Win/Linux) | Suggested Keys (macOS) |
|-----------|---------------------------|------------------------|
| Nudge Up | `Ctrl+Up` | `Cmd+Up` |
| Nudge Down | `Ctrl+Down` | `Cmd+Down` |
| Move Up | `Ctrl+Shift+Up` | `Cmd+Shift+Up` |
| Move Down | `Ctrl+Shift+Down` | `Cmd+Shift+Down` |
| Move Left | `Ctrl+Shift+Left` | `Cmd+Shift+Left` |
| Move Right | `Ctrl+Shift+Right` | `Cmd+Shift+Right` |
| Clone Up | `Ctrl+Alt+Up` | `Cmd+Option+Up` |
| Clone Down | `Ctrl+Alt+Down` | `Cmd+Option+Down` |
| Clone Left | `Ctrl+Alt+Left` | `Cmd+Option+Left` |
| Clone Right | `Ctrl+Alt+Right` | `Cmd+Option+Right` |
| Clear | `Ctrl+Delete` | `Cmd+Delete` |

## Operations

### Nudge

Nudge increments or decrements the current note property by one unit.

**Supported Properties**:
- **Note Pitch**: C-0 to B-9 (wraps around by default)
- **Instrument**: 00 to FE (wraps around)
- **Volume**: 00 to 7F (stops at boundaries by default)
- **Panning**: 00 to 7F (stops at boundaries by default)
- **Delay**: 00 to FF (wraps around)
- **Effect Number**: Cycles through valid effect commands
- **Effect Amount**: 00 to FF (wraps around)

**Usage**:
1. Position cursor on desired property column
2. Press nudge up/down keybinding
3. Value adjusts by one unit

**Blank Values**:
- When nudging from blank, value is set to configured default
- Default behavior: C-4 for notes, 00 for instruments, 40 for volume/pan

**Wrapping**:
Configured per-property in `config.lua`. Default wrapping:
- Notes: ON (127 → 0)
- Instrument: ON (254 → 0)
- Volume/Panning: OFF (stops at 0 or 127)
- Delay: ON (255 → 0)

### Move

Move relocates a note from current position to adjacent line/column.

**Directions**:
- **Up**: Moves to line above
- **Down**: Moves to line below
- **Left**: Moves to column on the left
- **Right**: Moves to column on the right

**Behavior**:
- Finds first blank column in destination line (vertical moves)
- Copies all note properties to destination
- Clears source note
- Updates cursor to follow moved note

**Selection Mode**:
When a selection exists, moves entire selection instead of single note.

**Boundaries**:
- Cannot move beyond first/last line
- Cannot move beyond first/last track (horizontal)
- Operation silently fails at boundaries

### Clone

Clone duplicates current note to adjacent position.

**Directions**: Up, Down, Left, Right

**Behavior**:
- Copies all note properties to destination
- Source note remains unchanged
- By default, cursor moves to cloned note (configurable)

**Use Cases**:
- Quickly duplicate patterns
- Create note echoes
- Build chords horizontally

### Clear

Clear resets note properties to blank state.

**Single Note**:
- Clears all properties of current note
- Works on both note and effect columns

**Selection**:
- Clears all notes in selection
- Uses undo grouping (single undo for entire selection)
- Works across multiple tracks and columns

**Cleared Values**:
- Note: Blank (---)
- Instrument: Blank (--)
- Volume/Panning: Blank (--)
- Delay: 00
- Effects: 00

## Configuration

### Config File Location

Default configuration: `config.lua`
User overrides: `user_config.lua` (create manually, gitignored)

### Common Settings

**Log Level**:
```lua
log_level = "WARN"  -- Options: DEBUG, INFO, WARN, ERROR
```

**Wrapping**:
```lua
wrap_at_boundaries = {
  note_value = true,      -- Wrap note pitch
  instrument_value = true,
  volume_value = false,   -- Stop at 0/127
  panning_value = false,
  delay_value = true
}
```

**Auto-Advance**:
```lua
auto_advance_after_nudge = false  -- Move to next line after nudge
```

**Auto-Select Cloned**:
```lua
auto_select_cloned_note = true  -- Move cursor to cloned note
```

**Default Values**:
```lua
default_values = {
  note_value = 48,      -- C-4
  instrument_value = 0,
  volume_value = 64,    -- Half volume
  panning_value = 64,   -- Center
  delay_value = 0
}
```

### Creating User Config

1. Copy `config.lua` to `user_config.lua`
2. Edit only the settings you want to change
3. Restart Renoise or reload tool

## Tips & Tricks

### Rapid Pattern Creation

1. Enter first note
2. Clone down to create pattern
3. Nudge clones to create variations
4. Use selection move for bulk repositioning

### Precise Mixing

1. Select volume column across multiple tracks
2. Use nudge to adjust levels in unison
3. Fine-tune with single-note nudges

### Effect Automation

1. Place effect command
2. Clone vertically to create column
3. Nudge each value for sweep effect

### Keyboard-Only Workflow

1. Set up keybindings for all operations
2. Use tab/arrows for navigation
3. Never touch mouse during pattern entry

## Troubleshooting

### Operations Don't Work

**Check**:
- Is a note column selected?
- Is cursor on the correct sub-column?
- Are you at pattern boundary?

**Solutions**:
- Click into pattern editor first
- Position cursor on desired property
- Move away from boundaries

### Unexpected Wrapping

**Issue**: Values wrap when you don't want them to

**Solution**: Edit `config.lua` or create `user_config.lua`:
```lua
wrap_at_boundaries = {
  volume_value = false  -- Disable wrapping
}
```

### Phrase Editor Not Working

**Issue**: Operations don't work in phrase editor

**Check**: Renoise version (3.5+ required for full support)

**Solutions**:
- Upgrade to Renoise 3.5 or later
- Some features work on 3.4 with limitations

### Selection Clear Too Slow

**Issue**: Clearing large selections is slow

**Check**: Undo grouping setting

**Solution**: Ensure in `config.lua`:
```lua
use_undo_grouping = true  -- Enables faster batch operations
```

### Configuration Not Loading

**Issue**: Changes to config don't take effect

**Solutions**:
- Restart Renoise
- Check for syntax errors in config file
- Use `user_config.lua` instead of editing `config.lua`

## Advanced Usage

### Macro Recording

Combine operations into sequences:
1. Clone note pattern
2. Nudge each instance differently
3. Move entire section

### Selection Manipulation

1. Select region
2. Move selection to new location
3. Clone horizontally for doubling
4. Clear to reset sections

### Effect Building

1. Set base effect
2. Clone column
3. Nudge amounts progressively
4. Create automation effect

## Support & Feedback

- **Issues**: Report bugs at GitHub Issues
- **Documentation**: See other docs in `docs/` folder
- **Source Code**: Review implementation details
- **Configuration**: Full options in `config.lua`

## See Also

- [Developer Guide](DEVELOPMENT.md) - For contributors
- [Examples](EXAMPLES.md) - Specific use cases
- [Architecture](../ARCHITECTURE_OVERHAUL.md) - Technical details
