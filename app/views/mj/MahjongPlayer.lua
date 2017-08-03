
local MahjongPlayer = class("MahjongPlayer", function()
    return cc.Layer:create()
end)
local MahjongTile = import(".MahjongTile")
local TingpaiHelper = require("utils.extends.TingpaiHelper")
local TingpaiHelperV2 = require("utils.extends.TingpaiHelperV2")
local selfPosition = {
    waiting = {cc.p(consts.Size.width/2, 110),cc.p(consts.Size.width-100, consts.Size.height/2),cc.p(consts.Size.width/2, consts.Size.height-80),cc.p(100, consts.Size.height/2)},
    playing = {cc.p(70, 240),cc.p(1295, 525),cc.p(1105, 702),cc.p(70, 525)}
}
local selfReadyPosition = {
    waiting = {cc.p(40,120),cc.p(-40,46),cc.p(cc.p(40,-90)),cc.p(120,46)},
    playing = {cc.p(0, 0),cc.p(0,0),cc.p(0, 0),cc.p(0,0)}
}
local pengPosition = {{{41,266,79},{59,0,0}},
                        {{1180,0,0},{180,95,28}},
                        {{1005,-150,-46},{715,0,0}},
                        {{206,0,0},{680,-95,-28}}} --num1 + count * num2
local gangPosition = {26,38,16,-17}
local cardPosition = {{{49,266,97},{71,0,0}},
                        {{1190,0,0},{180,95,28}},
                        {{1005,-150,-46},{715,0,0}},
                        {{195,0,0},{680,-95,-28}}} --num1 + count * num2 + (i - 1) * num3
local justGotPosition = {{{104,1},{71,0}},{{1190,0},{45,1}},{{-56,1},{715,0}},{{195,0},{-45,1}}} --num1 + num2 * mj_old:getPositionX()
local playOutPosition = {{683,240},{1080,384},{683,528},{290,384}}
local playedPosition = {{585,47,355,-56},{865,65,303,41},{820,-47,460,56},{540,-65,505,-41}}  --num1 + sid * num2,num3 + lid * num4

local curPlayedPosList = {
        cc.p(10,-10),
        cc.p(10,10),
        cc.p(-10,10),
        cc.p(-10,-10)
    }

--name, id
function MahjongPlayer:ctor(params)
    self:enableNodeEvents()
    self.pos = params.pos
    self.status=params.status or "playing"
    self.isDealCard = false
    self.hold_tiles = List:new()
    self.played_tiles = {}
    self.noShow_readyfor_game = params.noShow_readyfor_game
    self.used_tiles = {}
    self.played_tiles_count = 0
    self.used_tiles_count = 0
    self.isSitDown = false
    self.layout = ccui.Layout:create():setContentSize(cc.size(88,122))
    self.layout:addTo(self, 0)
    self.layout:setTouchEnabled(true)
    self.layout:setAnchorPoint(cc.p(0.5,0.5))
    -- self.bg = display.newSprite("mj/"..UserData:getCurBgType().."/battle_head_back.png", 0, 0):addTo(self, 0)
    self.bg = display.newSprite("mj/"..UserData:getCurBgType().."/head_kuang.png", 0, 0):addTo(self, 0):setPosition(cc.p(1, 18))
    -- self.block = display.newSprite("mj/"..UserData:getCurBgType().."/battle_head_block.png", 0, 4):setVisible(false):addTo(self, 0)
    -- self.block:runAction(cc.Repeat:create(cc.Sequence:create(cc.FadeIn:create(0.8),cc.FadeOut:create(0.8)),cc.REPEAT_FOREVER))         
    self.banker = display.newSprite("mj/icon_self_zhuang.png", -32, 35):addTo(self, 1)
    -- self.banker:setRotation(-45)
    self.banker:setVisible(false)
    self.ic_readyfor_game= display.newSprite("mj/ic_readyfor_game.png", 0, 0):addTo(self.bg, 0)
    self.ic_readyfor_game:setVisible(false)
    self:setPlayerPosition()
    self.layout:addClickEventListener(handler(self,self.callback))
    NotifyMgr:reg(consts.Notify.CHANGE_BG_TYPE, self.onChangeBgType, self)

    --策划说碰牌位置要调整（战局回放）
    if UserData.isInReplayScene then
        pengPosition[2] = {{1190,0,0},{180,95,28}}
        pengPosition[4] = {{196,0,0},{680,-95,-28}}
    end
end

function MahjongPlayer:callback(sender)
    if self.isSitDown then
        UIMgr:showPlayerInfoDialog(UserData:getPlayerInfoById(self.id))
    end
end

-- 设置玩家位置
function MahjongPlayer:setPlayerPosition()
    self:setPosition(selfPosition[self.status][self.pos])
    self.ic_readyfor_game:setPosition(selfReadyPosition[self.status][self.pos])
end

-- 玩家坐下参加游戏
-- params{parent = self, id = pinfo.uid, chairId = pinfo.chair_id, 
-- name = pinfo.nickname, score = 1000, url = pinfo.image_url}
function MahjongPlayer:sitDown(params)
    self.isSitDown = true
    self.chairId = params.chairId
    self.parent = params.parent
    self.id = params.id
    self.score = params.score
    self.name = params.name
    self.url = params.url
    self.sex = params.sex or 1
    self.realPos = params.realPos
    if self.lbname then self.lbname:removeSelf() end
    if self.lbscore then self.lbscore:removeSelf() end
    if self.head then self.head:removeSelf() end
    if self.offLine then self.offLine:removeSelf() end
    self.lbname = nil
    self.lbscore = nil
    self.head = nil
    self.offLine = nil
    if(Is_App_Store)then
        self.head = display.newSprite("uires/main/guest_icon_1.png", 1, 19):addTo(self, -1)
    elseif params.url then
        self.head  = NetSprite:getSpriteUrl(params.url,"mj/bg_default_avatar_1.png")
        self.head:setPosition(cc.p(1,19))
        self.head:setImageContentSize(cc.size(76,76))
        self.head:addTo(self, -1)
    else
      self.head = display.newSprite("mj/bg_default_avatar_1.png", 1, 19):addTo(self, -1)
    end
    self.lbname = cc.LabelTTF:create(self.name, "Arial", 20):addTo(self.bg, 2)
    self.lbname:setPosition(cc.p(45, -10))
    self.lbscore= cc.LabelTTF:create(self.score, "Arial", 20):addTo(self.bg, 2)
    -- self.lbscore:setPosition(cc.p(45, 25))
    self.lbscore:setPosition(cc.p(40, -38))
    -- self.lbscore:setColor(cc.c3b(38, 231, 233))
    self.lbscore:setColor(cc.c3b(255, 255, 0))
    self.lbscore:setVisible(not UserData.isInReplayScene)
    self.jifenFrame = ccui.ImageView:create("mj/jifen_kuang.png"):setPosition(cc.p(0, -66))
    self.jifenFrame:addTo(self)

    if self.status == "waiting" then
        self.ic_readyfor_game:setVisible(true)
    end
    self.offLine = display.newSprite("mj/offline.png", 95, 93):addTo(self.bg, 1)
    self.offLine:setPosition(cc.p(95/2.0, 93/2.0))
    self.offLine:setVisible(false)

    if self.piaoPoint then self.piaoPoint:removeSelf() end
    self.piaoPoint = cc.LabelTTF:create("飘3分", "Arial", 20):addTo(self.bg, 2)
    self.piaoPoint:setPosition(cc.p(45, 135))
    self.piaoPoint:setVisible(false)
end

