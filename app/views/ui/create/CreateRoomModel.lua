--
-- Author: LXL
-- Date: 2016-11-09 15:09:27
--

local CreateRoomModel = class("CreateRoomModel" , cc.load("mvc").ModelBase)

function CreateRoomModel:ctor(callback)
    CreateRoomModel.super.ctor(self,callback)
end

function CreateRoomModel:getProList()
	--页面数据
    local list = {
    	"build_on_request_new_rooms",
    	"room_enter_room"
    }
    return list
end

return CreateRoomModel