-- LuaRocks configuration

rocks_trees = {
   { name = "user", root = home .. "/.luarocks" };
   { name = "system", root = "/home/runner/work/RixInGithub/RixInGithub/.luarocks" };
}
lua_interpreter = "lua";
variables = {
   LUA_DIR = "/home/runner/work/RixInGithub/RixInGithub/.lua";
   LUA_BINDIR = "/home/runner/work/RixInGithub/RixInGithub/.lua/bin";
}
