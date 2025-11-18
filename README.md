# yoda-logging.nvim

> **Production-ready logging framework for Neovim with multiple output strategies.**

Strategy pattern (console/file/notify/multi), lazy evaluation, level filtering, structured context. 77 tests, ~95% coverage.

---

## 📋 Features

- **🎯 Multiple Strategies**: Console, file, notification, or combined (multi)
- **📊 Log Levels**: TRACE, DEBUG, INFO, WARN, ERROR with filtering
- **⚡ Lazy Evaluation**: Function-based messages for performance
- **🏷️ Structured Context**: Add contextual data to log messages
- **📁 File Rotation**: Automatic log file rotation with size limits
- **🧪 Well-Tested**: 77 tests covering all strategies and edge cases
- **🎨 Customizable**: Configure format, timestamps, levels

---

## 📦 Installation

### With [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "jedi-knights/yoda-logging.nvim",
  dependencies = {
    "jedi-knights/yoda.nvim-adapters", -- Optional, for notify strategy
  },
  config = function()
    require("yoda-logging").setup({
      strategy = "file",  -- or "console", "notify", "multi"
      level = require("yoda-logging").LEVELS.DEBUG,
    })
  end,
}
```

---

## 🚀 Quick Start

```lua
local logging = require("yoda-logging")

logging.setup({
  strategy = "file",
  level = logging.LEVELS.DEBUG,
  file = {
    path = vim.fn.stdpath("data") .. "/my-plugin.log",
    max_size = 1024 * 1024,
    rotate_count = 3,
  },
})

logging.trace("Very detailed trace")
logging.debug("Debug information")
logging.info("General information")
logging.warn("Warning message")
logging.error("Error occurred")

logging.info("User logged in", {
  user_id = 123,
  session = "abc-def",
  ip = "192.168.1.1",
})

logging.debug(function()
  return "Expensive: " .. vim.inspect(huge_table)
end)
```

---

## 📚 Strategies

### Console Strategy

Outputs to console using `print()`. Great for development.

```lua
local logging = require("yoda-logging")
logging.setup({ strategy = "console" })
```

### File Strategy

Writes to a log file with automatic rotation.

```lua
local logging = require("yoda-logging")
logging.setup({
  strategy = "file",
  file = {
    path = vim.fn.stdpath("log") .. "/yoda.log",
    max_size = 1024 * 1024,
    rotate_count = 3,
  },
})
```

**File rotation:** When the log file reaches `max_size`, it's rotated:
- `yoda.log` → `yoda.log.1`
- `yoda.log.1` → `yoda.log.2`
- Oldest backup is deleted

### Notify Strategy

Shows logs as Neovim notifications (via yoda-adapters).

```lua
local logging = require("yoda-logging")
logging.setup({ strategy = "notify" })
```

**Requires**: `yoda.nvim-adapters` for best experience (auto-detects noice/snacks, falls back to native).

### Multi Strategy

Combines console and file output for comprehensive logging.

```lua
local logging = require("yoda-logging")
logging.setup({ strategy = "multi" })
```

---

## ⚙️ Configuration

### Log Levels

```lua
local logging = require("yoda-logging")

logging.LEVELS.TRACE  -- 0 (most verbose)
logging.LEVELS.DEBUG  -- 1
logging.LEVELS.INFO   -- 2
logging.LEVELS.WARN   -- 3
logging.LEVELS.ERROR  -- 4 (least verbose)
```

### Runtime Configuration

```lua
local logging = require("yoda-logging")

logging.set_level("debug")
logging.set_level("warn")

logging.set_strategy("file")
logging.set_strategy("multi")

logging.flush()

logging.clear()
```

### Full Configuration

```lua
local logging = require("yoda-logging")

