require "wsapi.mock"

local app = wsapi.mock.make_handler(require "app")

do
  print("test debug")
  local response = app:get("/debug")
  assert(200 == response.code)
end

do
  print("test hello")
  local response = app:get("/hello")
  assert(200 == response.code)
end

do
  print("test 404")
  local response = app:get("/this/does/not/exist")
  assert(404 == response.code)
end