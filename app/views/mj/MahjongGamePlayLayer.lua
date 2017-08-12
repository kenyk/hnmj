-- 麻将游戏战斗进行中图层

MahjongGamePlayLayer = class("MahjongGamePlayLayer", function()
    return cc.Layer:create()
end)

local RichLabel = require("utils.richlabel.RichLabel")
local MahjongTile = import(".MahjongTile")
local mjaction = import(".MjActionLogic")
local MahjongPlayer = import(".MahjongPlayer")
local DismissRoomApplyDialogLayer=import(".DismissRoomApplyDialogLayer")
function MahjongGamePlayLayer:ctor(params)
    self:enableNodeEvents()
    self:initLayer()
    self:initEvent()
    self:initData()
    self:hide_bn()
end

function MahjongGamePlayLayer:initData()
    self.textInfoStr = "剩余%d张                             第%d/%d局"
    self.m_voiceList = {}
    self.m_voicePlayNode = cc.Node:create()--语音专用播放node
    self:addChild(self.m_voicePlayNode)
    self.should_touch = false
    self.cur_sel = nil
    self.cur_selected = nil
    self.moving = false
    self.cur_sel_pos = 0
    self.firstDraw = true
    self.inFirstHuAction = false   --起手胡动作  区别是否做真正的胡
    self.isFirstHuEvent = true     --起手胡事件  开局设置为true  如果起手胡服务器不下发方位  否则在此设为false  用来区别开局是否有玩家起手胡
    self.huPlayerList = {}
    self.clickTime1 = 0
end

-- function MahjongGamePlayLayer:test()
--     local mj = self.myPlayer.hold_tiles[self.myPlayer.hold_tiles.count]--倒数第二张
--     self.cur_sel = mj
--     self.cur_sel_pos = self.myPlayer.hold_tiles.count
--     local tile_id = self.cur_sel:get_id()
--     AudioMgr:on_mahjong_tile(tile_id)
--     GnetMgr:lock()
--     self.myPlayer:play(tile_id, self.cur_sel_pos)
--     self.should_touch = false
--     self._model:send("game_out_card",{card = tile_id})
--     NotifyMgr:push(consts.Notify.CLEAR_SAME_CARD_TAG)
--     self.m_tingTip:setVisible(false)
--     self.cur_sel = nil
--     self.cur_sel_pos = 0
--     self.moving = false
-- end

function MahjongGamePlayLayer:initEvent()
    NotifyMgr:reg(consts.Notify.RECONNECT_CARD, self.showCardUpdate ,self)
    NotifyMgr:reg(consts.Notify.SHOW_LAIZI_CARD, self.showLaiziCard2 ,self)
    NotifyMgr:reg(consts.Notify.APP_ENTER_BACKGROUND, self.onBackgroud ,self)
    --add the touch event
    local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
            if(self.m_tingTip:isVisible())then self.m_tingTip:setVisible(false)end
            print(string.format("Paddle::onTouchBegan id = %d, x = %f, y = %f", touch:getId(), touch:getLocation().x, touch:getLocation().y))
            print("inDrawAction:",self.myPlayer.inDrawAction)
            print("isEnableOutCard:",self.isEnableOutCard)
            print("isFirstHuEvent",self.isFirstHuEvent)
            print("should_touch",self.should_touch)
            if GnetMgr.isHandle then --在处理协议的时候不能操作
                return
            end
            if self.isEnableOutCard or self.isFirstHuEvent then 
                return
            end
            if self.myPlayer.inDrawAction then return end
            local x = touch:getLocation().x
            local y = touch:getLocation().y
            if nil == self.cur_sel then
                if self.myPlayer.just_got then
                    local mj = self.myPlayer.just_got
                    if mj:containsPoint(x, y) then
                        self.cur_sel = mj
                        self.cur_sel_pos = self.myPlayer.hold_tiles.count + 1
                        print("select a majong_tile")
                    end
                end
                for i = 1, self.myPlayer.hold_tiles.count do
                    local mj = self.myPlayer.hold_tiles[i]
                    if mj:containsPoint(x, y) then
                        self.cur_sel = mj
                        self.cur_sel_pos = i
                        print("select a majong_tile")
                    end
                end
            end
            if self.cur_sel then
                self:reorderChild(self.cur_sel, 1500)
            end
            self.start_x = x
            self.start_y = y
            return true
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    listenner:registerScriptHandler(function(touch, event)
            if GnetMgr.isHandle then --在处理协议的时候不能操作
                return
            end
            local x = touch:getLocation().x
            local y = touch:getLocation().y
            if self.cur_sel and self.should_touch then
                if self.moving or math.abs(self.start_x - x) + math.abs(self.start_y - y) > 20 then
                    self.cur_sel:setPosition(self:convertToNodeSpace(cc.p(x, y)))
                    self.moving = true;
                end
            end
        end,cc.Handler.EVENT_TOUCH_MOVED )
    listenner:registerScriptHandler(function(touch, event)
            if GnetMgr.isHandle then --在处理协议的时候不能操作
                return
            end
            local x = touch:getLocation().x
            local y = touch:getLocation().y
            if self.cur_sel then
                AudioMgr:on_mahjong()
                if self.should_touch then
                    print("touchend sel a tile")
                    if not self.moving then
                        print("tap a tile, and try to make it up", self.cur_sel:get_id())
                        NotifyMgr:push(consts.Notify.SELECT_ONE_MJ, self.cur_sel:get_id())
                        if self.cur_sel.is_sel then
                            local tile_id = self.cur_sel:get_id()
                            AudioMgr:on_out()
                            performWithDelay(display.getRunningScene(), function()
                                AudioMgr:on_mahjong_tile(tile_id)
                            end, 0.2)
                            GnetMgr:lock()
                            self.myPlayer:play(tile_id, self.cur_sel_pos)
                            self.should_touch = false
                            self._model:send("game_out_card",{card = tile_id})
                            NotifyMgr:push(consts.Notify.CLEAR_SAME_CARD_TAG)
                            self.m_tingTip:setVisible(false)
                        else
                            if self.cur_selected then
                                self:set_sel(self.cur_selected, false)
                                self.cur_selected = nil
                            end
                            self:set_sel(self.cur_sel, true)
                            self.cur_selected = self.cur_sel
                            --听牌提示
                            self:updateTingTip(self.cur_sel_pos,self.cur_sel:getPositionX())
                        end
                    elseif (y - self.start_y) > 50 then
                        --moving out
                        local tile_id = self.cur_sel:get_id()
                        GnetMgr:lock()
                        self.myPlayer:play(tile_id, self.cur_sel_pos)
                        self.should_touch = false
                        AudioMgr:on_out()
                            performWithDelay(display.getRunningScene(), function()
                                AudioMgr:on_mahjong_tile(tile_id)
                            end, 0.2)
                        self._model:send("game_out_card",{card = tile_id})
                        NotifyMgr:push(consts.Notify.CLEAR_SAME_CARD_TAG)

                        self.m_tingTip:setVisible(false)
                    else
                        self:reorderChild(self.cur_sel, 1000)
                        self.myPlayer:update_mj()
                    end
                elseif not self.moving then
                    local sameIndex = self.cur_selected == self.cur_sel
                    if self.cur_selected then
                        self:set_sel(self.cur_selected, false)
                        self.cur_selected = nil
                        NotifyMgr:push(consts.Notify.CLEAR_SAME_CARD_TAG)
                    end
                    if not sameIndex then
                        self:set_sel(self.cur_sel, true)
                        self.cur_selected = self.cur_sel
                        NotifyMgr:push(consts.Notify.SELECT_ONE_MJ, self.cur_sel:get_id())
                    end
                end
            else
                if self.cur_selected then
                    self:set_sel(self.cur_selected, false)
                    self.cur_selected = nil
                    NotifyMgr:push(consts.Notify.CLEAR_SAME_CARD_TAG)
                end
            end
            self.cur_sel = nil
            self.cur_sel_pos = 0
            self.moving = false
        end,cc.Handler.EVENT_TOUCH_ENDED )
    listenner:registerScriptHandler(function(touch, event)
            if self.cur_sel or self.moving then
                self.myPlayer:update_mj()
            end
            self.cur_sel = nil
            self.cur_sel_pos = 0
            self.moving = false
        end,cc.Handler.EVENT_TOUCH_CANCELLED)
    
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)

    self.bn_pass:addClickEventListener(handler(self,self.pass))
    self.bn_hu1:addClickEventListener(handler(self,self.hu))
    self.bn_gang1:addClickEventListener(handler(self,self.gang))
    self.bn_bu1:addClickEventListener(handler(self,self.bu))
    self.bn_peng1:addClickEventListener(handler(self,self.peng))
    self.bn_ting1:addClickEventListener(handler(self,self.ting))
    self.bn_chi1:addClickEventListener(handler(self,self.chi))

    self.bn_hu2:addClickEventListener(handler(self,self.hu))
    self.bn_gang2:addClickEventListener(handler(self,self.gang))
    self.bn_bu2:addClickEventListener(handler(self,self.bu))
    self.bn_peng2:addClickEventListener(handler(self,self.peng))
    self.bn_ting2:addClickEventListener(handler(self,self.ting))
    self.bn_chi2:addClickEventListener(handler(self,self.chi))

    NotifyMgr:reg(consts.Notify.CHANGE_BG_TYPE, self.onChangeBgType, self)
end

