
local hmac = require "resty.hmac";
local String = require "utility.string";

local function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
    end
    return iter
end

local authorization = ngx.req.get_headers()["authorization"];
local algorithm_end_index = string.find(authorization, ' ', 1);
local algorithm = string.sub(authorization, 1, algorithm_end_index-1);
local other_part = string.sub(authorization, algorithm_end_index+1, -1);

local credential = '';
local access_key_id = '';
local scope = '';
local signed_headers_str = '';
local signed_headers = {};
local signature = '';

for _, val in pairs(String.split(other_part, ', ')) do
    if String.startsWith(val, 'Credential=') then
        credential = string.gsub(val, 'Credential=', '', 1);
    end
    if String.startsWith(val, 'SignedHeaders=') then
        signed_headers_str = string.gsub(val, 'SignedHeaders=', '', 1);
        for _, signed_header in pairs(String.split(signed_headers_str, ';')) do
            signed_headers[string.lower(signed_header)] = true;
        end
    end
    if String.startsWith(val, 'Signature=') then
        signature = string.gsub(val, 'Signature=', '', 1);
    end
end

local canonical_headers = {};
for key, val in pairsByKeys(ngx.req.get_headers()) do
    if signed_headers[key] then
        local header = string.lower(key) .. ':' .. String.trim(val);
        table.insert(canonical_headers, header);
    end
end

local canonical_headers_string = table.concat(canonical_headers, '\n') .. '\n';

local method = ngx.req.get_method();
local canonical_uri = ngx.var.uri;

local canonical_query = {};
local args = ngx.req.get_uri_args();
for key, val in pairsByKeys(args) do
    local param = ngx.escape_uri(key) .. '=' .. ngx.escape_uri(val);
    table.insert(canonical_query, param);
end
local canonical_query_string = table.concat(canonical_query, '&');

local payload = ngx.req.get_body_data();

ngx.say('method ', method);
ngx.say('canonical_uri ', canonical_uri);
ngx.say('canonical_query_string ', canonical_query_string);
ngx.say('canonical_headers_string ', canonical_headers_string);
ngx.say('algorithm ', algorithm);
ngx.say('credential ', credential);
ngx.say('signature ', signature);