mkdir -p package/lua/plugin
cp -R hook package/lua/plugin/hook
cp -R template-library-corona/bin package/bin
cp -R template-library-corona/tmp package/tmp
cp template-library-corona/lua/*.* package/lua
cp example/main_plugin.lua package/lua/main.lua
cp metadata.json package
echo "return require('plugin.hook.client')" > package/lua/plugin/hook.lua
