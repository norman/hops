# Hops

Hops is a lightweight, pluggable web framework for Lua built on WSAPI.

It is currently in progress, so you probably shouldn't be using it yet.

To the greatest extent possible, Hops does everything via plugins, so that you
can use it as a bare-bone dispatcher, or (eventually) a full-stack MVC
framework.

Here's a sample bare-bones Hops app:

    module(..., require "hops", package.seeall)

    use "lp"
    use "logger"

    local function index()
      locals.title = "Welcome to the index page"
    end

    local function hello(name)
      locals.title = "Why, hello there"
      locals.name  = name
    end

    routes.index = get("/", index)
    routes.hello = get("/hello/()", hello)

To get a better idea of what you can do with Hops, for now see the example app
included with the source repository.

To run it, you can do this:

    git clone git://github.com/norman/hops
    cd hops
    ./hops run example

You can also install Hops via Luarocks, but at the moment you have to do it like this:

    git clone git://github.com/norman/hops
    cd hops
    sudo luarocks make rockspecs/hops-scm-1.rockspec

Hops is free software, released under the MIT License.

Copyright (c) 2011 Norman Clarke

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
