
local ConfirmDialogUI = class("ConfirmDialogUI", cc.load("mvc").UIBase)
local roomId = ""
local index = 0

ConfirmDialogUI.RESOURCE_FILENAME = "common/UI_ConfirmDialog.csb"
-- ConfirmDialogUI.RESOURCE_MODELNAME = "app.views.ui.setting.SettingModel"

local canCancelOutside

function ConfirmDialogUI:onCreate(msg)

    self:setInOutAction()
    NotifyMgr:reg(consts.Notify.CONFIRM_DLALOG_CLOSE, self.close,self)
    self.yesBtn = helper.findNodeByName(self.resourceNode_,"btn_yes")
    self.yesBtn:setPressedActionEnabled(true)
    self.noBtn = helper.findNodeByName(self.resourceNode_,"btn_no")
    self.noBtn:setPressedActionEnabled(true)
    self.titleImg= helper.findNodeByName(self.resourceNode_,"title_img")
    self.bottemBg = helper.findNodeByName(self.resourceNode_,"bg_bottem")
    --self.contentBgImage= helper.findNodeByName(self.resourceNode_,"bg_image")
    self.yesBtnText = helper.findNodeByName(self.resourceNode_,"btn_yes_text")
    self.noBtnText = helper.findNodeByName(self.resourceNode_,"btn_no_text")

    self.contentSize={width=consts.bgSize.m.w,height=consts.bgSize.m.h}
    self.btnPadding=85
    self.titlePadding = 23
    if msg.btnPadding then
        self.btnPadding=msg.btnPadding
    end
    if msg.width then 
        self.contentSize.width=msg.width
    end
    if msg.height then 
        self.contentSize.height=msg.height
        if msg.height == consts.bgSize.s.h then
            self.titlePadding = 58
        end
    end
    -- 如果no按钮没设置事件，则不显示no按钮
    if msg.noBtnEvent then
        self.noBtn:addClickEventListener(function(sender)
            if msg.notDismissDialogForBtnClick==nil or msg.notDismissDialogForBtnClick==false then 
                self:close()
            end
            msg.noBtnEvent()
        end)
    else 
        self.yesBtn:setPosition(cc.p(display.width/2, (display.height-self.contentSize.height)/2+self.btnPadding))
        self.noBtn:setVisible(false)
    end
    if msg.yesBtnEvent then
        self.yesBtn:addClickEventListener(function(sender)
            if msg.notDismissDialogForBtnClick==nil or msg.notDismissDialogForBtnClick==false then 
                self:close()
            end
            msg.yesBtnEvent()
        end)
    else 
        self.noBtn:setPosition(cc.p(display.width/2, (display.height-self.contentSize.height)/2+self.btnPadding))
        self.yesBtn:setVisible(false)
    end
    self.yesBtn:setPositionY((display.height-self.contentSize.height)/2+self.btnPadding - 5 -70)
    self.noBtn:setPositionY((display.height-self.contentSize.height)/2+self.btnPadding - 5 -70)

    if msg.title then
        self.titleImg:loadTexture(msg.title)
    else
    end
    if msg.child then
        msg.childOffsetX = msg.childOffsetX or 0 
        msg.childOffsetY = msg.childOffsetY or 0
        msg.child:setAnchorPoint(cc.p(0.5,0.5))
        local contentNode = self:getContentNode()
        if contentNode then
            msg.child:setPosition(cc.p(0 + msg.childOffsetX,20 + msg.childOffsetY))
            msg.child:addTo(contentNode,2)
            if msg.child.setParentWrapper then
                msg.child:setParentWrapper(self)
            end
        else
            msg.child:setPosition(cc.p(consts.Size.width / 2 + msg.childOffsetX, 
                consts.Size.height / 2 + msg.childOffsetY))
            msg.child:addTo(self,2)
        end
    end
    --self.contentBgImage:setContentSize(cc.size(self.contentSize.width - 20,self.contentSize.height - 20))
    --self.titleImg:setPosition(cc.p(display.width/2 + 10,display.height-(display.height-self.contentSize.height)/2 + self.titlePadding))
    canCancelOutside=msg.canCancelOutside
    if msg.useForAgreement then
        self.yesBtnText:loadTexture("mj/dialog_btn_agree.png")
        self.noBtnText:loadTexture("mj/dialog_btn_reject.png")
    elseif msg.yao then
        self.yesBtnText:loadTexture("mj/yao.png")
        self.noBtnText:loadTexture("mj/guo.png")
    else
        self.yesBtnText:loadTexture("uires/common/dialog/dialog_btn_confirm.png")
        self.noBtnText:loadTexture("uires/common/dialog/dialog_btn_cancel.png")
    end
end

function ConfirmDialogUI:hideButtons()
    self.noBtn:setVisible(false)
    self.yesBtn:setVisible(false)
end

function ConfirmDialogUI:onDialogOutsideClick()
    if  canCancelOutside then
       self:close()
    end
end

function ConfirmDialogUI:onDialogContentClick()
end




return ConfirmDialogUI