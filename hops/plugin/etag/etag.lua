-- A simple ETag plugin. When invoked explicitly in an action, sets an ETag for
-- the response. When not invoked explicitly, sets an ETag that is an MD5 of the
-- response body (if possible).

local path      = require "md5"
local mod       = {}
local app       = nil

local function etag(string)
  return md5.sumhexa(string)
end

function mod.init(hops_app, options)
  app               = hops_app
  local wrapped_run = app.run

  app.etag = function(string)
    app.response.headers["ETag"] = etag(string)
  end

  function app.run(env)
    code, headers, result = wrapped_run(env)
    if app.body and not headers["ETag"] then 
      headers["ETag"] = etag(app.body)
    end
    return code, headers, result
  end
end

return mod
