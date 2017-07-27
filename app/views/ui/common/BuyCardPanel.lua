

local BuyCardPanel = class("BuyCardPanel", cc.load("mvc").UIBase)

BuyCardPanel.RESOURCE_FILENAME = "common/UI_Buycard_Panel.csb"

function BuyCardPanel:onCreate()
    self:setInOutAction()
    self.closeBtn = helper.findNodeByName(self.resourceNode_,"closeBtn")
    self.closeBtn:setPressedActionEnabled(true)
    self.cardInfoBtn = helper.findNodeByName(self.resourceNode_,"btn_copyCardInfo")
    self.cardInfoBtn:setPressedActionEnabled(true)
    self.delegateInfoBtn = helper.findNodeByName(self.resourceNode_,"btn_copyDelegateInfo")
    self.delegateInfoBtn:setPressedActionEnabled(true)
    self.compliantInfoBtn = helper.findNodeByName(self.resourceNode_,"btn_copyCompliantInfo")
    self.compliantInfoBtn:setPressedActionEnabled(true)

    self.cardInfo = helper.findNodeByName(self.resourceNode_,"lbl_cardInfo")
    self.delegateInfo = helper.findNodeByName(self.resourceNode_,"lbl_delegateInfo")
    self.complainInfo = helper.findNodeByName(self.resourceNode_,"lbl_complainInfo")
end

function BuyCardPanel:onCopyCardInfo()
	LuaCallPlatformFun.copyStr(self.cardInfo:getString())
    self:showContent()
end

function BuyCardPanel:onCopyDelegateInfo()
	LuaCallPlatformFun.copyStr(self.delegateInfo:getString())
    self:showContent()
end

function BuyCardPanel:onCopyCompliantInfo()
	LuaCallPlatformFun.copyStr(self.complainInfo:getString())
    self:showContent()
end

function BuyCardPanel:showContent()
    UIMgr:showTips("复制成功", nil)
end


function BuyCardPanel:onCloseBtnClick(  )
    self:close()
end

return BuyCardPanel;
