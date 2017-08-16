--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

BIHttpClient = {}

local http = cc.load("luasocket").socket.http

local function getBIDefaultParams()
    local params = {
        uuid =  LuaCallPlatformFun.getPhoneUUId(),
        imei = LuaCallPlatformFun.getPhoneIMEI(),
        appId = consts.BIAppId[device.platform], 
        appCode = consts.appCode,
        appVersion = consts.clientVer,
        osType = consts.BIosType[device.platform],
        macAddr = LuaCallPlatformFun.getPhoneMacAddr() or "macAddr null",
        deviceModel = LuaCallPlatformFun.getPhoneModel(),
        osVersion = LuaCallPlatformFun.getPhoneOSVer(),
        operator =  LuaCallPlatformFun.getPhoneOperator(),
        netType =  LuaCallPlatformFun.getPhoneNettype(),
        time = tostring(os.time()),
        resolution = tostring(display.sizeInPixels.width).."*"..tostring(display.sizeInPixels.height),
        eventInfo = ""
        }
    if UserData.userInfo then
        params.userId = tostring(UserData.uid)
    end
    return  params
end

local function getBIeventInfo(BIeventType,BIcurrentPath)
    local params = {
        eventType =  BIeventType,
        currentPath =  BIcurrentPath,
        sessionId = consts.BIsessionId,
        eventTime = tostring(os.time()),
        }
    return  params
end

function BIHttpClient:postBIeventInfo(BIeventType,BIcurrentPath)
    -- local url = "http://" .. consts.BIHttpHost ..consts.BIHttpUrl.BIeventInfo
    -- local param = getBIDefaultParams()
    -- param.eventInfo = json.encode(getBIeventInfo(BIeventType,BIcurrentPath))
    -- local paramstr=HttpClient.paramsToUrl(param)
    -- BIHttpClient:asyncPostRequest(url,nil,paramstr,nil)
end

function BIHttpClient:asyncPostRequest(url,callback,param,failCallBack)
    print(url,param)
    local xhr = cc.XMLHttpRequest:new() -- 新建一个XMLHttpRequest对象
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING -- 相应类型为字符串
    xhr:open("POST", url)-- post方式
    local function onReadyStateChange()
        local statusCode = xhr.status
        print("BIHttpClient Http Status Code:"..statusCode) -- 状态吗为200时成功
        print("BIHttpClient response:"..xhr.response)
        if statusCode == 200 then
            if callback then
                callback(xhr.response)
            end
        else
            if failCallBack then
                failCallBack(xhr.response)
            end
        end
    end
    -- 注册脚本方法回调
    xhr:registerScriptHandler(onReadyStateChange)
    if param then
        xhr:send(param)-- 发送
    else
        xhr:send()
    end
    print("waiting...http")
end

return BIHttpClient