function MahjongGamePlayLayer:initLayer()
    self.csb = cc.CSLoader:createNode("gameLayer.csb"):addTo(self)
    helper.findNodeByName(self.csb, "bg"):setVisible(false)
    self.img_click_tip = helper.findNodeByName(self.csb, "img_click_tip"):setTexture("mj/"..UserData:getCurBgType().."/i18n_double_click.png"):setVisible(false)
    self.img_double_click = helper.findNodeByName(self.csb, "img_double_click"):setVisible(false)
    self.layout_click = helper.findNodeByName(self.csb, "layout_click")
    self.layout_click:setVisible(false)
    -- self.layout_click:addTouchEventListener(function(sender, eventType)
    --     if eventType == ccui.TouchEventType.ended then
    --         print("2222222222", self.clickTime1)

    --         -- print("click", os.clock())
    --         if 0 == self.clickTime1 then
    --             self.clickTime1 = os.clock()
    --             if nil == self.clickTimer then
    --                 self.clickTimer = performWithDelay(display.getRunningScene(), function()
    --                     if 0 ~= self.clickTime1 then
    --                         self.clickTime1 = 0
    --                     end
    --                     self.clickTimer = nil
    --                 end, 0.6)
    --             end
    --         else
    --             local interval = os.clock() - self.clickTime1
    --             print(interval <= 0.5 and self.should_touch, interval, self.should_touch)
    --             if interval <= 0.5 and self.should_touch then
    --                 GnetMgr:lock()
    --                 local tile_id
    --                 if self.myPlayer.just_got then
    --                     tile_id = self.myPlayer.just_got.id
    --                     self.myPlayer:play(tile_id, self.myPlayer.hold_tiles.count + 1)
    --                 else
    --                     tile_id = self.myPlayer.hold_tiles[self.myPlayer.hold_tiles.count].id
    --                     self.myPlayer:play(tile_id, self.myPlayer.hold_tiles.count)
    --                 end
    --                 self.should_touch = false
    --                 self._model:send("game_out_card",{card = tile_id})
    --                 NotifyMgr:push(consts.Notify.CLEAR_SAME_CARD_TAG)
    --                 self.m_tingTip:setVisible(false)
    --             end
    --             self.clickTime1 = 0
    --         end
    --     end
    -- end)
    local listenner = cc.EventListenerTouchOneByOne:create()
    listenner:registerScriptHandler(function(touch, event)
            return true
        end,cc.Handler.EVENT_TOUCH_BEGAN)
    listenner:registerScriptHandler(function(touch, event)
        print("11111111111")
        local x = touch:getLocation().x
        local y = touch:getLocation().y
        local rect = self.layout_click:getBoundingBox()
        if not cc.rectContainsPoint(rect, touch:getLocation()) then
            return
        end
        print("2222222222", self.clickTime1)

        -- print("click", os.clock())
        if 0 == self.clickTime1 then
            self.clickTime1 = os.clock()
            self.clickPos = touch:getLocation()
            if nil == self.clickTimer then
                self.clickTimer = performWithDelay(display.getRunningScene(), function()
                    if 0 ~= self.clickTime1 then
                        self.clickTime1 = 0
                    end
                    self.clickTimer = nil
                end, 0.6)
            end
        else
            local dy = math.abs(y - self.clickPos.y)
            local dx = math.abs(x - self.clickPos.x)
            local distance = math.sqrt(dx * dx + dy * dy)
            -- dumpLog("????????", math.sqrt(dx * dx + dy * dy))

            local interval = os.clock() - self.clickTime1
            print(interval <= 0.5 and self.should_touch, interval, self.should_touch)
            if interval <= 0.5 and self.should_touch and distance <= 50 then
                GnetMgr:lock()
                local tile_id
                if self.myPlayer.just_got then
                    tile_id = self.myPlayer.just_got.id
                    self.myPlayer:play(tile_id, self.myPlayer.hold_tiles.count + 1)
                else
                    tile_id = self.myPlayer.hold_tiles[self.myPlayer.hold_tiles.count].id
                    self.myPlayer:play(tile_id, self.myPlayer.hold_tiles.count)
                end
                self.should_touch = false
                self._model:send("game_out_card",{card = tile_id})
                NotifyMgr:push(consts.Notify.CLEAR_SAME_CARD_TAG)
                self.m_tingTip:setVisible(false)
            end
            self.clickTime1 = 0
        end
    end, cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = self.layout_click:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(listenner, -1)

    local font = "Arial"
    self.bn_passX = 1200
    self.bn_passY1 = 220
    -- self.bn_passY2 = 350
    self.bn_passY2 = 410
    self.bn_pass = ccui.Button:create("mj/bn_pass.png", "mj/bn_pass.png", ""):addTo(self, 100)
    self.bn_pass:setPosition(cc.p(self.bn_passX, self.bn_passY1))
    
    self.bn_hu1 = ccui.Button:create("mj/bn_hu.png", "mj/bn_hu.png", ""):addTo(self, 100)
    self.bn_hu2 = ccui.Button:create("mj/bn_hu.png", "mj/bn_hu.png", ""):addTo(self, 100)
    
    self.bn_gang1 = ccui.Button:create("mj/bn_gong.png", "mj/bn_gong.png", ""):addTo(self, 100)
    self.bn_gang2 = ccui.Button:create("mj/bn_gong.png", "mj/bn_gong.png", ""):addTo(self, 100)
    
    self.bn_bu1 = ccui.Button:create("mj/bn_bu.png", "mj/bn_bu.png", ""):addTo(self, 100)
    self.bn_bu2 = ccui.Button:create("mj/bn_bu.png", "mj/bn_bu.png", ""):addTo(self, 100)

    self.bn_peng1 = ccui.Button:create("mj/bn_beng.png", "mj/bn_beng.png", ""):addTo(self, 100)
    self.bn_peng2 = ccui.Button:create("mj/bn_beng.png", "mj/bn_beng.png", ""):addTo(self, 100)

    self.bn_ting1 = ccui.Button:create("mj/bn_ting.png", "mj/bn_ting.png", ""):addTo(self, 100)
    self.bn_ting2 = ccui.Button:create("mj/bn_ting.png", "mj/bn_ting.png", ""):addTo(self, 100)

    self.bn_chi1 = ccui.Button:create("mj/bn_chi.png", "mj/bn_chi.png", ""):addTo(self, 100)
    self.bn_chi2 = ccui.Button:create("mj/bn_chi.png", "mj/bn_chi.png", ""):addTo(self, 100)

    self.operationBg = display.newSprite("mj/operationBg.png"):addTo(self, 99)
    self.label_time = cc.LabelAtlas:_create(0, "mj/time_font.png", 21, 34,  string.byte("0")):addTo(self, 100)
    self.label_time:setAnchorPoint(cc.p(0.5, 0.5))
    self.label_time:setPosition(cc.p(702, 408))
    self.direction = display.newSprite("mj/"..UserData:getCurBgType().."/battle_dir_bg.png", 702, 408):addTo(self, 1)
    self.dir = {
        display.newSprite("mj/"..UserData:getCurBgType().."/battle_dir2.png",108,66):addTo(self.direction, 3):setTag(222),
        display.newSprite("mj/"..UserData:getCurBgType().."/battle_dir3.png",66,110):addTo(self.direction, 3):setTag(223),
        display.newSprite("mj/"..UserData:getCurBgType().."/battle_dir4.png",24,66):addTo(self.direction, 3):setTag(224),
        display.newSprite("mj/"..UserData:getCurBgType().."/battle_dir1.png",66,25):addTo(self.direction, 3):setTag(221),
    }
    for _,v in ipairs(self.dir) do
        v:setVisible(false)
    end
    self.cur_flag = display.newSprite("mj/battle_arrow.png"):addTo(self, 50)
    self.cur_flag:setVisible(false)
    self.textInfo = cc.LabelTTF:create("剩余52张                             第1/8局", font, 22)
    -- self.textInfo:setColor(cc.c3b(105, 215, 92))
    -- self.textInfo:setColor(cc.c3b(239, 237, 224))
    -- self.textInfo:setColor(consts.bg_type[UserData:getCurBgType()].textInfoColor)
    self.textInfo:setColor(cc.c3b(38, 231, 233))
    self.textInfo:setAnchorPoint(cc.p(0.5, 1))
    self.textInfo:setPosition(cc.p(700, 420))
    self:addChild(self.textInfo, 2)
    self.labelroom = cc.LabelTTF:create("", font, 24)
    self.labelroom:setAnchorPoint(cc.p(0.5, 0.5))
    self.labelroom:setPosition(cc.p(80, 715))
    -- self.labelroom:setColor(cc.c3b(199, 199, 199))
    -- self.labelroom:setColor(consts.bg_type[UserData:getCurBgType()].roomIdColor)
    self.labelroom:setColor(helper.str2Color("#ccc332"))
    self.labelroom:addTo(self, 100)

    -- self.battle_di1 = display.newSprite("mj/battle_di.png"):addTo(self):setPosition(cc.p(560, 407)):setContentSize(cc.size(100, 45))
    -- self.battle_di2 = display.newSprite("mj/battle_di.png"):addTo(self):setPosition(cc.p(830, 407)):setContentSize(cc.size(100, 45))

    self.battle_di1 = ccui.ImageView:create("mj/battle_di.png"):addTo(self):setPosition(cc.p(575, 407)):setContentSize(cc.size(105, 45)):ignoreContentAdaptWithSize(false):setScale9Enabled(true)
    self.battle_di2 = ccui.ImageView:create("mj/battle_di.png"):addTo(self):setPosition(cc.p(835, 407)):setContentSize(cc.size(105, 45)):ignoreContentAdaptWithSize(false):setScale9Enabled(true)

    self.m_tingTip = cc.CSLoader:createNode("uiSetting/Tingpai_Tip.csb"):addTo(self,1600)
    self.m_tingTip:setPosition(cc.p(1136-200,74))
    self.m_tingTip:setVisible(false)

    self.m_tileLeftLs = {}--剩余牌

    -- self.btn_rule = ccui.Button:create("mj/huanganniu_x.png", "mj/huanganniu_x.png", ""):addTo(self, 100)
    -- self.btn_rule:ignoreContentAdaptWithSize(false)
    -- self.btn_rule:setContentSize(cc.size(160, 70))
    -- -- self.btn_rule:setScale(0.8)
    -- ccui.ImageView:create("mj/text_guize.png"):addTo(self.btn_rule):setPosition(cc.p(self.btn_rule:getContentSize().width / 2,
    --  self.btn_rule:getContentSize().height / 2 + 5))
    -- self.btn_rule:setAnchorPoint(cc.p(0.5, 1))
    -- self.btn_rule:setPressedActionEnabled(true)
    -- self.btn_rule:setPosition(cc.p(250, consts.Size.height))
    -- self.btn_rule:addTouchEventListener(function(sender, eventType)
    --         if eventType == ccui.TouchEventType.ended then
    --             UIMgr:openUI(consts.UI.RuleUI, nil, nil)
    --         end
    --     end)

    -- local rule_layout = ccui.Layout:create():addTo(self, 101)
    -- rule_layout:setAnchorPoint(cc.p(0.5, 1))
    -- -- rule_layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    -- -- rule_layout:setBackGroundColor(cc.c3b(0x00, 0x00, 0xff))
    -- rule_layout:setContentSize(cc.size(self.btn_rule:getContentSize().width * 2, self.btn_rule:getContentSize().height * 2))
    -- rule_layout:setPosition(cc.p(self.btn_rule:getPositionX(), self.btn_rule:getPositionY()))
    -- rule_layout:setTouchEnabled(true)
    -- rule_layout:addTouchEventListener(function(sender, eventType)
    --         if eventType == ccui.TouchEventType.ended then
    --             UIMgr:openUI(consts.UI.RuleUI, nil, nil)
    --         end
    --     end)
 end

function MahjongGamePlayLayer:onChangeBgType()
    -- self.textInfo:setColor(consts.bg_type[UserData:getCurBgType()].textInfoColor)
    self.textInfo:setColor(cc.c3b(38, 231, 233))
    self.labelroom:setColor(consts.bg_type[UserData:getCurBgType()].roomIdColor)
    self.direction:setTexture("mj/"..UserData:getCurBgType().."/battle_dir_bg.png")
    self.img_click_tip:setTexture("mj/"..UserData:getCurBgType().."/i18n_double_click.png")
    -- for k,v in ipairs(self.dir) do
    --     v:setTexture("mj/"..UserData:getCurBgType().."/battle_dir" .. k ..".png")
    -- end
end

function MahjongGamePlayLayer:setModel(model)
    self._model = model
end

function MahjongGamePlayLayer:set_sel(tile, is_sel)
    if is_sel and not tile.is_sel then
        tile:runAction(CCMoveTo:create(0.05, cc.p(tile:getPositionX(), 106)))
        tile.is_sel = true
    elseif tile.is_sel then
        tile:runAction(CCMoveTo:create(0.05, cc.p(tile:getPositionX(), 71)))
        tile.is_sel = false
    end
end

function MahjongGamePlayLayer:set_cur_tile(tile,pos)
    self.curPlayedMjPos = pos
    self.curPlayedMj = tile
    -- self.curPlayedMj:runAction(cc.MoveBy:create(0,curPlayedPosList[pos]))
    local x, y = tile:getPosition()
    self.cur_flag:stopAllActions()
    local actTime = 0.3
    local offset = 10
    local seq1 = cc.Sequence:create(cc.MoveBy:create(actTime, cc.p(0, offset)), cc.MoveBy:create(actTime, cc.p(0, -offset)), cc.MoveBy:create(actTime, cc.p(0, -offset)), cc.MoveBy:create(actTime, cc.p(0, offset)))
    -- if pos == 1 then
    --     self.cur_flag:setRotation(-90)
    --     self.cur_flag:setPosition(cc.p(x, y + 70))
    --     seq1 = cc.Sequence:create(cc.MoveBy:create(actTime, cc.p(0, offset)), cc.MoveBy:create(actTime, cc.p(0, -offset)), cc.MoveBy:create(actTime, cc.p(0, -offset)), cc.MoveBy:create(actTime, cc.p(0, offset)))
    -- elseif pos == 2 then
    --     self.cur_flag:setRotation(180)
    --     self.cur_flag:setPosition(cc.p(x-50, y + 6))
    --     seq1 = cc.Sequence:create(cc.MoveBy:create(actTime, cc.p(offset, 0)), cc.MoveBy:create(actTime, cc.p(-offset, 0)), cc.MoveBy:create(actTime, cc.p(-offset, 0)), cc.MoveBy:create(actTime, cc.p(offset, 0)))
    -- elseif pos == 3 then
    --     self.cur_flag:setRotation(90)
    --     self.cur_flag:setPosition(cc.p(x, y - 50))
    --     seq1 = cc.Sequence:create(cc.MoveBy:create(actTime, cc.p(0, offset)), cc.MoveBy:create(actTime, cc.p(0, -offset)), cc.MoveBy:create(actTime, cc.p(0, -offset)), cc.MoveBy:create(actTime, cc.p(0, offset)))
    -- elseif pos == 4 then
    --     self.cur_flag:setRotation(0)
    --     self.cur_flag:setPosition(cc.p(x+50, y + 6))
    --     seq1 = cc.Sequence:create(cc.MoveBy:create(actTime, cc.p(offset, 0)), cc.MoveBy:create(actTime, cc.p(-offset, 0)), cc.MoveBy:create(actTime, cc.p(-offset, 0)), cc.MoveBy:create(actTime, cc.p(offset, 0)))
    -- end
    self.cur_flag:setVisible(false)
    self:stopAllActions()
    self.cur_flag:setPosition(cc.p(pos.x, pos.y + 50))
    performWithDelay(self, function()
        self.cur_flag:setVisible(true)
    end, 0.1)
    -- self.cur_flag:setPosition(cc.p(pos.x, pos.y + 50))
    self.cur_flag:runAction(cc.RepeatForever:create(seq1))

end

function MahjongGamePlayLayer:pass()
    if self.bn_hu1:isVisible() or self.bn_hu2:isVisible() then
        local dialogContentLabel1 = helper.createRichLabel({maxWidth = 600,fontSize = 30,fontColor = consts.ColorType.THEME})
        dialogContentLabel1:setString("您真的不胡吗？")
        UIMgr:showConfirmDialog("提示",{child = dialogContentLabel1, childOffsetY = 10},
            handler(self,function()
                self.should_touch = false
                self._model:send("game_cancel_action")
                --取消操作后检查有没有杠后自动出牌
                self:delayOutCard()
                if self.cur_draw_player == self.myPlayer then
                    self.should_touch = true
                end
                self.myPlayer:showTing()
                self:hide_bn()
            end),
            function()

            end)
    else
        -- self.should_touch = false
        self._model:send("game_cancel_action")
        -- if self.cur_draw_player == self.myPlayer then
        if self.cur_draw_player == self.myPlayer or self.cur_player == self.myPlayer then
            self.should_touch = true
        end
        self.myPlayer:showTing()
        self:hide_bn()
    end
end

function MahjongGamePlayLayer:hu(sender)
    local huCard
    if sender == self.bn_hu1 then
        huCard = self.huCard1
    else 
        huCard = self.huCard2
    end
    if huCard then
        if type(huCard) == "table" then
            self._model:send("game_hu_card")
        else
            -- self._model:send("game_hu_card", {card = tonumber(huCard)})
            local ret = xpcall(function ()
                self._model:send("game_hu_card", {card = huCard})
            end, __G__TRACKBACK__)
            if not ret then
                print("2222222222")
                self._model:send("game_hu_card")
            end
        end
    else
        self._model:send("game_first_hu")
    end
    self:hide_bn()
end

function MahjongGamePlayLayer:gang(sender)
    local handle = function ()
        local index = index or 1
        --同时有多个gang时，用户不选择具体的gang哪个牌，默认gang第一个
        if self.selectedGangTile then 
            index = self.selectedGangTile.index
        else
            index = 1
        end
        local index = index or 1
        local tile_id
        if sender == self.bn_gang1 then
            tile_id = self.gangCardList1[index]
        else
            tile_id = self.gangCardList2[index]
        end
        self.should_touch = false
        self._model:send("game_gang_card",{card = tile_id,gang_type=2})
        self:hide_bn()
    end

    if self.bn_hu1:isVisible() or self.bn_hu2:isVisible() then
        local dialogContentLabel1 = helper.createRichLabel({maxWidth = 600,fontSize = 30,fontColor = consts.ColorType.THEME})
        dialogContentLabel1:setString("您真的不胡吗？")
        UIMgr:showConfirmDialog("提示",{child = dialogContentLabel1, childOffsetY = 10},
            handler(self,function()
                handle()
            end),function ()
                
            end)
    else
        handle()
    end
end

function MahjongGamePlayLayer:bu(sender)
    local handle = function ()
        local index = index or 1
        --同时有多个bu时，用户不选择具体的bu哪个牌，默认bu第一个
        if self.selectedGangTile then 
            index = self.selectedGangTile.index
        else
            index = 1
        end
        local index = index or 1
        local tile_id
        if sender == self.bn_bu1 then
            tile_id = self.buCardList1[index]
        else
            tile_id = self.buCardList2[index]
        end
        self.should_touch = false
        self._model:send("game_bu_card",{card = tile_id,bu_type=2})
        self:hide_bn()
    end

    if self.bn_hu1:isVisible() or self.bn_hu2:isVisible() then
        local dialogContentLabel1 = helper.createRichLabel({maxWidth = 600,fontSize = 30,fontColor = consts.ColorType.THEME})
        dialogContentLabel1:setString("你真的不胡吗？")
        UIMgr:showConfirmDialog("提示",{child = dialogContentLabel1, childOffsetY = 10},
            handler(self,function()
                handle()
            end),function ()
                
            end)
    else
        handle()
    end
end

function MahjongGamePlayLayer:peng(sender)
    local handle = function ()
        self.cur_flag:setVisible(false)
        local tile_id
        if sender == self.bn_peng1 then
            tile_id = self.pengCard1
        else
            tile_id = self.pengCard2
        end
        --test
        -- performWithDelay(self, function()
        --    self._model:send("game_peng_card",{card = tile_id}) 
        -- end, 3)
        self._model:send("game_peng_card",{card = tile_id})
        self:hide_bn()
    end

    if self.bn_hu1:isVisible() or self.bn_hu2:isVisible() then
        local dialogContentLabel1 = helper.createRichLabel({maxWidth = 600,fontSize = 30,fontColor = consts.ColorType.THEME})
        dialogContentLabel1:setString("你真的不胡吗？")
        UIMgr:showConfirmDialog("提示",{child = dialogContentLabel1, childOffsetY = 10},
            handler(self,function()
                handle()
            end),function ()
                
            end)
    else
        handle()
    end
end

function MahjongGamePlayLayer:ting()
    self.cur_flag:setVisible(false)
    self._model:send("game_ting_card")
    self:hide_bn()
end

function MahjongGamePlayLayer:chi(index, line)
    local handle = function ()
        if nil == line then --点击吃 按钮的
            if index == self.bn_chi1 then
                line = 1
            else
                line = 2
            end
        end
        local chilist = self["chiCardList"..line]
        print("zzzzzzz", chilist, line, index, index == self.bn_chi1, index == self.bn_chi2)
        if type(index) ~= "number" then
            if #chilist == 2 then
                index = 1
            else
                return
            end
        end
        local chidata = {}
        for i = 1, 3 do
            if chilist[index + 1][i] ~= chilist[1] then
                table.insert(chidata,chilist[index + 1][i])
            end
        end
        self._model:send("game_chi_card",{chi_card = chilist[1],will_chi_card = chidata})
        self:hide_bn()
    end

    if self.bn_hu1:isVisible() or self.bn_hu2:isVisible() then
        local dialogContentLabel1 = helper.createRichLabel({maxWidth = 600,fontSize = 30,fontColor = consts.ColorType.THEME})
        dialogContentLabel1:setString("你真的不胡吗？")
        UIMgr:showConfirmDialog("提示",{child = dialogContentLabel1, childOffsetY = 10},
            handler(self,function()
                handle()
            end),function ()
                
            end)
    else
        handle()
    end
end

function MahjongGamePlayLayer:hide_bn()
    self.bn_pass:setVisible(false)

    self.bn_hu1:setVisible(false)
    self.bn_gang1:setVisible(false)
    self.bn_peng1:setVisible(false)
    self.bn_ting1:setVisible(false)
    self.bn_chi1:setVisible(false)
    self.bn_bu1:setVisible(false)

    self.bn_hu2:setVisible(false)
    self.bn_gang2:setVisible(false)
    self.bn_peng2:setVisible(false)
    self.bn_ting2:setVisible(false)
    self.bn_chi2:setVisible(false)
    self.bn_bu2:setVisible(false)

    self.operationBg:setVisible(false)
    self:clearOperationTile()
end

local dirPosition = {cc.p(50, 14),cc.p(86, 50),cc.p(50, 86),cc.p(14, 50)}
function MahjongGamePlayLayer:set_player(pos)
    for k,v in ipairs(self.dir) do
        v:setVisible(false)
        v:stopAllActions()
    end
    if self.banker_pos == nil then return end
    for k,v in ipairs(self.playerList) do
        v:setOperationState(v:get_pos() == pos)
        if not v.isDealCard then
            return
        end
    end
    self.dir[pos]:runAction(cc.Repeat:create(cc.Sequence:create(cc.FadeIn:create(0.8),
        cc.FadeOut:create(0.8)),cc.REPEAT_FOREVER)) 
    self.dir[pos]:setVisible(true)
end

function MahjongGamePlayLayer:set_banker(pos)
    self.banker_pos = pos
    for k,player in pairs(self.playerList) do
        player:set_is_banker(player.pos == pos)
    end
    self:set_player(pos)
end

function MahjongGamePlayLayer:updateTime()
    if self.timeLeft < 99 and not self.game_end then
        self.timeLeft = self.timeLeft + 1
        self.label_time:setString(self.timeLeft)
        if (0 == (self.timeLeft % 10) or 99 == self.timeLeft) and self.cur_player == self.myPlayer then
            AudioMgr:on_overTime()
            if self.rotateSprite then
                self.rotateSprite:stopAllActions()
                self.rotateSpriteBg:stopAllActions()
            end
            self.rotateSprite = display.newSprite("mj/img_time_over.png"):addTo(self.direction, 1):setPosition(cc.p(self.direction:getContentSize().width / 2, self.direction:getContentSize().height / 2))
            self.rotateSprite:setVisible(true)
            self.rotateSprite:runAction(cc.Sequence:create(cc.Spawn:create(cc.RotateBy:create(1, -360), cc.Sequence:create(cc.FadeIn:create(0.3), cc.DelayTime:create(0.5), cc.FadeOut:create(0.2))),
             cc.CallFunc:create(function ()
                self.rotateSprite:setVisible(false)
            end)))

            self.rotateSpriteBg = display.newSprite("mj/img_time_over_bg.png"):addTo(self.direction, 1):setPosition(cc.p(self.direction:getContentSize().width / 2, self.direction:getContentSize().height / 2))
            self.rotateSpriteBg:setOpacity(0)
            self.rotateSpriteBg:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.FadeIn:create(0.4), cc.FadeOut:create(0.4)))
        end
        if 0 == (self.timeLeft % 16) and self.cur_player == self.myPlayer then
            local script = string.format("local msg={type = 2,id = %d,len=%s,sex = %d}  return msg",12, 2, UserData.userInfo.gender)
            GnetMgr:send("game_talk_and_picture", {id = script})
        end
    end
