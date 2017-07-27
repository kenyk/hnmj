--
-- Author: LHF
-- Date: 2016-12-23
--

local HaidiUI = class("HaidiUI", cc.load("mvc").UIBase)
HaidiUI.RESOURCE_FILENAME = "uihaidi/UI_Haidi.csb"
HaidiUI.RESOURCE_MODELNAME = "app.views.ui.create.CreateRoomModel"
local MahjongTile = require("app.views.mj.MahjongTile")

function HaidiUI:onCreate(data)
    local fadeOutTime = 1
    if data.wang then
        self.tile = MahjongTile.new({id = data.wang, type = 1, is_free = false}):addTo(self.resourceNode_)
        self.resourceNode_:getChildByName("Image_16"):setVisible(false)
        self.resourceNode_:getChildByName("Image_15"):setVisible(false)
        local time2 = 0.3
        self.resourceNode_:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(function ()
            local seq = cc.Sequence:create(cc.ScaleTo:create(0.5, 1.5), cc.ScaleTo:create(0.5, 1), cc.CallFunc:create(function ()
                self.tile.bg:runAction(cc.FadeOut:create(time2))
                self.tile.cg:runAction(cc.FadeOut:create(time2))
                if self.tile.laiziImg then
                    self.tile.laiziImg:runAction(cc.FadeOut:create(time2))
                end
                self.tile:runAction(cc.MoveTo:create(time2, cc.p(100, 600)))
                self.resourceNode_:runAction(cc.FadeOut:create(time2))
                performWithDelay(self.resourceNode_, function()
                            NotifyMgr:push(consts.Notify.SHOW_LAIZI_CARD, {laizi = data.wang, ani = true})
                            UIMgr:closeUI(consts.UI.haidiui)
                        end, time2 + 0.1)
            end))
            self.tile:runAction(seq)
        
    end)))
    elseif data.haidi then
        self.tile = MahjongTile.new({id = data.haidi, type = 1, is_free = false}):addTo(self.resourceNode_)
        self.resourceNode_:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function ()
        self.tile.bg:runAction(cc.FadeOut:create(fadeOutTime))
        self.tile.cg:runAction(cc.FadeOut:create(fadeOutTime))
        if self.tile.laiziImg then
            self.tile.laiziImg:runAction(cc.FadeOut:create(fadeOutTime))
        end
        self.resourceNode_:runAction(cc.FadeOut:create(fadeOutTime))
        performWithDelay(self.resourceNode_, function()
                    UIMgr:closeUI(consts.UI.haidiui)
                end, fadeOutTime + 0.1)
    end)))
    end
    self.tile:setAnchorPoint(cc.p(0, 0))
    self.tile:setPosition(cc.p(690, 384))
    -- self.tile:setPosition(cc.p(100, 600))
end

function HaidiUI:onEnter()
    
end

function HaidiUI:onExit()
    self.resourceNode_:stopAllActions()
end

return HaidiUI