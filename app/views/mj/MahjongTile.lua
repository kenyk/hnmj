
local back_list = { "#tile_back_self.png",          "#tile_back_up.png",        "#tile_back_opp.png",           "#tile_back_up.png",   --手牌4
                    "#tile_back_used_self.png",     "#tile_back_played_up.png", "#tile_back_played_self.png",   "#tile_back_played_up.png",  --碰杠8
                    "#tile_back_played_self.png",   "#tile_back_played_up.png", "#tile_back_played_self.png",   "#tile_back_played_up.png",   --出过的牌12
                    "#tile_back_cover_self.png",    "#tile_back_cover_up.png",  "#tile_back_cover_opp.png",     "#tile_back_cover_up.png", --暗杠16
                    "#tile_back_self_big.png",      "#tile_back_up_big.png",    "#tile_back_self_big.png",      "#tile_back_up_big.png",    --出的牌大 (废弃)20
                    "#tile_back_self.png",   nil,                        nil,                            nil,                        --小鸟24
                    "#tile_back_used_self.png",     nil,                        nil,                            nil,                        --大鸟28
                    "#tile_back_self.png"}                                                                                        

local MahjongTile = class("MahjongTile", function()
    return cc.Layer:create()
end)

--name, id
function MahjongTile:ctor(params)
    self.params = params
    self:enableNodeEvents()
    self:updateShow(params)
end

function MahjongTile:updateShow(params)
    self:setData(params)
    self:setImage()
end

function MahjongTile:setData(params)
    self.id = params.id or 1
    self.type = params.type
    self.is_free = UserData:isLaizi() and self.id == 45
    if params.is_dfree then
        self.is_free = false
    end
    self.is_bird = params.is_bird or false
    self.is_win_bird = params.is_win_bird or false
    self.is_hu = params.is_hu or false
    self.lid = self.id % 10
    self.sid = (self.id - self.lid) / 10
end

local tileName = {"#tile_wan","#tile_tong","#tile_tiao","#tile_zhi"}

