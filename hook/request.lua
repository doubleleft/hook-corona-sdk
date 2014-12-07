local network = require('network')
local json = require('json')

local request = {}
request.__index = request

function request.new(url, method, params)
  local self = setmetatable({}, request)
  local handler = function(e) self:handler(e); end

  -- callbacks
  self.onSuccessCallback = {}
  self.onErrorCallback = {}
  self.onCompleteCallback = {}

  -- properties
  self.completed = false
  self.response = nil
  self.isError = nil
  self.request = network.request(url, method, handler, params)

  return self
end

function request:onSuccess(callback)
  table.insert(self.onSuccessCallback, callback)

  -- call it immediatelly if response is already set
  if self.response and not self.isError then
    self.onSuccessCallback(self.response)
  end

  return self
end

function request:onError(callback)
  table.insert(self.onErrorCallback, callback)

  -- call it immediatelly if response is already set
  if self.response and self.isError then
    self.onErrorCallback(self.response)
  end

  return self
end

function request:onComplete(callback)
  table.insert(self.onCompleteCallback, callback)

  -- call it immediatelly if response is already set
  if self.response then
    self.onCompleteCallback(self.response)
  end

  return self
end

function request:triggerCallbacks(t, data)
  for k, callback in pairs(self[t]) do
    callback(data)
  end
end

function request:handler(event)
  self.isError = event.isError or (event.status >= 400)
  self.response = json.decode(event.response) or {}

  if self.isError then
    print("hook responed with error (".. event.status .. "): " .. (self.response.error or "unexpected"))

    -- call onError callback
    self:triggerCallbacks("onErrorCallback", self.response)
  else
    -- call onSuccess callback
    self:triggerCallbacks("onSuccessCallback", self.response)
  end

  -- call onComplete callback
  self:triggerCallbacks("onCompleteCallback", self.response)
end

return request
