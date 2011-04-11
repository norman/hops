local class = {}

class.http_methods = {
  GET    = true,
  POST   = true,
  PUT    = true,
  DELETE = true
}

local function format_pattern(pattern)
  -- An empty capture is interpreted as "([^/]+)"
  pattern = pattern:gsub("%(%)", "([^/]+)")

  -- Patterns must always match from the beginning of the path.
  if not pattern:match("^^") then
    pattern = "^" .. pattern
  end
  -- Patterns must specify the entire path.
  if not pattern:match("$$") then
    pattern = pattern .. "/?$"
  end
  return pattern
end

local function format_method(method)
  local method = method:upper()
  if not class.http_methods[method] then
    error("Unsupported http method " .. method)
  end
  return method
end

local instance_methods = {}
local route_methods = {}

function instance_methods:match(request)
  for _, r in ipairs(self[request.method]) do
    if r.match_func(request) then
      return r
    end
  end
end

local function add_route(self, key, arg)
  local method  = arg.method
  local name    = key
  local path    = arg.path
  local pattern = format_pattern(arg.path)
  local func    = arg.func

  method = format_method(method)
  if not self[method] then self[method] = {} end

  local match_func = function(request)
    local rm = request.method
    local pi = request.env.PATH_INFO
    return rm == method and pi:match(pattern)
  end

  -- Add a path matching function to get paths from names and args
  local path_func_name = name .. "_path"
  self.app[path_func_name] = function(...)
    local args = {...}
    local i = 0
    local value = path:gsub("%b()", function()
      i = i + 1
      if args[i] then return args[i] end
      error(("missing argument %d to %s"):format(i, path_func_name))
    end)
    return value
  end

  table.insert(self[method], {
    name       = name,
    func       = func or function() end,
    pattern    = pattern,
    match_func = match_func
  })
end

function class.new(app)
  local instance = {app = app}
  for http_method, _ in pairs(class.http_methods) do
    instance[http_method] = {}
  end
  return setmetatable(instance, {
    __index    = instance_methods,
    __newindex = add_route
  })
end

return class
