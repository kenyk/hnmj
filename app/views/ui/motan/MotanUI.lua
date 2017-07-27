

local MotanUI = class("MotanUI", cc.load("mvc").UIBase)

-- MotanUI.RESOURCE_FILENAME = "app.views.ui.motan.MotanUI.csb"
MotanUI.RESOURCE_FILENAME = "motan/motanUI.csb"

function MotanUI:onCreate()
    self:setInOutAction()
    self.btnBack = helper.findNodeByName(self.resourceNode_, "btnBack")
    self.btnBack:setPressedActionEnabled(true)
end

function MotanUI:onBack()
    self:close()
end

function MotanUI:onExit()
    MotanUI.super.onExit(self)
end

function MotanUI:onBaoming()
    cc.Application:getInstance():openURL("http://wap.kuailai88.com/index/actEnter")
end

function MotanUI:onDetail()
    cc.Application:getInstance():openURL("http://wap.kuailai88.com/ClubCompetition/")
end

return MotanUI




