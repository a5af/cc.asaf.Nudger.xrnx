# Note Properties (Nudger) - Tests

Automated test suite using Busted testing framework.

## Setup

### Install Busted

**Using LuaRocks** (Recommended):
```bash
luarocks install busted
```

**Using Package Manager**:
```bash
# macOS
brew install luarocks
luarocks install busted

# Ubuntu/Debian
sudo apt-get install luarocks
luarocks install busted
```

### Install Dependencies

```bash
cd /home/asafe/Repo/cc.asaf.Nudger.xrnx
luarocks install --local busted
```

## Running Tests

### Run All Tests

```bash
busted
```

### Run Specific Test File

```bash
busted tests/spec/core/constants_spec.lua
```

### Run Tests with Coverage

```bash
busted --coverage
```

### Run Tests Verbosely

```bash
busted --verbose
```

## Test Structure

```
tests/
├── README.md                    # This file
├── spec/                        # Test specifications
│   ├── core/                    # Core module tests
│   │   ├── constants_spec.lua   # Constants tests
│   │   ├── validator_spec.lua   # Validator tests (TODO)
│   │   └── config_manager_spec.lua  # Config tests (TODO)
│   ├── operations/              # Operation tests (TODO)
│   │   ├── nudge_spec.lua
│   │   ├── move_spec.lua
│   │   └── clone_spec.lua
│   └── helpers/                 # Test helpers
│       └── mock_renoise.lua     # Mock Renoise API
```

## Writing Tests

### Example Test

```lua
describe("MyModule", function()
  local MyModule

  setup(function()
    -- Setup before all tests
    MyModule = require('path/to/my_module')
  end)

  teardown(function()
    -- Cleanup after all tests
  end)

  before_each(function()
    -- Setup before each test
  end)

  after_each(function()
    -- Cleanup after each test
  end)

  it("should do something", function()
    local result = MyModule.do_something()
    assert.equals(expected, result)
  end)

  it("should handle errors", function()
    assert.has_error(function()
      MyModule.do_bad_thing()
    end)
  end)
end)
```

### Assertions

**Equality**:
```lua
assert.equals(expected, actual)
assert.same({a=1}, {a=1})  -- Deep equality
```

**Truthiness**:
```lua
assert.is_true(value)
assert.is_false(value)
assert.is_nil(value)
assert.is_not_nil(value)
```

**Errors**:
```lua
assert.has_error(function() error("oops") end)
assert.has_no_error(function() return true end)
```

**Type Checking**:
```lua
assert.is_string(value)
assert.is_number(value)
assert.is_table(value)
assert.is_function(value)
```

## Mocking

### Using Mock Renoise

```lua
local MockRenoise = require('tests/spec/helpers/mock_renoise')

describe("Pattern Operations", function()
  local song

  before_each(function()
    -- Setup mock Renoise API
    MockRenoise.setup_global()

    -- Create mock song
    song = MockRenoise.create_mock_song()
    song.patterns[1] = MockRenoise.create_mock_pattern(8, 64)
    song.tracks[1] = song.patterns[1].tracks[1]

    MockRenoise.set_song(song)
  end)

  after_each(function()
    MockRenoise.teardown_global()
  end)

  it("should work with mocked API", function()
    local current_song = renoise.song()
    assert.equals(song, current_song)
  end)
end)
```

## Current Test Coverage

- ✅ `core/constants.lua` - Complete
- ⏳ `core/validator.lua` - TODO
- ⏳ `core/config_manager.lua` - TODO
- ⏳ `core/error_handler.lua` - TODO
- ⏳ `operations/nudge.lua` - TODO
- ⏳ `operations/move.lua` - TODO
- ⏳ `operations/clone.lua` - TODO
- ⏳ `operations/clear.lua` - TODO

## Testing Strategy

### Phase 1: Pure Functions (Current)
Test modules without Renoise API dependencies:
- Constants
- Validators (value range checks)
- Config utilities

### Phase 2: Mocked API
Test modules using mocked Renoise API:
- Accessors (with mock song/patterns)
- Operations (with mock context)

### Phase 3: Integration Tests
Test with actual Renoise (manual):
- Create test songs
- Verify operations in real environment
- Performance testing

## CI Integration

### GitHub Actions (Future)

```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: leafo/gh-actions-lua@v9
      - uses: leafo/gh-actions-luarocks@v4
      - run: luarocks install busted
      - run: busted --verbose --coverage
```

## Troubleshooting

### Tests Won't Run

**Issue**: `busted: command not found`

**Solution**:
```bash
# Install busted globally
sudo luarocks install busted

# Or add to PATH
export PATH=$PATH:~/.luarocks/bin
```

### Module Not Found

**Issue**: `module 'core/constants' not found`

**Solution**: Run busted from project root:
```bash
cd /home/asafe/Repo/cc.asaf.Nudger.xrnx
busted
```

### Mock Renoise Issues

**Issue**: Mock doesn't match real Renoise API

**Solution**: Update `mock_renoise.lua` based on actual API behavior. Check Renoise docs.

## Contributing Tests

1. Create test file: `tests/spec/module_name_spec.lua`
2. Follow naming convention: `*_spec.lua`
3. Include describe blocks for organization
4. Write clear test names: `"should do X when Y"`
5. Add mocks if needed
6. Update coverage list in this README

## Resources

- [Busted Documentation](https://lunarmodules.github.io/busted/)
- [Renoise Scripting API](https://tutorials.renoise.com/wiki/Scripting)
- [Lua Testing Best Practices](https://github.com/lunarmodules/busted/wiki)