logging.setup({
  level = logging.LEVELS.INFO,
  strategy = "file",
  file = {
    path = vim.fn.stdpath("log") .. "/yoda.log",
    max_size = 1024 * 1024,
    rotate_count = 3,
  },
  format = {
    include_timestamp = true,
    include_level = true,
    include_context = true,
    timestamp_format = "%Y-%m-%d %H:%M:%S",
  },
  lazy_evaluation = true,
})
```

---

## 🏗️ Architecture

### Design Patterns

- **Strategy Pattern** (GoF #8): Pluggable output backends
- **Facade Pattern**: Simple API over complex subsystem
- **Lazy Evaluation**: Performance optimization for expensive operations

### Log Message Flow

```
1. Logger API (trace/debug/info/warn/error)
   ↓
2. Level Filtering (early bailout if below threshold)
   ↓
3. Lazy Evaluation (evaluate function messages if needed)
   ↓
4. Formatter (add timestamp, level, context)
   ↓
5. Strategy (console/file/notify/multi)
   ↓
6. Output (print/file write/notification)
```

---

## 📝 Examples

### Basic Logging

```lua
local logging = require("yoda-logging")

logging.info("Application started")
logging.debug("Loading configuration")
logging.warn("Deprecated API used")
logging.error("Failed to connect to server")
```

### Structured Context

```lua
local logging = require("yoda-logging")

logging.info("Request processed", {
  method = "GET",
  path = "/api/users",
  status = 200,
  duration_ms = 45,
})
```

### Lazy Evaluation

```lua
local logging = require("yoda-logging")

logging.debug(function()
  local expensive_data = compute_expensive_data()
  return "Result: " .. vim.inspect(expensive_data)
end)
```

### Plugin Integration

```lua
local M = {}
local logging = require("yoda-logging")

function M.setup(opts)
  logging.setup({
    strategy = opts.log_strategy or "file",
    level = opts.log_level or logging.LEVELS.INFO,
    file = {
      path = vim.fn.stdpath("data") .. "/my-plugin.log",
    },
  })
  
  logging.info("Plugin initialized", { version = "1.0.0" })
end

function M.do_something()
  logging.debug("Starting operation")
  
  local ok, err = pcall(function()
  end)
  
  if not ok then
    logging.error("Operation failed", { error = err })
  else
    logging.info("Operation completed")
  end
end

return M
```

---

## 🧪 Testing

```bash
# Run all tests
make test

# Check code style
make lint

# Format code
make format
```

---

## 📚 API Reference

### Setup

#### `setup(opts)`
Configure the logging system.

**Parameters:**
- `opts` (table|nil): Configuration options

### Logging Functions

#### `trace(msg, context)`
Log trace message (most verbose).

#### `debug(msg, context)`
Log debug message.

#### `info(msg, context)`
Log info message.

#### `warn(msg, context)`
Log warning message.

#### `error(msg, context)`
Log error message.

**Parameters:**
- `msg` (string|function): Message or lazy message function
- `context` (table|nil): Optional structured context

### Configuration

#### `set_level(level)`
Change log level at runtime.

**Parameters:**
- `level` (number|string): Level number or name ("trace", "debug", etc.)

#### `set_strategy(strategy)`
Change logging strategy at runtime.

**Parameters:**
- `strategy` (string): Strategy name ("console", "file", "notify", "multi")

### Utilities

#### `flush()`
Flush current strategy output.

#### `clear()`
Clear log output (if supported by strategy).

---

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass (`make test`)
5. Format code (`make format`)
6. Submit a pull request

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

## 🔗 Related Projects

- **[yoda.nvim](https://github.com/jedi-knights/yoda.nvim)** - Comprehensive Neovim distribution
- **[yoda.nvim-adapters](https://github.com/jedi-knights/yoda.nvim-adapters)** - Notification and picker adapters
- **[yoda-terminal.nvim](https://github.com/jedi-knights/yoda-terminal.nvim)** - Python venv terminal integration

---

## 💬 Support

- **Issues**: [GitHub Issues](https://github.com/jedi-knights/yoda-logging.nvim/issues)
- **Discussions**: [GitHub Discussions](https://github.com/jedi-knights/yoda-logging.nvim/discussions)

---

**May the Force be with you! ⚡**
