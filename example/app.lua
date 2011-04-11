module("app", require "hops", package.seeall)

use "logger"
use "lp"

local function index()
  locals.title = "Hops: Home"
end

local function debug()
  locals.title    = "Hops: Debug"
  locals.request  = request
  locals.route    = route
  locals.response = response
end

local function hello(name)
  locals.title = "Hops: Hello!"
  locals.name  = name
end

-- This demonstrates WSAPI's response streaming. You may have to view this
-- in Mozilla as Webkit defaults to a larger buffer before showing the page.
local function stream()
  return function()
    for i=1,10 do
      -- Portable sleep, but pegs CPU at 100%. For demo purposes only!
      local t0 = os.clock()
      while os.clock() - t0 <= 0.3 do end
      coroutine.yield(i .. "<br/>\n")
    end
  end
end

routes.index  = get("/", index)
routes.debug  = get("/debug", debug)
routes.hello  = get("/hello/()", hello)
routes.stream = get("/stream", stream)
