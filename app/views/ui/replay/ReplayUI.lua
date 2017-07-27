local ReplayUI = class("ReplayUI", cc.load("mvc").UIBase)
ReplayUI.RESOURCE_FILENAME = "uiReplay/UI_Replay.csb"
-- ReplayUI.RESOURCE_MODELNAME = "app.views.ui.create.CreateRoomModel"

function ReplayUI:onCreate(data)
    self.Button_1 = helper.findNodeByName(self.resourceNode_,"Button_1")
    self.Button_2 = helper.findNodeByName(self.resourceNode_,"Button_2")
    self.Button_3 = helper.findNodeByName(self.resourceNode_,"Button_3")
    self.Button_4 = helper.findNodeByName(self.resourceNode_,"Button_4")
    for i=1,4 do
        self["Button_"..i]:setPressedActionEnabled(true)
        self["Button_"..i]:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if self.Button_4 == sender then
                    -- self:exit()
                    local dialogContentLabel1=helper.createRichLabel({maxWidth = 600,fontSize = 30})
                    dialogContentLabel1:setString("是否退出播放？")
                    dialogContentLabel1:setColor(cc.c3b(153, 78, 46))
                    local dialogContent =cc.Layer:create()
                    dialogContentLabel1:addTo(dialogContent,1)
                    UIMgr:showConfirmDialog("提示",{child=dialogContent, childOffsetY= 25},function ()
                        self:exit()
                    end, function()end)
                elseif self.Button_3 == sender then
                    NotifyMgr:push(consts.Notify.REPLAY_SPEED)
                elseif self.Button_2 == sender then
                    NotifyMgr:push(consts.Notify.REPLAY_PAUSE)
                elseif self.Button_1 == sender then
                    NotifyMgr:push(consts.Notify.REPLAY_BACK)
                end
            end
        end)
    end
end

function ReplayUI:exit()
    MyApp:goToMain()
    self:close()
end

function ReplayUI:onEnter()
    
end

function ReplayUI:changePlayState(isPlay)
    if isPlay then
        self.Button_2:loadTextureNormal("uires/replay/replay_play.png")
        self.Button_2:loadTexturePressed("uires/replay/replay_play.png")
    else
        self.Button_2:loadTextureNormal("uires/replay/replay_pause.png")
        self.Button_2:loadTexturePressed("uires/replay/replay_pause.png")
    end
end

function ReplayUI:onExit()
    self.resourceNode_:stopAllActions()
end

return ReplayUI