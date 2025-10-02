# Architectural Overhaul: Note Properties (Nudger) Tool

## Executive Summary

Transform the Nudger tool from a functional prototype into a professional, maintainable, and future-proof Renoise plugin. This overhaul addresses critical architectural flaws, completes all TODO features, adds Renoise 3.5 support, and establishes a sustainable foundation for growth.

---

## Vision & Goals

### Core Vision
Enable complete keyboard-centric mastery of Renoise note manipulation across both pattern and phrase editors, with zero crashes, comprehensive error handling, and seamless integration with Renoise 3.5's latest features.

### Primary Goals
1. **Reliability**: Defensive programming, graceful error handling, zero crashes
2. **Completeness**: Implement all TODOs (FX nudging, phrase editor, selection operations)
3. **Maintainability**: Clear modular architecture enabling easy understanding
4. **Future-Ready**: Support Renoise 3.5 features (API 6.2, phrase editor, undo/redo)
5. **User Experience**: Configurable behavior, helpful feedback, intuitive operation

---

## Current State: Critical Issues

### Architectural Problems

**1. Monolithic Design**
- 528 lines in `main.lua` mixing UI, logic, and data access
- Impossible to test, understand, or modify safely
- High coupling between unrelated functionality

**2. Zero Error Handling**
- Every function assumes perfect Renoise state
- No validation, nil checks, or boundary conditions
- Single invalid state = crash

**3. Massive Code Duplication**
- `nudgeUp()` and `nudgeDown()`: 180 lines of 90% identical code
- Move/clone operations repeat patterns
- Bug fixes require changes in multiple places

**4. Incomplete Features (README TODOs)**
- Effect column operations: stubs that print debug messages
- Phrase editor support: completely missing
- Clone left/right: empty functions
- Selection move/clear: partially implemented
- Effect move operations: unimplemented

**5. Critical Bugs**
- `get_right_note()`: decrements instead of increments (wrong direction)
- No boundary validation leads to crashes at pattern edges

**6. No Abstraction Layer**
- 200+ direct `renoise.song()` calls scattered everywhere
- Cannot test, mock, or debug
- Renoise API changes break everything

**7. Hardcoded Everything**
- Magic numbers: 121, 255, 0xFF everywhere (undocumented)
- IP addresses, ports hardcoded in OSC code
- No configuration system

**8. Zero Documentation**
- No inline comments explaining logic
- No API contracts or function documentation
- Magic numbers unexplained

---

## Renoise 3.5 Integration Opportunities

### Latest Features (API 6.2, July 2025)

**Phrase Editor API Support**
Renoise 3.5 introduces dedicated phrase editor selection properties:
- `selected_phrase_line`: Current line in phrase editor
- `selected_phrase_note_column`: Current note column in phrase
- `selected_phrase_effect_column`: Current effect column in phrase

**Impact**: Native API support makes phrase editor implementation straightforward. We can unify pattern/phrase operations through context detection.

**Undo/Redo Support**
New undo management methods:
- `describe_batch_undo()`: Group multiple operations into single undo
- `is_undo_redoing()`: Detect undo/redo state

**Impact**: Can implement proper undo support for nudge/move/clone operations. Multi-note operations become single undo actions.

**LuaJIT Performance**
Replaced Lua 5.1 with LuaJIT for improved performance.

**Impact**: Better performance for bulk operations on selections. Enables more complex features without slowdown.

**LuaLS Language Server Support**
Modern IDE integration with code completion and error checking.

**Impact**: Better development experience. Easier for contributors to understand API.

**Microtuning Support**
New tuning properties: `tuning`, `tuning_name`, `mts_esp_tuning`

**Impact**: Note nudging might need tuning awareness in future versions. Currently compatible as-is.

---

## Proposed Architecture

### Design Philosophy

**Separation of Concerns**: Each module owns one responsibility.

**Layered Abstraction**: Operations → Accessors → Renoise API. Each layer validates below.

