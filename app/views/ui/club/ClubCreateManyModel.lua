--
-- Author: LXL
-- Date: 2016-11-10 11:37:54
--

local ClubCreateManyModel = class("ClubCreateManyModel" , cc.load("mvc").ModelBase)

function ClubCreateManyModel:ctor(callback)
    ClubCreateManyModel.super.ctor(self,callback)
end

function ClubCreateManyModel:getProList()
	local list = {
        "get_batch_room_list",
        "dismiss_batch_room",
    }
    return list
end

return ClubCreateManyModel