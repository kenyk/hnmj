local ClubTabBtn = class("ClubTabBtn", ccui.Layout)

function ClubTabBtn:ctor(index)
	self.index = index

	local size = cc.size(240, 110)
	self:setContentSize(size)

	self.m_btn = ccui.ImageView:create()
	self.m_btn:loadTexture("uires/createRoom/button2.png")
	self:addChild(self.m_btn)
	self.m_btn:setPosition(cc.p(25, 0))
	self.m_btn:setAnchorPoint(cc.p(0, 0))
	self.m_btn:setTouchEnabled(true)
	-- self.m_btn:ignoreContentAdaptWithSize(false)

	self.m_title = ccui.ImageView:create()
	self.m_title:loadTexture(string.format("uires/club/i18n_txtzhanji%d_n.png", index))
	self:addChild(self.m_title)
	self.m_title:setPosition(cc.p(123, 55))
	-- self.m_title:setAnchorPoint(cc.p(0, 0))
end

function ClubTabBtn:setSelect(bSelect)
	-- self.m_btn:setHighlighted(bSelect)
	self.m_btn:setTouchEnabled(not bSelect)
	if bSelect then
		self.m_title:loadTexture(string.format("uires/club/i18n_txtzhanji%d_s.png", self.index))
		self.m_btn:loadTexture("uires/createRoom/button1.png")
	else
		self.m_title:loadTexture(string.format("uires/club/i18n_txtzhanji%d_n.png", self.index))
		self.m_btn:loadTexture("uires/createRoom/button2.png")
	end
end

return ClubTabBtn