**Defensive Programming**: Validate inputs, check state, handle errors, assume nothing.

**Configuration Over Code**: User preferences in files, not hardcoded values.

**API Abstraction**: All Renoise API calls go through accessor layer for testing and validation.

### Module Structure

```
cc.asaf.Nudger.xrnx/
├── main.lua                    # Minimal entry point
├── config.lua                  # User-editable configuration
│
├── core/                       # Foundation infrastructure
│   ├── validator.lua           # All validation logic
│   ├── error_handler.lua       # Error handling & logging
│   ├── config_manager.lua      # Configuration system
│   └── constants.lua           # All magic numbers named
│
├── operations/                 # Business logic
│   ├── nudge.lua               # Unified nudge (no duplication)
│   ├── move.lua                # Move operations
│   ├── clone.lua               # Clone operations (complete)
│   └── clear.lua               # Clear operations
│
├── renoise/                    # Renoise API abstraction
│   ├── context.lua             # Pattern vs phrase detection
│   ├── pattern_accessor.lua    # Pattern editor access
│   ├── phrase_accessor.lua     # Phrase editor access (3.5)
│   └── selection_accessor.lua  # Selection operations
│
├── ui/                         # User interface
│   ├── keybindings.lua         # Keybinding registration
│   └── menu.lua                # Menu registration
│
├── network/                    # Optional OSC features
│   ├── osc_server.lua          # Configurable OSC server
│   └── osc_client.lua          # Configurable OSC client
│
└── utils/                      # Utilities
    └── helpers.lua             # General utilities
```

### Layer Responsibilities

**Core Layer**: Infrastructure that everything depends on
- Validator: Check preconditions before operations
- Error Handler: Log errors, show messages, enable debugging
- Config Manager: Load/save user preferences
- Constants: Document all magic numbers

**Accessor Layer**: Renoise API abstraction
- Context: Detect pattern vs phrase editor mode
- Pattern/Phrase Accessors: Unified interface for both editors
- Selection Accessor: Multi-note selection operations
- All API calls, validation, boundary checking happens here

**Operations Layer**: Business logic
- Nudge: Calculate new values, handle wrapping
- Move: Navigate and relocate notes
- Clone: Duplicate notes directionally
- Clear: Reset values
- All operations editor-agnostic (work via accessors)

**UI Layer**: User-facing interface
- Keybindings: Register keyboard shortcuts
- Menus: Register menu items
- Feedback: Status messages, warnings

---

## Error Handling Strategy

### Three-Tier Protection

**Tier 1: Prevention (Validation)**
Stop errors before they happen:
- Validate all function parameters (type, value, range)
- Check Renoise state (song loaded, selection valid)
- Verify boundary conditions (not at first/last line)
- Confirm indices within bounds

**Tier 2: Handling (Safe Execution)**
Catch and handle errors gracefully:
- Wrap Renoise API calls in protected mode
- Log detailed error info for debugging
- Show user-friendly messages
- Never crash, always degrade gracefully

**Tier 3: Recovery (State Management)**
Maintain valid state after errors:
- Use undo/redo to rollback partial changes
- Return to safe state on failure
- Provide clear feedback on what went wrong
- Suggest corrective actions

### Validation Philosophy

**Every public function validates**:
- Parameter types and values
- Renoise state preconditions
- Boundary conditions
- Returns success/failure with error messages

**Every Renoise API call**:
- Goes through accessor layer (no direct calls)
- Is validated before execution
- Is logged for debugging
- Has error handling

---

## Feature Completion Plan

### 1. Complete Effect Column Operations

**Current**: Stub printing debug messages
**Target**: Full effect number/amount nudging

**Requirements**:
- Nudge effect number through valid commands
- Nudge effect amount with wrapping
- Work in both pattern and phrase editors
- Handle blank effects

**Implementation**:
- Unified nudge logic handles note and effect columns
- Effect command cycling uses Renoise 3.5 constants
- Same validation and error handling as notes

