require "wsapi.request"

local class   = {}
local methods = {}

function class.new(env)
  local instance = {}
  local request  = wsapi.request.new(env)

  if request.POST._method then
    instance.method = request.POST._method:upper()
  else
    instance.method = env.REQUEST_METHOD
  end

  instance.params        = {}
  instance.env           = env
  instance.wsapi_request = request

  -- extract params from GET and POST
  for _, method in ipairs({"GET", "POST"}) do
    if request[method] then
      for k, v in pairs(request[method]) do
        instance.params[k] = v
      end
    end
  end

  return setmetatable(instance, {__index = function(table, key)
    return rawget(table, key) or methods[key] or request[key]
  end})
end

return class
