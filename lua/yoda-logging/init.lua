local M = {}

function M.setup(opts)
  local config = require("yoda-logging.config")
  if opts then
    config.update(opts)
  end
end

M.trace = function(msg, context)
  return require("yoda-logging.logger").trace(msg, context)
end

M.debug = function(msg, context)
  return require("yoda-logging.logger").debug(msg, context)
end

M.info = function(msg, context)
  return require("yoda-logging.logger").info(msg, context)
end

M.warn = function(msg, context)
  return require("yoda-logging.logger").warn(msg, context)
end

M.error = function(msg, context)
  return require("yoda-logging.logger").error(msg, context)
end

M.set_level = function(level)
  return require("yoda-logging.logger").set_level(level)
end

M.set_strategy = function(strategy)
  return require("yoda-logging.logger").set_strategy(strategy)
end

M.flush = function()
  return require("yoda-logging.logger").flush()
end

M.clear = function()
  return require("yoda-logging.logger").clear()
end

M.LEVELS = require("yoda-logging.config").LEVELS

return M
