local json = require('json')

--
-- hook.collection class
--
local collection = {}
collection.__index = collection

function collection.new(client, name)
  local self = setmetatable({}, collection)

  self.client = client
  self.name = name
  self.segments = "collection/" .. self.name

  self:reset()
  return self
end

function collection:reset()
  self.options = {}
  self.wheres = {}
  self.ordering = {}
  self._group = {}
  self._limit = nil
  self._offset = nil
  self._remember = nil
  return self
end

function collection:create(data)
  return self.client:post(self.segments, data)
end

function collection:select(...)
  self.options["select"] = arg
end

function collection:where(objects, _operation, _value, _boolean)
  if #objects == 0 then
    -- 'objects' is a dictionary
    -- add multiple where fields

    for field, value in pairs(objects) do
      self:addWhere(field, "=", value)
    end

  else
    -- 'objects' is an array
    -- add a single where field

    local field = objects
    local operation = _value and _operation or "="
    local value = _value or _operation
    local boolean = _boolean or "and"
    self:addWhere(objects, operation, value, boolean)
  end

  return self
end

function collection:orWhere(objects, _operation, _value)
  return self:where(objects, _operation, _value, "or")
end

function collection:find(_id)
  return self.client:get(self.segments .. '/' .. _id, self:buildQuery())
end

function collection:join(...)
  self.options['with'] = arg
  return self
end

function collection:distinct()
  self.options.distinct = true
  return self
end

function collection:group(...)
  self._group = arg
  return self
end

function collection:count(field)
  self.options.aggregation = {
    method = 'count',
    field = field or "*"
  }
  return self:get()
end

function collection:max(field)
  self.options.aggregation = {
    method = 'max',
    field = field
  }
  return self:get()
end

function collection:min(field)
  self.options.aggregation = {
    method = 'min',
    field = field
  }
  return self:get()
end

function collection:avg(field)
  self.options.aggregation = {
    method = 'avg',
    field = field
  }
  return self:get()
end

function collection:sum(field)
  self.options.aggregation = {
    method = 'sum',
    field = field
  }
  return self:get()
end

function collection:first()
  self.options.first = 1
  return self:get()
end

function collection:firstOrCreate(data)
  self.options.first = 1
  self.options.data = data
  return self.client:post(self.segments, self:buildQuery())
end

function collection:sort(field, direction)
  if (type(direction)=="number") then
    direction = (direction == -1) and "desc" or "asc"
  else
    direction = direction or "asc"
  end
  table.insert(self.ordering, { field, direction })
  return self
end

function collection:limit(int)
  self._limit = int
  return self
end

function collection:offset(int)
  self._offset = int
  return self
end

function collection:remember(minutes)
  self._remember = minutes
  return self
end

function collection:remove(_id)
  local path = self.segments
  if (type(_id)=="string") then
    path = path .. "/" .. _id
  end
  return self.client:remove(path, self:buildQuery())
end

function collection:update(_id, data)
  return self.client:post(self.segments .. '/' .. _id, data)
end

function collection:increment(field, value)
  self.options.operation = {
    method = "increment",
    field = field,
    value = value
  }
  return self.client:put(self.segments, self:buildQuery())
end

function collection:decrement(field, value)
  self.options.operation = {
    method = "decrement",
    field = field,
    value = value
  }
  return self.client:put(self.segments, self:buildQuery())
end

function collection:updateAll(data)
  self.options.data = data
  return self.client:put(self.segments, self:buildQuery())
end

function collection:addWhere(field, operation, value, boolean)
  table.insert(self.wheres, { field, string.lower(operation), value, boolean })
  return self
end

function collection:buildQuery()
  local query = {}

  -- apply limit / offset and remember
  if (self._limit) then
    query.limit = self._limit
  end

  if (self._offset) then
    query.offset = self._offset
  end

  if (self._remember) then
    query.remember = self._remember
  end

  -- apply wheres
  if (#self.wheres > 0) then
    query.q = self.wheres
  end

  -- apply ordering
  if (#self.ordering > 0) then
    query.s = self.ordering
  end

  -- apply group
  if (#self._group > 0) then
    query.g = self._group
  end

  local shortnames = {
    paginate = 'p',        -- pagination (perPage)
    first = 'f',           -- first / firstOrCreate
    aggregation = 'aggr',  -- min / max / count / avg / sum
    operation = 'op',      -- increment / decrement
    data = 'data',         -- updateAll / firstOrCreate
    with = 'with',       -- join / relationships
    select = 'select',     -- fields to return
    distinct = 'distinct'  -- use distinct operation
  }

  for longname, shortname in pairs(shortnames) do
    if self.options[longname] then
      query[shortname] = self.options[longname]
    end
  end

  -- clear wheres/ordering for future calls
  self:reset()

  return query
end

function collection:get()
  return self.client:get(self.segments, self:buildQuery())
end

--
-- syntactic sugar for request callbacks
--
function collection:onSuccess(callback)
  return self:get():onSuccess(callback)
end

function collection:onError(callback)
  return self:get():onError(callback)
end

function collection:onComplete(callback)
  return self:get():onComplete(callback)
end

return collection