### 2. Phrase Editor Support (Renoise 3.5)

**Current**: No phrase editor support
**Target**: All operations work identically in phrase editor

**Requirements**:
- Auto-detect phrase editor context
- Nudge all properties in phrases
- Move/clone/clear notes in phrases
- Respect phrase boundaries
- Support phrase-specific features (MIDI channel column)

**Implementation**:
- Context layer detects active editor using new API 6.2 properties:
  - `selected_phrase_line`
  - `selected_phrase_note_column`
  - `selected_phrase_effect_column`
- Phrase accessor implements same interface as pattern accessor
- Operations remain editor-agnostic
- Same keybindings work everywhere

### 3. Selection Operations

**Current**: Partially implemented
**Target**: Complete selection move and clear

**Requirements**:
- Move entire selections (up/down/left/right)
- Clear all notes in selection
- Multi-track and multi-column support
- Validate destination space available
- Use undo grouping for single undo action

**Implementation**:
- Selection accessor provides boundaries
- Move validates destination doesn't overlap
- Clear iterates all notes in selection
- Use `describe_batch_undo()` for atomic undo

### 4. Complete Clone Operations

**Current**: Left/right are stubs
**Target**: All four directions functional

**Requirements**:
- Clone to left/right columns
- Find available blank column
- Respect track boundaries
- Move cursor to cloned note

**Implementation**:
- Reuse vertical clone logic
- Horizontal navigation
- Same boundary checking pattern

### 5. Undo/Redo Support (Renoise 3.5)

**New Feature**: Proper undo integration

**Requirements**:
- Group multi-note operations (selections)
- Single undo for complex operations
- Descriptive undo names
- Don't interfere with manual undo/redo

**Implementation**:
- Wrap operations in `describe_batch_undo()`
- Use `is_undo_redoing()` to detect undo state
- Provide meaningful undo descriptions

---

## Configuration System

### User-Configurable Settings

**Behavior**:
- Wrapping at boundaries (on/off per property type)
- Auto-advance cursor after operations
- Show status messages vs silent mode

**Development**:
- Log level (DEBUG, INFO, WARN, ERROR)
- Debug mode with verbose logging

**Network (OSC)**:
- Enable/disable OSC server
- Server IP and port
- Client IP and port

**Advanced**:
- Experimental features toggle
- Performance optimizations

### Configuration Files

**`config.lua`**: Default configuration (shipped with tool)
**`user_config.lua`**: User overrides (gitignored, survives updates)
**Future**: Preference panel UI for non-programmers

### Benefits

- Power users customize without code changes
- Developers enable debug logging
- OSC users configure network settings
- Beta testers access experimental features

---

## Testing & Quality Strategy

### Quality Metrics

- **100%** public functions have input validation
- **100%** Renoise API calls have error handling
- **Zero** direct `renoise.song()` calls outside accessors
- **<10%** code duplication
- **Zero** magic numbers (all named constants)

### Testing Approach

**Unit Tests**: Test business logic with mocked accessors
**Integration Tests**: Test full operations in Renoise context
**Edge Case Tests**: Boundary conditions, empty selections, invalid state
**Regression Tests**: Prevent fixed bugs from returning

### Documentation Standards

**Inline**: All functions document purpose, parameters, returns, edge cases
**User Docs**: README, user guide, configuration reference
**Developer Docs**: Architecture, API reference, contribution guide
**Examples**: Common workflows demonstrated

---

## Implementation Roadmap

### Phase 1: Foundation (Week 1)
**Focus**: Core infrastructure

- Validator module with all precondition checks
- Error handler with logging system
- Config manager with user config loading
- Constants module with all magic numbers documented
- No feature changes, foundation only

**Success**: All direct constants replaced, config system works, validation functions ready

### Phase 2: Abstraction (Week 2)
**Focus**: Renoise API layer

