package = "hops"
version = "scm-1"
source = {
   url = "git://github.com/norman/hops.git",
}
description = {
   summary = "A pluggable web framework written in Lua.",
   detailed = [[
      Hops is an in-progress, lightweight, pluggable web framework written in Lua.
   ]],
   license = "MIT/X11",
   homepage = "http://github.com/norman/hops"
}
dependencies = {
   "lua >= 5.1",
   "wsapi",
   "wsapi-xavante"
}

build = {
  type = "builtin",
  modules = {
    hops                          = "hops.lua",
    ["hops.router"]               = "hops/router.lua",
    ["hops.lp"]                   = "hops/lp.lua",
    ["hops.plugin.haml.haml"]     = "hops/plugin/haml/haml.lua",
    ["hops.plugin.lp.lp"]         = "hops/plugin/lp/lp.lua",
    ["hops.plugin.logger.logger"] = "hops/plugin/logger/logger.lua"
  },
  install = {
    lua = {
      ["hops.templates.404"] = "hops/templates/404.lp",
      ["hops.templates.500"] = "hops/templates/500.lp"
    },
    bin = {
      hops = "bin/hops"
    },
  },
}
