--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

HttpClient = {}

-- 密钥
local secretKey  = "U2FsdGVkX18fIUZvnjd4tmmlRjsojAJ2"
-- 客户端自定义的key
local pKey = "string"

require("utils.Sha1")

local http = cc.load("luasocket").socket.http
local ltn12 = cc.load("luasocket").ltn12

local function getDefaultParams()

    local chanTab = LuaCallPlatformFun.getPhoneChanId()
    local params = {
        appId = consts.appId, 
        appCode = consts.appCode,
        loginFrom = consts.loginFrom.weixin,
        clientFrom = consts.clientFrom[device.platform],
        clientVer = consts.clientVer,
        imei = LuaCallPlatformFun.getPhoneIMEI(),
        macAddr = LuaCallPlatformFun.getPhoneMacAddr(),
        model = LuaCallPlatformFun.getPhoneModel(),
        osVer = LuaCallPlatformFun.getPhoneOSVer(),
        chanId = chanTab[1],
        operator =  LuaCallPlatformFun.getPhoneOperator(),
        nettype =  LuaCallPlatformFun.getPhoneNettype(),
        uuId =  LuaCallPlatformFun.getPhoneUUId(),
        }
        if(chanTab[2])then params.chanCode = chanTab[2]end
        print("测渠道",params.chanId,tostring(params.chanCode))
    if UserData.userInfo then
        params.userId = UserData.uid
        params.token = UserData.userInfo.token
    end
    print("LuaCallPlatformFun.getPhoneChanId():",LuaCallPlatformFun.getPhoneChanId())
    return  params
end


function HttpClient.sortParams(params)
    params.pKey = pKey
    params.secretKey = secretKey
    local keys = {} 
    local sortedParamsUrl =""
     --取出所有的键  
    for key,_ in pairs(params) do  
        table.insert(keys,key)  
    end   
    --对所有键进行排序  
    table.sort(keys)  
    for _,key in pairs(keys) do  
        sortedParamsUrl = sortedParamsUrl .. key .. "=" .. urlEncode(params[key]) .. "&"
    end
    return string.sub(sortedParamsUrl, 1, #sortedParamsUrl - 1)  
end

function HttpClient.paramsToUrl(params)
    local paramsUrl = ""
    for key,value in pairs(params) do  
        paramsUrl =paramsUrl .. key .. "=" .. urlEncode(params[key]) .. "&"
    end
    return string.sub(paramsUrl, 1, #paramsUrl - 1)  
end

function HttpClient.sign(params)
    params = params or {}
    local paramsStr = HttpClient.paramsToUrl(params)
    local sortedParamsUrl =  HttpClient.sortParams(params)
    local urlEncode = urlEncodeForSign(sortedParamsUrl)
    local signStr = Sha1(urlEncode)
    return paramsStr .. "&sign=" .. signStr 
end

-- 返回值: entity.data，entity，r，c，h
-- 网络错误 entity.data 和 entity 都为nil，可根据r，c，h进行处理
-- 后台接口错误 entity.data 为nil，可根据entity进行处理
--function HttpClient:get(u, params, host)
--   local t = {}
--   params = params or {}
--   table.merge(params, getDefaultParams())
--   local signstr=HttpClient.sign(params)
--   local httphost = host or consts.HttpHost
--   local u = "http://" .. httphost .. u .. "?" .. signstr
--   print("requestUrl------" .. u)
--   local r,c,h = http.request{
--        method = "GET",
--        url = u ,
--        sink = ltn12.sink.table(t),
--        headers =  {     
--            pKey = pKey,
--            host = consts.HttpHost 
--        }
--    }

--    if c == 200 and t ~= nil then
--        local entity = json.decode((string.gsub(unicodeToUtf8(table.concat(t)),"\\","")))
--        dump(entity)
--        if entity ~= nil and entity.status  == 1 and entity.errCode == 0 then
--            return entity.data,entity,r,c,h
--        end
--        return nil,entity,r,c,h
--    end
--    return nil,nil,r,c,h
--end

-- 返回值: entity.data，entity，c
-- 网络错误 entity.data 和 entity 都为nil，可根据r，c，h进行处理
-- 后台接口错误 entity.data 为nil，可根据entity进行处理
function HttpClient:asyncGet(u, params, callback, host)
    local t = {}
    params = params or {}
    table.merge(params, getDefaultParams())
    dump(params,"requestUrl data")
    local signstr = HttpClient.sign(params)
    local httphost = host or consts.HttpHost
    u = "http://" .. httphost .. u .. "?" .. signstr
    print("requestUrl------" .. u)
    local xhr = cc.XMLHttpRequest:new() -- 新建一个XMLHttpRequest对象
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON -- 相应类型为字符串
    xhr:setRequestHeader("pKey", pKey)
    xhr:open("GET", u)
    local function onReadyStateChange()
        
        local statusCode = xhr.status
        print("Http Status Code:"..statusCode) -- 状态吗为200时成功
        if callback then
            if statusCode == 200 then
                local temp = xhr.response
                local entity = nil
                if temp then 
                    --entity = json.decode((string.gsub(unicodeToUtf8(xhr.response),"\\/","/")))
                    entity = json.decode((string.gsub(xhr.response,"\\/","/")))
                end
                dump(entity)
                if entity and entity.status  == 1 and entity.errCode == 0 then
                    callback(entity.data, entity, statusCode)
                else
                    callback(nil, entity, statusCode)
                end
            else 
                callback(nil, nil, statusCode)
            end
        end
    end
    -- 注册脚本方法回调
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send()
end


function HttpClient:asyncGetWhitGameHttpHost(u, params,callback)
    return HttpClient:asyncGet(u, params, callback, consts.GameHttpHost)
end

function HttpClient:getWhitGameHttpHost(u, params)
    return HttpClient:get(u, params,consts.GameHttpHost)
end

return HttpClient