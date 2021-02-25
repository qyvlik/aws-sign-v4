local resty_hmac = require "resty.hmac";
local utility_string = require "utility.string";
local resty_string = require "resty.string";
local resty_sha256 = require "resty.sha256"
local json = require "cjson"

local function pairs_by_keys (t, f)
    local a = {}
    for n in pairs(t) do
        table.insert(a, n)
    end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function()
        -- iterator function
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end

local function hmac_sha256(secret, data, to_hex)
    local hash = resty_hmac:new(secret, resty_hmac.ALGOS.SHA256);
    hash:update(data);
    local digest = hash:final();
    if to_hex then
        return resty_string.to_hex(digest);
    end
    return digest;
end

local function sha256(data, to_hex)
    local hash = resty_sha256:new()
    hash:update(data);
    local digest = hash:final();
    if to_hex then
        return resty_string.to_hex(digest);
    end
    return digest;
end

function goodbye(status)
    ngx.status = status;
    ngx.header.content_type = "application/json;charset=utf8"
    ngx.say(json.encode({
        code = status,
        message = '',
        data = json.null,
        success = false
    }));
end

local authorization = ngx.req.get_headers()["authorization"];
if authorization == '' or authorization == nil then
    ngx.log(ngx.ERR, 'header authorization is blank');
    goodbye(ngx.HTTP_UNAUTHORIZED);
    return ;
end

local request_date_time = ngx.req.get_headers()["x-amz-date"];
if request_date_time == '' or request_date_time == nil then
    ngx.log(ngx.ERR, 'header x-amz-date is blank');
    goodbye(ngx.HTTP_BAD_REQUEST);
end

local algorithm_end_index = string.find(authorization, ' ', 1);
local algorithm = string.sub(authorization, 1, algorithm_end_index - 1);
local authorization_part = string.sub(authorization, algorithm_end_index + 1, -1);

local credential = '';
local access_key = '';
local secret_key = '00000000000000000000000000000000';
local credential_scope = '';
local signed_headers_str = '';
local signed_headers = {};
local client_signature = '';

for _, val in pairs(utility_string.split(authorization_part, ', ')) do
    if utility_string.startsWith(val, 'Credential=') then
        -- Credential=a000000-0000-0000-0000-0000000000/20210225/us-west-1/s3/aws4_request
        credential = string.gsub(val, 'Credential=', '', 1);
        local access_key_end_index = string.find(credential, '/', 1);
        access_key = string.sub(credential, 1, access_key_end_index - 1);
        credential_scope = string.sub(credential, access_key_end_index + 1, -1);
    end
    if utility_string.startsWith(val, 'SignedHeaders=') then
        signed_headers_str = string.gsub(val, 'SignedHeaders=', '', 1);
        for _, signed_header in pairs(utility_string.split(signed_headers_str, ';')) do
            signed_headers[string.lower(signed_header)] = true;
        end
    end
    if utility_string.startsWith(val, 'Signature=') then
        client_signature = string.gsub(val, 'Signature=', '', 1);
    end
end

local canonical_headers = {};
for key, val in pairs_by_keys(ngx.req.get_headers()) do
    if signed_headers[key] then
        local header = string.lower(key) .. ':' .. utility_string.trim(val);
        table.insert(canonical_headers, header);
    end
end
-- todo lost some header
local canonical_headers_string = table.concat(canonical_headers, '\n') .. '\n';

local method = ngx.req.get_method();
local canonical_uri = ngx.var.uri;

local canonical_query = {};
local args = ngx.req.get_uri_args();
for key, val in pairs_by_keys(args) do
    local param = ngx.escape_uri(key) .. '=' .. ngx.escape_uri(val);
    table.insert(canonical_query, param);
end
local canonical_query_string = table.concat(canonical_query, '&');

local request_payload = ngx.req.get_body_data() or '';
local hashed_payload = sha256(request_payload, true);

local canonical_request = method .. '\n'
        .. canonical_uri .. '\n'
        .. canonical_query_string .. '\n'
        .. canonical_headers_string .. '\n'
        .. signed_headers_str .. '\n'
        .. hashed_payload

local hashed_canonical_request = sha256(canonical_request, true);

local string_to_sign = algorithm .. '\n'
        .. request_date_time .. '\n'
        .. credential_scope .. '\n'
        .. hashed_canonical_request;

local scope = utility_string.split(credential_scope, '/');

local date = scope[1]
local region = scope[2];
local service = scope[3];

local k_data = hmac_sha256("AWS4" .. secret_key, date);
local k_region = hmac_sha256(k_data, region);
local k_service = hmac_sha256(k_region, service);
local k_signing = hmac_sha256(k_service, 'aws4_request');

local signature = hmac_sha256(k_signing, string_to_sign, true);

ngx.say("signature ", signature);
ngx.say("client_signature ", client_signature);