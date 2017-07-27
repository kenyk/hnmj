--
-- Author: LXL
-- Date: 2016-11-03 12:15:12
--

local LoginLowUI = class("LoginLowUI", cc.load("mvc").UIBase)

LoginLowUI.RESOURCE_FILENAME = "uiLogin/UI_Law.csb"

function LoginLowUI:onCreate()
    self.closeBtn = helper.findNodeByName(self.resourceNode_,"closeBtn")
    self.closeBtn:setPressedActionEnabled(true)
end

function LoginLowUI:onClose(event)
	self:close()
end

return LoginLowUI