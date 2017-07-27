--[["
    desc: 心跳管理
    author: lxl
    since: 2014-09-25
 "]]


HeartMgr = {}

local serverTime = nil
local isFirst = nil
local pingTbl = {}
local clock1 = nil
local clock2 = nil

function HeartMgr.setServerTime(curTime)
    serverTime = curTime
    HeartMgr.serverToClientHeat()
end

local heartSchedule = nil
local heartOutLineSchedule = nil

-- 结束心跳相关
function HeartMgr.stop()
    if heartSchedule then
        gScheduler:unscheduleScriptEntry(heartSchedule)
        heartSchedule = nil
    end 

    if heartOutLineSchedule then
        gScheduler:unscheduleScriptEntry(heartOutLineSchedule)
        heartOutLineSchedule = nil
    end 
end

-- 开始心跳
function HeartMgr.start()
    
    if heartSchedule then
        gScheduler:unscheduleScriptEntry(heartSchedule)
        heartSchedule = nil
    end 
    heartSchedule = gScheduler:scheduleScriptFunc(HeartMgr.sendToServerHeat, 15, false)
    HeartMgr.sendToServerHeat(true)
end

--心跳协议
function HeartMgr.sendToServerHeat(firstH)
    -- print("sendToServerHeat( ) 发送心跳",isFirst)
    if firstH then
        isFirst = firstH        
    end

    local isSendOk = GnetMgr:send("heartbeat")
--    if isSendOk and GnetMgr:isConnect() then
--        HeartMgr.outTime = os.time()
--        HeartMgr.isTimeOutOfLine = false
--        if heartOutLineSchedule then
--            gScheduler:unscheduleScriptEntry(heartOutLineSchedule)
--            heartOutLineSchedule = nil
--        end
--        heartOutLineSchedule = gScheduler:scheduleScriptFunc(HeartMgr.timeOutScriptFunc,3, false )
--    end

    if heartOutLineSchedule == nil and GnetMgr:isConnect() then
        heartOutLineSchedule = gScheduler:scheduleScriptFunc(HeartMgr.timeOutOfLine,17, false )
    end
    clock1 = os.clock()
end

--function HeartMgr.timeOutScriptFunc()
--    local outTime = os.time() - HeartMgr.outTime
--    if HeartMgr.isTimeOutOfLine then
--        HeartMgr.timeOutOfLine()
--        HeartMgr.isTimeOutOfLine = false
--        return
--    end
--    if outTime > 5 then
--        HeartMgr.isTimeOutOfLine = true
--    end
--      HeartMgr.timeOutOfLine()
--end

function HeartMgr.serverToClientHeat()
    --收到心跳返回
    -- print("收到心跳数据")
    if heartOutLineSchedule then 
        gScheduler:unscheduleScriptEntry(heartOutLineSchedule)
        heartOutLineSchedule = nil
    end
    
    if isFirst then
        isFirst = nil
        --房间解散后  再进入游戏 第一次收到心跳包 判断是否有房间信息  没有的话退回主界面
        if UserData.isInGame and UserData.table_config == nil then
            MyApp:goToMain()
        end
    end
    --第一次忽略ping
    if #UserData.averPingTbl == 0 then
        clock2 = clock1
    else
        clock2 = os.clock()
    end
    local ping = (clock2 - clock1) / 2 * 1000
    if #pingTbl > 5 then
        table.remove(pingTbl, 1)
    end
    table.insert(pingTbl, ping)
    local sum = 0
    for i, v in ipairs(pingTbl) do
        sum = sum + v
    end
    local averPing = sum / #pingTbl
    NotifyMgr:push(consts.Notify.UPDATE_PING, averPing)

    local cur_date = os.date("*t", os.time())
    local str = string.format("%02d", cur_date.hour)..string.format("%02d", cur_date.min)..string.format("%02d", cur_date.sec)
    str = str.."_"..tostring(math.ceil(averPing))
    table.insert(UserData.averPingTbl, str)
end

--检测发送数据
function HeartMgr:checkSendMsg()
    --发送成功才取消心跳。重启
--    if heartSchedule then 
--        gScheduler:unscheduleScriptEntry(heartSchedule)
--    end
--    HeartMgr.serverHeatTime =  os.time()
--    heartSchedule = gScheduler:scheduleScriptFunc(HeartMgr.serverHeatScriptFunc, 6, false)
 end

--function HeartMgr:serverHeatScriptFunc()
--    local time = os.time() - HeartMgr.serverHeatTime
--    if time >= 6 then
--        HeartMgr.sendToServerHeat()
--    end
--end

function HeartMgr.timeOutOfLine()
    --15秒没收到心跳返回，掉线了。。
    print("HeartMgr.timeOutOfLine(  ) 心跳断线")
    GnetMgr:close()
end



