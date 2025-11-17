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
local logger = require("yoda-logging")

-- Setup (optional, has sensible defaults)
logger.setup({
  strategy = "file",  -- "console", "file", "notify", or "multi"
  level = logger.LEVELS.DEBUG,
  file = {
    path = vim.fn.stdpath("data") .. "/my-plugin.log",
    max_size = 1024 * 1024,  -- 1MB
    rotate_count = 3,
  },
})

-- Log at different levels
logger.trace("Very detailed trace")
logger.debug("Debug information")
logger.info("General information")
logger.warn("Warning message")
logger.error("Error occurred")

-- Add structured context
logger.info("User logged in", {
  user_id = 123,
  session = "abc-def",
  ip = "192.168.1.1",
})

-- Lazy evaluation (only evaluated if logged)
logger.debug(function()
  return "Expensive: " .. vim.inspect(huge_table)
end)
```

---

## 📚 Strategies

### Console Strategy

Outputs to console using `print()`. Great for development.

```lua
logger.setup({ strategy = "console" })
```

### File Strategy

Writes to a log file with automatic rotation.

```lua
logger.setup({
  strategy = "file",
  file = {
    path = vim.fn.stdpath("log") .. "/yoda.log",
    max_size = 1024 * 1024,  -- 1MB
    rotate_count = 3,  -- Keep 3 backups
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
logger.setup({ strategy = "notify" })
```

**Requires**: `yoda.nvim-adapters` for best experience (auto-detects noice/snacks, falls back to native).

### Multi Strategy

Combines console and file output for comprehensive logging.

```lua
logger.setup({ strategy = "multi" })
```

---

## ⚙️ Configuration

### Log Levels

```lua
local logger = require("yoda-logging")

logger.LEVELS.TRACE  -- 0 (most verbose)
logger.LEVELS.DEBUG  -- 1
logger.LEVELS.INFO   -- 2
logger.LEVELS.WARN   -- 3
logger.LEVELS.ERROR  -- 4 (least verbose)
```

### Runtime Configuration

```lua
-- Change level at runtime
logger.set_level("debug")  -- or logger.LEVELS.DEBUG
logger.set_level("warn")

-- Change strategy at runtime
logger.set_strategy("file")
logger.set_strategy("multi")

-- Flush output (ensures writes are committed)
logger.flush()

-- Clear logs (file strategy only)
logger.clear()
```

### Full Configuration

```lua
logger.setup({
  -- Minimum level to log
  level = logger.LEVELS.INFO,
  
  -- Strategy: "console", "file", "notify", or "multi"
  strategy = "file",
  
  -- File configuration
  file = {
    path = vim.fn.stdpath("log") .. "/yoda.log",
    max_size = 1024 * 1024,  -- 1MB
    rotate_count = 3,
  },
  
  -- Message formatting
  format = {
    include_timestamp = true,
    include_level = true,
    include_context = true,
    timestamp_format = "%Y-%m-%d %H:%M:%S",
  },
  
  -- Performance
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
local logger = require("yoda-logging")

logger.info("Application started")
logger.debug("Loading configuration")
logger.warn("Deprecated API used")
logger.error("Failed to connect to server")
```

### Structured Context

```lua
logger.info("Request processed", {
  method = "GET",
  path = "/api/users",
  status = 200,
  duration_ms = 45,
})

-- Output:
-- [2025-11-17 15:30:45] [INFO] Request processed | method=GET path=/api/users status=200 duration_ms=45
```

### Lazy Evaluation

```lua
-- Expensive operation only runs if DEBUG level is enabled
logger.debug(function()
  local expensive_data = compute_expensive_data()
  return "Result: " .. vim.inspect(expensive_data)
end)
```

### Plugin Integration

```lua
-- In your plugin
local M = {}
local logger = require("yoda-logging")

function M.setup(opts)
  logger.setup({
    strategy = opts.log_strategy or "file",
    level = opts.log_level or logger.LEVELS.INFO,
    file = {
      path = vim.fn.stdpath("data") .. "/my-plugin.log",
    },
  })
  
  logger.info("Plugin initialized", { version = "1.0.0" })
end

function M.do_something()
  logger.debug("Starting operation")
  
  local ok, err = pcall(function()
    -- Your code here
  end)
  
  if not ok then
    logger.error("Operation failed", { error = err })
  else
    logger.info("Operation completed")
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
