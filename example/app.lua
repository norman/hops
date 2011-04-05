module("app", require "hops", package.seeall)

use "logger"
use "lp"

local function index()
  locals.title = "Hops: Home"
end

local function debug()
  locals.title   = "Hops: Debug"
  locals.request = request
  locals.route   = route
end

local function hello(name)
  locals.title = "Hops: Hello!"
  locals.name  = name
end

routes.index = get("/", index)
routes.debug = get("/debug", debug)
routes.hello = get("/hello/()", hello)
