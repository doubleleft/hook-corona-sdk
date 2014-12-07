--
-- hook.key_values class
--
local key_values = {}
key_values.__index = key_values

function key_values.new(client)
  local self = setmetatable({}, key_values)

  self.client = client

  return self
end

return key_values