function MahjongTile:setImage()
    if self.bg then self.bg:removeSelf() end
    if self.laiziImg then self.laiziImg:removeSelf() end
    if self.cg then self.cg:removeSelf() end
    self.bg = nil
    self.cg = nil
    self.laiziImg = nil
    self.wangImg = nil
    if self.is_bird then
        if self.type == 21 then
            self.bg = display.newSprite("#tile_back_bird.png"):addTo(self, 0)
            self.bg:setScale(0.5)
        elseif self.type == 1 then
            self.bg = display.newSprite("#tile_back_bird.png"):addTo(self, 0)
        elseif self.type == 25 then
            self.bg = display.newSprite("#tile_back_bird.png"):addTo(self, 0)
            self.bg:setScale(0.5)
        end
    else
        self.bg = display.newSprite(back_list[self.type]):addTo(self, 0)
    end
    if self.type == 2 then
        self.bg:setFlippedX(true)
    elseif self.type == 14 or self.type == 16 then --24号位置暗杠的牌
        self.bg:setScale(0.7)
    end

    --test
    -- self.bg:setColor(cc.c3b(255, 255, 0))

    local sid = self.sid
    local lid = self.lid
    self:setContentSize(self.bg:getBoundingBox())
    if self.type == 1 or (self.type > 4 and self.type < 13) or self.type > 16 then
        -- if self.type%4 == 3 and self.type ~= 19 then
        --     self.cg = display.newSprite(tileName[sid].. lid .."s.png"):addTo(self, 1)
        -- else
        --     self.cg = display.newSprite(tileName[sid].. lid ..".png"):addTo(self, 1)
        -- end
        if self.type == 1 or self.type == 5 or self.type > 24 then
            self.cg = display.newSprite(tileName[sid].. lid ..".png"):addTo(self, 1)
        else
            self.cg = display.newSprite(tileName[sid].. lid .."s.png"):addTo(self, 1)
        end
        if self.is_free and self.cg then
            if self.type == 1 then
                self.laiziImg = display.newSprite("mj/mylaizi.png", 85, 117):addTo(self.cg, 0)
            elseif self.type == 29 then
                self.laiziImg = display.newSprite("mj/mylaizi.png", 87, 120):addTo(self.cg, 0)
                self.laiziImg:setScale(0.9)
            elseif self.type%4 == 1 or self.type%4 == 3 then
                self.laiziImg = display.newSprite("mj/laizi.png", 40, 61):addTo(self.cg, 0)
            elseif self.type%4 == 2 or self.type%4 == 0 then
                self.laiziImg = display.newSprite("mj/laizi.png", 36, 66):addTo(self.cg, 0)
            -- elseif self.type%4 == 3 then
            --     self.laiziImg = display.newSprite("mj/laizi.png", -13, -7):addTo(self, 2)
            --     self.laiziImg:setRotation(180)
            --     self.laiziImg:setScale(0.5)
            end
        end
        if self.is_win_bird and self.cg then
            self.winBirdImg = display.newSprite("mj/win_bird.png", 88, 119):addTo(self.cg, 0)
        end
        if self.is_hu then
            self.laiziImg = display.newSprite("mj/hu.png", 60, 78):addTo(self.cg, 0)
        end
        self.cg:setRotation((self.type%4 - 1)*(-90))
        if self.type == 1 then --自己手牌
            -- self.cg:setPosition(cc.p(0, - 13))
        -- elseif self.type == 5 or self.type == 9 or self.type == 25 then --自己碰杠出的牌
        elseif self.type == 5 then --自己碰杠的牌
            self.cg:setPosition(cc.p(0, 24))
            self.cg:setScale(0.8)
        elseif self.type == 6 then --2号位置碰杠的牌
            self.cg:setPosition(cc.p(6, 6))
            self.cg:setScale(0.7)
            self.bg:setScale(0.7)
        elseif self.type == 8 then --4号位置碰杠的牌
            self.cg:setPosition(cc.p(-6, 6))
            self.cg:setScale(0.7)
            self.bg:setScale(0.7)
        elseif self.type == 10 then --2号位置出的牌
            self.cg:setPosition(cc.p(8, 10))
        elseif self.type == 12 then --4号位置出的牌
            self.cg:setPosition(cc.p(-8, 10))
        elseif self.type == 7 or self.type == 11 then --3号位置碰杠出的牌
            self.cg:setPosition(cc.p(0, 16))
        elseif self.type == 17 or self.type == 19 then
            self.cg:setPosition(cc.p(0, 16))        
        elseif self.type == 18 or self.type == 20 then
            self.cg:setPosition(cc.p(0, 14))
        elseif self.type == 21 then
            self.cg:setPosition(cc.p(0,-15))
            -- self.cg:setScale(0.5)
            self.bg:setScale(0.5)
        elseif self.type == 25 then
            self.cg:setScale(0.5)
        elseif self.type == 29 then
            self.cg:setScale(0.5)
            self.bg:setScale(0.5)
        end
        self:updateForLaiZi()
    end
end

function MahjongTile:updateForLaiZi()
    local function setTagImg(bigImgName, smallImgName)
        if self.type == 1 or (self.type > 4 and self.type < 13) or self.type > 16 then
            if self.type == 1 then
                self.wangImg = display.newSprite(bigImgName, 85, 117):addTo(self.cg, 0)
            elseif self.type == 29 then
                self.wangImg = display.newSprite(bigImgName, 87, 120):addTo(self.cg, 0)
                self.wangImg:setScale(0.9)
            -- elseif self.type == 21 then
            --     self.wangImg = display.newSprite(bigImgName, 54, 68):addTo(self.cg, 0)
            --     self.wangImg:setScale(0.9)
            elseif self.type%4 == 1 or self.type%4 == 3 then
                self.wangImg = display.newSprite(smallImgName, 40, 61):addTo(self.cg, 0)
            elseif self.type%4 == 2 or self.type%4 == 0 then
                self.wangImg = display.newSprite(smallImgName, 36, 66):addTo(self.cg, 0)
            -- elseif self.type%4 == 3 then
            --     self.wangImg = display.newSprite(smallImgName, -13, -7):addTo(self, 2)
            --     self.wangImg:setRotation(180)
            --     self.wangImg:setScale(0.5)
            end
        end
    end

    if UserData.laiziCardId and UserData.laiziCardId == self.id then
        -- setTagImg("mj/mylaizi.png", "mj/laizi.png")
        setTagImg("mj/mywang.png", "mj/wang.png")
    end

    -- if UserData.chaotianCardId and UserData.chaotianCardId == self.id then
    --     setTagImg("mj/mychaotian.png", "mj/chaotian.png")
    -- end
