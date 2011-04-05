require "wsapi.request"
require "wsapi.response"
require "wsapi.util"

local lp            = require "hops.lp"
local router        = require "hops.router"
local template_path = debug.getinfo(1).source:match("@(.*)$"):gsub("hops.lua", "hops/templates")

local default_config = {
  views            = "views",
  layout           = "layout",
  renderers        = {},
  default_renderer = function(str)
    error("No default renderer has been configured")
  end
}

local function emulate_http_methods(request)
  if request.POST._method then
    local method = request.POST._method:upper()
    request.env.REQUEST_METHOD = method
    request.method = method
    request.POST._method = nil
  end
  return request
end

local function load_templates(...)
  local templates = {}
  for _, filename in ipairs({...}) do
    local path = template_path .. "/" .. filename .. ".lp"
    local str  = assert(io.open(path, "r")):read("*a")
    templates[filename] = lp.new(str):compile()
    templates[filename].path = path
  end
  return templates
end

local function use_plugin(app, plugin_name, options)

  local plugin_path = plugin_name
  if not plugin_name:match("%.") then
    plugin_path = ("hops.plugin.%s.%s"):format(plugin_name, plugin_name)
  end
  local plugin = require(plugin_path)
  plugin.init(app, options)
end

local function new(self, config)
  self.config           = setmetatable(config or {}, {__index = default_config})
  self.routes           = router.new(self)
  self.templates        = load_templates("404", "500")
  self.use              = function(...)
    use_plugin(self, ...)
  end

  -- DSL methods for setting up routes
  for method, _ in pairs(router.http_methods) do
    self[method:lower()] = function(path, func)
      return {method = method, path = path, func = func}
    end
  end

  self.run = function(wsapi_env)
    local request  = emulate_http_methods(wsapi.request.new(wsapi_env))
    local headers  = {["Content-Type"]= "text/html; charset=utf-8"}
    local response = wsapi.response.new(200, headers)
    local route    = self.routes:match(wsapi_env)

    if not route then
      self.template = self.templates["404"].path
      response:write(self.templates["404"]:render())
      response.status = 404
      return response:finish()
    end

    -- extract input params from routes
    local input = {wsapi_env.PATH_INFO:match(route.pattern)}

    -- extract params from GET and POST
    local params = {}
    for _, method in ipairs({"GET", "POST"}) do
      if request[method] then
        for k, v in pairs(request[method]) do
          params[k] = v
        end
      end
    end

    local function respond()
      self.route    = route
      self.response = response
      self.request  = request
      self.params   = params
      self.headers  = headers
      self.page     = {}
      self.template = nil
      self.error    = nil
      self.locals   = setmetatable({}, {__index = self})
      return route.func(unpack(input))
    end

    local ok, result = xpcall(respond, debug.traceback)
    if ok then
      -- If the action returns a function, then return a coroutine that WSAPI
      -- can use to provide streaming output.
      if type(result) == "function" then
        return response.status, response.headers, coroutine.wrap(result)
      -- If the return value is nil, then render with the default renderer.
      elseif result == nil then
        result = self.config.default_renderer(route.name)
      end
      response:write(result)
      return response:finish()
    else
      self.template = self.templates["500"].path
      self.error = result
      response:write(self.templates["500"]:render({error = result}))
      response.status = 500
      return response:finish()
    end
  end

  return self
end

return new
