--
-- hook.system class
--
local system = {}
system.__index = system

function system.new(client)
  local self = setmetatable({}, system)

  self.client = client

  return self
end

return system

