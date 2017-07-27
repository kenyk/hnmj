local SwitchBtn = class("SwitchBtn", ccui.Layout)

function SwitchBtn:ctor(callback)
	self.widget = cc.CSLoader:createNode("common/SwitchBtn.csb")
	self:addChild(self.widget)
	self.layout = self.widget:getChildByName("layout")
	self:setContentSize(self.layout:getContentSize())

	self.switch_open = self.layout:getChildByName("switch_open")
	self.switch_close = self.layout:getChildByName("switch_close")
	self.switch_btn = self.layout:getChildByName("switch_btn")

	self.callback = callback

	self.isOpen = false
	self:changeState()
	self.layout:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			self:changeState()
			if callback then
				callback(self.isOpen)
			end
		end
	end)
end

function SwitchBtn:changeState()
	self.isOpen = not self.isOpen
	self.switch_open:setVisible(self.isOpen)
	self.switch_close:setVisible(not self.isOpen)
	if self.isOpen then
		self.switch_btn:setPosition(cc.p(26.57, 15.59))
	else
		self.switch_btn:setPosition(cc.p(77.57, 15.59))
	end
end

function SwitchBtn:setState(s)
	self.isOpen = not s
	self:changeState()
end

return SwitchBtn
