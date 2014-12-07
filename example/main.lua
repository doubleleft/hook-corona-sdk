-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local json = require('json')

--
-- Initialize hook client with valid credentials
--

local hook = require('hook.client').setup({
  endpoint = "http://hook.dev/public/index.php/",
  app_id = "2",
  key = "0473fae7392cc9653029f59b79126ace"
})

--
-- Collection examples
--
hook:collection("scores"):create({
  name = "Endel",
  score = 10
}):onSuccess(function(data)
  print("Created successfully.")
  print("Name: " .. data.name .. ", Score: " .. data.score .. ", Created at: " .. data.created_at)
end):onError(function(data)
  print("error on create")
end)

-- where and first
hook:collection("scores"):where("score", "<", 10):first():onSuccess(function(data)
  print("Score < 10?")
  print(json.encode(data))
end):onError(function()
  print("Not found!")
end)

-- where and count
hook:collection("scores"):where({
  score = 10
}):count():onSuccess(function(data)
  print("Total scores: " .. data)
end)

-- multiple wheres
hook:collection("scores"):
  where("score", 10):
  where("name", "Endel"):
  sort("created_at", -1):
  onSuccess(function(data)
  print("Number of rows: " .. #data .. ", first._id: " .. data[1]._id .. ", last._id: " .. data[#data]._id)
end)

-- aggregation
hook:collection("scores"):
  sum("score"):
  onSuccess(function(data)
  print("Sum of all scores: " .. data)
end)

-- --
-- -- Authentication examples
-- --
hook.auth:register({
  email = "edreyer@doubleleft.com",
  password = "123456"
}):onSuccess(function(data)
  print(json.encode(data))
end):onError(function(data)
  print("Error: " .. data.error)
end)
