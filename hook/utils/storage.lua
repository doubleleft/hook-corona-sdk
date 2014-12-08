local sqlite3 = require("sqlite3")
local storage = {}

--
-- Open "hook.db". If the file doesn't exist, it will be created.
--
local path = system.pathForFile("hook.db", system.DocumentsDirectory)
local db = sqlite3.open(path)

--
-- Handle the "applicationExit" event to close the database
--
local function onSystemEvent( event )
  if ( event.type == "applicationExit" ) then
    db:close()
  end
end

--
-- Set up config table if it doesn't exist
--
local create_table = [[CREATE TABLE IF NOT EXISTS config ("id", "value", PRIMARY KEY("id"));]]
db:exec(create_table)

function storage.get(name)
  for row in db:nrows([[SELECT value FROM config WHERE id = "]] .. name .. [["]]) do
    return row.value
  end
  return nil
end

function storage.set(name, value)
  -- escape single quotes
  value = string.gsub(value, "'", "''")

  -- make sure it exists
  local insert = [[INSERT OR IGNORE INTO config (id, value) VALUES ("]] .. name .. [[", ']] .. value .. [[');]]
  db:exec(insert)

  local update = [[UPDATE config SET value = ']] .. value .. [[' WHERE id="]].. name ..[[";]]
  return db:exec(update)
end

function storage.remove(name)
  return db:exec([[DELETE FROM config WHERE id="]].. name ..[[";]])
end

-- Print the SQLite version
print("SQLite version " .. sqlite3.version())

--
-- Setup the event listener to catch "applicationExit"
--
Runtime:addEventListener( "system", onSystemEvent )

return storage
