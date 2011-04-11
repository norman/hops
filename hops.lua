require "wsapi.util"

local lp            = require "hops.lp"
local router        = require "hops.router"
local hops_request  = require "hops.request"
local hops_response = require "hops.response"
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
    self.response = hops_response.new(200, self.headers)
    self.route    = self.routes:match(self.request)

    if not self.route then
      self.template = self.templates["404"].path
      return self.response:finish(self.templates["404"]:render(), 404)
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
      if type(result) == "function" then
        return self.response:wrap(result)
      elseif result == nil then
        result = self.config.default_renderer(self.route.name)
      end
      return self.response:finish(result)
    else
      self.template = self.templates["500"].path
      self.error    = result
      local content = self.templates["500"]:render({error = result})
      return self.response:finish(content, 500)
    end
  end

  return self
end

return new