end

function MahjongGamePlayLayer:onEnter()
    print("MahjongGamePlayLayer on enter:",self)
    self.timeLeft = 0
    if self.timeEntity == nil then
        self.timeEntity = gScheduler:scheduleScriptFunc(handler(self,self.updateTime), 1, false)
    end
end

function MahjongGamePlayLayer:onExit()
    print("MahjongGamePlayLayer on exit")
    if self.timeEntity then
        gScheduler:unscheduleScriptEntry(self.timeEntity)
        self.timeEntity = nil
    end
    NotifyMgr:unregWithObj(self)
    --移除player的事件
    -- for _, v in pairs(self.playerList) do
    --     NotifyMgr:unregWithObj(v)
    -- end
    for _,v in pairs(self.dir) do
        v:stopAllActions()
    end
    self:stopAllActions()
end

function MahjongGamePlayLayer:updatePlayerInfo(msg)
    self.playerList = self.playerList or {}
    local player_count = UserData.table_config.player_count
    local game_count = UserData.table_config.game_count
    for i = 1, player_count do
        local pInfo     = UserData:getPlayerInfoByChairId(i)
        local realPos   = helper.getRealPos(i,UserData.myChairId,player_count)
        local player    = self.playerList[i] or MahjongPlayer:create({pos = realPos,noShow_readyfor_game=1}):addTo(self, 1000)
        self.playerList[i] = player
        NotifyMgr:reg(consts.Notify.SELECT_ONE_MJ, player.showSameSelectMJ ,player)
        NotifyMgr:reg(consts.Notify.CLEAR_SAME_CARD_TAG, player.clearSameCardTag ,player)
        if pInfo then
            player:sitDown({parent = self, id = pInfo.uid, chairId = pInfo.chair_id, name = pInfo.nickname, score = pInfo.point, url = pInfo.image_url,sex = pInfo.gender or 1, realPos = helper.getRealPos(i, 1, player_count)})
            player:setPlayerPoint()
            if realPos == 1 then
                self.myPlayer = player
            end
        else
            player:standUp()
        end
    end
    self:setVisible(UserData.game_status == UserData.GAME_STATUS.start)
    -- self.game_end = false
    self.game_end = not (UserData.game_status == UserData.GAME_STATUS.start)
