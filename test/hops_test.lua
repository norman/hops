package.path = ("./?.lua;%s"):format(package.path)
require "wsapi.mock"
local pretty = require "pl.pretty"
local hops = require "hops"

context("Hops", function()

  local app, mock

  context("Initialization", function()
    before(function()
      app = hops({}, {})
    end)

    for _, name in ipairs({"config", "routes", "templates", "run", "use"}) do
      test("should assign a value to app." .. name, function()
        assert_not_nil(app[name])
      end)
    end

  end)

  context("Requests", function()

    before(function()
      app = hops({}, {})
      mock = wsapi.mock.make_handler(app)
    end)

    test("Should initialize a state table with framework-related request info")
    test("Should not preserve state between requests")

    test("Should emulate PUT", function()
      app.routes.hello = app.put("/hello", function() return "hello!" end)
      local response = mock:post("/hello", {_method = "PUT"})
      assert_equal(200, response.code)
    end)

    test("Should emulate DELETE", function()
      app.routes.hello = app.delete("/hello", function() return "hello!" end)
      local response = mock:post("/hello", {_method = "DELETE"})
      assert_equal(200, response.code)
    end)
  end)

  context("Handling errors", function()
    before(function()
      app = hops({}, {})
      mock = wsapi.mock.make_handler(app)
    end)

    test("should use 404 template for 404 errors", function()
      local response = mock:get("/hello")
      assert_equal("./hops/templates/404.lp", app.template)
    end)

    test("should use 500 template for 500 errors", function()
      app.routes.hello = app.get("/hello", function() error "hello!" end)
      local response = mock:get("/hello")
      assert_equal("./hops/templates/500.lp", app.template)
    end)

    test("should assign error to a variable for use by plugins", function()
      app.routes.hello = app.get("/hello", function() error "hello!" end)
      local response = mock:get("/hello")
      assert_not_nil(app.error)
    end)
  end)

  context("Response codes", function()

    before(function()
      app = hops({}, {})
      mock = wsapi.mock.make_handler(app)
    end)

    test("should respond 200 when all is well", function()
      app.routes.hello = app.get("/hello", function() return "hello!" end)
      local response = mock:get("/hello")
      assert_equal(200, response.code)
    end)

    test("should respond 404 for unrecognized paths", function()
      local response = mock:get("/hello")
      assert_equal(404, response.code)
    end)

    test("should respond 500 for errors", function()
      app.routes.hello = app.get("/hello", function() error "hello!" end)
      local response = mock:get("/hello")
      assert_equal(500, response.code)
    end)
  end)
end)


