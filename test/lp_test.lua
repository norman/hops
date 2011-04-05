require "telescope"
local lp = require "hops.lp"

telescope.make_assertion("render", "\n%s to render as:\n%s",
  function(string, expected, locals)
    local rendered = lp.render_string(string, locals)
    return expected == rendered
  end
)

context("Lua Pages", function()
  context("rendering a string", function()

    test("with simple prints", function()
      assert_render("hello <%= var %>!", "hello world!", {var = "world"})
    end)

    test("with no code", function()
      assert_render("hello world!", "hello world!")
    end)

    test("with statements", function()
      local fixture = "<a>\n<% for i=1,3 do %>\n<b></b>\n<% end %>\n</a>"
      local expected = "<a>\n\n<b></b>\n\n<b></b>\n\n<b></b>\n\n</a>"
      assert_render(fixture, expected)
    end)

    test("with statements and chomping", function()
      local fixture = "<a>\n<% for i=1,3 do -%>\n<b></b>\n<% end -%>\n</a>"
      local expected = "<a>\n<b></b>\n<b></b>\n<b></b>\n</a>"
      assert_render(fixture, expected)
    end)

  end)
end)
