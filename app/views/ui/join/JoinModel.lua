--
-- Author: LXL
-- Date: 2016-11-09 15:07:35
--

local JoinModel = class("JoinModel" , cc.load("mvc").ModelBase)

function JoinModel:ctor(callback)
    JoinModel.super.ctor(self,callback)
end

function JoinModel:getProList()
	--页面数据
    local list = {
    	"room_enter_room"
    }
    return list
end

return JoinModel