end

function MahjongTile:setMask(enable)

    if self.type ~= 1 then return end

    local name = "mj_mask"
    self:removeChildByName(name)

    if enable then

        local posX,posY = self.bg:getPosition()
        display.newSprite("mj/ban_mask_big.png",0,0):setName(name):addTo(self,1000)
                                           
   end
end

function MahjongTile:containsPoint(x, y)
    local point = self:convertToNodeSpace(cc.p(x, y))
    -- return cc.rectContainsPoint(self.bg:getBoundingBox(), point)
    local box = self.bg:getBoundingBox()
    return cc.rectContainsPoint(cc.rect(box.x, box.y - 50, box.width, box.height + 50), point)
end

function MahjongTile:setMyScale(scale)
    local scale_old = self.cg:getScale()
    -- self.cg:setScale(scale * scale_old * 0.95)
    self.cg:setScale(scale * scale_old)
    scale_old = self.bg:getScale()
    self.bg:setScale(scale * scale_old)
end

function MahjongTile:get_id()
    return self.id
end

function MahjongTile:get_sort_id()
    --癞子牌排在最左边
    if UserData.laiziCardId and UserData.laiziCardId == self.id then
        return 0
    end
    
    if self.is_free then
        lid = self.id % 10
        return lid
    else
        return self.id
    end
end

function MahjongTile:fadeInAction(delayTime)
    if self.bg then
        self.bg:setOpacity(0)
        self.bg:runAction(cc.FadeIn:create(delayTime))
    end
    if self.cg then
        self.cg:setOpacity(0)
        self.cg:runAction(cc.FadeIn:create(delayTime))
    end
    if self.laiziImg then
        self.laiziImg:setOpacity(0)
        self.laiziImg:runAction(cc.FadeIn:create(delayTime))
    end
end

function MahjongTile:fadeOutAction(delayTime)
    if self.bg then
        self.bg:setOpacity(100)
        self.bg:runAction(cc.FadeOut:create(delayTime))
    end
    if self.cg then
        self.cg:setOpacity(100)
        self.cg:runAction(cc.FadeOut:create(delayTime))
    end
    if self.laiziImg then
        self.laiziImg:setOpacity(100)
        self.laiziImg:runAction(cc.FadeOut:create(delayTime))
    end
end

--玩家选定一张牌，场上相同的牌有特殊标记
function MahjongTile:setSameCardTag()
    self.bg:setColor(cc.c3b(255, 255, 0))
end

function MahjongTile:clearSameCardTag()
    self.bg:setColor(cc.c3b(255, 255, 255))
end

function MahjongTile:onExit()
    self:stopAllActions()
end

--加听牌三角
function MahjongTile:setTingIcon(show, isBest)
    if(not self.m_tingTip)then
        self.m_tingTip = display.newSprite("mj/tip_icon.png"):addTo(self,1600)
        self.m_tingTip:setPosition(cc.p(0,80))
    end
    if isBest then
        self.m_tingTip:setTexture("mj/tip_icon_best.png")
        self.m_tingTip:setPosition(cc.p(0,100))
    else
        self.m_tingTip:setTexture("mj/tip_icon.png")
        self.m_tingTip:setPosition(cc.p(0,80))
    end
    self.m_tingTip:setVisible(show)
end

return MahjongTile