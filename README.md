hook-corona
===========

Corona client for [hook](https://github.com/doubleleft/hook).

[Usage examples](example/main.lua)

TODO
---

- Write test units
- Push notifications
- Channels API
- Remove CoronaSDK dependency and publish a [luarocks](http://luarocks.org/)
  package.
  - Use [socket.http](http://w3.impa.br/~diego/software/luasocket/http.html)
    instead of corona.network
  - Use [lua-resty-libcjson](https://github.com/bungle/lua-resty-libcjson)
    instead of corona.json

This library was tested only against CoronaSDK 2014.2511. It possible runs on
older versions. Please create a pull-request if you find any problem.

License
---

MIT
