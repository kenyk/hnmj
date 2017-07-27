-- local ClubPlayerInfo = class("ClubPlayerInfo", ccui.Layout)
local ClubPlayerInfo = class("ClubPlayerInfo", cc.load("mvc").UIBase)

function ClubPlayerInfo:ctor()
	-- local size = cc.size(240, 110)

	-- self.widget = cc.CSLoader:createNode("uiClub/ClubPlayerInfo.csb")
	-- self:addChild(self.widget)
	-- self:setContentSize(self.widget:getContentSize())
	self:createResourceNode("uiClub/ClubPlayerInfo.csb")
	self:setContentSize(self.resourceNode_:getContentSize())

	self.img_head = helper.findNodeByName(self.resourceNode_,"img_head")
	self.txt_name = helper.findNodeByName(self.resourceNode_,"txt_name")
	self.txt_id = helper.findNodeByName(self.resourceNode_,"txt_id")
end

function ClubPlayerInfo:updateData(data)
	self.data = data
	if nil == data then
		self:setVisible(false)
		return
	end
	self.txt_name:setString(data.nickname)
	self.txt_id:setString(data.uid)
	self.head = NetSprite:getSpriteUrl(data.image_url,"mj/bg_default_avatar_1.png")
    self.head:setAnchorPoint(cc.p(0, 0))
    self.head:setImageContentSize(self.img_head:getContentSize())
    self.head:addTo(self.img_head, 1)
end

return ClubPlayerInfo
