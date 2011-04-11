require "wsapi.response"
require "wsapi.util"

local lp            = require "hops.lp"
local router        = require "hops.router"
local hops_request  = require "hops.request"
local template_path = debug.getinfo(1).source:match("@(.*)$"):gsub("hops.lua", "hops/templates")

local default_config = {
  views            = "views",
  layout           = "layout",
  renderers        = {},
  default_renderer = function(str)
    error("No default renderer has been configured")
  end
}

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
  self.config    = setmetatable(config or {}, {__index = default_config})
  self.routes    = router.new(self)
  self.templates = load_templates("404", "500")
  self.use       = function(...) use_plugin(self, ...) end

  -- DSL methods for setting up routes
  for method, _ in pairs(router.http_methods) do
    self[method:lower()] = function(path, func)
      return {method = method, path = path, func = func}
    end
  end

  self.run = function(wsapi_env)
    self.request  = hops_request.new(wsapi_env)
    self.headers  = {["Content-Type"]= "text/html; charset=utf-8"}
    self.response = wsapi.response.new(200, self.headers)
    self.route    = self.routes:match(self.request)

    if not self.route then
      self.template = self.templates["404"].path
      self.response:write(self.templates["404"]:render())
      self.response.status = 404
      return self.response:finish()
    end

    self.params   = self.request.params
    self.page     = {}
    self.template = nil
    self.error    = nil
    self.locals   = setmetatable({}, {__index = self})

    local function respond()
      -- extract input params from routes
      local input = {self.request.env.PATH_INFO:match(self.route.pattern)}
      return self.route.func(unpack(input))
    end

    local ok, result = xpcall(respond, debug.traceback)
    if ok then
      -- If the action returns a function, then return a coroutine that WSAPI
      -- can use to provide streaming output.
      if type(result) == "function" then
        return self.response.status, self.response.headers, coroutine.wrap(result)
      -- If the return value is nil, then render with the default renderer.
      elseif result == nil then
        result = self.config.default_renderer(self.route.name)
      end
      self.response:write(result)
      return self.response:finish()
    else
      self.template = self.templates["500"].path
      self.error = result
      self.response:write(self.templates["500"]:render({error = result}))
      self.response.status = 500
      return self.response:finish()
    end
  end

  return self
end

return new
