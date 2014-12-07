--
-- URL Helpers for LUA
--

local url = {}

function url.encode (s)
  s = string.gsub(s, "([&=+%c])", function (c)
    return string.format("%%%02X", string.byte(c))
  end)
  s = string.gsub(s, " ", "+")
  return s
end

function url.decode (s)
  s = string.gsub(s, "+", " ")
  s = string.gsub(s, "%%(%x%x)", function (h)
    return string.char(tonumber(h, 16))
  end)
  return s
end

return url
