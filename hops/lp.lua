local class = {
  pattern = '<%%(=?)(.-)(%-?)%%>'
}

local methods = {}

function class.new(str)
  local instance = {str = str}
  setmetatable(instance, {__index = methods})
  instance:compile(str)
  return instance
end

function class.render_string(str, locals)
  local lp = class.new(str)
  lp:compile()
  return lp:render(locals)
end

function class.render_file(path, locals)
  local template = assert(io.open(path, "r")):read("*a")
  return class.render_string(template, locals)
end

function methods:add_code(operator, code)
  if operator ~= "" then
    table.insert(self.buffer, ("__write__(%s);"):format(code))
  else
    table.insert(self.buffer, ("%s"):format(code))
  end
end

function methods:add_string(first, last)
  table.insert(self.buffer, ("__write__(%q);"):format(self.str:sub(first, last)))
end

function methods:chomp()
  self.buffer[#self.buffer] = self.buffer[#self.buffer]:gsub('\\\n"%);', '");')
end

function methods:precompile()
  local first, last, operator, code, should_chomp = self.str:find(class.pattern, self.position)
  if not first then return self:add_string(self.position, #self.str) end
  self:add_string(self.position, first - 1)
  if should_chomp ~= "" then self:chomp() end
  self:add_code(operator, code)
  self.position = last + 1
  self:precompile()
  return self
end

function methods:compile()
  self:init()
  self:precompile()
  self.precompiled = table.concat(self.buffer)
  self.compiled = assert(loadstring(self.precompiled))
  self:init()
  return self
end

function methods:init()
  self.buffer   = {}
  self.position = 1
  return self
end

function methods:render(locals)
  local buffer     = {}
  local locals     = locals or {}
  locals.__write__ = function(str) table.insert(buffer, str) end
  setfenv(self.compiled, locals or {})
  self.compiled()
  return table.concat(buffer)
end

return class