end

function MahjongGamePlayLayer:getPlayer(chairId)
    return self.playerList[chairId]
end

function MahjongGamePlayLayer:onRespChangShaStartOut()
    self.isFirstHuEvent = false
    -- self.should_touch = true
    self.recvOnRespChangShaStartOut = true
end

-- 处理服务端下发的发牌事件
function MahjongGamePlayLayer:onRespGameDealCard(msg)
    local mycards = msg.args.cards
    local cardsNum = msg.args.card_num
    local firstPlayer = msg.args.card_first
    self.cardsLeftNum =  UserData:getTotalCardNum()
    self:enableToOutAllCards(false)
    -- if UserData.table_config.player_count == 4 and self.dirZi == nil then
    --     self.dirZi = display.newSprite("mj/battle_dir_zi.png", 75, 78):addTo(self.direction, 1)
    --     self.dirZi:setRotation((UserData.self_pos-1)*90)
    -- end
    self.textInfo:setString(string.format(self.textInfoStr,self.cardsLeftNum,UserData:getCurCount(),UserData:getTotalCount()))
    for k,player in pairs(self.playerList) do
        player:draws(mycards)
        self.cardsLeftNum = self.cardsLeftNum - #mycards
    end

    self:updateLeftTile()

    self.img_double_click:setVisible(true)
    self.img_click_tip:setVisible(true)
    performWithDelay(self.img_click_tip, function()
        self.img_double_click:setVisible(false)
        self.img_click_tip:setVisible(false)
    end, 15)
end

--战局回放 抽卡
function MahjongGamePlayLayer:onRespReplayGameDealCard(msg)
    local mycards = msg.args.cards
    -- local cardsNum = msg.args.card_num
    -- local firstPlayer = msg.args.card_first
    self.cardsLeftNum =  UserData:getTotalCardNum()
    self:enableToOutAllCards(false)
    self.textInfo:setString(string.format(self.textInfoStr,self.cardsLeftNum,UserData:getCurCount(),UserData:getTotalCount()))
    for k, player in pairs(self.playerList) do
        player:draws(mycards[k])
        self.cardsLeftNum = self.cardsLeftNum - #mycards
    end
    self:updateLeftTile()
end

