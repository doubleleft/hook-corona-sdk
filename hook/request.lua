local network = require('network')
local json = require('json')

local request = {}
request.__index = request

function request.new(url, method, params)
  local self = setmetatable({}, request)
  local handler = function(e) self:handler(e); end

  -- callbacks
  self.onSuccessCallback = nil
  self.onErrorCallback = nil

  -- properties
  self.completed = false
  self.response = nil
  self.isError = nil
  self.request = network.request(url, method, handler, params)

  return self
end

function request:onSuccess(callback)
  self.onSuccessCallback = callback

  -- call it immediatelly if response is already set
  if self.response and not self.isError then
    self.onSuccessCallback(self.response)
  end

  return self
end

function request:onError(callback)
  self.onErrorCallback = callback

  -- call it immediatelly if response is already set
  if self.response and self.isError then
    self.onErrorCallback(self.response)
  end

  return self
end

function request:handler(event)
  self.response = json.decode(event.response)
  self.isError = event.isError

  if self.isError then
    print("Network error: " .. event)
    if self.onErrorCallback then
      self.onErrorCallback(self.response)
    end
  else
    if self.onSuccessCallback then
      self.onSuccessCallback(self.response)
    end
  end
end

return request
