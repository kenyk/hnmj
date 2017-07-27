--
-- Author: LXL
-- Date: 2016-11-09 09:05:54
--

local ChatModel = class("ChatModel" , cc.load("mvc").ModelBase)

function ChatModel:ctor(callback)
    ChatModel.super.ctor(self,callback)
end

function ChatModel:getProList()
    local list = {
    	"game_talk_and_picture"
    }
    return list
end

return ChatModel