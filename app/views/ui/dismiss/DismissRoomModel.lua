
local DismissRoomModel = class("DismissRoomModel", cc.load("mvc").ModelBase)

function DismissRoomModel:ctor(callback)
	DismissRoomModel.super.ctor(self, callback)
end

function DismissRoomModel:getProList()
	local list = {
		"room_post_vote_dismiss",
		-- "room_vote_dismiss_room",
	}
	return list
end

return DismissRoomModel
