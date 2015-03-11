local json = require('json')
local storage = require('hook.utils.storage')

--
-- hook.auth class
--
local auth = {}
auth.__index = auth

local AUTH_DATA_KEY = 'hook-auth-data'
local AUTH_TOKEN_KEY = 'hook-auth-token'
local AUTH_TOKEN_EXPIRATION = 'hook-auth-token-expiration'

local strtotime = function(str)
  if str == "" then
    return os.time()
  end

  -- extracted from http://forums.coronalabs.com/topic/29019-convert-string-to-date/
  local pattern = "(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)([%+%-])(%d+)%:(%d+)"
  local xyear, xmonth, xday, xhour, xminute, xseconds, xoffset, xoffsethour, xoffsetmin = str:match(pattern)
  local convertedTimestamp = os.time({
    year = xyear,
    month = xmonth,
    day = xday,
    hour = xhour,
    min = xminute,
    sec = xseconds
  })
  local offset = xoffsethour * 60 + xoffsetmin
  if xoffset == "-" then offset = offset * -1 end
  return convertedTimestamp + offset
end

function auth.new(client)
  local self = setmetatable({}, auth)

  self.client = client
  self.currentUser = nil

  local tokenExpiration = strtotime(storage.get(client.config.app_id .. '-' .. AUTH_TOKEN_EXPIRATION) or "")
  local currentUser = storage.get(client.config.app_id .. '-' .. AUTH_DATA_KEY)
  local now = os.time()

  -- Fill current user only when it isn't expired yet.
  if (currentUser and now < tokenExpiration) then
    self.currentUser = json.decode(currentUser)
  end

  return self
end

function auth:setCurrentUser(data)
  if not data then
    -- TODO: trigger logout event
    -- self.trigger('logout', self.currentUser);
    self.currentUser = data

    storage.remove(self.client.config.app_id .. '-' .. AUTH_TOKEN_KEY)
    storage.remove(self.client.config.app_id .. '-' .. AUTH_DATA_KEY)
  else
    storage.set(self.client.config.app_id .. '-' .. AUTH_DATA_KEY, json.encode(data))

    self.currentUser = data

    -- TODO: trigger login event
    -- self.trigger('login', data);
  end

  return self
end

function auth:register(data)
  local request = self.client:post("auth/email", data)

  request:onSuccess(function(response)
    self:_registerToken(response)
  end)

  return request
end

function auth:login(data)
  local request = self.client:post("auth/email/login", data)

  request:onSuccess(function(response)
    self:_registerToken(response)
  end)

  return request
end

function auth:update(data)
  if not self.currentUser then
    error("not logged in.")
  end

  local request = self.client:post("auth/update", data)

  request:onSuccess(function(data)
    self:setCurrentUser(data)
  end)

  return request
end

function auth:forgotPassword(data)
  return self.client:post("auth/email/forgotPassword", data)
end

function auth:resetPassword(data)
  if not data.token then
    error("'token' is required to reset password.")
  end

  if not data.password then
    error("'password' is required to reset password.")
  end

  return self.client:post("auth/email/resetPassword", data)
end

function auth:logout()
  return self:setCurrentUser(nil)
end

function auth:getToken()
  return storage.get(self.client.config.app_id .. '-' .. AUTH_TOKEN_KEY)
end

function auth:_registerToken(data)
  if data.token then
    -- register authentication token on localStorage
    storage.set(self.client.config.app_id .. '-' .. AUTH_TOKEN_KEY, data.token.token);
    storage.set(self.client.config.app_id .. '-' .. AUTH_TOKEN_EXPIRATION, data.token.expire_at);

    data["token"] = nil

    -- Store curent user
    self:setCurrentUser(data);
  end
end

return auth