-- 处理服务端下发的摸牌事件
function MahjongGamePlayLayer:onRespGameDrawCard(msg)
    local chairId = msg.args.chair_id
    local card = msg.args.card
    print("onRespGameDrawCardchairId:",chairId)
    local player = self:getPlayer(chairId)
    local function overHandler()
        if self.firstDraw then
            self.firstDraw = false
            self.myPlayer:showSortAction()
            if self.operationTbl then
                performWithDelay(self, function()
                    self:onRespGameCheckOperation()
                    if player == self.myPlayer and not self.bn_pass:isVisible() then
                        self.should_touch = true
                        if UserData:isHongZhong() then --红中不能跳过胡
                            self.should_touch = false
                        end
                    end
                    GnetMgr:unlock()
                end, 0.3)
            else
                if player == self.myPlayer and not self.bn_pass:isVisible() then
                    self.should_touch = true
                end
                GnetMgr:unlock()
            end
        else
            if player == self.myPlayer and not self.bn_pass:isVisible() then
                self.should_touch = true
            end
            GnetMgr:unlock()
        end
        self:set_player(player:get_pos())
        -- self.timeLeft = 16
        self.timeLeft = 0
        -- if self.cur_selected then
        --     self:set_sel(self.cur_selected, true)
        -- end
    end
    self.cur_player = player
    player:draw(msg.args.card)
    if player ~= self.myPlayer then
        self.myPlayer:showTing()
    end
    self:delayOutCard()
    if self.firstDraw then
        self:set_banker(player.pos)
        mjaction:dealCardsAction(self.playerList,chairId,overHandler)
    else
        if self.curPlayedMj ~= nil then
            
            -- self.curPlayedMj:setPosition(self.curPlayedMjPos)
            local time1, time2 = 0.3, 0.1
            if UserData.isSkipAnimate then
                time1, time2 = consts.replayTime, consts.replayTime
            end
            self.curPlayedMj:runAction(
                    transition.sequence({
                        cc.DelayTime:create(time1),
                        cc.MoveTo:create(time2, self.curPlayedMjPos),
                        -- cc.CallFunc:create(function()
                        --         AudioMgr:on_mahjong_played()
                        --     end)
                        })
                )

            self.curPlayedMj = nil
            self.curPlayedMjPos = nil
        end
        overHandler()
    end
    self.cur_draw_player = player
    if self.firstDraw then
        for _, player in pairs(self.playerList) do
            player:fixPos(self.cur_draw_player:get_id())
        end
    end

    self.cardsLeftNum = self.cardsLeftNum - 1
    self.textInfo:setString(string.format(self.textInfoStr,self.cardsLeftNum,UserData:getCurCount(),UserData:getTotalCount()))

    self:updateLeftTile()
end

function MahjongGamePlayLayer:delayOutCard()
    --杠后自动出牌
    if self.isEnableOutCard and self.myPlayer.just_got then
        local newNode = display.newNode():addTo(self)
        newNode:runAction(transition.sequence({
                                        cc.DelayTime:create(1), 
                                        cc.CallFunc:create(function()
                                                if not self.bn_pass:isVisible() then
                                                    if self.myPlayer.just_got then
                                                        local tile_id = self.myPlayer.just_got:get_id()
                                                        AudioMgr:on_out()
                                                        performWithDelay(display.getRunningScene(), function()
                                                            AudioMgr:on_mahjong_tile(tile_id)
                                                        end, 0.2)
                                                        self.myPlayer:play(tile_id,self.myPlayer.hold_tiles.count + 1)
                                                        self._model:send("game_out_card",{card = tile_id})
                                                        NotifyMgr:push(consts.Notify.CLEAR_SAME_CARD_TAG)
                                                        newNode:removeFromParent()
                                                    end
                                                end
                                        end)})) 
    end
end

-- 处理服务端下发的出牌事件
function MahjongGamePlayLayer:onRespGameOutCard(msg)
    if msg.args.code then
        GnetMgr:unlock()
        if msg.args.code ~= 0 then
            GnetMgr:reConnect() --在错误的时候出了牌，重连
        end
        return 
    end
    local chairId = msg.args.chair_id
    local card = msg.args.card
    local addCard = msg.args.addition_card    
    local player = self:getPlayer(chairId)
    self.cur_card = card
    self.cur_player = player
    
    if addCard then
        --长沙麻将杠玩法  两张牌自动打出进入牌桌 
        local cards = {}
        table.insert(cards,card)
        table.insertto(cards, addCard)
        player:autoPlay(cards) 
        if player == self.myPlayer then
            self:enableToOutAllCards(true)
        end
    else
        if self.isReplay then --战局回放
            AudioMgr:on_out()
            performWithDelay(display.getRunningScene(), function()
                AudioMgr:on_mahjong_tile(tile_id)
            end, 0.2)
            player:play(card, player:getHandCardPosByID(card))
            player:update_mj()
        elseif player ~= self.myPlayer then
            AudioMgr:on_out()
            performWithDelay(display.getRunningScene(), function()
                AudioMgr:on_mahjong_tile(tile_id)
            end, 0.2)
            player:play(card,1)
        else
            GnetMgr:unlock()
        end
    end

end

function MahjongGamePlayLayer:enableToOutAllCards(enable)
    self.isEnableOutCard = enable
    self.myPlayer:setMahjongEnableState(enable)
end

function MahjongGamePlayLayer:updateBnsByOperation(operationTbl)
    -- if not operation then return end
    if not operationTbl then return end

    self.operationTbl = operationTbl
    if self.firstDraw or self.inFirstHuAction then return end
    local handle = function (i, operation)
        local bn
        local index = 1
        self["huCard"..i] = nil
        self["pengCard"..i] = nil
        self["gangCardList"..i] = nil
        self["chiCardList"..i] = nil
        self["buCardList"..i] = nil
        for k,v in pairs(operation) do
            if k == "canHu" and v then
                -- bn = self.bn_hu
                bn = self["bn_hu"..i]
                -- self.huCard = operation.hucard
                self["huCard"..i] = operation.hucard
            elseif k == "canPeng" and v then
                -- bn = self.bn_peng
                bn = self["bn_peng"..i]
                self["pengCard"..i] = v
            elseif k == "canGang" and v then
                -- bn = self.bn_gang
                bn = self["bn_gang"..i]
                self["gangCardList"..i] = v
            elseif k == "canChi" and v then
                -- bn = self.bn_chi
                bn = self["bn_chi"..i]
                self["chiCardList"..i] = v
            elseif k == "canBu" and v then
                -- bn = self.bn_bu
                bn = self["bn_bu"..i]
                self["buCardList"..i] = v
            elseif k == "canFirstHu" and v then
                -- bn = self.bn_hu
                bn = self["bn_hu"..i]
                -- self.huCard = nil
                self["huCard"..i] = nil
            elseif k == "canTing" then
                -- bn = self.bn_ting
                bn = self["bn_ting"..i]
            elseif k == "canHaidi" then
                self.dialogText="</div><div fontcolor=#994e2e>海底捞一把?</div>"
                local dialogContentLabel=helper.createRichLabel({maxWidth = 600,fontSize = 50})
                dialogContentLabel:setString(self.dialogText)
                -- UIMgr:showConfirmDialog("解散失败",{child=dialogContentLabel},function() 
                --     log.print("解散失败")
                -- end)        
                local params = {width=736, height=366,
                        childOffsetY = 30, childOffsetX = 0,
                        child=dialogContentLabel, yao=true,notDismissDialogForBtnClick=true}
                self.applyDismissDialog=UIMgr:showConfirmDialog("",params,function ()
                    self._model:send("game_haidi_card")
                    UIMgr:closeUI(consts.UI.ConfirmDialogUI)
                end, function ()
                    self._model:send("game_cancel_action")
                    UIMgr:closeUI(consts.UI.ConfirmDialogUI)
                end, nil)    
            end
            if bn then
                bn:setVisible(true)
                bn:setPosition(cc.p(1000 - index * 150, 220))
                index = index + 1
            end
            if k == "canHu" and UserData:isHongZhong() then
                index = index - 1
                bn:setPosition(cc.p(1150 - index * 150, 220))
                self.should_touch = false
            end
        end
        if index > 1 then
            self.bn_pass:setVisible(true)
            self.bn_pass:setPosition(cc.p(self.bn_passX, 220))
            self.should_touch = false
            self:sortOperationBns(i)
        end
    end
    for i,v in ipairs(self.operationTbl) do
        if v then
            handle(i, v)
        end
    end
    if 0 ~= table.nums(self.operationTbl) then
        --有操作不显示听牌按钮
        self.myPlayer:hideTing()
    end
end

-- 处理服务端下发的检查判断玩家该轮操作
function MahjongGamePlayLayer:onRespGameCheckOperation(msg)
    if msg then 
        local operationTbl = {}
        table.insert(operationTbl, (json.decode(msg.args.operation)))
        if msg.args.operation1 then
            table.insert(operationTbl, (json.decode(msg.args.operation1)))
        end
        self:updateBnsByOperation(operationTbl)
    else
        self:updateBnsByOperation(self.operationTbl)
    end
end

function MahjongGamePlayLayer:unselectTile()
    self.cur_sel = nil
    self.cur_sel_pos = 0
    self.moving = false
end

