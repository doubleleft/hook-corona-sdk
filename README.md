hook-corona-sdk
===========

CoronaSDK client for [hook](https://github.com/doubleleft/hook).

Check the [usage example](example/) with instructions to setup.

Usage
---

**Initialize hook client with valid credentials**

```lua
local hook = require('hook.client').setup({
  endpoint = "http://localhost:4665/",
  app_id = "1",
  key = "0473fae7392cc9653029f59b79126ace" -- your application "device" key
})
```

**Collection examples**

```lua
hook:collection("scores"):create({
  name = "Endel",
  score = 10
}):onSuccess(function(data)
  print("Created successfully.")
  print("Name: " .. data.name .. ", Score: " .. data.score .. ", Created at: " .. data.created_at)
end):onError(function(data)
  print("error on create")
end)
```

```lua
-- where and first
hook:collection("scores"):where("score", "<", 10):first():onSuccess(function(data)
  print("Score < 10?")
  print(json.encode(data))
end):onError(function()
  print("Not found!")
end)
```

```lua
-- where and count
hook:collection("scores"):where({
  score = 10
}):count():onSuccess(function(data)
  print("Total scores: " .. data)
end)
```

```lua
-- multiple wheres
hook:collection("scores"):
  where("score", 10):
  where("name", "Endel"):
  sort("created_at", -1):
  onSuccess(function(data)
  print("Number of rows: " .. #data .. ", first._id: " .. data[1]._id .. ", last._id: " .. data[#data]._id)
end)
```

```lua
-- aggregation
hook:collection("scores"):
  sum("score"):
  onSuccess(function(data)
  print("Sum of all scores: " .. data)
end)
```

**Authentication examples**

```lua
-- user registration
hook.auth:register({
  email = "edreyer@doubleleft.com",
  password = "123456"
}):onSuccess(function(data)
  print(json.encode(data))
end):onError(function(data)
  print("auth:register error: " .. data.error)
end)
```

```lua
-- user login
hook.auth:login({
  email = "somebody@email.com",
  password = "test"
}):onSuccess(function(data)
  print("Logged in: " .. json.encode(data))
end):onError(function(data)
  print("auth:login error: " .. data.error)
end)
```

TODO
---

- Write test units
- Push notifications
- Channels API
- Remove CoronaSDK dependency and publish a [luarocks](http://luarocks.org/)
  package.
  - Use [socket.http](http://w3.impa.br/~diego/software/luasocket/http.html)
    instead of corona.network
  - Use [lua-resty-libcjson](https://github.com/bungle/lua-resty-libcjson)
    instead of corona.json

This library was tested only against CoronaSDK 2014.2511. It possible runs on
older versions. Please create a pull-request if you find any problem.

License
---

MIT
