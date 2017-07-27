--
-- Created by IntelliJ IDEA.
-- User: chenshu
-- Date: 2015/7/30
-- Time: 17:33
-- To change this template use File | Settings | File Templates.
--
--
-- Author: LXL
-- Date: 2015-07-28 16:11:46
-- 包含socket通信
--

local ModelBase = class("ModelBase")

function ModelBase:ctor(callback)
    local list = self:getProList()
    for _,proNo in pairs(list) do
        GnetMgr:reg(proNo, self.proListHandler, self)
    end
    self.callback_ = callback
    if self.onCreate then self:onCreate() end
end

function ModelBase:getProList()
    local list = {}
    return list
end

--服务器数据收集处理
function ModelBase:proListHandler(msg)
    if self.callback_ then
        self.callback_(msg)
    end
end

function ModelBase:send(name,data)
    GnetMgr:send(name,data)
end

function ModelBase:setCallBack(callback)
    self.callback_ = callback
end

--销毁
function ModelBase:destroy()
    print("ModelBase:destroy()")
    GnetMgr:unregWithObj(self)
    NotifyMgr:unregWithObj(self)
end

return ModelBase
