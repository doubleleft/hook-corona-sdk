--
-- core dependencies
--
local json = require('json')

--
-- hook dependencies
--
local auth = require('hook.auth')
local collection = require('hook.collection')
local key_values = require('hook.key_values')
local system = require('hook.system')

local url = require('hook.utils.url')
local request = require('hook.request')

--
-- hook.client class
--
local client = {}
client.__index = client

function client.setup(config)
  local self = setmetatable({}, client)

  self.config = config

  -- ensure that the endpoint has a final slash
  if not string.match(self.config.endpoint, "/$") then
    self.config.endpoint = self.config.endpoint .. "/"
  end

  self.auth = auth.new(self)
  self.key_values = key_values.new(self)
  self.system = system.new(self)

  return self
end

function client:collection(name)
  return collection.new(self, name)
end

function client:channel(name)
  error("not implemented")
end

function client:get(segments, data)
  return self:request(segments, "GET", data);
end

function client:post(segments, data)
  return self:request(segments, "POST", data);
end

function client:put(segments, data)
  return self:request(segments, "PUT", data);
end

function client:remove(segments, data)
  return self:request(segments, "DELETE", data);
end

function client:request(segments, method, data)
  data = json.encode(data)
  local params = {
    headers = self:getHeaders()
  }

  if method == "GET" then
    segments = segments .. "?" .. data
  else
    params["body"] = data
  end

  local request = request.new(self.config.endpoint .. segments, method, params)
  return request
end

function client:getHeaders()
  local headers = {}
  headers["Content-Type"] = "application/json"
  headers["X-App-Id"] = self.config.app_id
  headers["X-App-Key"] = self.config.key

  if self.auth.currentUser then
    headers["X-Auth-Token"] = self.auth:getToken()
  end

  return headers
end

return client
