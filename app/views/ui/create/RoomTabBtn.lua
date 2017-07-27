local RoomTabBtn = class("RoomTabBtn", ccui.Layout)

function RoomTabBtn:ctor(index)
	self.index = index

	local size = cc.size(240, 110)
	self:setContentSize(size)

	-- self.m_btn = ccui.Button:create("uires/createRoom/button2.png", "uires/createRoom/button1.png", "")
	self.m_btn = ccui.ImageView:create()
	self.m_btn:loadTexture("uires/createRoom/button1.png")
	self:addChild(self.m_btn)
	self.m_btn:setPosition(cc.p(5, 18))
	self.m_btn:setAnchorPoint(cc.p(0, 0))
	self.m_btn:setTouchEnabled(true)
	self.m_btn:ignoreContentAdaptWithSize(false)
	self.m_btn:setContentSize(cc.size(240, 85))

	self.m_line = ccui.ImageView:create()
	self.m_line:loadTexture("uires/createRoom/xuxian.png")
	self:addChild(self.m_line)
	self.m_line:setPosition(cc.p(234/2.0, 0))
	self.m_line:setAnchorPoint(cc.p(0.5, 0))
	self.m_line:setTouchEnabled(true)
	self.m_line:ignoreContentAdaptWithSize(false)
	self.m_line:setContentSize(cc.size(229, 18))


	self.m_title = ccui.ImageView:create()
	self.m_title:loadTexture(string.format("uires/createRoom/creat_title_%d_n.png", index))
	self:addChild(self.m_title)
	self.m_title:setPosition(cc.p(123, 65))
	-- self.m_title:setAnchorPoint(cc.p(0, 0))
end

function RoomTabBtn:setSelect(bSelect)
	-- self.m_btn:setHighlighted(bSelect)
	self.m_btn:setTouchEnabled(not bSelect)
	if bSelect then
		self.m_title:loadTexture(string.format("uires/createRoom/creat_title_%d_s.png", self.index))
		self.m_btn:loadTexture("uires/createRoom/button1.png")
		self.m_btn:setContentSize(cc.size(240, 85))
		--self.m_btn:setVisible(true)
	else
		self.m_title:loadTexture(string.format("uires/createRoom/creat_title_%d_n.png", self.index))
		self.m_btn:loadTexture("uires/createRoom/button2.png")
		--self.m_btn:loadTexture("")
		--self.m_btn:setVisible(false)
		self.m_btn:setContentSize(cc.size(240, 85))
	end
end

return RoomTabBtn