function MahjongGamePlayLayer:sortOperationBns(line) --line 第几行的
    local bns = {
        -- self.bn_ting,
        -- self.bn_chi,
        -- self.bn_peng,
        -- self.bn_bu,
        -- self.bn_gang,
        -- self.bn_hu
        self["bn_ting"..line],
        self["bn_chi"..line],
        self["bn_peng"..line],
        self["bn_bu"..line],
        self["bn_gang"..line],
        self["bn_hu"..line]
    }

    --吃的麻将
    local posy
    if line == 1 then
        posy = 260
    elseif line == 2 then
        posy = 390
    end
    local chiCardList = self["chiCardList"..line]
    if chiCardList and #chiCardList > 2 then
        local cardId = chiCardList[1]
        local chiLayout = ccui.Layout:create():addTo(self, 100):move(1060,posy)
        chiLayout:setBackGroundImage("mj/chi_bg.png")
        chiLayout:setAnchorPoint(cc.p(1,0))
        chiLayout:setBackGroundImageScale9Enabled(true)
        chiLayout:setContentSize(cc.size(175*(#chiCardList-1),95))
        chiLayout:setBackGroundImageCapInsets(cc.rect(10,10,78,75))
        chiLayout:setTouchEnabled(true)
        for i = 2 , #chiCardList do
            local mjList = chiCardList[i]
            for k,v in ipairs(mjList) do
                local mj = nil
                if v == cardId then
                    mj = MahjongTile.new({id = v , type = 25 , is_bird = true}):addTo(chiLayout)
                else
                    mj = MahjongTile.new({id = v , type = 29}):addTo(chiLayout)
                end
                mj:move(175*(i-2)+35+(k-1)*49,46)
            end
        end
        -- mj.bg:setColor(cc.c3b(255, 255, 0))
        chiLayout:onTouch(function (event)
                if event.name == "ended" then
                    print(event.x,"-------------",index)
                    local index = math.floor((event.x - (1060-175*(#chiCardList-1)))/175 + 1)
                    self:chi(index, line)
                end
            end)
        self["chiLayout"..line] = chiLayout
    end

    --需要画的麻将
    local titleList = {}
    --有多个gang牌可以选择时，只画gang牌；否则从peng gang hu牌中找要画的牌（只会找到一张牌）
    local buCardList = self["buCardList"..line]
    if buCardList and #buCardList > 1 then
        titleList = buCardList
    elseif self["gangCardList"..line] and #self["gangCardList"..line]  > 1 then
        titleList = self["gangCardList"..line]
    else
        -- if self.huCard then
        --     if type(self.huCard) == "number" then
        --         table.insert(titleList, self.huCard)
        --     elseif type(self.huCard) == "table" then
        --         table.merge(titleList, self.huCard)
        --     end 
        if self["huCard"..line] then
            if type(self["huCard"..line]) == "number" then
                table.insert(titleList, self["huCard"..line])
            elseif type(self["huCard"..line]) == "table" then
                table.merge(titleList, self["huCard"..line])
            end            
        elseif self["pengCard"..line] then
            table.insert(titleList, self["pengCard"..line])
        elseif self["gangCardList"..line] then
            table.merge(titleList, self["gangCardList"..line])
        elseif chiCardList then
            table.insert(titleList, chiCardList[1])
        end
    end
    local mjBgWidth = 0
    local firstWidth = self.bn_peng1:getContentSize().width 
    local passAndFirtBtnWidth = self.bn_pass:getContentSize().width + firstWidth
    --画完 过按钮 麻将之后，左边第一个按钮的X坐标
    local firstX = 0
    local mjTile
    local mjTileLayout
    local mjTileSpace = 20
    local btnSpace = 10
    local mjTileWidth = 50
    local mjTileCount = #titleList
    mjBgWidth = mjTileSpace * (mjTileCount + 1) + mjTileWidth * mjTileCount  
        + passAndFirtBtnWidth / 2
    firstX = self.bn_passX  - mjBgWidth
    if #titleList  > 0 then
        self.operationBg:setScaleX(mjBgWidth / self.operationBg:getContentSize().width)
        self.operationBg:setAnchorPoint(cc.p(1,0.5))
        self.operationBg:setPosition(cc.p(self.bn_passX, self["bn_passY"..line]))
        self.operationBg:setVisible(true)
        local tileUiList = {}
        self.selectedGangTile = nil
        for i = 1, mjTileCount do
            mjTile = MahjongTile.new({id =titleList[i], type = 29}):addTo(self, 100)
            -- mjTile:setVisible(false)
            -- mjTile.bg:setColor(cc.c3b(255, 255, 0))
            mjTileLayout = ccui.Layout:create():addTo(self, 100)
            mjTileLayout:setAnchorPoint(consts.Point.CenterAnchorPoint)
            mjTileLayout:setTouchEnabled(true)
            --mjTile:setMyScale(mjTileWidth / mjTile:getContentSize().width)
            mjTileLayout:setContentSize(mjTile:getContentSize())
            mjTile:setPosition(cc.p(firstX + firstWidth / 2  + mjTileWidth / 2  + i * mjTileSpace + (i - 1) * mjTileWidth, self["bn_passY"..line]))
            mjTileLayout:setPosition(mjTile:getPosition())
            tileUiList[i] = {}
            tileUiList[i][1] =  mjTile
            tileUiList[i][2] =  mjTileLayout
            -- 有多个gang牌可以选择
            if (buCardList and #buCardList > 1) or (self["gangCardList"..line] and #self["gangCardList"..line] > 1) then
                mjTileLayout:setTag(i)
                mjTileLayout:addClickEventListener(function(sender)
                    local index = sender:getTag()
                    local mjTile = tileUiList[index][1]
                    if self.selectedGangTile then
                        local y1 = self.selectedGangTile.mjTile:getPositionY()  - 10
                        self.selectedGangTile.mjTile:setPositionY(y1)
                        self.selectedGangTile.mjTileLayout:setPositionY(y1)
                    else
                        self.selectedGangTile = {}
                    end
                    local y2 = mjTile:getPositionY() + 10
                    mjTile:setPositionY(y2)
                    sender:setPositionY(y2)
                    self.selectedGangTile.mjTile = mjTile
                    self.selectedGangTile.mjTileLayout = sender
                    self.selectedGangTile.index = index
                end)
            end
        end
        self["tileUiList"..line] = tileUiList
    end
    local index = 1
    local beforeBtnX = nil
    local beforeBtn = nil
    for k, v in ipairs(bns) do 
        if v:isVisible() then
            if index == 1 then
                v:setPosition(cc.p(firstX, self["bn_passY"..line]))
            else
                v:setPosition(cc.p((beforeBtnX - (beforeBtn:getContentSize().width + v:getContentSize().width)/2), self["bn_passY"..line]))
            end
            beforeBtnX = v:getPositionX()
            beforeBtn = v
            index = index + 1
        end
    end
end

-- 处理服务端下发的碰牌事件
function MahjongGamePlayLayer:onRespGamePengCard(msg)
    if msg.args.code then
        return 
    end
    self.cur_flag:setVisible(false)
    local chairId = msg.args.chair_id
    local card = msg.args.card
    local player = self:getPlayer(chairId)
    AudioMgr:on_peng(player:get_sex())
    self.curPlayedMj = nil
    self.cur_player:removeOnePlayed(card)
    self.cur_player = player
    player:peng(card, msg.args.out_chair)
    if player == self.myPlayer then
        self.should_touch = true;
    end
    self.cur_player:showTing()
    mjaction:pengAction(player.pos,self)
    self.timeLeft = 0

    -- self:test()
end

-- 处理服务端下发的杠牌事件
function MahjongGamePlayLayer:onRespGameGangCard(msg)
    if msg.args.code then
        return 
    end
    
    local chairId = msg.args.chair_id
    local card = msg.args.card
    local gangType = msg.args.gang_type
    local player = self:getPlayer(chairId)
    AudioMgr:on_gang(player:get_sex())
    if gangType == 3 then
        self.cur_flag:setVisible(false)
        self.curPlayedMj = nil
        self.cur_player:removeOnePlayed(card)
    end
    self.cur_player = player
    player:gang(card, msg.args.out_chair,gangType == 2,gangType)
    if player == self.myPlayer then
        -- self.should_touch = true;
        --杠牌不能出牌，摸了才能出
        self.should_touch = false;
    end
    mjaction:gangAction(gangType,player.pos,self)
    self.timeLeft = 0
end

-- 处理服务端下发的补牌事件
function MahjongGamePlayLayer:onRespGameBuCard(msg)
    if msg.args.code then
        return 
    end
    
    local chairId = msg.args.chair_id
    local card = msg.args.card
    local buType = msg.args.bu_type
    local player = self:getPlayer(chairId)
    AudioMgr:on_Bu(player:get_sex())
    if buType == 3 then
        self.cur_flag:setVisible(false)
        self.curPlayedMj = nil
        self.cur_player:removeOnePlayed(card)
    end
    self.cur_player = player
    player:gang(card, msg.args.out_chair,buType == 2,buType)
    if player == self.myPlayer then
        self.should_touch = true;
    end
    mjaction:buAction(player.pos,self)
    self.timeLeft = 0
end

-- 清除当前操作的牌
function MahjongGamePlayLayer:clearOperationTile()
    if self.tileUiList1 then
        for i = 1, #self.tileUiList1 do
            for j = 1, #self.tileUiList1[i] do
                self.tileUiList1[i][j]:removeSelf()
            end
        end
        self.tileUiList1 = nil
    end

    if self.tileUiList2 then
        for i = 1, #self.tileUiList2 do
            for j = 1, #self.tileUiList2[i] do
                self.tileUiList2[i][j]:removeSelf()
            end
        end
        self.tileUiList2 = nil
    end

    if self.chiLayout1 then
        self.chiLayout1:removeSelf()
        self.chiLayout1 = nil
    end
    if self.chiLayout2 then
        self.chiLayout2:removeSelf()
        self.chiLayout2 = nil
    end
    self.operationTbl = nil
    self.pengCard1 = nil
    self.pengCard2 = nil
    self.gangCardList1 = nil
    self.gangCardList2 = nil
    self.chiCardList1 = nil
    self.chiCardList2 = nil
    self.huCard1 = nil
    self.huCard2 = nil
    self.selectedGangTile = nil

end

-- 处理服务端下发的吃牌事件
function MahjongGamePlayLayer:onRespGameChiCard(msg)
    if msg.args.code then
        return 
    end

    self.cur_flag:setVisible(false)
    local chairId = msg.args.chair_id
    local card = msg.args.card
    local cards = msg.args.card_table
    local player = self:getPlayer(chairId)
    AudioMgr:on_chi(player:get_sex())
    self.curPlayedMj = nil
    self.cur_player:removeOnePlayed(card)
    self.cur_player = player
    player:chi(cards,card)
    if player == self.myPlayer then
        self.should_touch = true
    end
    self.cur_player:showTing()
    mjaction:chiAction(player.pos,self)
    self.timeLeft = 0
end

-- 处理服务端下发的起手胡事件
function MahjongGamePlayLayer:onRespGameFirstHuCard(data)
    
    dump(huData,"firstHuData")
    self.inFirstHuAction = true
    local huData = json.decode(data.hu_info)

    --判断性别
    -- local chair_id = 1
    -- for k,v in pairs(huData) do
    --     chair_id = tonumber(k)
    -- end
    -- local  player = self:getPlayer(chair_id)
    -- if(player)then AudioMgr:on_hu(player:get_sex())end
    local function callback()   
        self.inFirstHuAction = false
        self:onRespGameCheckOperation()
        if self.recvOnRespChangShaStartOut then
            self.should_touch = true
        end
    end
    mjaction:firstHuAction(self.myPlayer,self.playerList,huData,callback)
end

-- 处理服务端下发的本局胡事件
function MahjongGamePlayLayer:onRespGameHuCard(msg)
    if helper.isCallbackSuccess(msg) then return end
    local chairId = msg.args.chair_id
    local cards = msg.args.card_table
    self.curhuType = msg.args.hu_type
    self.curhuPlayer = self:getPlayer(chairId)
    table.insert(self.huPlayerList, {player = self.curhuPlayer, huType = self.curhuType})
    local player = self.curhuPlayer
    AudioMgr:on_hu(player:get_sex(),msg.args.hu_type)
    if player ~= self.myPlayer then
        player:hu(cards)
    end
end

-- 处理服务端下发的游戏结束事件
function MahjongGamePlayLayer:onRespGameEnd(msg)
    -- mjaction:curGameEndAction(self,self.curhuType,self.curhuPlayer)
    if #self.huPlayerList > 0 then
        for _, tbl in pairs(self.huPlayerList) do
            mjaction:curGameEndAction(self, tbl.huType, tbl.player)
        end
    else
        --流局延时
        performWithDelay(self, function()
                    mjaction:curGameEndAction(self, nil, nil)
                end, 1.5)
    end
    self.myPlayer.m_tingLs = nil
    self.game_end = true
    AudioMgr:playMusic()
    if(self.m_tingTip:isVisible())then self.m_tingTip:setVisible(false)end
end

-- 处理服务端下发的设置方位事件
function MahjongGamePlayLayer:onRespSetPos(msg)
    local pos = self:getPlayer(msg.args.chair_id):get_pos()
    self:set_player(pos)
    if msg.args.chair_id ~= UserData.myChairId then
        self:hide_bn()
        self.should_touch = false
    end

    --起手胡事件完成  
    if self.isFirstHuEvent then
        self.isFirstHuEvent = false
    end
end

-- 重新初始化麻将牌 准备开始新的一局
function MahjongGamePlayLayer:resetGameTable()
    for k,player in pairs(self.playerList) do
        player:removeAllMj()
    end
    self:hide_bn()
    self.should_touch = false
    self.cur_sel = nil
    self.cur_selected = nil
    self.moving = false
    self.cur_sel_pos = 0
    self.curPlayedMj = nil
    self.cur_flag:setVisible(false)
    self.firstDraw = true
    self.inFirstHuAction = false
    self.isFirstHuEvent = true
    self.curhuType = nil
    self.curhuPlayer = nil
    self.huPlayerList = {}
end


function MahjongGamePlayLayer:showUpdate()
    self.labelroom:setString("房号 " .. UserData.roomId)
    self:updatePlayerInfo()
    if UserData.game_status == UserData.GAME_STATUS.nextWaiting then
        self:resetGameTable()
    end

    if UserData.game_status == UserData.GAME_STATUS.start then
        self:setDir()
    end

     --钻石消耗    
     local height = 685
    if not self.jewelTips and UserData.table_config.rule and UserData.table_config.rule.jewel then           
        self.jewelTips = cc.LabelTTF:create("大赢家扣", font, 24)
                                    :setAnchorPoint(cc.p(0, 0.5))        
                                    -- :setPosition(cc.p(160,745))
                                    :setPosition(cc.p(13, height))
                                    :setColor(helper.str2Color("#3f8a6e"))
                                    :addTo(self, 10)

       display.newSprite("uires/common/jewel_icon.png", 120,height):setScale(0.5):addTo(self, 10)
       local jewelNum = cc.LabelTTF:create(tostring(UserData.table_config.rule.jewel), font, 24)
                                       :setAnchorPoint(cc.p(0, 0.5))        
                                       -- :setPosition(cc.p(270,745))
                                       :setPosition(cc.p(140,height))
                                       :setColor(helper.str2Color("#3f8a6e"))
                                       :addTo(self, 10)   
        if 1 == UserData.table_config.rule.roomData[1][2] then
            jewelNum:setString(UserData.table_config.rule.jewel * 2)
        end                                                                 
    end
end

function MahjongGamePlayLayer:setDir()
    local player_count = UserData.table_config.player_count

    local realPos = helper.getRealPos(UserData.myChairId, 1, player_count)

    if 1 == realPos then --东
        self.direction:setRotation(90)
        self.dir = {}
        table.insert(self.dir, self.direction:getChildByTag(222))
        table.insert(self.dir, self.direction:getChildByTag(223))
        table.insert(self.dir, self.direction:getChildByTag(224))
        table.insert(self.dir, self.direction:getChildByTag(221))
    elseif 2 == realPos then --南
        self.direction:setRotation(180)
        -- local tmp = clone(self.dir)
        self.dir = {}
        table.insert(self.dir, self.direction:getChildByTag(223))
        table.insert(self.dir, self.direction:getChildByTag(224))
        table.insert(self.dir, self.direction:getChildByTag(221))
        table.insert(self.dir, self.direction:getChildByTag(222))
    elseif 3 == realPos then --西
        self.direction:setRotation(270)
        -- local tmp = clone(self.dir)
        self.dir = {}
        table.insert(self.dir, self.direction:getChildByTag(224))
        table.insert(self.dir, self.direction:getChildByTag(221))
        table.insert(self.dir, self.direction:getChildByTag(222))
        table.insert(self.dir, self.direction:getChildByTag(223))
    elseif 4 == realPos then --北
        -- local tmp = clone(self.dir)
        self.dir = {}
        table.insert(self.dir, self.direction:getChildByTag(221))
        table.insert(self.dir, self.direction:getChildByTag(222))
        table.insert(self.dir, self.direction:getChildByTag(223))
        table.insert(self.dir, self.direction:getChildByTag(224))
    end
end

--设置赖子皮和癞子牌
function MahjongGamePlayLayer:setLaiZiPiAndLaiZi(laizipi, laizi)
    UserData.laizipiCardId = laizipi
    UserData.laiziCardId = laizi

    --因为癞子牌和癞子牌是所有玩家摸完牌才决定的，所以要update一下
    for _, v in pairs(self.playerList) do
        v:updateHandCardForLZ()
    end
end

function MahjongGamePlayLayer:showCardUpdate()
    self:clearOperationTile()
    local data          = UserData.reConnectCardData
    if 1 == data.code then
        return
    end
    local cards         = data.playerCard
    local lastOutCard   = data.lastOutCard
    local lastOutChair  = data.lastOutChair
    local curOutCHair   = data.curOutCHair
    local bankerChair   = data.banker
    local gangLock      = data.gangLock
    local laizi         = data.laizi
    local laizipi       = data.laizipi
    local lastPlayer    = self:getPlayer(lastOutChair)
    local curPlayer     = self:getPlayer(curOutCHair)
    local banker        = self:getPlayer(bankerChair)
    local hasJustGot    = false
    self.firstDraw = false
    self.cur_player = curPlayer
    self.cardsLeftNum = data.leftNum
    self.isFirstHuEvent = data.state
    self.label_time:setString(0)
    -- UserData:setCurCount(data.gameIndex)
    self.textInfo:setString(string.format(self.textInfoStr,self.cardsLeftNum,UserData:getCurCount(),UserData:getTotalCount()))

    self:setLaiZiPiAndLaiZi(laizipi, laizi)
    if laizi and 0 ~= laizi then
        self:showLaiziCard(laizi)
    end

    if banker then
        self:set_banker(banker.pos)
    end
    for k,v in ipairs(cards) do
        local player = self:getPlayer(k)
        hasJustGot = player:showCards(v) or hasJustGot
        if player.pos == 1 then
            self.myPlayer = player
        end
    end

    -- self:test()

    if gangLock then
        self:enableToOutAllCards(true)
        self:delayOutCard()
    end

    -- if lastPlayer and not hasJustGot then
    if lastPlayer then
        if lastPlayer.played_tiles[lastPlayer.played_tiles_count] then
            -- self:set_cur_tile(lastPlayer.played_tiles[lastPlayer.played_tiles_count],lastPlayer.pos)
            self:set_cur_tile(lastPlayer.played_tiles[lastPlayer.played_tiles_count], cc.p(lastPlayer.played_tiles[lastPlayer.played_tiles_count]:getPosition()))
        end
    end
    -- else
    --     -- self.cur_flag:setVisible(false)
    -- end
    print(curOutCHair,curPlayer)
    if curPlayer then
        local cardCount = curPlayer.hold_tiles.count
        if curPlayer.just_got then
            cardCount = cardCount + 1
        end
        if curPlayer.pos == 1 and cardCount%3 == 2 then
            self.should_touch = true
        end
        self:set_player(curPlayer.pos)
    end
    local operationTbl = {}
    table.insert(operationTbl, (json.decode(data.canOperation)))
    if data.canOperation1 then
        -- table.insert(operationTbl, (json.decode(data.canOperation1)))
        table.insert(operationTbl, 1, (json.decode(data.canOperation1)))
    end
    self:updateBnsByOperation(operationTbl)
    self.myPlayer:showTing()
    --test
    -- performWithDelay(self, function()
    --     UIMgr:openUI(consts.UI.haidiui, nil, nil, {wang = laizi})
    -- end, 0.5)
    self:updateLeftTile()
    self.cur_sel = nil
end

function MahjongGamePlayLayer:setOffLine(data)
    local chairId = data.chair_id
    local isOnline = data.connect
    if self.playerList[chairId] then
        self.playerList[chairId]:setOffLine(isOnline)
    end
end

-- 聊天消息
function MahjongGamePlayLayer:onRespChat(msg)
    print("收到聊天消息")
    dump(msg)
    if nil == msg.args then return end
    --msg解析
    local tab=assert(loadstring(msg.args.id))()
    print("聊天消息解析",tab.type,tab.len,tab.id)
    tab.len = string.format("%.2f",tab.len) + 0.01
    
    local chatTyoe = tonumber(tab.type)
    tab.uid = msg.args.uid

    if(chatTyoe == 1)then--表情
        self:showChat(tab)
    elseif(chatTyoe == 2)then--语句
        self:showChat(tab)
    elseif(chatTyoe == 3)then--语音
        table.insert(self.m_voiceList,1,tab)
        if(not self.m_voice_showing)then
            self:showNextVoice()
        end
    end
end

function MahjongGamePlayLayer:gCloudvoiceComplete()
    for i = 1,  #self.playerList do
        self.playerList[i]:dimissVoice()
    end
end

--播放下一个语音
function MahjongGamePlayLayer:showNextVoice()
    if(#self.m_voiceList > 0)then
        self.m_voice_showing = true
        local tab = self.m_voiceList[#self.m_voiceList]
        -- LuaCallPlatformFun.playVoiceById(tab.id)
        self:showChat(tab)
        table.remove(self.m_voiceList)
        performWithDelay(self.m_voicePlayNode, handler(self,self.showNextVoice),tab.len)
    else
        self.m_voice_showing = false
    end
end

function MahjongGamePlayLayer:showChat( tab )
    for i = 1,  #self.playerList do
        if self.playerList[i].id == tab.uid then
            self.playerList[i]:chat(tab)
            return
        end
    end
end

--update玩家头上飘的分数
function MahjongGamePlayLayer:onRespUpdatePiaoPoint(data)
    for k, v in pairs(data.info) do
        local player = self:getPlayer(tonumber(k))
        player:updatePiaoPoint(v)
    end
end

--翻癞子
function MahjongGamePlayLayer:onRespGameFlipLaizi(data)
    self:setLaiZiPiAndLaiZi(data.laizipi, data.laizi)

    -- local card = data.laizipi
    -- local player
    -- for _, v in pairs(self.playerList) do
    --     if self.banker_pos == v.pos then
    --         player = v
    --         break
    --     end
    -- end
    -- self.cur_card = card
    -- self.cur_player = player
    -- player:flipChaoTianCard(card, self.banker_pos)

    -- self:showLaiziCard(data.laizi)
    performWithDelay(self, function()
        UIMgr:openUI(consts.UI.haidiui, nil, nil, {wang = data.laizi})
    end, 0.5)
end

function MahjongGamePlayLayer:showLaiziCard2(data)
    self:showLaiziCard(data.data.laizi, data.data.ani)
end

--显示左上方的癞子
function MahjongGamePlayLayer:showLaiziCard(laizi, ani)
    if not laizi or 0 == laizi then
        return
    end
    if self.img_show_wang then self.img_show_wang:removeSelf() end
    if self.laizi_mj then self.laizi_mj:removeSelf() end

    self.img_show_wang = ccui.ImageView:create("mj/black_bg.png"):addTo(self, 1):setPosition(cc.p(55, 630)):setContentSize(cc.size(90,64)):ignoreContentAdaptWithSize(false):setScale9Enabled(true)
    self.txt_show_wang = cc.LabelTTF:create("王\n牌","Arial", 22):setPosition(cc.p(30, 630)):setColor(helper.str2Color("#ebefeb")):addTo(self, 1)
    self.laizi_mj = MahjongTile.new({id = laizi, type = 9, is_free = false}):addTo(self, 1)
    self.laizi_mj:setAnchorPoint(cc.p(0, 0))
    self.laizi_mj:setPosition(cc.p(70, 630))
    self.laizi_mj:setScale(0.8)
    if ani then
        self.laizi_mj:setPosition(cc.p(-70, 630))
        self.img_show_wang:setPosition(cc.p(-55, 630))
        self.txt_show_wang:setPosition(cc.p(-30, 630))
        self.laizi_mj:runAction(cc.MoveBy:create(0.5, cc.p(70 * 2, 0)))
        self.img_show_wang:runAction(cc.MoveBy:create(0.5, cc.p(55 * 2, 0)))
        self.txt_show_wang:runAction(cc.MoveBy:create(0.5, cc.p(30 * 2, 0)))
    end
end

--听牌，锁定手牌
function MahjongGamePlayLayer:onRespTing(data)
    if not data.chair_id then return end
    for _, chairId in pairs(data.chair_id) do
        local player = self:getPlayer(chairId)
        mjaction:baotingAction(player.pos, self)
        if player == self.myPlayer then
            self:enableToOutAllCards(true)
            self:delayOutCard()
        end
    end
end

function MahjongGamePlayLayer:onRespOpenHaidi(data)
    UIMgr:openUI(consts.UI.haidiui, nil, nil, {haidi = data.card})
end

--显示听的牌
function MahjongGamePlayLayer:updateTingTip( index ,touchPos)
    -- if(not consts.TingPaiGameType[UserData.curMahjongType] or UserData:isLaizi())then return end
    if(not consts.TingPaiGameType[UserData.curMahjongType])then return end

    if(self.m_tingTip:isVisible())then
        self.m_tingTip:setVisible(false)
        return
    end

    local idLs = self.myPlayer:getTingLsByPos(index)
    if(not idLs or #idLs < 1)then return end

    self.m_tingTip:setVisible(true)
    -- local num = #idLs < 13 and #idLs or 12
    local num = #idLs < 34 and #idLs or 1
    if num > 12 then
        self.m_tingTip:setScale(0.8)
    else
        self.m_tingTip:setScale(1)
    end
    local contentX = 86*(num+1)+24
    local tip_bg = helper.findNodeByName(self.m_tingTip, "tip_bg")
    tip_bg:setContentSize(cc.size(contentX,136))

    local more_des = helper.findNodeByName(self.m_tingTip,"more_des")
    -- more_des:setVisible(#idLs > 12)
    more_des:setVisible(false)
    local tile_node = helper.findNodeByName(self.m_tingTip,"tile_node")
    tile_node:removeAllChildren()
    
    for i=1,num do
        local mj = MahjongTile.new({id = idLs[i], type = 9, is_free = false}):addTo(tile_node, 1)
        mj:setPosition(cc.p((i-1)*86,0))

        local numBg = display.newSprite("mj/num_bg.png"):addTo(mj,1)
        numBg:setPosition(cc.p(30,-30))
        local leftNum = self:getLeftMjNum(idLs[i])
        -- local leftNum = self.m_tileLeftLs[idLs[i]]
        -- leftNum = not leftNum and 4 or leftNum
        if 0 == leftNum and not (#idLs >= 34) then
            mj.bg:setColor(cc.c3b(180, 180, 180))
        end
        local numLab = cc.LabelTTF:create("X"..leftNum, "Arial", 22)
        numBg:addChild(numLab)
        numLab:setPosition(cc.p(20,20))

        if #idLs >= 34 then --听任意牌
            mj.cg:removeSelf()
            mj.cg = display.newSprite("mj/renyi.png"):addTo(mj, 1)
            mj.cg:setScale(0.8)
            numBg:setVisible(false)
        end
    end

    local maxX = consts.Size.width - 110
    local minX = 100
    if(index == 0)then
        self.m_tingTip:setPosition(cc.p(maxX,180))
    else
        --矫正位置
        local posX = touchPos + contentX/2
        posX = posX - contentX < minX and 200 + contentX or posX--最左
        posX = posX <= maxX and posX or maxX --最右
        self.m_tingTip:setPosition(cc.p(posX,180))
    end
end

function MahjongGamePlayLayer:getLeftMjNum(id)
    local leftNum = self.m_tileLeftLs[id]
    leftNum = not leftNum and 4 or leftNum
    return leftNum
end

--更新剩余牌数
function MahjongGamePlayLayer:updateLeftTile()
    -- if(not consts.TingPaiGameType[UserData.curMahjongType] or UserData:isLaizi())then return end
    if(not consts.TingPaiGameType[UserData.curMahjongType])then return end

    local tileLeftLs = {}

    for i=1,#self.playerList do
        local mjLs = {}
        --自己的手牌
        if(self.playerList[i].pos == 1)then
            local hold_tiles = self.playerList[i].hold_tiles
            for j=1,#hold_tiles do
                table.insert(mjLs,hold_tiles[j])
            end
            table.insert(mjLs,self.playerList[i].just_got)
        end

        --出过的牌
        local played_tiles = self.playerList[i].played_tiles
        for j=1,#played_tiles do
            table.insert(mjLs,played_tiles[j])
        end

        --碰杠吃
        local used_tiles = self.playerList[i].used_tiles
        for j=1,#used_tiles do
            for k=1,4 do
                table.insert(mjLs,used_tiles[j]["tile"..k])
            end
        end

        for j=1,#mjLs do
            if(mjLs[j])then
                local tileId = mjLs[j].id
                if(not tileLeftLs[tileId])then tileLeftLs[tileId] = 4 end
                tileLeftLs[tileId] = tileLeftLs[tileId] - 1
            end
        end
    end
    self.m_tileLeftLs = tileLeftLs
end

--战局回放中需要更新的
function MahjongGamePlayLayer:updateInReplay()
    self.textInfo:setString(string.format(self.textInfoStr,self.cardsLeftNum,UserData:getCurCount(),UserData:getTotalCount()))
end

function MahjongGamePlayLayer:onBackgroud()
    self.should_touch = false
end

return MahjongGamePlayLayer






