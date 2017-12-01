--
-- Author: LXL
-- Date: 2016-11-09 15:07:35
--

local ActivationModel = class("ActivationModel" , cc.load("mvc").ModelBase)

function ActivationModel:ctor(callback)
    ActivationModel.super.ctor(self,callback)
end

function ActivationModel:getProList()
	--页面数据
    local list = {
    	"room_enter_room"
    }
    return list
end

return ActivationModel