function MahjongPlayer:standUp()
    self.isSitDown = false
    self.chairId = nil
    self.parent = nil
    self.id = nil
    self.score = nil
    self.name = nil
    self.url = nil
    if self.lbname then self.lbname:removeSelf() end
    if self.lbscore then self.lbscore:removeSelf() end
    if self.head then self.head:removeSelf() end
    if self.offLine then self.offLine:removeSelf() end
    self.lbname = nil
    self.lbscore = nil
    self.head = nil
    self.offLine = nil
    self.ic_readyfor_game:setVisible(false)
end

function MahjongPlayer:setJifenFrameUnVisible()
    self.jifenFrame:setVisible(false)
end

function MahjongPlayer:get_id()
    return self.id
end

function MahjongPlayer:get_chairId()
    return self.chairId
end

function MahjongPlayer:get_pos()
    return self.pos
end

function MahjongPlayer:get_sex(  )
    return self.sex
end

function MahjongPlayer:set_is_banker(is_banker)
    if is_banker then
        self.banker:setVisible(true)
    else
        self.banker:setVisible(false)
    end
end

----排序
function MahjongPlayer:sort()
    -- print("MahjongPlayer:sort():",self.hold_tiles.count)
    local result = false
    for i = 1, self.hold_tiles.count - 1 do
        for j = i + 1, self.hold_tiles.count do
            -- print(j,"self.hold_tiles.count")
            local mj1 = self.hold_tiles[i]
            local mj2 = self.hold_tiles[j]
            if mj1:get_sort_id() > mj2:get_sort_id() then
                self.hold_tiles[i] = mj2
                self.hold_tiles[j] = mj1
                result = true
            end
        end
    end
    return result
end

function MahjongPlayer:update_mj(isHU)
    local count = self.used_tiles_count
    local isNew = false
    if (self.pos == 1 or isHU) and self.isDealCard then
        isNew = self:sort(self.hold_tiles)
    end
    for i = 1, self.hold_tiles.count do
        local mj = self.hold_tiles[i]
        local x = cardPosition[self.pos][1][1] + count * cardPosition[self.pos][1][2] + (i - 1) * cardPosition[self.pos][1][3]
        local y = cardPosition[self.pos][2][1] + count * cardPosition[self.pos][2][2] + (i - 1) * cardPosition[self.pos][2][3]
        -- mj.is_sel = nil
        if self.pos == 2 then
            if isHU then
                x = x - cardPosition[self.pos][1][1] + pengPosition[self.pos][1][1]
                -- y = y + (i - 1) * 12 
            end
            self.parent:reorderChild(mj, self.hold_tiles.count + 1 - i)
        elseif self.pos == 4 then
            if isHU then
                x = x - cardPosition[self.pos][1][1] + pengPosition[self.pos][1][1]
                -- y = y + (i - 1) * 12 
            end
            self.parent:reorderChild(mj, i+1)
        end
        if mj.is_sel then
            y = y + 30
        end
        mj:setPosition(cc.p(x, y))
    end
    --update just gotten one
    if self.just_got then
        local mj_old = self.hold_tiles[self.hold_tiles.count]
        local mj = self.just_got
        if self.pos == 2 then
            self.parent:reorderChild(mj, 0)
        elseif self.pos == 4 then
            self.parent:reorderChild(mj, 14)
        end
        if mj_old then
            local x = justGotPosition[self.pos][1][1] + justGotPosition[self.pos][1][2] * mj_old:getPositionX()
            local y = justGotPosition[self.pos][2][1] + justGotPosition[self.pos][2][2] * mj_old:getPositionY()
            mj:setPosition(cc.p(x, y))
        end
    end
    
    --更新听牌队列
    -- if(isNew)then
    --     self:showTing()    
    -- else
    --     self:updateTingIcon()
    -- end
    self:showTing()

    if 1 == self.pos then
        for i = 1, self.hold_tiles.count do
            local mj = self.hold_tiles[i]
            self.parent:reorderChild(mj, 1500)
        end
    end
end

--修复 开局时庄家牌位置显示错误，其他玩家看到庄家的牌没有单独分一张出来
function MahjongPlayer:fixPos(cur_draw_player_id)
    if cur_draw_player_id == self:get_id() then
        local mj_old = self.hold_tiles[self.hold_tiles.count-1]
        local mj = self.hold_tiles[self.hold_tiles.count]
        local x = justGotPosition[self.pos][1][1] + justGotPosition[self.pos][1][2] * mj_old:getPositionX()
        local y = justGotPosition[self.pos][2][1] + justGotPosition[self.pos][2][2] * mj_old:getPositionY()
        mj:setPosition(cc.p(x, y))
    end
end

function MahjongPlayer:draws(tiles)
    self.dealCount = 0
    self.dealNum = 0
    local count = #tiles
    for i = 1, count do
        local mj
        if UserData.isInReplayScene and self.pos ~= 1 then
            mj = MahjongTile.new({id = tiles[i], type = self.pos + 4, is_free = false}):move(-100,-100):addTo(self.parent, 1)
        else
            mj = MahjongTile.new({id = tiles[i], type = self.pos, is_free = false}):move(-100,-100):addTo(self.parent, 1)
        end
        mj:setVisible(false)
        self.hold_tiles:add(mj)
    end
    self:update_mj()
end

function MahjongPlayer:draw(tile_id)
    local mj
    if UserData.isInReplayScene and self.pos ~= 1 then
        mj = MahjongTile.new({id = tile_id, type = self.pos + 4, is_free = false}):move(-100,-100):addTo(self.parent, 1)
    else
        mj = MahjongTile.new({id = tile_id, type = self.pos, is_free = false}):move(-100,-100):addTo(self.parent, 1)
    end
    local moveDis = {{0,500},{-700,0},{0,-500},{700,0}}
    local time1, time2 = 0.1, 0.1
    if UserData.isSkipAnimate then
        time1, time2 = consts.replayTime, consts.replayTime
    end
    if self.isDealCard then
        self.inDrawAction = true
        if self.just_got then
            self.hold_tiles:add(self.just_got)
        end
        self.just_got = mj
        local mj_old = self.hold_tiles[self.hold_tiles.count]
        local x = justGotPosition[self.pos][1][1] + justGotPosition[self.pos][1][2] * mj_old:getPositionX()
        local y = justGotPosition[self.pos][2][1] + justGotPosition[self.pos][2][2] * mj_old:getPositionY()
        self.parent:reorderChild(mj, 1000)
        mj:fadeInAction(time1)
        mj:setPosition(cc.p(x + moveDis[self.pos][1],y + moveDis[self.pos][2]))
        mj:runAction(transition.sequence({
                cc.MoveTo:create(time2,cc.p(x,y)),
                cc.CallFunc:create(function()
                    self:update_mj()
                    self.inDrawAction = false
                end)}))
    else
        if self.pos == 1 and self.hold_tiles.count == 13 then
            self.dealCardDraw = mj
        end
        self.hold_tiles:add(mj)
        mj:setVisible(false)
        self:update_mj()
    end
end

--更新手牌中的朝天牌和癞子牌特殊标记，并重新排序
function MahjongPlayer:updateHandCardForLZ()
    for i=1, self.hold_tiles.count do
        self.hold_tiles[i]:updateForLaiZi()
    end
    self:update_mj()
end

