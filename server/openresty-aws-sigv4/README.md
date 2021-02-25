#


```bash
curl -d="xxx" "localhost:3001/test?a=x&A=x&F=z&1=2" 
```

## lua String-Trim

http://lua-users.org/wiki/StringTrim

## Using LuaRocks to install packages in the current directory 

https://leafo.net/guides/customizing-the-luarocks-tree.html

```bash

luarocks install --tree lua_modules  lua-resty-hmac
```

## opm

https://opm.openresty.org/package/jkeys089/lua-resty-hmac

## Lua Ngx API

https://openresty-reference.readthedocs.io/en/latest/Lua_Nginx_API/

## openresy steps

- set_by_lua: 流程分之处理判断变量初始化
- rewrite_by_lua: 转发、重定向、缓存等功能(例如特定请求代理到外网)
- access_by_lua: IP准入、接口权限等情况集中处理(例如配合iptable完成简单防火墙)
- content_by_lua: 内容生成
- header_filter_by_lua: 应答HTTP过滤处理(例如添加头部信息)
- body_filter_by_lua: 应答BODY过滤处理(例如完成应答内容统一成大写)
- log_by_lua: 回话完成后本地异步完成日志记录(日志可以记录在本地，还可以同步到其他机器)