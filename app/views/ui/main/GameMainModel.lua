--
-- Author: LXL
-- Date: 2016-11-09 15:00:14
--

local GameMainModel = class("GameMainModel" , cc.load("mvc").ModelBase)

function GameMainModel:ctor(callback)
    GameMainModel.super.ctor(self,callback)
end

function GameMainModel:getProList()
	--页面数据
    local list = {
    "room_enter_room",
    }
    return list
end

return GameMainModel