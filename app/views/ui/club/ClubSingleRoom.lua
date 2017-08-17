--
-- Author: LXL
-- Date: 2016-11-08 09:20:25
--

local ClubSingleRoom = class("ClubSingleRoom", cc.load("mvc").UIBase)
local index = 0

ClubSingleRoom.RESOURCE_FILENAME = "uiClub/ClubSingleRoom.csb"
-- ClubSingleRoom.RESOURCE_MODELNAME = "app.views.ui.join.JoinModel"
local ClubPlayerInfo = require "app.views.ui.club.ClubPlayerInfo"

function ClubSingleRoom:onCreate(data)
 	self.closeBtn = helper.findNodeByName(self.resourceNode_,"closeBtn")
 	self.content_node = helper.findNodeByName(self.resourceNode_,"content_node")
 	self.txt_state = helper.findNodeByName(self.resourceNode_,"txt_state")
 	self.txt_room_id = helper.findNodeByName(self.resourceNode_,"txt_room_id")
 	self.btn_invite = helper.findNodeByName(self.resourceNode_,"btn_invite")
 	self.btn_out = helper.findNodeByName(self.resourceNode_,"btn_out")
 	self.btn_enter_room = helper.findNodeByName(self.resourceNode_,"btn_enter_room")
 	self.closeBtn:setPressedActionEnabled(true)
    self:setInOutAction()

    for i=1,4 do
        local item = ClubPlayerInfo:create()
        self.content_node:addChild(item)
        print(i /2, i)
        item:setPosition(cc.p(-510 + ((i - 1) % 2) * 530, 80 - (math.ceil(i / 2) - 1) * 150))
        self["ClubPlayerInfo"..i] = item
    end
    self:updateData(data)
end

function ClubSingleRoom:updateData(data)
	self.data = data
    for i=1,4 do
        local playerInfo = self.data.players[i]
        -- if nil == playerInfo then
        --     self["ClubPlayerInfo"..i]:setVisible(false)
        -- else

        -- end
        self["ClubPlayerInfo"..i]:updateData(playerInfo)
    end
    self.txt_room_id:setString(data.room_id)


    local ret = string.split(data.progress, ":")
    if tonumber(ret[1]) == 0 then --未开局
        -- self.btn_enter_room:setVisible(true)
        self.btn_out:setVisible(true)
        self.btn_invite:setVisible(true)
        -- self.txt_state:setString(string.format("%d:%d 未开局", #data.players, tonumber(data.player_num)))
        self.txt_state:setString(data.progress.." 未开局")
    else
        self.btn_enter_room:setVisible(false)
        self.btn_out:setVisible(true)
        self.btn_invite:setVisible(false)
        -- self.txt_state:setString(string.format("%d:%d 已开局", #data.players, tonumber(data.player_num)))
        self.txt_state:setString(data.progress.." 已开局")
    end

    -- if tonumber(data.progress) == 0 then --未开局
    --     self.btn_enter_room:setVisible(true)
    --     self.btn_out:setVisible(true)
    --     self.btn_invite:setVisible(true)
    --     self.txt_state:setString(string.format("%d/%d 未开局", #data.players, 4))
    -- else
    --     self.btn_enter_room:setVisible(false)
    --     self.btn_out:setVisible(true)
    --     self.btn_invite:setVisible(false)
    --     self.txt_state:setString(string.format("%d/%d 已开局", #data.players, 4))
    -- end
end

function ClubSingleRoom:onEnter()
    ClubSingleRoom.super.onEnter(self)
end

function ClubSingleRoom:onClose()
	self:close()
end

function ClubSingleRoom:onInvite()
	local shareTitle = ""
    local sharedesc = ""
    local ret = string.split(self.data.progress, ":")
    local roomInfo = json.decode(self.data.data)
    shareTitle = "【俱乐部比赛专房】 "..self.data.player_num .. "人" .. consts.GameTypeName[roomInfo.type] .. ",".."房号:"..self.data.room_id.."("..ret[2].."局)"
    sharedesc = UserData:getShareDesc(roomInfo).."\n[点击加入房间]"
    print(shareTitle)
    print(sharedesc)

    local weburl = "https://acz5fi.mlinks.cc/AcqJ?".."roomId="..self.data.room_id
    local img = ""
    local args = {title=shareTitle,desc=sharedesc,webUrl=weburl,imageUrl=img}
	LuaCallPlatformFun.share(args)
end

function ClubSingleRoom:onOneOut()
    -- print(tonumber(self.data.room_id))
	local dialogContentLabel1 = helper.createRichLabel({maxWidth = 600,fontSize = 30,fontColor = consts.ColorType.THEME})
    dialogContentLabel1:setString("是否解散该房间")
	self.applyDismissDialog=UIMgr:showConfirmDialog("提示", {child = dialogContentLabel1, childOffsetY = 10}, function ()
		GnetMgr:send("dismiss_batch_room", {handle = {tonumber(self.data.room_id)} })
	end, function ()
		
	end, self)
end

function ClubSingleRoom:onEnterRoom()
    UserData.roomId = tonumber(self.data.room_id)
    GnetMgr:send("room_enter_room", {enter_code = UserData.roomId})
	self:close()
end

return ClubSingleRoom