function MahjongPlayer:deal(callback)
    for i=self.dealCount * 4 + 1, self.dealCount * 4 + 4 do
        local mj = self.hold_tiles[i]
        local time1, time2, time3 = 0.05, 0.05, 0.05
        if UserData.isSkipAnimate then
            time1, time2, time3 = consts.replayTime, consts.replayTime, consts.replayTime
        end
        if mj then
            -- local x,y = mj:getPosition()
            -- mj:move(683,384)
            -- mj:fadeInAction(time1)
            -- mj:setVisible(true)
            -- mj:runAction(transition.sequence({cc.MoveTo:create(time2, cc.p(x, y)),
            --     cc.DelayTime:create(time3), 
            --     cc.CallFunc:create(function()
            --         self.dealNum = self.dealNum + 1
            --         if self.dealNum == self.hold_tiles.count then
            --             self.isDealCard = true
            --             callback(true)
            --         elseif self.dealNum == self.dealCount * 4 + 4 then
            --             self.dealCount = self.dealCount + 1
            --             callback()
            --         end
            --     end)}))
            
            local x,y = mj:getPosition()
            -- mj:move(683,384)
            mj:fadeInAction(time1)
            mj:setVisible(true)
            mj:runAction(transition.sequence({
                -- cc.DelayTime:create(time3), 
                cc.CallFunc:create(function()
                    self.dealNum = self.dealNum + 1
                    if self.dealNum == self.hold_tiles.count then
                        self.isDealCard = true
                        callback(true)
                    elseif self.dealNum == self.dealCount * 4 + 4 then
                        self.dealCount = self.dealCount + 1
                        callback()
                    end
                end)}))
        end
    end
end

function MahjongPlayer:showSortAction()
    -- local bglist = {}
    for i=1,self.hold_tiles.count do
        local mj = self.hold_tiles[i]
        -- local bg = display.newSprite("#mj_actionBg.png"):addTo(mj, 10)
        -- table.insert(bglist,bg)
        local bg = display.newSprite("#mj_actionBg.png")
        bg:setName("mj_actionBg")
        mj:addChild(bg, 10)
    end
    self:update_mj()
    performWithDelay(self, function()
            -- for _,v in ipairs(bglist) do
            --     v:removeSelf()
            -- end
            for i=1, self.hold_tiles.count do
                local mj = self.hold_tiles[i]
                if mj:getChildByName("mj_actionBg") then
                    mj:getChildByName("mj_actionBg"):removeSelf()
                end
            end
            if self.pos == 1 and self.hold_tiles.count == 14 then
                self.just_got = self.dealCardDraw
                self.dealCardDraw = nil
                self.hold_tiles:removeValue(self.just_got)
                self:update_mj()
            end
        end, 0.2)
        -- end, 0.001)
end

function MahjongPlayer:peng(tile_id, owner)
    local remove_count = 2
    if self.pos == 1 or UserData.isInReplayScene then
        for i = self.hold_tiles.count, 1, - 1 do
            local mj = self.hold_tiles[i]
            if mj and mj:get_id() == tile_id then
                print("try to remove tile because of peng")
                self.hold_tiles:remove(i)
                mj:removeFromParent(true)
                remove_count = remove_count - 1
                if remove_count <= 0 then
                    break
                end
            end
        end
    else
        local mj = self.hold_tiles[1]
        mj:removeFromParent(true)
        self.hold_tiles:remove(1)
        mj = self.hold_tiles[1]
        mj:removeFromParent(true)
        self.hold_tiles:remove(1)
        -- print("the hold tiles remain", self.hold_tiles.count)
    end
    self:addPengCard(tile_id, owner)
    
    if not self.just_got then
        local mj = self.hold_tiles[self.hold_tiles.count]
        self.hold_tiles:remove(self.hold_tiles.count)
        self.just_got = mj
    end
    self:update_mj()
end

function MahjongPlayer:gang(tile_id, owner, is_super,gangType)
    local remove_count = 4
    local upgrade = false
    for i = 1, self.used_tiles_count do
        if self.used_tiles[i].action == "peng" and self.used_tiles[i].tile1:get_id() == tile_id then
            upgrade = true
            break
        end
    end
    -- if gangType ~= 1 then
        if self.pos == 1 or UserData.isInReplayScene then
            for i = self.hold_tiles.count, 1, - 1 do
                local mj = self.hold_tiles[i]
                if mj and mj:get_id() == tile_id then
                    self.hold_tiles:remove(i)
                    mj:removeFromParent(true)
                    remove_count = remove_count - 1
                    -- print("the hold tiles remain:", self.hold_tiles.count)
                    if remove_count <= 0 then
                        break
                    end
                end
            end
            if self.just_got then
                if self.just_got:get_id() == tile_id then
                    self.just_got:removeFromParent(true)
                    self.just_got = nil
                else
                    self.hold_tiles:add(self.just_got)
                    self.just_got = nil
                end
            end
        else
            if gangType ~= 1 then
                local index = is_super and 1 or 2
                if self.just_got then
                    index = index + 1
                    self.just_got:removeFromParent(true)
                    self.just_got = nil
                end
                for i=index,4 do
                    local mj = self.hold_tiles[1]
                    mj:removeFromParent(true)
                    self.hold_tiles:remove(1)
                end
            else
                if self.just_got then
                    self.just_got:removeFromParent(true)
                    self.just_got = nil
                end
            end
        end
    -- else
    --     if self.just_got then
    --         self.just_got:removeFromParent(true)
    --         self.just_got = nil
    --     end
    -- end
    self:addGangCard(tile_id,is_super,upgrade, owner)
    if not self.just_got then
        -- local mj = self.hold_tiles[self.hold_tiles.count]
        -- self.hold_tiles:remove(self.hold_tiles.count)
        -- self.just_got = mj
    end
    self:update_mj()
end


local function sortChiCard(tile_table,tile_id)
    local cardList = nil
    if tile_table[1] > tile_id then
        cardList = {tile_id,tile_table[1],tile_table[2]}
    elseif tile_table[1] < tile_id and tile_id < tile_table[2] then
        cardList = {tile_table[1],tile_id,tile_table[2]}
    else
        cardList = {tile_table[1],tile_table[2],tile_id}
    end
    return cardList
end

function MahjongPlayer:chi(tile_table,tile_id)
    local remove_count = 2
    if self.pos == 1 or UserData.isInReplayScene then
        for _,v in ipairs(tile_table) do
            for i = self.hold_tiles.count, 1, - 1 do
                local mj = self.hold_tiles[i]
                if mj and mj:get_id() == v then
                    print("try to remove tile because of peng")
                    self.hold_tiles:remove(i)
                    mj:removeSelf()
                    break
                end
            end
        end
    else
        for _,v in ipairs(tile_table) do
            local mj = self.hold_tiles[1]
            mj:removeSelf()
            self.hold_tiles:remove(1)
        end
    end
    -- self:addChiCard(sortChiCard(tile_table,tile_id))
    table.insert(tile_table, 2, tile_id) --吃的放中间
    self:addChiCard(tile_table)

    if not self.just_got then
        local mj = self.hold_tiles[self.hold_tiles.count]
        self.hold_tiles:remove(self.hold_tiles.count)
        self.just_got = mj
    end
    self:update_mj()
end

