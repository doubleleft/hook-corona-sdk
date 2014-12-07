--
-- hook.auth class
--
local auth = {}
auth.__index = auth

function auth.new(client)
  local self = setmetatable({}, auth)

  self.client = client
  self.currentUser = nil

  return self
end

function auth:getToken()
end

function auth:register()
end

function auth:login()
end

return auth
