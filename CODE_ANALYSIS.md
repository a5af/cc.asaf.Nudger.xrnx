# Code Analysis: Note Properties (Nudger) Tool for Renoise

## Overview

This is a Renoise scripting tool that provides enhanced keyboard-based control for manipulating note properties within the Renoise tracker interface. The tool extends Renoise's built-in functionality by adding precise increment/decrement controls and note movement capabilities.

## Primary Purpose

The tool enables users to:
1. **Nudge** (increment/decrement) individual note properties using keyboard shortcuts
2. **Move** notes and selections between columns and rows in the pattern editor
3. **Clone** notes to adjacent positions
4. **Clear** note values quickly

## Core Functionality

### 1. Nudge Operations (`main.lua:138-317`)

The `nudgeUp()` and `nudgeDown()` functions allow fine-grained control over note properties:

- **Note Value**: Increment/decrement pitch (range: 1-119, representing musical notes from C-0 to B-9)
- **Instrument**: Cycle through instruments (0-255)
- **Volume**: Adjust volume levels (0-127) or volume effect parameters
- **Panning**: Adjust stereo panning (0-127) or panning effect parameters
- **Delay**: Adjust note delay timing (0-255)
- **Effect Number**: Cycle through available effect commands
- **Effect Amount**: Adjust effect parameter values (0-255)

The nudging wraps around at boundaries (e.g., at max value, wraps to min) and handles special blank values (255) appropriately.

### 2. Move Operations (`main.lua:396-517`)

Four directional move functions allow notes to be relocated:

- **moveUp/moveDown**: Moves notes vertically between pattern lines, finding the first available blank column in the destination line
- **moveLeft/moveRight**: Moves notes horizontally between note columns
- **selectionMoveUp/moveDown/Left/Right**: Moves entire selections in bulk

The move operations preserve all note properties (pitch, instrument, volume, panning, delay, effects) and clear the source location after copying.

### 3. Clone Operations (`clone.lua:45-78`)

Clone functions duplicate notes to adjacent positions:

- **cloneUp/cloneDown**: Copies note to the line above/below and moves cursor to the new position
- **cloneLeft/cloneRight**: Planned but not yet implemented

### 4. Clear Operation (`main.lua:389-394`)

Clears all properties of the currently selected note, resetting it to blank state.

## Technical Implementation

### Data Structures

**Effect Command Mapping** (`constants.lua:55-103`):
- Maps Renoise's internal effect number values to sequential cardinal numbers
- Enables cycling through effect commands in a predictable order
- Supports 23 different effect commands (A, U, D, G, V, I, O, T, C, M, L, S, B, E, Q, R, Y, N, P, W, X, Z, J)

**Note Column Properties**:
- Note value: 121 = blank, 1-119 = playable notes, 120 = note-off
- Instrument/Volume/Panning: 255 = blank, 0-127 = valid values, 128-254 = effect commands
- Delay/Effect Amount: 0-255 range

### Helper Functions (`utils.lua`)

- `copy_note_values()`: Copies all properties from source to destination note
- `clear_note_values()`: Resets note to blank state
- `is_note_col_blank()`: Checks if a note column is empty
- `move_selection()`: Handles bulk selection movement
- `DEC_HEX()`: Converts decimal to hexadecimal for effect display
- `enum()`: Creates enumerated type objects

### Context Retrieval (`main.lua:26-136`)

Multiple getter functions retrieve current context:
- `get_current_note()`: Gets the note at cursor position
- `get_current_selected()`: Gets note or effect column depending on selection
- `get_above_note()/get_below_note()`: Gets adjacent notes vertically
- `get_left_note()/get_right_note()`: Gets adjacent notes horizontally
- `get_cur_line_track_col_pattern_inst_phrase()`: Retrieves complete position context

## User Interface

### Keybindings (`main.lua:319-387`)

The tool registers several global keybindings:
- "cc.asaf Nudge Up/Down": Increment/decrement current property
- "cc.asaf Move Up/Down/Left/Right": Relocate notes directionally
- "cc.asaf Clone Up/Down/Left/Right": Duplicate notes to adjacent positions
- "cc.asaf Clear": Reset current note to blank

### Menu Integration

All functions are also accessible through "Main Menu:Tools:cc.asaf" for mouse-based access.

## Current Limitations

1. **Incomplete Features**:
   - `cloneLeft()` and `cloneRight()` are stubs (line 61-62)
   - `moveUpEffect()` and `moveDownEffect()` are not implemented (lines 424-426, 458-460)
   - Effect column nudging shows placeholder prints instead of functionality (lines 223-224, 315-316)

2. **Move Logic Issues**:
   - `get_right_note()` (line 73-85) has incorrect logic: decrements instead of increments, potentially causing bugs

3. **Boundary Checking**:
   - Some functions lack robust boundary validation for edge cases

## Additional Components

**OSC Support** (`osc_client.lua`, `osc_server.lua`):
- Commented out in initialization (lines 526-527)
- Provides Open Sound Control protocol integration for external control
- Currently disabled, suggesting future planned functionality

## Use Cases

This tool is particularly valuable for:
- **Tracker workflow optimization**: Quickly adjust values without mouse interaction
- **Precise editing**: Increment/decrement by single units rather than typing values
- **Pattern manipulation**: Efficiently reorganize notes within patterns
- **Live performance**: Real-time parameter tweaking via keyboard shortcuts

## Architecture Quality

**Strengths**:
- Clean separation of concerns (utils, constants, main logic, keybindings)
- Comprehensive helper function library
- Handles edge cases like wrapping and blank values
- Supports both note columns and effect columns

**Areas for Improvement**:
- Incomplete implementation of some features
- Bug in `get_right_note()` logic
- No error handling or validation in many functions
- OSC functionality is stubbed but unused
