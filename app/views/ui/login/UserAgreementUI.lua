--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

local UserAgreementUI = class("UserAgreementUI", cc.load("mvc").UIBase)
local RichLabel = require("utils.richlabel.RichLabel")

UserAgreementUI.RESOURCE_FILENAME = "uiLogin/UI_User_Agreement.csb"

function UserAgreementUI:onCreate(params)
    self:setInOutAction()
    self.text = "游戏用户协议"
    self.closeBtn = helper.findNodeByName(self.resourceNode_,"closeBtn")
    self.closeBtn:setPressedActionEnabled(true)
    self.scrollView = helper.findNodeByName(self.resourceNode_,"scrollView")
    self.bgContent = helper.findNodeByName(self.resourceNode_,"bgContent")
    self.Image_1 = helper.findNodeByName(self.resourceNode_,"Image")
    --csb页
    for i=1,2 do
        local title = helper.findNodeByName(self.resourceNode_,"title_"..i)
        local msg = helper.findNodeByName(self.resourceNode_,"msg_"..i)
        -- title:setVisible(false)
        -- msg:setVisible(false)
    end
end

function UserAgreementUI:onEnter()
    UserAgreementUI.super.onEnter(self)
    NotifyMgr:reg(consts.Notify.UPDATE_MAIL, self.update ,self)
end

function UserAgreementUI:onExit()
    UserAgreementUI.super.onExit(self)
end

function UserAgreementUI:update(data)
    local params = data.data
    for i=1,2 do
        local title = helper.findNodeByName(self.resourceNode_,"title_"..i)
        local msg = helper.findNodeByName(self.resourceNode_,"msg_"..i)
        title:setVisible(i == params.type)
        msg:setVisible(i == params.type)
    end
    if params.url then
        self.scrollView:setVisible(false)
        helper.findNodeByName(self.resourceNode_,"msg_"..1):setVisible(false)
        helper.findNodeByName(self.resourceNode_,"msg_"..2):setVisible(false)
        local size = cc.size(980+60, 480+60)
        --local pos = cc.p(10, 10)
        local pos = cc.p(1202/2, 40)
        if cc.PLATFORM_OS_WINDOWS == cc.Application:getInstance():getTargetPlatform() then
            local layout = ccui.Layout:create()
            layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
            layout:setBackGroundColor(cc.c3b(0x00, 0x00, 0xff))
            layout:setContentSize(size)
            layout:setPosition(pos)
            layout:setTouchEnabled(true)
            -- layout:setAnchorPoint(cc.p(0.5, 0.5))
            self.Image_1:addChild(layout)
        else
            local view = ccexp.WebView:create()
            view:loadFile(params.url)
            view:setBounces(false)
            view:setAnchorPoint(cc.p(0.5, 0))
            view:setContentSize(size)
            view:setScalesPageToFit(true)
            view:setPosition(pos)
            self.Image_1:addChild(view)
        end
    end
end

function UserAgreementUI:showText()
	local label = ccui.Text:create(self.text,"Arial", 25)
    label:setColor(cc.c3b(142, 108, 89))
    label:setPosition(cc.p(10, 5440))
    label:setAnchorPoint(cc.p(0,1))
    label:ignoreContentAdaptWithSize(false)
    label:setContentSize(cc.size(1179, 5440));
    label:addTo(self.scrollView,1)
end


function UserAgreementUI:onCloseBtnClick()
	self:close()
end


return UserAgreementUI