local path = require "pl.path"
local mod  = {}
local app  = nil

local function haml(template, locals)
  local template     = path.join(app.config.views, template .. ".haml")
  local layout       = app.page.layout or app.config.layout
  app.locals.content = app.haml_engine:render_file(template, app.locals)
  if layout then
    layout = path.join(app.config.views, layout .. ".haml")
    return app.haml_engine:render_file(layout, app.locals)
  else
    return app.locals.content
  end
end

function mod.init(hops_app, options)
  app      = hops_app
  app.haml = haml
  local options = options or {}
  -- If no renderers have been added yet, make this the default even if not
  -- specified as such.
  if options.default == nil then
    options.default = #app.config.renderers == 0
  end
  if options.default then
    app.config.default_renderer = haml
    options.default = nil
  end
  app.haml_engine = require("haml").new(options)
end

return mod
