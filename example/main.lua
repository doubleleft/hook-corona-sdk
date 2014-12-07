-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

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
hook:collection("posts"):create({
  title = "Runnng hook inside corona",
  since = "07-12-2014"
}):onSuccess(function(data)
  print("Post created successfully.")
  print("Title: " .. data.title)
  print("Created at: " .. data.created_at)
end):onError(function(data)
  print(data)
end)

--
-- Authentication examples
--
hook.auth:register({
  email = "edreyer@doubleleft.com",
  password = "123456"
})