function MahjongPlayer:autoPlay(cards)
    if not cards then return end
    if self.just_got then
        self.hold_tiles:add(self.just_got)
        self.just_got = nil
    end
    self:update_mj()
    for i = 1,#cards do
        local tile_id = cards[i]
        local playedMJ = self:addPlayedCard(tile_id)
    end

    local time1, time2 = 0.5, 1
    if UserData.isSkipAnimate then
        time1, time2 = consts.replayTime, consts.replayTime
    end

    if self.pos == 1 or UserData.isInReplayScene then
        local x, y = playOutPosition[self.pos][1],playOutPosition[self.pos][2]
        local layout = ccui.Layout:create():addTo(self.parent, 100):move(x,y)
        layout:setBackGroundImage("mj/chi_bg.png")
        layout:setAnchorPoint(cc.p(0.5,0.5))
        layout:setBackGroundImageScale9Enabled(true)
        layout:setContentSize(cc.size(80*(#cards)+20,120+20))
        layout:setBackGroundImageCapInsets(cc.rect(10,10,78,75))
        layout:setTouchEnabled(false)
        for i = 1 , #cards do
            local tile_id = cards[i]
            local mj = MahjongTile.new({id = tile_id , type = 1}):addTo(layout)
            mj:move(80*(i-1)+40+10,60+10)
        end
        layout:setScale(0.1)
        layout:runAction(transition.sequence({ 
                                        cc.Spawn:create({cc.FadeIn:create(time1),cc.ScaleTo:create(0.5,1)}),
                                        cc.DelayTime:create(time2), 
                                        cc.Spawn:create({cc.FadeOut:create(time1),cc.ScaleTo:create(0.5,0.1)}),
                                        cc.CallFunc:create(function()
                                            layout:removeFromParent(true)
                                            GnetMgr:unlock()
                                        end)}))
    else
        -- --因为庄家自动出牌   少了一个出牌动作   其他玩家也自动减少一张牌
        -- local removeMJ = self.hold_tiles[1]
        -- self.hold_tiles:remove(1)
        -- removeMJ:removeSelf()
        GnetMgr:unlock()
    end
end

function MahjongPlayer:setMahjongEnableState(enable)
    for i=1,self.hold_tiles.count do
        local mj = self.hold_tiles[i]
        mj:setMask(enable)
    end
end

function MahjongPlayer:play(tile_id, pos)
    local x, y, mj, mj1, mj2, endPos
    local moveTime = 0.1 --移动牌所花费时间
    local delayTime = 0.1
    if UserData.isSkipAnimate then
        moveTime = consts.replayTime
        delayTime = consts.replayTime
    end
    if self.pos == 1 then
        if pos <= self.hold_tiles.count then
            mj = self.hold_tiles[pos]
        else
            mj = self.just_got
            self.just_got = nil
        end
        x, y = mj:getPosition()
        self.hold_tiles:remove(pos)

        --出牌后更新听牌
        if(self.m_tingLs and self.m_tingLs[pos])then
            local ting = self.m_tingLs[pos]
            self.m_tingLs = {[0] = ting}
        else
            print("出牌无听牌")
        end
    else
        if UserData.isInReplayScene then
            if pos <= self.hold_tiles.count then
                mj = self.hold_tiles[pos]
            else
                mj = self.just_got
                self.just_got = nil
            end
            self.hold_tiles:remove(pos)
        else
            if self.just_got then
                mj = self.just_got
                self.just_got = nil
            else
                -- mj = self.hold_tiles[1]
                -- self.hold_tiles:remove(1)
                mj = self.hold_tiles[self.hold_tiles.count]
                self.hold_tiles:remove(self.hold_tiles.count)
            end
        end
        x, y = mj:getPosition()
    end

    mj:removeSelf()
    mj2 = self:addPlayedCard(tile_id)
    endPos = cc.p(mj2:getPosition())
    self.parent:set_cur_tile(mj2,endPos)
    local indexPos = cc.p(mj2:getPosition())
    indexPos.x = indexPos.x + curPlayedPosList[self.pos].x
    indexPos.y = indexPos.y + curPlayedPosList[self.pos].y
    mj2:setPosition(cc.p(x, y))
    mj2:runAction(transition.sequence({
        -- cc.MoveTo:create(moveTime,indexPos),
        cc.MoveTo:create(moveTime,endPos),
        cc.CallFunc:create(function()
            -- self:update_mj()
            self:showTing()
            if 1 == self.pos then
                self:getParent():updateTingTip(0)
            elseif self:getParent().m_tingTip:isVisible() then
                self:getParent().m_tingTip:setVisible(false)
            end
        end)
        }))
    if self.just_got then
        local justGotIndex = nil
        for i = 1 , self.hold_tiles.count do
            local moveMj = self.hold_tiles[i]
            if moveMj:get_sort_id() > self.just_got:get_sort_id() then
                justGotIndex = i
                local count = self.used_tiles_count
                local posx = cardPosition[self.pos][1][1] + count * cardPosition[self.pos][1][2] + (i - 1) * cardPosition[self.pos][1][3]
                local posy = cardPosition[self.pos][2][1] + count * cardPosition[self.pos][2][2] + (i - 1) * cardPosition[self.pos][2][3]
                local movePos = cc.p(posx,posy)
                self.parent:reorderChild(self.just_got, 1000)
                self.just_got:runAction(transition.sequence({
                    cc.MoveTo:create(moveTime,movePos),
                    cc.DelayTime:create(delayTime),
                    cc.CallFunc:create(function()
                                        self.hold_tiles:add(self.just_got)
                                        self.just_got = nil
                                        self:update_mj()
                                    end)}))
                break
            end
        end
        if nil == justGotIndex then
            local count = self.used_tiles_count
            local posx = cardPosition[self.pos][1][1] + count * cardPosition[self.pos][1][2] + self.hold_tiles.count * cardPosition[self.pos][1][3]
            local posy = cardPosition[self.pos][2][1] + count * cardPosition[self.pos][2][2] + self.hold_tiles.count * cardPosition[self.pos][2][3]
            self.parent:reorderChild(self.just_got, 1000)
            self.just_got:runAction(transition.sequence({
                        cc.MoveTo:create(moveTime,cc.p(posx,posy)),
                        cc.DelayTime:create(delayTime),
                        cc.CallFunc:create(function()
                                            self.hold_tiles:add(self.just_got)
                                            self.just_got = nil
                                            self:update_mj()
                                        end)}))
            for i = pos,self.hold_tiles.count do
                local mjIndex = self.hold_tiles[i]
                local count = self.used_tiles_count
                local posx = cardPosition[self.pos][1][1] + count * cardPosition[self.pos][1][2] + (i - 1) * cardPosition[self.pos][1][3]
                local posy = cardPosition[self.pos][2][1] + count * cardPosition[self.pos][2][2] + (i - 1) * cardPosition[self.pos][2][3]
                mjIndex:runAction(cc.MoveTo:create(moveTime,cc.p(posx,posy)))
            end
        else
            local count = self.used_tiles_count
            if justGotIndex ~= pos then
                local index = nil
                local startIndex = nil
                local endIndex = nil
                if justGotIndex < pos then
                    startIndex = justGotIndex
                    endIndex = pos
                    index = 0
                else
                    startIndex = pos
                    endIndex = justGotIndex
                    index = -1
                end
                for i = startIndex ,endIndex - 1 do
                    local posx = cardPosition[self.pos][1][1] + count * cardPosition[self.pos][1][2] + (i + index) * cardPosition[self.pos][1][3]
                    local posy = cardPosition[self.pos][2][1] + count * cardPosition[self.pos][2][2] + (i + index) * cardPosition[self.pos][2][3]
                    local point = cc.p(posx,posy)
                    self.hold_tiles[i]:runAction(cc.MoveTo:create(moveTime, point))
                end
            end
        end
    end

    performWithDelay(self, function()
        GnetMgr:unlock()
    end, moveTime + delayTime + 0.1)
end

function MahjongPlayer:hideCards()
    for i=1,self.hold_tiles.count do
        self.hold_tiles[i]:updateShow({id = 0, type = self.pos})
    end
end

function MahjongPlayer:hu(cards)
    if self.just_got then
        self.hold_tiles:add(self.just_got)
        self.just_got = nil
    end
    -- print("MahjongPlayer:hu(cards):",self.hold_tiles.count,#cards)
    for k,v in ipairs(cards) do
        if self.hold_tiles[k] then
            self.hold_tiles[k]:updateShow({id = v, type = self.pos + 4})
        else
            self.hold_tiles:add(MahjongTile.new({id = v, type = self.pos + 4}):addTo(self.parent, 1))
        end
    end
    self:update_mj(true)
end

function MahjongPlayer:removeOnePlayed(tileId)
    print("removeOnePlayed:",#self.played_tiles)
    print("self.played_tiles_count:",self.played_tiles_count)

    if tileId then --湖南长沙出两张牌，找出要碰的
        local posIndex
        local removeMj
        -- for i=1, self.played_tiles_count do
        for i=self.played_tiles_count, 1, -1 do
            if tileId == self.played_tiles[i].id then
                posIndex = i
                removeMj = self.played_tiles[i]
                break
            end
        end
        if not posIndex then
            print("异常，试图移除一张没出过的牌")
            return
        end
        for i=self.played_tiles_count, posIndex+1, -1 do
            self.played_tiles[i]:setPosition(cc.p(self.played_tiles[i-1]:getPosition()))
        end
        removeMj:removeSelf()
        for i=posIndex+1, self.played_tiles_count do
            self.played_tiles[i-1] = self.played_tiles[i]
        end
        self.played_tiles[self.played_tiles_count] = nil
        self.played_tiles_count = self.played_tiles_count - 1
    else
        self.played_tiles[self.played_tiles_count]:removeSelf()
        self.played_tiles[self.played_tiles_count] = nil
        self.played_tiles_count = self.played_tiles_count - 1
    end
end

function MahjongPlayer:removeAllMj()

    for k,v in ipairs(self.played_tiles) do
        v:removeSelf()
    end

    self.played_tiles = {}
    for i=1,self.hold_tiles.count do
        self.hold_tiles[i]:removeSelf()
    end
    self.hold_tiles:reset()
    --{{action = "peng", tile1 = xxx, tile2 = xxx, tile3 = xxx}}
    for k,v in pairs(self.used_tiles) do
        v.tile1:removeSelf()
        v.tile2:removeSelf()
        if v.tile3 then
            v.tile3:removeSelf()
        end        
        if v.tile4 then
            v.tile4:removeSelf()
        end
    end
    if self.just_got then
        self.just_got:removeSelf()
    end
    self.just_got = nil
    self.used_tiles = {}
    self.played_tiles_count = 0
    self.used_tiles_count = 0
    self.ic_readyfor_game:setVisible(false)
    self.isDealCard = false
    self:setPlayerPoint()
end

function MahjongPlayer:getPlayerState()
    self.isDealCard = true
    self:sort(self.hold_tiles)
    self:update_mj()
    local state = {}
    state.playedList = {}
    state.handList = {}
    state.usedList = {}
    for k,v in ipairs(self.played_tiles) do
        table.insert(state.playedList, {params = v.params, pos = cc.p(v:getPosition())})
    end

    for i=1,self.hold_tiles.count do
        table.insert(state.handList, {params = self.hold_tiles[i].params, pos = cc.p(self.hold_tiles[i]:getPosition())})
    end

    for k,v in pairs(self.used_tiles) do
        local config = {}
        config.action = v.action
        config.tile1 = {params = v.tile1.params, pos = cc.p(v.tile1:getPosition())}
        config.tile2 = {params = v.tile2.params, pos = cc.p(v.tile2:getPosition())}
        if v.tile3 then
            config.tile3 = {params = v.tile3.params, pos = cc.p(v.tile3:getPosition())}
        end        
        if v.tile4 then
            config.tile4 = {params = v.tile4.params, pos = cc.p(v.tile4:getPosition())}
        end
        table.insert(state.usedList, config)
    end
    if self.just_got then
        state.just_got = {params = self.just_got.params, pos = cc.p(self.just_got:getPosition())}
    end
    state.hold_tiles_count = self.hold_tiles.count
    state.played_tiles_count = self.played_tiles_count
    state.used_tiles_count = self.used_tiles_count
    return state
end

function MahjongPlayer:loadState(state)
    self:removeAllMj()
    for _, v in ipairs(state.playedList) do
        self:addPlayedCard(v.params.id)
    end
    self.played_tiles_count = state.played_tiles_count

    for _, v in ipairs(state.usedList) do
        if "peng" == v.action then
            self:addPengCard(v.tile1.params.id)
        elseif "chi" == v.action then
            self:addChiCard({v.tile1.params.id, v.tile2.params.id, v.tile3.params.id})
        elseif "gang" == v.action then
            self:addGangCard(v.tile1.params.id)
        end
    end

    for _, v in ipairs(state.handList) do
        local mj = MahjongTile.new(v.params):addTo(self.parent, 1)
        mj:setPosition(v.pos)
        self.hold_tiles:add(mj)
    end

    if state.just_got then
        self.just_got = MahjongTile.new(state.just_got.params):addTo(self.parent, 1)
        self.just_got:setPosition(state.just_got.pos)
    end
    self.isDealCard = true
    -- self:sort(self.hold_tiles)
    self:update_mj()
end

function MahjongPlayer:setPlayerPoint()
    if self.lbscore then
        self.lbscore:setString(UserData:getPlayerPoint(self.chairId))
    end
end

function MahjongPlayer:setReady(isready)

    self.ic_readyfor_game:setVisible(isready)
end

function MahjongPlayer:showCards(cards)
    self:removeAllMj()
    self.isDealCard = true
    local cardNum   = cards.cardNum
    local gangCards = json.decode(cards.gangCards)
    local pengCards = json.decode(cards.pengCards)
    local chiCards  = json.decode(cards.chiCards)
    local handCards = cards.handCards or {}
    local outCards  = cards.outCards or {}
    local hasJustGot = false
    ----手牌
    for i = 1, cardNum do
        local mj = MahjongTile.new({id = handCards[i], type = self.pos}):addTo(self.parent, 1);
        mj:setPosition(cc.p(683, 384))
        if i == cardNum and cardNum%3 == 2 then
            if self.just_got then
                self.just_got:removeSelf()
            end
            self.just_got = mj
            hasJustGot = true
            print("add to just_got")
        else
            self.hold_tiles:add(mj)
        end
        if 1 == self.pos then
            self.parent:reorderChild(mj, 1500)
        end
    end
    --test
    -- for i=1,30 do
    --     table.insert(outCards, 35)
    -- end
    ----出过的牌
    for k,v in ipairs(outCards) do
        self:addPlayedCard(v)
    end
    ----杠牌
    for k,v in pairs(gangCards) do
        self:addGangCard(tonumber(k),v[1] == 2,false, v[2])
    end
    ----碰牌
    for k,v in pairs(pengCards) do
        self:addPengCard(tonumber(k), v)
    end
    --吃牌
    for k,v in pairs(chiCards) do
        self:addChiCard(v)
    end

    if cards.piaoPoint then
        self:updatePiaoPoint(cards.piaoPoint)
    end

    self:update_mj()

    return hasJustGot
end

function MahjongPlayer:setOffLine(isOnline)
    if self.offLine then
        self.offLine:setVisible(not isOnline)
    end
end

function MahjongPlayer:getPlayedSidLid(count)
    if count <= 6 then
        lid = 1
        sid = (count - 1) % 6
    elseif count <= 14 then
        lid = 2
        sid = (count - 7) % 8 - 1
    elseif count <= 24 then
        lid = 3
        sid = (count - 15) % 10 - 2
    else
        lid = 4
        sid = count - 28
    end
    if self.pos%2 ~= 1 then
        local index = lid
        lid = sid
        sid = index
    end
    return lid, sid
end

function MahjongPlayer:addPlayedCard(cardid,isBird,isWinBird)
    local count = self.played_tiles_count + 1
    local mj
    if isBird then
        mj = MahjongTile.new({id = cardid, type = 25, is_bird = isBird, is_win_bird = isWinBird}):addTo(self.parent, 1);
    else
        mj = MahjongTile.new({id = cardid, type = 8 + self.pos}):addTo(self.parent, 1);
    end
    self.played_tiles[count] = mj
    self.played_tiles_count = count
    local lid, sid = self:getPlayedSidLid(count)
    local x,y = playedPosition[self.pos][1] + sid * playedPosition[self.pos][2],playedPosition[self.pos][3] + lid * playedPosition[self.pos][4]
    if self.pos == 2 or self.pos == 3 then
        self.parent:reorderChild(mj, 40 - count)
    end
    mj:setPosition(cc.p(x, y))

    if count > 24 then --第4行,1，3号位要全部调整麻将位置
        for i=1, self.played_tiles_count do
            local mj = self.played_tiles[i]
            lid, sid = self:getPlayedSidLid(i)
            local playedPosition = {{585,47,400,-56},{865,65,303,41},{820,-47,410,56},{540,-65,505,-41}}  --num1 + sid * num2,num3 + lid * num4
            local x,y = playedPosition[self.pos][1] + sid * playedPosition[self.pos][2],playedPosition[self.pos][3] + lid * playedPosition[self.pos][4]
            mj:setPosition(cc.p(x, y))
        end
    end
    return mj
end

--添加 碰 杠牌的方位标记
function MahjongPlayer:addPosTag(owner, mj)
    -- local pos = helper.getRealPos(owner, self.chairId, UserData.table_config.player_count)
    if not owner then
        return
    end
    local pos = helper.getRealPos(owner, UserData.myChairId, UserData.table_config.player_count)
    local tag
    if 1 == pos then --下
        tag = ccui.ImageView:create("mj/down.png"):addTo(mj, 100)
    elseif 2 == pos then --右
        tag = ccui.ImageView:create("mj/right.png"):addTo(mj, 100)
    elseif 3 == pos then --上
        tag = ccui.ImageView:create("mj/up.png"):addTo(mj, 100)
    elseif 4 == pos then --左
        tag = ccui.ImageView:create("mj/left.png"):addTo(mj, 100)
    end
    if tag then
        if 1 == self.pos then
            tag:setPosition(cc.p(0, -40))
        elseif 2 == self.pos then
            tag:setPosition(cc.p(40, 0))
            tag:setScale(0.6)
        elseif 3 == self.pos then
            tag:setPosition(cc.p(0, -40))
            tag:setScale(0.6)
        elseif 4 == self.pos then
            tag:setPosition(cc.p(-40, 0))
            tag:setScale(0.6)
        end
    end
end

function MahjongPlayer:addPengCard(tile_id, owner)
    local count = self.used_tiles_count
    local mj1 = MahjongTile.new({id = tile_id, type = self.pos + 4}):addTo(self.parent, 1)
    local mj2 = MahjongTile.new({id = tile_id, type = self.pos + 4}):addTo(self.parent, 1)
    local mj3 = MahjongTile.new({id = tile_id, type = self.pos + 4}):addTo(self.parent, 1)
    self.used_tiles[count + 1] = {action = "peng", tile1 = mj1, tile2 = mj2, tile3 = mj3}
    self.used_tiles_count = count + 1
    local x = pengPosition[self.pos][1][1] + count * pengPosition[self.pos][1][2]
    local y = pengPosition[self.pos][2][1] + count * pengPosition[self.pos][2][2]
    mj1:setPosition(cc.p(x, y))
    mj2:setPosition(cc.p(x + pengPosition[self.pos][1][3]       , y + pengPosition[self.pos][2][3]))
    mj3:setPosition(cc.p(x + pengPosition[self.pos][1][3] * 2   , y + pengPosition[self.pos][2][3] * 2))
    if self.pos == 2 then
        self.parent:reorderChild(mj1, 30 - count * 3)
        self.parent:reorderChild(mj2, 30 - count * 3 - 1)
        self.parent:reorderChild(mj3, 30 - count * 3 - 2)
    end
    self:addPosTag(owner, mj2)
end

function MahjongPlayer:addChiCard(tile_table)
    local count = self.used_tiles_count
    local mj1 = MahjongTile.new({id = tile_table[1], type = self.pos + 4}):addTo(self.parent, 1)
    local mj2 = MahjongTile.new({id = tile_table[2], type = self.pos + 4}):addTo(self.parent, 1)
    local mj3 = MahjongTile.new({id = tile_table[3], type = self.pos + 4}):addTo(self.parent, 1)
    self.used_tiles[count + 1] = {action = "chi", tile1 = mj1, tile2 = mj2, tile3 = mj3}
    self.used_tiles_count = count + 1
    local x = pengPosition[self.pos][1][1] + count * pengPosition[self.pos][1][2]
    local y = pengPosition[self.pos][2][1] + count * pengPosition[self.pos][2][2]
    mj1:setPosition(cc.p(x, y))
    mj2:setPosition(cc.p(x + pengPosition[self.pos][1][3]       , y + pengPosition[self.pos][2][3]))
    mj3:setPosition(cc.p(x + pengPosition[self.pos][1][3] * 2   , y + pengPosition[self.pos][2][3] * 2))
    if self.pos == 2 then
        self.parent:reorderChild(mj1, 30 - count * 3)
        self.parent:reorderChild(mj2, 30 - count * 3 - 1)
        self.parent:reorderChild(mj3, 30 - count * 3 - 2)
    end
end

function MahjongPlayer:addGangCard(tile_id,is_super,upgrade, owner)
    local count = self.used_tiles_count
    local addition = 0
    if is_super then
        addition = 8
    end
    local mj1 = MahjongTile.new({id = tile_id, type = self.pos + 4 + addition}):addTo(self.parent, 1)
    local mj2 = MahjongTile.new({id = tile_id, type = self.pos + 4 + addition}):addTo(self.parent, 1)
    local mj3 = MahjongTile.new({id = tile_id, type = self.pos + 4 + addition}):addTo(self.parent, 1)
    local mj4 = MahjongTile.new({id = tile_id, type = self.pos + 4}):addTo(self.parent, 1)
    if not upgrade then
        self.used_tiles[count + 1] = {action = "gang", tile1 = mj1, tile2 = mj2, tile3 = mj3, tile4 = mj4}
        self.used_tiles_count = count + 1
    else
        for i = 1, self.used_tiles_count do
            if self.used_tiles[i].action == "peng" and self.used_tiles[i].tile1:get_id() == tile_id then
                self.used_tiles[i].tile1:removeSelf()
                self.used_tiles[i].tile2:removeSelf()
                self.used_tiles[i].tile3:removeSelf()
                self.used_tiles[i] = {action = "gang", tile1 = mj1, tile2 = mj2, tile3 = mj3, tile4 = mj4}
                count = i - 1
                break
            end
        end
    end
    local x = pengPosition[self.pos][1][1] + count * pengPosition[self.pos][1][2]
    local y = pengPosition[self.pos][2][1] + count * pengPosition[self.pos][2][2]
    mj1:setPosition(cc.p(x, y))
    mj2:setPosition(cc.p(x + pengPosition[self.pos][1][3]       , y + pengPosition[self.pos][2][3]))
    mj3:setPosition(cc.p(x + pengPosition[self.pos][1][3] * 2   , y + pengPosition[self.pos][2][3] * 2))
    mj4:setPosition(cc.p(x + pengPosition[self.pos][1][3]       , y + gangPosition[self.pos]))
    if self.pos == 2 then
        self.parent:reorderChild(mj1, 30 - count * 3)
        self.parent:reorderChild(mj2, 30 - count * 3 - 1)
        self.parent:reorderChild(mj3, 30 - count * 3 - 2)
        self.parent:reorderChild(mj4, 35 - count * 3 -1)        
    end
    self:addPosTag(owner, mj4)
end

-- 显示聊天的内容
function MahjongPlayer:chat(tab)
    local posY = 45
    local bgMsgHeight = 70 
    self:dimissChat()
    if self.m_timeCall then
        gScheduler:unscheduleScriptEntry(self.m_timeCall)
        self.m_timeCall = nil
    end

    local chatType = tonumber(tab.type)
    local id = tab.id
    UserData.chatList = UserData.chatList or {}
    if 3 ~= chatType then --历史记录不包含语音
        table.insert(UserData.chatList, tab)
    end

    if chatType == 1 then
        if self.emoji then
            self.emoji:loadTexture("mj/emoji/" .. id .. ".png")
        else
            self.emoji =  ccui.ImageView:create("mj/emoji/" .. id .. ".png"):addTo(self.bg, 1)
            self.emoji:setAnchorPoint(cc.p(0,0))
            if self.pos == 1 or self.pos == 4 then
                self.emoji:setPosition(100, posY - 25)
            elseif self.pos == 2  or self.pos == 3 then
                self.emoji:setPosition(-75, posY - 25)
            end 
        end
        self.emoji:setVisible(true)
    elseif chatType == 3 and consts.App.APP_PLATFORM ~= cc.PLATFORM_OS_WINDOWS then
        LuaCallPlatformFun.stopVoiceById()
        LuaCallPlatformFun.playVoiceById(id)
        if self.bgVoice then
            self.voicemsg:setString(math.ceil(tab.len).."\"")
        else
            self.bgVoice = ccui.ImageView:create("mj/bg_chat_msg_bubble.png")
            self.bgVoice:setAnchorPoint(cc.p(0,0))
            self.bgVoice:setScale9Enabled(true)
            self.bgVoice:addTo(self.bg, 1)
            self.bgVoice:setContentSize(cc.size(self.bgVoice:getContentSize().width - 30 ,bgMsgHeight))
            self.voice = ccui.ImageView:create("mj/recordvoice2.png"):addTo(self.bgVoice, 2)
            self.voice:setAnchorPoint(cc.p(0,0.5))
            self.voice:setPosition(cc.p(30, bgMsgHeight / 2))

            self.voicemsg =  ccui.Text:create(math.ceil(tab.len).."\"", nil, 30):addTo(self.bgVoice, 2)
            self.voicemsg:setAnchorPoint(cc.p(0.5,0.5))
            self.voicemsg:setColor(cc.c3b(255,255,255))
            self.voicemsg:setPosition(cc.p(self.bgVoice:getContentSize().width+20,  bgMsgHeight / 2))
            if self.pos == 1 or self.pos == 4 then
                self.bgVoice:setPosition(cc.p(95 , posY))
            elseif self.pos == 2  or self.pos == 3 then
                self.bgVoice:setPosition(cc.p(0, posY))
                self.bgVoice:setFlippedX(true)
                self.voicemsg:setFlippedX(true)
            end 
        end
        --self.msg:setVisible(true)
        self.bgVoice:setVisible(true)
        performWithDelay(self,function()
        self:dimissVoice()
            print("lua播放完成")
            AudioMgr:resumeMusic()
        end,tab.len)
    elseif chatType == 2 then
        local index = tonumber(id)
        local str
        if index then --常用语
            str = consts.chatMsgArray[index]
        else --文字聊天
            str = tab.txt
        end
        if self.bgMsg then
            -- self.msg:setString(consts.chatMsgArray[index])
            self.msg:setString(str)
            if self.pos == 2  or self.pos == 3 then
                self.msg:setPosition(cc.p(0 - self.msg:getContentSize().width - 30 ,  posY + bgMsgHeight / 2 - 40))
            end 
            self.bgMsg:setContentSize(cc.size(self.msg:getContentSize().width + 45 ,bgMsgHeight))
        else
            self.bgMsg = ccui.ImageView:create("mj/bg_chat_msg_bubble.png")
            self.bgMsg:setAnchorPoint(cc.p(0,0))
            self.bgMsg:setScale9Enabled(true)
            self.bgMsg:addTo(self.bg, 1)
            -- self.msg =  ccui.Text:create(consts.chatMsgArray[index], nil, 28):addTo(self.bg, 2)
            self.msg =  ccui.Text:create(str, nil, 28):addTo(self.bg, 2)
            self.msg:setAnchorPoint(cc.p(0,0.5))
            self.msg:setColor(cc.c3b(150,92,69))
            self.bgMsg:setContentSize(cc.size(self.msg:getContentSize().width + 45 ,bgMsgHeight))

            if self.pos == 1 or self.pos == 4 then
                self.bgMsg:setPosition(cc.p(95 , posY - 40))
                self.msg:setPosition(cc.p(95 + 30, posY + bgMsgHeight / 2 - 40))
            elseif self.pos == 2  or self.pos == 3 then
                self.bgMsg:setPosition(cc.p(0, posY - 40))
                self.bgMsg:setFlippedX(true)
                self.msg:setPosition(cc.p(0 - self.msg:getContentSize().width - 30 , posY + bgMsgHeight / 2 - 40))
            end 
        end
        self.msg:setVisible(true)
        self.bgMsg:setVisible(true)
        if index then
            AudioMgr:onChatMsg(index,tab.sex)
        end
    end
    self.m_timeCall = gScheduler:scheduleScriptFunc(handler(self,self.dimissChat),2,false )
    --performWithDelay(self, handler(self,self.dimissChat), 2)
end

function MahjongPlayer:dimissChat()
    if self.emoji and self.emoji:isVisible() then
        self.emoji:setVisible(false)
    end
    if self.bgMsg and  self.bgMsg:isVisible() then
        self.bgMsg:setVisible(false)
    end
    if self.msg and  self.msg:isVisible() then
        self.msg:setVisible(false)
    end
end

function MahjongPlayer:dimissVoice()
    if self.bgVoice and self.bgVoice:isVisible() then
        self.bgVoice:setVisible(false)
    end
end

function MahjongPlayer:onExit()
    self:stopAllActions()
    NotifyMgr:unregWithObj(self)
end

--重复牌标识:已出的牌、已碰的牌、已吃的牌
function MahjongPlayer:showSameSelectMJ(data)
    local selectCardId = data.data
    self:clearSameCardTag()
    --setTag
    for _, v in pairs(self.played_tiles) do
        if selectCardId == v:get_id() then
            v:setSameCardTag()
        end
    end
    for _, v in pairs(self.used_tiles) do
        if (v.action == "peng" or v.action == "chi") then
            if selectCardId == v.tile1:get_id() then
                v.tile1:setSameCardTag()
            end
            if selectCardId == v.tile2:get_id() then
                v.tile2:setSameCardTag()
            end
            if selectCardId == v.tile3:get_id() then
                v.tile3:setSameCardTag()
            end
        end
    end
end

--清除重复牌的标记
function MahjongPlayer:clearSameCardTag()
    for _, v in pairs(self.played_tiles) do
        v:clearSameCardTag()
    end
    for _, v in pairs(self.used_tiles) do
        if v.action == "peng" or v.action == "chi"then
            v.tile1:clearSameCardTag()
            v.tile2:clearSameCardTag()
            v.tile3:clearSameCardTag()
        end
    end
end

--设置操作状态
function MahjongPlayer:setOperationState(bOper)
    bOper = bOper or false
    -- self.block:setVisible(bOper)
    -- self:showTing()
end

--update飘 分数
function MahjongPlayer:updatePiaoPoint(num)
    if num == 0 then
        self.piaoPoint:setString("不飘")
    else
        self.piaoPoint:setString("飘"..num.."分")
    end
    self.piaoPoint:setVisible(true)
end

function MahjongPlayer:onChangeBgType()
    for i=1, self.hold_tiles.count do
        local mj = self.hold_tiles[i]
        mj:updateShow(mj.params)
    end

    for i=1, self.used_tiles_count do
        local one = self.used_tiles[i]
        for j = 1, 4 do
            local mj = one["tile"..j]
            if mj then 
                mj:updateShow(mj.params)
            end
        end
    end

    for i=1, self.played_tiles_count do
        local mj = self.played_tiles[i]
        mj:updateShow(mj.params)
    end

    if self.just_got then
        self.just_got:updateShow(self.just_got.params)
    end
    -- self.bg:setTexture("mj/"..UserData:getCurBgType().."/battle_head_back.png")
    -- self.block:setTexture("mj/"..UserData:getCurBgType().."/battle_head_block.png")
end

function MahjongPlayer:getHandCardPosByID(tile_id)
    for i=1, self.hold_tiles.count do
        local mj = self.hold_tiles[i]
        if tile_id == mj.id then
            return i
        end
    end
    return self.hold_tiles.count + 1
end

--更新听牌三角
function MahjongPlayer:showTing()
    -- if(self.pos ~= 1 or not consts.TingPaiGameType[UserData.curMahjongType] or UserData:isLaizi())then return end
    if (self.pos ~= 1 or not consts.TingPaiGameType[UserData.curMahjongType]) then return end
    print("更新听牌队列")
    self:updateTingLs()
    self:updateTingIcon()
end

function MahjongPlayer:hideTing()
    if (self.pos ~= 1 or not consts.TingPaiGameType[UserData.curMahjongType]) then return end
    print("隐藏听牌提示按钮")
    self.m_tingLs = {}
    self:updateTingIcon()
end

function MahjongPlayer:updateTingIcon()
    -- if(self.pos ~= 1 or not consts.TingPaiGameType[UserData.curMahjongType] or UserData:isLaizi())then return end
    if(self.pos ~= 1 or not consts.TingPaiGameType[UserData.curMahjongType])then return end
    if(self.parent.should_touch and self.just_got)then
        local function getTingNum(tbl)
            local tingNum = 0
            for i = 1, #tbl do
                local id = tbl[i]
                tingNum = tingNum + self:getParent():getLeftMjNum(tbl[i])
            end
            -- print("mmmmmmmm", tingNum)
            return tingNum
        end
        --最佳听牌
        local maxTingNum = 0
        for i=1, self.hold_tiles.count + 1 do
            if self.m_tingLs[i] then
                local tingNum = getTingNum(self.m_tingLs[i])
                if tingNum > maxTingNum then
                    maxTingNum = tingNum
                end
            end
        end
        -- dumpLog(maxTingNum)
        -- dump2(self.m_tingLs)
        for i=1,self.hold_tiles.count do
            self.hold_tiles[i]:setTingIcon(self.m_tingLs[i] ~= nil, self.m_tingLs[i] ~= nil and maxTingNum == getTingNum(self.m_tingLs[i]))
        end
        self.just_got:setTingIcon(self.m_tingLs[self.hold_tiles.count+1] ~= nil, self.m_tingLs[self.hold_tiles.count+1] ~= nil and maxTingNum == getTingNum(self.m_tingLs[self.hold_tiles.count+1]))
    else
        for i=1,self.hold_tiles.count do
            self.hold_tiles[i]:setTingIcon(false, false)
        end
    end

    if self.m_tingLs and table.nums(self.m_tingLs) > 0 and "battle.mp3" == AudioMgr.curMusicName then
        AudioMgr:changeTingMusic()
    end

    --更新听牌按钮
    MyApp.curScene.MahjongBgLayer.btn_ting:setVisible(not self.parent.should_touch and self.m_tingLs and self.m_tingLs[0] ~= nil)
end

function MahjongPlayer:getTingLsByPos( index )
    return self.m_tingLs[index]
end

--更新听牌队列
function MahjongPlayer:updateTingLs()
    
    if(self.hold_tiles.count < 1)then return end

    local isChangsha = UserData.curMahjongType == 2 or UserData.curMahjongType == 5
    if (self.parent.should_touch and self.just_got) then --摸到牌
        print("自己出牌刷")
        self.m_tingLs = {}
        local idLs = {}
        for i=1,self.hold_tiles.count do
            table.insert(idLs,self.hold_tiles[i].id)
        end
        table.insert(idLs,self.just_got.id)
        if self.handleTimer then
            gScheduler:unscheduleScriptEntry(self.handleTimer)
            self.handleTimer = nil
        end
        local i = 0
        local map = {} --过滤重复手牌
        for i = 1, #idLs do
            map[idLs[i]] = true
        end
        local array = {} --无重复手牌队列
        for k, v in pairs(map) do
            table.insert(array, k)
        end
        -- dump2(array)

        self.handleTimer = gScheduler:scheduleScriptFunc(function ()
            i = i + 1
            if i > #array then
                gScheduler:unscheduleScriptEntry(self.handleTimer)
                self.handleTimer = nil
                for i, id in ipairs(idLs) do
                    if map[id] ~= true then
                        self.m_tingLs[i] = map[id]
                    end
                end
                self:updateTingIcon()
                return
            end
            local tmpLs = clone(idLs)
            table.removebyvalue(tmpLs, array[i], false)
            -- dump2(UserData:getQiDuiTbl())
            -- dumpLog(UserData:getLaiziId())
            local tingLs = getAllting(tmpLs, UserData:getQiDuiTbl(), UserData:getLaiziId())
            self:checkTingLs(tingLs)
            print("计算听牌", array[i], #tingLs)
            if (#tingLs > 0) then
                map[array[i]] = tingLs
            end
        end, 0.01, false)

    elseif(not self.just_got and not self.m_tingLs)then
        self.m_tingLs = {}
        --没摸牌
        print("初次别人出牌刷")
        local idLs = {}
        for i=1, self.hold_tiles.count do
            table.insert(idLs,self.hold_tiles[i].id)
        end
        -- local numLs = mjIdToNumVer(idLs)
        -- local tingLs = getTingPai( numLs ,isChangsha,UserData:isLaizi())
        local tingLs = getAllting(idLs, UserData:getQiDuiTbl(), UserData:getLaiziId())
        self:checkTingLs(tingLs)
        if(#tingLs > 0)then
            self.m_tingLs = {[0] = tingLs}--0为提示按钮值
        end
        self:updateTingIcon()
    else
        print("别人出牌不刷")
        self:updateTingIcon()
    end
end


function MahjongPlayer:checkTingLs(tingLs)
    --把剩余牌为负数的要听的牌移除
    for i = #tingLs, 1, -1 do
        if self.parent.m_tileLeftLs[tingLs[i]] and self.parent.m_tileLeftLs[tingLs[i]] < 0 then
            table.remove(tingLs, i)
        end
    end
end

return MahjongPlayer