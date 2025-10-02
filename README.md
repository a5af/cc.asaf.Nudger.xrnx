# Note Properties (Nudger)

A Renoise tool for keyboard-centric note manipulation in pattern and phrase editors.

![Demo](nudger.gif)

## Features

- **Nudge**: Increment/decrement note properties using keyboard shortcuts
  - Note pitch, Instrument, Volume, Panning, Delay
  - Effect number and amount
- **Move**: Relocate notes directionally (up/down/left/right)
  - Single notes and selections
- **Clone**: Duplicate notes to adjacent positions
- **Clear**: Reset note properties to blank state
- **Works in both Pattern Editor and Phrase Editor** (Renoise 3.5+)

## Installation

1. **Download** the latest release `.xrnx` file from [Releases](https://github.com/asafebgi/cc.asaf.Nudger.xrnx/releases)
2. **Locate** your Renoise tools directory:
   - **Windows**: `%APPDATA%\Renoise\V3.5.0\Scripts\Tools\`
   - **macOS**: `~/Library/Preferences/Renoise/V3.5.0/Scripts/Tools/`
   - **Linux**: `~/.renoise/V3.5.0/Scripts/Tools/`
3. **Copy** the `.xrnx` file to the tools directory
4. **Restart** Renoise
5. **Verify** the tool appears in `Tools > Note Properties` menu

## Keyboard Shortcuts

**Quick Setup**: See [KEYBINDINGS.md](KEYBINDINGS.md) for detailed setup instructions and alternatives.

### Recommended Shortcuts

Configure in `Preferences > Keys > Tools > cc.asaf`:

| Operation | Suggested Shortcut | Description |
|-----------|-------------------|-------------|
| **Nudge Up** | `Ctrl+Up` (Win/Linux)<br>`Cmd+Up` (macOS) | Increment current property |
| **Nudge Down** | `Ctrl+Down` (Win/Linux)<br>`Cmd+Down` (macOS) | Decrement current property |
| **Move Up** | `Ctrl+Shift+Up` | Move note to line above |
| **Move Down** | `Ctrl+Shift+Down` | Move note to line below |
| **Move Left** | `Ctrl+Shift+Left` | Move note to left column |
| **Move Right** | `Ctrl+Shift+Right` | Move note to right column |
| **Clone Up** | `Ctrl+Alt+Up` | Duplicate note above |
| **Clone Down** | `Ctrl+Alt+Down` | Duplicate note below |
| **Clone Left** | `Ctrl+Alt+Left` | Duplicate note to left |
| **Clone Right** | `Ctrl+Alt+Right` | Duplicate note to right |
| **Clear** | `Ctrl+Delete` (Win/Linux)<br>`Cmd+Delete` (macOS) | Clear note properties |

*Note: These shortcuts work in both pattern and phrase editors*

## Usage

1. **Select** a note column or effect column
2. **Position** cursor on the property you want to modify
3. **Press** the keybinding to nudge, move, clone, or clear

The tool automatically detects which property you're editing (note, instrument, volume, etc.) and adjusts accordingly.

## Configuration

Edit `config.lua` to customize behavior:
- Wrapping at value boundaries
- Auto-advance cursor after operations
- Debug logging level
- OSC network settings

## Requirements

- **Recommended**: Renoise 3.5.0+ (for full phrase editor support)
- **Minimum**: Renoise 3.4.0 (limited phrase editor features)

## Recent Updates

**Version 2.0** - Architectural Overhaul Complete:
- ✅ Complete effect column nudging (all properties)
- ✅ Full phrase editor integration (Renoise 3.5 API)
- ✅ Selection move and clear operations
- ✅ Undo/redo integration with batch grouping
- ✅ Comprehensive error handling and validation
- ✅ Configurable behavior via config.lua
- ✅ Fixed critical bugs (move right, etc.)
- ✅ 60% code reduction through refactoring

See [ARCHITECTURE_OVERHAUL.md](ARCHITECTURE_OVERHAUL.md) for architectural details.

## Releases

**Latest Release**: [v2.0-beta](https://github.com/asafebgi/cc.asaf.Nudger.xrnx/releases/latest)

### Release Channels

- **Beta Releases** (`v2.x-beta`): Feature-complete with comprehensive testing needed
- **Stable Releases** (`v2.x`): Production-ready, fully tested

### Download

Download the latest `.xrnx` file from the [Releases page](https://github.com/asafebgi/cc.asaf.Nudger.xrnx/releases).

### Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history and migration guides.

## Support

- **Issues**: [GitHub Issues](https://github.com/asafebgi/cc.asaf.Nudger.xrnx/issues)
- **Documentation**: See `docs/` folder
- **Source**: [GitHub Repository](https://github.com/asafebgi/cc.asaf.Nudger.xrnx)