- Context detection (pattern vs phrase, API 6.2)
- Pattern accessor with validation
- Phrase accessor with validation (API 6.2 properties)
- Selection accessor
- Move all `renoise.song()` calls to accessors

**Success**: Zero direct API calls outside accessors, mock accessors for testing

### Phase 3: Operations Refactor (Week 3)
**Focus**: Consolidate and fix

- Unify nudge (eliminate 90% duplication)
- Fix move operations (right note bug)
- Complete clone operations (left/right)
- Add validation and error handling to all

**Success**: Code reduced 60%, all operations validated, all bugs fixed

### Phase 4: Feature Completion (Week 4)
**Focus**: Complete TODOs

- Effect column nudging (complete)
- Phrase editor support (all operations)
- Selection move and clear
- Undo/redo integration (API 6.2)

**Success**: All README TODOs done, phrase editor works, undo grouping works

### Phase 5: Documentation & Polish (Week 5)
**Focus**: User experience

- Comprehensive README with install instructions
- Suggested keyboard shortcuts
- User guide with examples
- Developer guide for contributors
- Inline documentation complete

**Success**: All docs complete, new users can install and use easily

### Phase 6: Advanced Features (Optional)
**Focus**: Enhancements

- Configurable OSC server/client
- Preference panel UI
- Performance optimizations
- Advanced macro system

---

## README Requirements

### Must Include

**What It Does**:
- Brief description of keyboard-centric note manipulation
- Pattern and phrase editor support
- All supported properties (note, instrument, volume, panning, delay, effects)

**Installation**:
- Download latest release
- Platform-specific paths to Renoise tools directory:
  - Windows: `%APPDATA%\Renoise\V3.5.0\Scripts\Tools\`
  - macOS: `~/Library/Preferences/Renoise/V3.5.0/Scripts/Tools/`
  - Linux: `~/.renoise/V3.5.0/Scripts/Tools/`
- Extract to tools directory
- Restart Renoise
- Verify in Tools menu

**Suggested Keyboard Shortcuts**:
- **Nudge Up/Down**: `Ctrl+Up/Down` or `Cmd+Up/Down`
- **Move**: `Ctrl+Shift+Arrows`
- **Clone**: `Ctrl+Alt+Arrows`
- **Clear**: `Ctrl+Delete` or `Cmd+Delete`
- Note: Work in both pattern and phrase editors

**Animated Demo**: Keep existing `nudger.gif`

**Features List**:
- Pattern editor support
- Phrase editor support (Renoise 3.5+)
- Nudge: Note, Instrument, Volume, Panning, Delay, FX
- Move: Up, Down, Left, Right (single notes and selections)
- Clone: Up, Down, Left, Right
- Clear: Reset note properties
- Undo/redo integration

**Configuration**: Link to `config.lua` for customization

**Requirements**: Renoise 3.5+ recommended (3.4+ compatible with limitations)

**Support**: Link to GitHub issues, documentation

---

## Migration & Compatibility

### Backward Compatibility

**Strategy**:
- Maintain legacy function names as wrappers
- Feature flags for new functionality
- Gradual migration, one module at a time
- Extensive testing after each phase

**Version Strategy**:
- **v1.x**: Current implementation
- **v2.0**: Architectural overhaul (this plan)
- **v2.1+**: New features on new architecture
- **v3.0**: Remove legacy code (future)

### Renoise Version Support

**Primary Target**: Renoise 3.5 (API 6.2)
**Minimum**: Renoise 3.4 (API 6.1) with feature detection

**Feature Detection**:
```
if song.selected_phrase_line then
  -- Use Renoise 3.5 phrase editor features
else
  -- Gracefully degrade or show message
