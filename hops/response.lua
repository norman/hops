require "wsapi.response"

local class   = {}
local methods = {}

function methods:finish(content, status)
  if status then self.wsapi_response.status = status end
  if content then self:write(content) end
  return self.wsapi_response:finish()
end

function methods:write(content)
  return self.wsapi_response:write(content)
end

function methods:wrap(func)
  return self.wsapi_response.status, self.wsapi_response.headers, coroutine.wrap(func)
end

function class.new(status, headers)
  local status  = status or 200
  local headers = headers or {["Content-Type"]= "text/html; charset=utf-8"}
  local instance = {
    headers        = headers,
    wsapi_response = wsapi.response.new(status, headers)
  }
  return setmetatable(instance, {__index = methods})
end

return class