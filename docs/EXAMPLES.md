# Note Properties (Nudger) - Examples

Common workflows and use cases demonstrating the power of keyboard-centric note manipulation.

## Table of Contents
- [Basic Operations](#basic-operations)
- [Pattern Creation](#pattern-creation)
- [Mixing & Mastering](#mixing--mastering)
- [Effect Automation](#effect-automation)
- [Phrase Editor Workflows](#phrase-editor-workflows)
- [Advanced Techniques](#advanced-techniques)

## Basic Operations

### Example 1: Transpose a Note

**Goal**: Change C-4 to D-4

**Steps**:
1. Position cursor on note column
2. Press Nudge Up twice

**Result**: C-4 → C#4 → D-4

### Example 2: Adjust Volume Levels

**Goal**: Reduce volume from 80 to 70

**Steps**:
1. Position cursor on volume column
2. Press Nudge Down 16 times (0x80 → 0x70)

**Shortcut**: Hold key for repeat

### Example 3: Move Note to Different Track

**Goal**: Move note from track 1 to track 2

**Steps**:
1. Select note in track 1
2. Press Move Right repeatedly until in track 2
3. Note finds blank column automatically

## Pattern Creation

### Example 4: Create Kick Drum Pattern

**Initial State**: Single kick note at line 00

**Steps**:
1. Position on kick note (line 00)
2. Clone Down (line 04)
3. Clone Down (line 08)
4. Clone Down (line 0C)

**Result**: Kick on every 4th line (4/4 pattern)

### Example 5: Build a Chord

**Goal**: Create C major chord (C-E-G)

**Steps**:
1. Enter C-4 in column 1
2. Clone Right (creates C-4 in column 2)
3. Nudge Up 4 times (C-4 → E-4)
4. Clone Right (creates E-4 in column 3)
5. Nudge Up 3 times (E-4 → G-4)

**Result**: C-4, E-4, G-4 played simultaneously

### Example 6: Arpeggio Pattern

**Goal**: Create rising arpeggio

**Steps**:
1. Enter C-4 at line 00
2. Clone Down to line 01
3. Nudge Up 4 times (→ E-4)
4. Clone Down to line 02
5. Nudge Up 3 times (→ G-4)
6. Clone Down to line 03
7. Nudge Up 5 times (→ C-5)

**Result**: C-4, E-4, G-4, C-5 sequence

## Mixing & Mastering

### Example 7: Fade Out

**Goal**: Create volume fade from 80 to 00

**Initial State**: Volume column with 80 at multiple lines

**Steps**:
1. Set volume 80 at line 00
2. Clone Down through pattern (00, 04, 08, 0C...)
3. Starting at line 04, nudge down each by increasing amounts
4. Or: Select all, manual adjust each

**Result**: Gradual volume decrease

### Example 8: Balance Tracks

**Goal**: Adjust relative levels across tracks

**Steps**:
1. Select volume column across tracks (selection)
2. Use Move Selection to shift all levels together
3. Individual nudge adjustments for fine-tuning

### Example 9: Stereo Width

**Goal**: Create stereo spread

**Steps**:
1. Track 1: Set panning 00 (full left)
2. Clone to Track 2
3. In Track 2, set panning 80 (full right)

**Result**: Wide stereo image

## Effect Automation

### Example 10: Filter Sweep

**Goal**: Automate filter cutoff

**Steps**:
1. Enter filter effect (e.g., 0Q00)
2. Clone Down every line
3. Nudge each effect amount progressively
4. Creates smooth sweep

**Pattern**:
```
Line 00: 0Q00
Line 01: 0Q10
Line 02: 0Q20
Line 03: 0Q30
...
```

### Example 11: Delay Timing

**Goal**: Create rhythmic delay variations

**Steps**:
1. Enter base note with delay 00
2. Clone Down
3. Nudge delay column: 00 → 20 → 40 → 60

**Result**: Humanized timing

### Example 12: Retrigger Effect

**Goal**: Build retrigger pattern

**Steps**:
1. Set retrigger effect (0R)
2. Clone Down
3. Vary effect amounts for different speeds

## Phrase Editor Workflows

### Example 13: Build Phrase Sequence

**Goal**: Create melodic phrase

**Steps** (in Phrase Editor):
1. Enter root note (C-4) at line 0
2. Clone Down to line 4
3. Nudge Up to create melody
4. Use Move to rearrange notes
5. Clone horizontally for harmony

**Same keybindings as pattern editor!**

### Example 14: Phrase Variations

**Goal**: Create phrase variations

**Steps**:
1. Create base phrase
2. Clone entire phrase (Ctrl+C traditional)
3. In variation, use Nudge to modify notes
4. Maintain rhythm, vary pitch

## Advanced Techniques

### Example 15: Quick Transposition

**Goal**: Transpose entire pattern up 2 semitones

**Steps**:
1. Select all notes in pattern
2. Would need multiple nudges (future: bulk nudge)
3. Current: Manual note-by-note

**Workaround**: Use Renoise's built-in transpose, or nudge selection

### Example 16: Pattern Doubling

**Goal**: Double pattern length with variations

**Steps**:
1. Clone original pattern  (traditional Renoise)
2. In second half, use Move Selection to shift timing
3. Use Nudge to create variations

### Example 17: Live Performance Tweaks

**Goal**: Adjust levels during playback

**Steps**:
1. While pattern plays, position on volume column
2. Nudge Up/Down to adjust in real-time
3. Changes take effect immediately

**Use Case**: Live mixing, performance adjustments

### Example 18: Effect Chain Building

**Goal**: Create complex effect sequence

**Steps**:
1. Start with base effect
2. Clone to create sequence
3. Use Nudge to create progression
4. Move to reorder if needed

### Example 19: Humanization

**Goal**: Add human feel to programmed drums

**Steps**:
1. Enter quantized drum pattern
2. For each hit, nudge delay by small random amounts
3. Nudge velocity (volume) slightly
4. Creates natural variation

### Example 20: Selection Cleanup

**Goal**: Clear unwanted notes from section

**Steps**:
1. Select region with unwanted notes
2. Press Clear
3. Entire selection cleared in one undo-able action

**Benefit**: Fast cleanup, single undo

## Tips for All Examples

### Keyboard Efficiency
- Learn keybindings for all operations
- Use Tab to navigate between columns
- Use arrow keys for fine positioning
- Combine with Renoise's block selection

### Undo Safety
- All operations are undo-able
- Selection operations use undo grouping (single undo)
- Test workflows before committing

### Configuration Tweaks
- Adjust wrapping behavior for your workflow
- Set default values for common notes
- Enable auto-advance for rapid entry

### Pattern vs Phrase
- Same operations work identically
- Build patterns in pattern editor
- Build melodies/arpeggios in phrase editor
- Seamless workflow between both

## Workflow Combinations

### Rapid Drum Programming
1. Clone to create pattern skeleton
2. Nudge for variations
3. Move for rearrangement
4. Clear for cleanup

### Melodic Construction
1. Enter root melody
2. Clone for variations
3. Nudge for harmonic changes
4. Move for structure

### Mixing Session
1. Set initial levels
2. Nudge for fine adjustment
3. Selection for bulk changes
4. Move for automation curves

## See Also

- [User Guide](USER_GUIDE.md) - Complete operation reference
- [Configuration](../config.lua) - Customize behavior
- [Developer Guide](DEVELOPMENT.md) - Extend functionality