end
```

---

## Benefits Summary

### For Users
- **Reliability**: No crashes, predictable behavior, helpful errors
- **Complete Features**: Everything in TODOs works
- **Phrase Editor**: Full support for phrase editing workflow
- **Undo Support**: Operations integrate with Renoise undo system
- **Customizable**: Configure behavior without coding
- **Modern**: Leverages Renoise 3.5 latest features

### For Developers
- **Clarity**: Obvious structure, clear responsibilities
- **Testability**: Mock accessors, unit testable logic
- **Debuggability**: Comprehensive logging, clear errors
- **Extensibility**: Add features without touching core
- **Modern Tooling**: LuaLS support, better IDE experience

### For Project
- **Maintainable**: Clear architecture, comprehensive docs
- **Professional**: Industry-standard patterns and practices
- **Collaborative**: Easy for others to contribute
- **Future-Proof**: Ready for Renoise future versions
- **Sustainable**: Can grow without becoming unmaintainable

---

## Success Criteria

### Completion Checklist

**Features**:
- [ ] All README TODOs completed
- [ ] Effect column nudging fully functional
- [ ] Phrase editor support complete (API 6.2)
- [ ] Selection move and clear working
- [ ] Clone left/right implemented
- [ ] Undo/redo integration (API 6.2)
- [ ] All bugs fixed (right note, etc.)

**Quality**:
- [ ] Zero crashes in testing
- [ ] All functions have validation
- [ ] All API calls have error handling
- [ ] All magic numbers replaced with constants
- [ ] Code duplication <10%
- [ ] Zero direct API calls outside accessors

**Documentation**:
- [ ] README with install instructions
- [ ] Suggested keyboard shortcuts documented
- [ ] User guide complete
- [ ] Developer guide complete
- [ ] All functions have inline docs

**Testing**:
- [ ] Unit tests for business logic
- [ ] Integration tests for operations
- [ ] Edge cases covered
- [ ] Regression tests for fixed bugs

---

## Key Architectural Decisions

### Why Layered Architecture?
**Decision**: Separate core, accessor, operation, and UI layers
**Rationale**: Enables testing, reduces coupling, clarifies responsibilities
**Tradeoff**: More files, but much better maintainability

### Why Abstract Renoise API?
**Decision**: All API calls through accessor layer
**Rationale**: Enable testing, validation, logging, and API change isolation
**Tradeoff**: Indirection overhead, but prevents crashes and enables testing

### Why Unified Operations?
**Decision**: Single `nudge(direction, property)` instead of duplicated up/down
**Rationale**: Reduce duplication from 180 to ~40 lines, fix bugs once
**Tradeoff**: Slightly more complex, but dramatically more maintainable

### Why Configuration System?
**Decision**: External config files instead of hardcoded values
**Rationale**: Users customize without code, developers debug easier
**Tradeoff**: Config complexity, but much better user experience

### Why Renoise 3.5 Focus?
**Decision**: Target API 6.2 with 3.4 compatibility
**Rationale**: Leverage phrase editor API, undo/redo, modern features
**Tradeoff**: Some features limited on 3.4, but graceful degradation

---

## Next Steps

1. **Review & Approve**: Team review this architectural plan
2. **Setup Environment**: LuaLS integration, testing framework
3. **Phase 1 Start**: Begin foundation implementation
4. **Weekly Check-ins**: Track progress, address blockers
5. **Continuous Testing**: Validate each phase before proceeding
6. **Documentation**: Write docs as features complete
7. **Beta Testing**: Community testing before release
8. **Release**: v2.0 with comprehensive changelog

---

## Conclusion

This architectural overhaul transforms Nudger from a working prototype into a professional, maintainable, feature-complete tool. By implementing proper separation of concerns, comprehensive error handling, Renoise 3.5 integration, and completing all TODO features, we create a foundation that supports years of growth.

The phased approach enables incremental progress while maintaining functionality. Renoise 3.5's new phrase editor API and undo/redo support provide perfect timing for this overhaul.

**The result**: A reliable, complete, well-documented tool that exemplifies quality Renoise plugin development and enables true keyboard-centric workflow mastery.
