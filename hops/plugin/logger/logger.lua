local mod = {}

local function log(app, start, finish)
  local start  = start  or 0
  local finish = finish or 0
  local route  = app.response.route
  print(
    app.request.method,
    app.request.path_info,
    "route: " .. (route and route.name or "NONE"),
    ("%.4f"):format(finish - start)
  )
end

function mod.init(app, log_func)
  local socket      = require "socket"
  local wrapped_run = app.run
  
  function app.run(env)
    local log_func             = log_func or log
    local start                = socket.gettime()
    local code, header, result = wrapped_run(env)
    log_func(app, start, socket.gettime())
    return code, header, result
  end
end

return mod