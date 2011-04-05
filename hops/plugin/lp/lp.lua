local path      = require "pl.path"
local lp_module = require "hops.lp"
local mod       = {}
local app       = nil

local function lp(template, locals)
  local template     = path.join(app.config.views, template .. ".lp")
  local layout       = app.page.layout or app.config.layout
  app.locals.content = lp_module.render_file(template, app.locals)
  if layout then
    layout = path.join(app.config.views, layout .. ".lp")
    return lp_module.render_file(layout, app.locals)
  else
    return app.locals.content
  end
end

function mod.init(hops_app, options)
  app    = hops_app
  app.lp = lp
  local options = options or {}
  -- If no renderers have been added yet, make this the default even if not
  -- specified as such.
  if options.default == nil then
    options.default = #app.config.renderers == 0
  end
  if options.default then
    app.config.default_renderer = lp
    options.default = nil
  end
end

return mod
