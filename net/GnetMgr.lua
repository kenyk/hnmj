
--[["
    desc: 网络通信数据处理
    author: TUYO
    since: 2014-3-14
 "]]

-- local login_ip = "10.17.173.96"
-- local login_port = 8888
local login_ip = "10.17.174.171"
local login_port = 8888
local error_Code = import(".error_code")
local gnet = require "net.net"
local GProtocolModel = import(".GProtocolModel")

local maps     = {}
local updateNetInstance
local protoTimer
local protoList = {}
local showWaitList = {}
GnetMgr = {}
GnetMgr.isHandle = false

function GnetMgr:init()
    self.isReConnect = false
    self.isInReconnect = false
    if self.protocolModel  == nil then
        self.protocolModel = GProtocolModel:create() --初始化全局接收器
    end
end

-- 初始化并连接
function GnetMgr:initConnect(netip, netport,callback)
    if self:isConnect() then
        self:closeConnect()
    end
    self.isReConnect = false
    self.isInReconnect = false
    local ip = netip or login_ip
    local port = netport or login_port
    assert(ip and port, string.format("ip:%s or port:%s not exist", ip,port))
    log.print("GnetMgr:initConnect",ip, port)
    self:start()
    self.connectSuccessCallback = callback
    gnet:init(ip, port, GnetMgr, GnetMgr.recv, GnetMgr.connectOK, GnetMgr.connectFail, GnetMgr.close)
    return gnet:connect()
end

function GnetMgr:dealloc()
    self:pause()
    self.protocolModel = nil
    self.reConnectModel = nil
    maps = {}
end

-- 开始网络连接
function GnetMgr:start()
    if updateNetInstance ~= nil then return end
    updateNetInstance = gScheduler:scheduleScriptFunc(function (dt) gnet.tick() end, 0.05, false)
    -- if self:isConnect() then
    --     HeartMgr.sendToServerHeat()
    -- end
end

-- 暂停网络连接
function GnetMgr:pause()
    if updateNetInstance ~= nil then
        gScheduler:unscheduleScriptEntry(updateNetInstance)
        updateNetInstance = nil
    end
    HeartMgr.stop()
end

-- 是否已经注册了回调
function GnetMgr:isExistReg(id)
    return (nil ~= maps[id])
end

-- 是否注册
function GnetMgr:isInit(id)
    return (maps[id] ~= nil)
end

-- 通过指定id注册
function GnetMgr:reg(id, callback, obj)
    if nil == maps[id] then maps[id] = {} end
    if nil == maps[id].obj then maps[id].obj = {} end
    if nil == maps[id].callback then maps[id].callback = {} end
    maps[id].isBusy     = false
    table.insert(maps[id].callback,callback)
    table.insert(maps[id].obj,obj)
--    print("GnetMgr:reg", id, callback, obj)
end

-- 获得回调相关（callback, obj）
function GnetMgr:getCallbackAbout(msgid)
    local callbacks, objs
    local mapInfo = maps[msgid]
    if nil ~= mapInfo then
        callbacks = mapInfo.callback
        objs      = mapInfo.obj
    end
    return callbacks, objs
end

-- 发送数据后处理
function GnetMgr:dealWithSend(id)
    -- 设置发送中
    local mapInfo = maps[id]
    if mapInfo then
        mapInfo.isBusy = true
    end
end

-- 接受数据后处理
function GnetMgr:dealWithRecv(data)
    if self:isInit(data.name) then
        maps[data.name].isBusy = false
    end
end

-- -- 接收完数据包调用该方法
-- function GnetMgr:recv(data)
--     if data.name ~= "heartbeat" then
--         log.dump(data,"GnetMgrRecv:",10)
--     end
--     local callbacks, objs = self:getCallbackAbout(data.name)
--     self:dealWithRecv(data)
--     if callbacks then
--         print("callbacks:number",#callbacks)
--         for k,v in ipairs(callbacks) do
--             v(objs[k], data)
--         end
--     else
--         print("GnetMgr:recv 没有注册回调函数 ", data.name)
--     end
-- end

function GnetMgr:checkData()
    if #protoList > 0 and false == GnetMgr.isHandle then
        local data = protoList[1]
        table.remove(protoList, 1)
        local callbacks, objs = self:getCallbackAbout(data.name)
        self:dealWithRecv(data)
        if callbacks then
            print("callbacks:number",#callbacks)
            for k,v in ipairs(callbacks) do
                v(objs[k], data)
            end
        else
            print("GnetMgr:recv 没有注册回调函数 ", data.name)
        end
    end
end

function GnetMgr:unlock()
    GnetMgr.isHandle = false
    self:checkData()
end

function GnetMgr:lock()
    GnetMgr.isHandle = true
end

function GnetMgr:clearData()
    protoList = {}
    GnetMgr.isHandle = false
end

-- 接收完数据包调用该方法
function GnetMgr:recv(data)
    if data.name ~= "heartbeat" then
        log.dump(data,"GnetMgrRecv:",10)
    end
    table.insert(protoList, data)
    self:checkData()
    -- local callbacks, objs = self:getCallbackAbout(data.name)
    -- self:dealWithRecv(data)
    -- if callbacks then
    --     print("callbacks:number",#callbacks)
    --     for k,v in ipairs(callbacks) do
    --         v(objs[k], data)
    --     end
    -- else
    --     print("GnetMgr:recv 没有注册回调函数 ", data.name)
    -- end
end

--战局回放调这个函数
function GnetMgr:recvInReplayScene(data)
    if data.name ~= "heartbeat" then
        log.dump(data,"GnetMgrRecv:",10)
    end
    local callbacks, objs = self:getCallbackAbout(data.name)
    self:dealWithRecv(data)
    if callbacks then
        print("callbacks:number",#callbacks)
        for k,v in ipairs(callbacks) do
            v(objs[k], data)
        end
    else
        print("GnetMgr:recv 没有注册回调函数 ", data.name)
    end
end
---------------------- public ----------------------

-- 发送数据
function GnetMgr:send(name, data)
    if data and data.name ~= "heartbeat" then
        log.dump(data,"GnetMgrSend:"..name)
    end
    local isSendOk = gnet:sendRequest(name,data)
    self:dealWithSend(name)
    if isSendOk and GnetMgr:isConnect() then
        HeartMgr:checkSendMsg()
    end
end

-- 通过obj注销回调
function GnetMgr:unregWithObj(obj)
    if nil == obj then return end
    for k, v in pairs(maps) do
        local objList = v["obj"]
        for kObj,vObj in ipairs(objList) do
            if vObj == obj then
                table.remove(objList,kObj)
                table.remove(v["callback"],kObj)
                break
            end
        end
        if #objList == 0 then
            maps[k] = nil
        end
    end
end

function GnetMgr:clear()
    self:dealloc()
end

-- 服务器连接成功
function GnetMgr:connectOK()
    log.print("服务器连接成功回调")
    UIMgr:closeUI(consts.UI.LoadingDialogUI)
    if self.isReConnect and not Is_App_Store then
        self.isReConnect = false
        if nil ~= UserData.uid then
            local function callback()
                local tokenID = UserData.userInfo and UserData.userInfo.token or ""
                self:send("login", {account = UserData.uid , token=tokenID})
                HeartMgr.start()
                -- GnetMgr:startProtoHandlerTimer()
            end
            self:queryStaus(callback)
        else
            UserData.login = false
            if UIMgr:getUI(consts.UI.login) == nil then
                MyApp:goToMain()
            end
        end
    else
        --游客临时处理
        if(Is_App_Store and not UserData.uid)then
            UserData.uid = self:getUidForIos()
        end
        local tokenID = UserData.userInfo and UserData.userInfo.token or ""
        self:send("login", {account = UserData.uid,token = tokenID})
        HeartMgr.start()
        -- GnetMgr:startProtoHandlerTimer()
        if self.connectSuccessCallback then
            self.connectSuccessCallback()
            self.connectSuccessCallback = nil
        end
    end
end

function GnetMgr:queryStaus(callback)
    HttpServiers:queryStaus(nil, 
        function(entity,response,statusCode)
            if entity and callback then
                callback()
                --连接成功
            elseif response and response.errCode == -1 then
                if UserData.isInGame then
                    MyApp:goToMain()
                end
            elseif response and response.errCode then
                UIMgr:closeUI(consts.UI.LoadingDialogUI)
                GnetMgr:showErrorTips(response.errCode, true)
            else
                UIMgr:showNetErrorTip(function()
                        self:queryStaus()
                end)
            end
        end)
end

-- 服务器连接失败
function GnetMgr:connectFail()
    self.isInReconnect = false
    log.print("服务器连接失败回调")
    self:reConnect()
end

-- 服务器关闭处理
function GnetMgr:close()
    self.isInReconnect = false
    log.print("服务器推送断线")
    HeartMgr.stop()
    GnetMgr:clearData()
    self:reConnect()
end

-- 是否连接上服务器
function GnetMgr:isConnect()
    return gnet:isconnect()
end

-- 关闭连接
function GnetMgr:closeConnect()
    gnet:close()
    HeartMgr.stop()
    GnetMgr:clearData()
end

function GnetMgr:reConnect()
    if self.isInReconnect then return end
    NotifyMgr:push(consts.Notify.APP_ENTER_BACKGROUND)
    self.isInReconnect = true
    print("服务器重连")
    if UIMgr:getUI(consts.UI.LoadingDialogUI) == nil then
        UIMgr:showLoadingDialog("自动连接中,请稍后……")
    end
    performWithDelay(display.getRunningScene(), function()
        self.isReConnect = true
        if self:isConnect() then
            self:closeConnect()
        end
        gnet:connect()
        self:start()
        self.isInReconnect = false
    end, 1)
end

function GnetMgr:showErrorTips(code, gameHttp)
    local str = error_Code[code]
    if gameHttp then
        str = error_Code.gameHttp[code]
    else
        str = error_Code[code]
    end
    str = str or "错误码:" .. code
    UIMgr:showTips(str)
end

--应对审核用
function GnetMgr:getUidForIos()
    
    local uid = LuaCallPlatformFun.getPhoneUUId()
    if(uid == "UnKnow IMIE")then--一般是模拟器
        uid = 10000120
    elseif(not string.find(uid,"-"))then
        uid = string.sub(uid,#uid-5,#uid)
    end
    --截取设备UUID
    local tab =string.split(uid, "-")
    local numStr = string.format("%u","0x"..tab[#tab])
    if(#numStr < 8)then 
        for i=1,8-#numStr do numStr = numStr.."0" end
    end
    local lenStr = string.sub(numStr,#numStr-7,#numStr)
    return tonumber(lenStr)
end
