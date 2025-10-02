# Keybinding Setup Guide

Quick guide to setting up keyboard shortcuts for Note Properties (Nudger).

## Table of Contents
- [Quick Setup (Recommended)](#quick-setup-recommended)
- [Manual Setup](#manual-setup)
- [Platform-Specific Shortcuts](#platform-specific-shortcuts)
- [Alternative Shortcuts](#alternative-shortcuts)

## Quick Setup (Recommended)

### Step 1: Open Keybindings Preferences

1. Open Renoise
2. Go to **Edit > Preferences** (or press `Ctrl+,` on Windows/Linux, `Cmd+,` on macOS)
3. Navigate to the **Keys** tab
4. In the left panel, expand **Tools** > **cc.asaf**

### Step 2: Assign Shortcuts

Use the table below to quickly assign all shortcuts:

| Operation | Find in Tree | Windows/Linux | macOS |
|-----------|-------------|---------------|-------|
| **Nudge Up** | Tools > cc.asaf > Nudge Up | `Ctrl+Up` | `Cmd+Up` |
| **Nudge Down** | Tools > cc.asaf > Nudge Down | `Ctrl+Down` | `Cmd+Down` |
| **Move Up** | Tools > cc.asaf > Move Up | `Ctrl+Shift+Up` | `Cmd+Shift+Up` |
| **Move Down** | Tools > cc.asaf > Move Down | `Ctrl+Shift+Down` | `Cmd+Shift+Down` |
| **Move Left** | Tools > cc.asaf > Move Left | `Ctrl+Shift+Left` | `Cmd+Shift+Left` |
| **Move Right** | Tools > cc.asaf > Move Right | `Ctrl+Shift+Right` | `Cmd+Shift+Right` |
| **Clone Up** | Tools > cc.asaf > Clone Up | `Ctrl+Alt+Up` | `Cmd+Option+Up` |
| **Clone Down** | Tools > cc.asaf > Clone Down | `Ctrl+Alt+Down` | `Cmd+Option+Down` |
| **Clone Left** | Tools > cc.asaf > Clone Left | `Ctrl+Alt+Left` | `Cmd+Option+Left` |
| **Clone Right** | Tools > cc.asaf > Clone Right | `Ctrl+Alt+Right` | `Cmd+Option+Right` |
| **Clear** | Tools > cc.asaf > Clear | `Ctrl+Delete` | `Cmd+Delete` |

### Step 3: How to Assign

For each operation:
1. Click the operation name in the left tree
2. Click in the **Shortcut** field (right panel)
3. Press the desired key combination
4. Click **Assign** button
5. Repeat for next operation

### Step 4: Save and Test

1. Click **OK** to close preferences
2. Open pattern editor
3. Test a shortcut (e.g., select a note and press `Ctrl+Up`)

## Manual Setup

### Finding the Commands

All Note Properties commands are located under:
```
Edit > Preferences > Keys > Tools > cc.asaf
```

Available commands:
- Nudge Up / Nudge Down
- Move Up / Move Down / Move Left / Move Right
- Clone Up / Clone Down / Clone Left / Clone Right
- Clear

### Assigning a Shortcut

1. **Select Command**: Click command in tree view
2. **Enter Shortcut**: Click in shortcut field, press key combination
3. **Check Conflicts**: Renoise will warn if shortcut is already used
4. **Assign**: Click "Assign" button
5. **Repeat**: Continue for all commands

### Conflict Resolution

If a shortcut is already assigned:
- Choose a different shortcut combination
- Or reassign the conflicting command
- Recommended: Use modifier keys (Ctrl/Cmd, Shift, Alt/Option)

## Platform-Specific Shortcuts

### Windows / Linux

**Pattern Navigation:**
- `Ctrl+Up/Down` - Nudge values
- `Ctrl+Shift+Up/Down/Left/Right` - Move notes
- `Ctrl+Alt+Up/Down/Left/Right` - Clone notes
- `Ctrl+Delete` - Clear note

**Workflow Tips:**
- Use arrow keys to navigate between note properties
- Use Tab to move between columns
- Combine nudge with arrow keys for rapid editing

### macOS

**Pattern Navigation:**
- `Cmd+Up/Down` - Nudge values
- `Cmd+Shift+Up/Down/Left/Right` - Move notes
- `Cmd+Option+Up/Down/Left/Right` - Clone notes
- `Cmd+Delete` - Clear note

**Workflow Tips:**
- Use arrow keys to navigate between note properties
- Use Tab to move between columns
- Combine nudge with arrow keys for rapid editing

### Linux-Specific Notes

Some Linux window managers use `Ctrl+Alt+Arrow` for workspace switching. If conflicts occur:

**Alternative Clone Shortcuts:**
- `Ctrl+Shift+Alt+Up/Down/Left/Right` for clone operations
- Or rebind your window manager shortcuts

## Alternative Shortcuts

If the recommended shortcuts conflict with your workflow or system shortcuts, try these alternatives:

### Alternative Set 1: Function Keys
| Operation | Shortcut |
|-----------|----------|
| Nudge Up | `F1` |
| Nudge Down | `F2` |
| Move Up | `Shift+F1` |
| Move Down | `Shift+F2` |
| Clone Up | `Alt+F1` |
| Clone Down | `Alt+F2` |

### Alternative Set 2: Numpad (Windows/Linux)
| Operation | Shortcut |
|-----------|----------|
| Nudge Up | `Ctrl+Numpad 8` |
| Nudge Down | `Ctrl+Numpad 2` |
| Move Up | `Ctrl+Shift+Numpad 8` |
| Move Down | `Ctrl+Shift+Numpad 2` |
| Move Left | `Ctrl+Shift+Numpad 4` |
| Move Right | `Ctrl+Shift+Numpad 6` |

### Alternative Set 3: Letter Keys
| Operation | Shortcut |
|-----------|----------|
| Nudge Up | `Ctrl+K` |
| Nudge Down | `Ctrl+J` |
| Move Up | `Ctrl+Shift+K` |
| Move Down | `Ctrl+Shift+J` |
| Clone Down | `Ctrl+D` |

## Verification Checklist

After setting up keybindings, verify they work:

- [ ] Open pattern editor
- [ ] Enter a note (e.g., C-4)
- [ ] Test Nudge Up - note should change to C#4
- [ ] Test Nudge Down - note should change back to C-4
- [ ] Test Move Down - note should move to line below
- [ ] Test Clone Down - note should be duplicated below
- [ ] Test Clear - note should be cleared

## Troubleshooting

### Shortcuts Not Working

**Check:**
1. Is the tool installed correctly? (`Tools > Note Properties` menu should exist)
2. Is a note column selected in pattern editor?
3. Is the cursor on the correct property (note, volume, etc.)?
4. Are there keybinding conflicts?

**Solutions:**
- Reload tool: Tools > Reload All Tools
- Check Renoise Scripting Terminal for errors
- Verify keybindings in Preferences > Keys

### Conflict with Other Tools

If shortcuts conflict with other Renoise tools:
1. Use the alternative shortcuts above
2. Customize conflicting tool shortcuts
3. Use modifier combinations (Ctrl+Shift+Alt)

### Platform-Specific Issues

**macOS:**
- Some system shortcuts may conflict (e.g., Mission Control)
- Disable conflicting system shortcuts in System Preferences > Keyboard > Shortcuts

**Linux:**
- Window manager shortcuts may conflict
- Configure window manager to use different shortcuts
- Or use alternative keybinding sets above

## Export/Import Keybindings

### Export Your Keybindings

1. Tools > Scripting Terminal and Preferences
2. Click "Import/Export Preferences"
3. Export to .xml file
4. Share with other users or backup

### Import Keybindings

1. Receive .xml file with keybindings
2. Tools > Scripting Terminal and Preferences
3. Click "Import/Export Preferences"
4. Import .xml file
5. Restart Renoise

## Tips for Efficient Setup

### Muscle Memory Patterns

The recommended shortcuts follow a pattern:
- **Nudge**: `Ctrl` (base modifier)
- **Move**: `Ctrl+Shift` (add Shift)
- **Clone**: `Ctrl+Alt` (add Alt/Option)

This creates consistent muscle memory:
- Same arrows for direction
- Modifiers add functionality

### Workflow-Based Assignment

Consider your workflow:
- **Frequent operations**: Easy shortcuts (`Ctrl+Up/Down`)
- **Less frequent**: More modifiers (`Ctrl+Alt+...`)
- **Directional**: Use arrow keys for spatial operations

### Practice Sequence

Learn shortcuts progressively:
1. Week 1: Nudge Up/Down (most used)
2. Week 2: Add Move operations
3. Week 3: Add Clone operations
4. Week 4: Add Clear

## See Also

- [README.md](README.md) - Installation and overview
- [docs/USER_GUIDE.md](docs/USER_GUIDE.md) - Complete user documentation
- [docs/EXAMPLES.md](docs/EXAMPLES.md) - Workflow examples
