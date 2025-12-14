local M = {}

local _is_setup = false
local _logger = nil
local _config = nil

local function get_logger()
  if not _logger then
    _logger = require("yoda-logging.logger")
  end
  return _logger
end

local function get_config()
  if not _config then
    _config = require("yoda-logging.config")
  end
  return _config
end

function M.setup(opts)
  if _is_setup then
    vim.notify("yoda-logging.nvim: setup() called multiple times", vim.log.levels.WARN)
    return
  end

  local config = get_config()
  if opts then
    config.update(opts)
  end
  _is_setup = true
end

M.trace = function(msg, context)
  return get_logger().trace(msg, context)
end

M.debug = function(msg, context)
  return get_logger().debug(msg, context)
end

M.info = function(msg, context)
  return get_logger().info(msg, context)
end

M.warn = function(msg, context)
  return get_logger().warn(msg, context)
end

M.error = function(msg, context)
  return get_logger().error(msg, context)
end

M.set_level = function(level)
  return get_logger().set_level(level)
end

M.set_strategy = function(strategy)
  return get_logger().set_strategy(strategy)
end

M.flush = function()
  return get_logger().flush()
end

M.clear = function()
  return get_logger().clear()
end

setmetatable(M, {
  __index = function(t, k)
    if k == "LEVELS" then
      local levels = get_config().LEVELS
      rawset(t, k, levels)
      return levels
    end
  end
})

return M
