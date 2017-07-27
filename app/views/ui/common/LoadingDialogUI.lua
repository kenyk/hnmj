
local LoadingDialogUI = class("LoadingDialogUI", cc.load("mvc").UIBase)

LoadingDialogUI.RESOURCE_FILENAME = "common/UI_Loading_Dialog.csb"

local AnimationView = require("utils.extends.AnimationView")

function LoadingDialogUI:onCreate(msg)
    self.cancelOutside  = false
    self.tMsg =  helper.findNodeByName(self.resourceNode_,"tMsg")
    self.bg =  helper.findNodeByName(self.resourceNode_,"bg_black")
    self.bgImage = helper.findNodeByName(self.resourceNode_,"bg_image")
    self.load_quan = helper.findNodeByName(self.resourceNode_,"load_quan")
    if msg then
        self.tMsg:setString(msg)
    end
	-- local animation = AnimationView:create("loading","action/loading.csb")
	-- animation:setPosition(cc.p(self.bgImage:getContentSize().width / 2, 145))
 --    animation:gotoFrameAndPlay(0,true)
 --    animation:addTo(self.bgImage,1000)
    local action = cc.Repeat:create(cc.RotateBy:create(.5,360),cc.REPEAT_FOREVER)
    self.load_quan:runAction(action)
    self.bg:setOpacity(0)
    performWithDelay(self.bg, function()
        self.bg:setOpacity(255)
        end, 2)
end

function LoadingDialogUI:onDialogOutsideClick(params)
    if self.cancelOutside then
        self:close()
    end
end

function LoadingDialogUI:onExit()
    LoadingDialogUI.super.onExit(self)
    self.load_quan:stopAllActions()
    self.bg:stopAllActions()
end

return LoadingDialogUI