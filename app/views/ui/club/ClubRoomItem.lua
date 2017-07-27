-- local ClubRoomItem = class("ClubRoomItem", ccui.Layout)
local ClubRoomItem = class("ClubRoomItem", cc.load("mvc").UIBase)

function ClubRoomItem:ctor()
	-- local size = cc.size(240, 110)

	-- self.widget = cc.CSLoader:createNode("uiClub/ClubRoomItem.csb")
	-- self:addChild(self.widget)
	-- self:setContentSize(self.widget:getContentSize())
	self:createResourceNode("uiClub/ClubRoomItem.csb")
	self:setContentSize(self.resourceNode_:getContentSize())

	self.txt_1 = helper.findNodeByName(self.resourceNode_,"txt_1")
	self.txt_2 = helper.findNodeByName(self.resourceNode_,"txt_2")
	self.txt_3 = helper.findNodeByName(self.resourceNode_,"txt_3")
	self.txt_4 = helper.findNodeByName(self.resourceNode_,"txt_4")
end

function ClubRoomItem:clickItem()
	print("click")
	UIMgr:openUI(consts.UI.ClubSingleRoom, nil, nil, self.data)
end

function ClubRoomItem:updateData(data)
	self.data = data
	if nil == data then
		self:setVisible(false)
		return
	end
	self:setVisible(true)
	self.txt_4:setString("对局"..data.progress)
	
	local ret = string.split(data.progress, ":")
	if tonumber(ret[1]) == 0 then
		self.txt_3:setString("未开局")
	else
		self.txt_3:setString("已开局")
	end
	self.txt_2:setString(string.format("人数:%d/%s",#data.players , data.player_num))
	self.txt_1:setString(data.room_id)
end

return ClubRoomItem
