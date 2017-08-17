
-- 单局结束

local CardResultUI = class("CardResultUI",cc.load("mvc").UIBase)
local roomId
local mjScale = 1
local mjWidth = 47
local TSpace = "   "
local chenzhouGoldBird

local MahjongTile = import("...mj.MahjongTile")

CardResultUI.RESOURCE_FILENAME = "uiResult/UI_Card_Result.csb"
CardResultUI.RESOURCE_MODELNAME = "app.views.ui.result.CardResultModel"

local uiGameInfo = require(consts.UI.GameInfoUI);

function CardResultUI:onCreate()

    self.font = "Arial"
    --self.title = helper.findNodeByName(self.resourceNode_,"title")
    self.title_text = helper.findNodeByName(self.resourceNode_,"title_text")
    if self:isHu() then
        if self:isHu_Chairs(UserData.myChairId) then
            -- self:changeTitle("mj/result_win.png")
            self:changeTitle("uires/result.png")
            -- self.title:loadTexture("mj/titleBg_1.png")
            --self.title:loadTexture("uires/createRoom/tab.png")
        else
            self:changeTitle("mj/result_lose.png")
            --self.title:loadTexture("mj/titleBg_2.png")
        end
    else
        self:changeTitle("mj/result_flow.png")
        --self.title:loadTexture("mj/titleBg_2.png")
    end
    self.btn_start = helper.findNodeByName(self.resourceNode_,"btn_start")
    self.btn_start:setPressedActionEnabled(true)
    self.sBg = helper.findNodeByName(self.resourceNode_,"sBg")
    self.layout_zhuoniao = helper.findNodeByName(self.resourceNode_,"layout_zhuoniao")
    self.Image_3 = helper.findNodeByName(self.resourceNode_,"Image_3")
    -- self.bottemFrame = helper.findNodeByName(self.resourceNode_,"Image_bottem")
    -- self.coverBg = helper.findNodeByName(self.resourceNode_,"Image_cover_bg")
    -- self.bottemCover = helper.findNodeByName(self.resourceNode_,"Image_cover")
    if UserData.cardResult ~= nil then
      if not self:isTableEmpty(UserData.cardResult.birdCard) then
          self.bridCount = self:createZhuoniao(UserData.cardResult.birdCard);
      end
      self:createPlay(UserData.cardResult)
      self.start_text = helper.findNodeByName(self.resourceNode_,"image_start")
      if UserData.table_config~= nil then
         if self:isBalanceResult() then
            self.start_text:loadTexture("mj/result_balance.png",0)
         end
      end
    end
    --helper.findNodeByName(self.resourceNode_,"Image_3"):loadTexture("mj/"..UserData:getCurBgType().."/result_bg.jpg")

    local gameInfo = uiGameInfo:create();
    -- gameInfo:setPosition(cc.p(-5, self.layout_zhuoniao:getPositionY() - 30))
    -- gameInfo:addTo(self, 0)

    gameInfo:setPosition(cc.p(78, 24))
    gameInfo:ignoreAnchorPointForPosition(false)
    gameInfo:setAnchorPoint(cc.p(0,0))
    gameInfo:addTo(self.Image_3, 0)

    -- print("上传ping", UserData.canUploadPing)
    -- if UserData.canUploadPing then
    --     local log = ""
    --     for i, v in ipairs(UserData.averPingTbl) do
    --         log = log..v
    --         if i ~= #UserData.averPingTbl then
    --             log = log.."-"
    --         end
    --     end

    --     HttpServiers:pingValue({pingLog = log}, function(data, response, statusCode)
    --             if data then
    --                 UserData.canUploadPing = data.continue
    --             end
    --         end)
    --     UserData.averPingTbl = {}
    -- end
end

--继续开始
function CardResultUI:onClickStart(event)
--    UIMgr:openUI(consts.UI.login)
    if UserData.table_config~= nil then
        if self:isBalanceResult() then
            --总结算
            UIMgr:openUI(consts.UI.SummaryResultUI)
        else
            --继续
            UserData:setGameStatus(UserData.GAME_STATUS.nextWaiting)
            self:send("room_get_ready")
        end
    end
    self:close()
end

--服务器数据收集处理
function CardResultUI:proListHandler(msg)
    --暂时没有回调
    -- if msg.name == "login_login_by_account" then
    --     DataModel.game_state.me = msg.args.userid
    --     self:into_mj({enter_code = "1283899"})
    -- end
end

--是否胡了
function CardResultUI:isHu_Chairs(chairs_id)
    if UserData.cardResult ~=nil then
        if UserData.cardResult.hu_chairs ~=nil then
        local hucount = #UserData.cardResult.hu_chairs
            for i=1,hucount do
                if UserData.cardResult.hu_chairs[i]==chairs_id then
                    return true
                end
            end
        end
    end

    return false
end

function CardResultUI:isHu()
    if UserData.cardResult ~=nil then
        if not self:isTableEmpty(UserData.cardResult.hu_chairs) then
            return true
        end
    end

    return false
end

--设置标题
function CardResultUI:changeTitle(img)
    self.title_text:loadTexture(img,0)
end

--创建玩家数据
function CardResultUI:createPlay(cardResult)
    local plays = nil
    if not cardResult then return end
    if( UserData:isZhuanZhuan() or UserData:isChangDe()) and cardResult.player_balance then
        plays = cardResult.player_balance
    elseif UserData:isChangSha() and cardResult.changsha_player_balance then
        plays = cardResult.changsha_player_balance
    elseif UserData:isNingXiang() and cardResult.ningxiang_player_balance then
        plays = cardResult.ningxiang_player_balance
    elseif UserData:isChenZhou() and cardResult.player_balance then
        plays = cardResult.player_balance
    elseif UserData:isHongZhong() and cardResult.player_balance then
        plays = cardResult.player_balance
    else
        return
    end
    local sBgHeight = self.sBg:getContentSize().height
    print("sBgHeight=" .. sBgHeight)
    local count = #plays
    local itemHeight = sBgHeight / count
    print("itemHeight=" .. itemHeight)
    local itemYBottom
    local itemCenterY
    --local y = 557-30;
    local space = 50;
    local offsetY = 5
    for i = 1, count do
        local x = 110
        itemYBottom = sBgHeight - i * itemHeight
        print("itemYBottom=" .. itemYBottom)
        itemCenterY = itemYBottom + itemHeight / 2 - 15
        print("itemCenterY=" .. itemCenterY)
        --玩家名
        local play= cc.LabelTTF:create(self:getPlayName(i), self.font, 30):addTo(self.sBg,1)
        play:setPosition(cc.p(80, offsetY + itemCenterY + self:getScaleSize(space)))
        play:setAnchorPoint(cc.p(0,0.5))
        play:setColor(helper.str2Color("#5f2b01"))
        if self:isBanker(i) then
            --庄家图标
            local zhuang = display.newSprite("mj/icon_self_zhuang.png", 0, 0):addTo(self.sBg, 1)
            zhuang:setPosition(cc.p(15,offsetY + itemCenterY + self:getScaleSize(space)-5))
            zhuang:setAnchorPoint(cc.p(0,0.5))            
        end
        --当前玩家
        if i == UserData.myChairId then
            play:setColor(helper.str2Color("#5f2b01"))
        end
        --玩家胡牌描述
        local playOthertype= cc.LabelTTF:create(self:getHuDescriStr(plays[i],i), self.font, 30):addTo(self.sBg,1)
        playOthertype:setPosition(cc.p(x+200+10, offsetY + itemCenterY+ self:getScaleSize(space)))
        playOthertype:setAnchorPoint(cc.p(0,0.5))
        playOthertype:setColor(helper.str2Color("#5f2b01"))
     
       
        --麻将
        local jtiles = json.decode(plays[i].handCard)
        if jtiles ~=nil then
            --if UserData:isLaizi() then
                self:laiziSort(jtiles)
            --end
            local handcardcount = #jtiles
            for j=1,handcardcount do
                local tilescount = #jtiles[j]
                --if j==handcardcount then
                    --self:sort(jtiles[j])
                --end
                for k=1,tilescount do
                    local free = false
                    local mj = MahjongTile.new({id =(jtiles[j])[k], type = 9, is_free = free,is_dfree = true}):addTo(self.sBg, 1)
                    mj:setPosition(cc.p(x-10, itemCenterY))
                    mj:setMyScale(mjScale)
                    if (jtiles[j])[k]==45 and UserData:isLaizi() then
                     local laiziImg = display.newSprite("mj/laizi.png"):addTo(mj, 0)
                     laiziImg:setPosition(cc.p(15, 25))
                    end
                    x = x+(mjScale*mjWidth)
                end
                x = x+20
            end
        end

        local huCards = {}
        if type(plays[i].huCard) == "number" then
            if plays[i].huCard > 0 then
               table.insert(huCards,plays[i].huCard)
            end
        elseif type(plays[i].huCard) == "table" then
           table.merge(huCards, plays[i].huCard)
        end

        --胡牌
        for i = 1,#huCards do
            local mj = MahjongTile.new({id =huCards[i], type = 9, is_free = false,is_hu = false,is_dfree = true}):addTo(self.sBg, 1)
            mj:setPosition(cc.p(x-10, itemCenterY))
            mj:setMyScale(mjScale)
            x = x+(mjScale*mjWidth)*i
            local huImg = display.newSprite("mj/hu.png"):addTo(mj.cg, 0)
            huImg:setPosition(cc.p(40, 60))
        end

        --x=x+150
    --积分
        --local f7= cc.LabelTTF:create(plays[i].fang, self.font, 30):addTo(self.sBg,1)
        --f7:setPosition(cc.p(x, y))
        --x=x+100
        --积分
        UserData:setPlayerPoint(i,plays[i].point)
        local point = self:calculatePoint(plays[i])
        local c7= cc.LabelTTF:create(point, self.font, 30):addTo(self.sBg,1)
        c7:setColor(helper.str2Color("#c01322"))
        c7:setPosition(cc.p(950-30, itemCenterY))

        --胡图标
        if UserData.cardResult.hu_chairs ~=nil then
            for h=1,#UserData.cardResult.hu_chairs do
                if UserData.cardResult.hu_chairs[h]==i then
                    local hu = display.newSprite("mj/battle_hu.png", 0, 0):addTo(self.sBg, 1)
                    local scaleold = hu:getScale()
                    hu:setScale(scaleold)
                    hu:setPosition(cc.p(1050-120,itemCenterY))
                    hu:setAnchorPoint(cc.p(0,0.5))
                end
            end
        end
        --画分隔线
        if i<count then
            local linel =display.newSprite("mj/result_line.png"):addTo(self.sBg, 1)
            linel:setPosition(cc.p(25-100,itemYBottom))
            linel:setAnchorPoint(cc.p(0,0.5))
        end
        --y = y-self:getScaleSize(space)
    end
end

--计算得分
function CardResultUI:calculatePoint(play)
    if not play then return end
    local point = 0    
    if UserData:isZhuanZhuan() or UserData:isChenZhou() or UserData:isHongZhong() or UserData:isChangDe() then
        point =  play.birdPoint+play.gangPoint+play.huPoint
    elseif UserData:isChangSha() or UserData:isNingXiang() then
        point = play.getpoint
    end 
    return point
end

--捉鸟
function CardResultUI:createZhuoniao(tiles)
    local birdCount = 0
    local count = #tiles
    local getbird =  UserData.cardResult.zhongbird
    local tzhouniao
    if UserData:isHongZhong() then
        tzhouniao= cc.LabelTTF:create("扎码", self.font, 30):addTo(self.layout_zhuoniao,1)
    else
        tzhouniao= cc.LabelTTF:create("捉鸟", self.font, 30):addTo(self.layout_zhuoniao,1)
    end
    tzhouniao:setAnchorPoint(cc.p(0,0.5))
    tzhouniao:setPosition(cc.p(5, 30))
    local x=95;
    local totalBirdCount = 0
    for i=1,count do
        if self:isGetBird(tiles[i], getbird) then
            totalBirdCount = totalBirdCount+1
        end
    end

    for i=1,count do
        local mode = tiles[i]%10
        local bird = false
        if self:isGetBird(tiles[i],getbird) then
             bird = true
             birdCount = birdCount+1
        end
        local free = false
        local mj
        chenzhouGoldBird = false
        if UserData:isChenZhou() and UserData.table_config.rule.goldbird and 0 == totalBirdCount then --满足郴州金鸟条件
            mj = MahjongTile.new({id=tiles[i], type = 21, is_free = free,is_bird = true,is_dfree = true}):addTo(self.layout_zhuoniao, 1)
            chenzhouGoldBird = true
        else
            mj = MahjongTile.new({id=tiles[i], type = 21, is_free = free,is_bird = bird,is_dfree = true}):addTo(self.layout_zhuoniao, 1)
        end
        mj:setPosition(cc.p(x, 30))
        mj:setMyScale(mjScale)
        if tiles[i]==45 and UserData:isLaizi() then
            local laiziImg = display.newSprite("mj/laizi.png"):addTo(mj, 0)
            laiziImg:setPosition(cc.p(15, 25))
        end
        x = x+(mjScale*mjWidth)
    end
    return birdCount
end

function CardResultUI:isGetBird(tile, getbird)
    if UserData.isZhuanZhuan() or UserData:isChenZhou() or UserData:isChangDe() or UserData:isHongZhong() then
        local mode = tile%10
        if (tile < 40 and ( mode ==1 or mode ==5 or mode ==9)) or (tile==45 and UserData:isLaizi()) then
            return true
        end
    -- elseif UserData:isHongZhong() then
    --     if nil == UserData.cardResult.zhongbird then return false end
    --     for _, id in pairs(UserData.cardResult.zhongbird) do
    --         if id == tile then
    --             return true
    --         end
    --     end
    --     return false
    elseif (UserData.isChangSha() or UserData:isNingXiang()) and getbird then
        for _k,v in pairs(getbird) do
            if tile == v then
                return true
            end
        end
    end
    return false
end

--缩放大小
function CardResultUI:getScaleSize(size)
    return mjScale*size
end

--排序
function CardResultUI:sort(jtiles)
    if jtiles ~= nil then
        for i = 1, #jtiles - 1 do
            for j = i + 1, #jtiles do
                local mj1 = jtiles[i]
                local mj2 = jtiles[j]
                if mj1 > mj2 then
                    jtiles[i] = mj2
                    jtiles[j] = mj1
                end
            end
        end
    end
end

--玩家名字
function CardResultUI:getPlayName(chair_id)
    if UserData.players~=nil then
        for i=1,#UserData.players do
            if UserData.players[i].chair_id==chair_id then
                return UserData.players[i].nickname
            end
        end
    end
    return "玩家"..chair_id
end

function CardResultUI:getHuDescriStr(play,i)
    local playOthertypeStr=""
    if UserData:isZhuanZhuan() then
        playOthertypeStr = self:getHutype(play.huType)..self:getGangType(play.gangType)..self:getBirdCount(i)
    elseif UserData:isChenZhou() then
        playOthertypeStr = self:getHutype(play.huType)..self:getGangType(play.gangType)..self:getBirdCount(i)
        if play.piaoPoint then
            playOthertypeStr = playOthertypeStr.."飘"..play.piaoPoint.."分"
        end
    elseif UserData:isHongZhong() or UserData:isChangDe() then
        local handCards = json.decode(play.handCard)
        local hasHongZhong = false
        for i=1,#handCards do
            for _, v in pairs(handCards[i]) do
                if 45 == tonumber(v) then
                    hasHongZhong = true
                    break
                end
            end
        end
        if play.huCard == 45 then
            hasHongZhong = true
        end
        
        local extraStr = ""
        if not hasHongZhong and play.huType ~= 0 and (UserData:isHongZhong() or UserData.table_config.rule.laizi) and 0 ~= UserData.table_config.rule.find_bird then
            extraStr = "无红中"..TSpace
        end
        if (UserData:isHongZhong() or UserData:isChangDe()) and 1 == UserData.table_config.rule.find_bird then
            extraStr = ""
        end
        playOthertypeStr = self:getHutype(play.huType)..self:getGangType(play.gangType)..extraStr..self:getBirdCount(i)
    elseif UserData:isChangSha() or UserData:isNingXiang() then
        local first_hu
        local hu_info
        if play.first_hu and play.first_hu ~= "" then
            first_hu = json.decode(play.first_hu)
        end
        if play.hu_info and play.hu_info ~= "" then
            hu_info = json.decode(play.hu_info)
        end
         -- 起手胡
        if first_hu then
            if first_hu.bigfour and #first_hu.bigfour > 0 then
                if #first_hu.bigfour == 1 then
                    playOthertypeStr = playOthertypeStr .. "四喜 "
                else
                    playOthertypeStr = playOthertypeStr .. "四喜X" .. #first_hu.bigfour .. " "
                end
                
            end
            if first_hu.lose_one_color then
                playOthertypeStr = playOthertypeStr .. "缺一色 "
            end
            if first_hu.banban then
                playOthertypeStr = playOthertypeStr .. "板板胡 "
            end
            if first_hu.liuliushun then
                playOthertypeStr = playOthertypeStr .. "六六顺 "
            end
        end

        -- 大胡
        if hu_info then
            if hu_info.tianhu then
                local num = hu_info.tianhu > 1 and "X"..tostring(hu_info.tianhu) or ""
                playOthertypeStr = playOthertypeStr .. "天胡 "..num
            end
            if hu_info.dihu then
                local num = hu_info.dihu > 1 and "X"..tostring(hu_info.dihu) or ""
                playOthertypeStr = playOthertypeStr .. "地胡 "..num
            end
            if hu_info.allask then
                local num = hu_info.allask > 1 and "X"..tostring(hu_info.allask) or ""
                playOthertypeStr = playOthertypeStr .. "全求人 "..num
            end
            if hu_info.pengpenghu then
                local num = hu_info.pengpenghu > 1 and "X"..tostring(hu_info.pengpenghu) or ""
                playOthertypeStr = playOthertypeStr .. "碰碰胡 "..num
            end
            if hu_info.jiangjianghu then
                local num = hu_info.jiangjianghu > 1 and "X"..tostring(hu_info.jiangjianghu) or ""
                playOthertypeStr = playOthertypeStr .. "将将胡 "..num
            end
            if hu_info.qingyise then
                local num = hu_info.qingyise > 1 and "X"..tostring(hu_info.qingyise) or ""
                playOthertypeStr = playOthertypeStr .. "清一色 "..num
            end
            if hu_info.haidilao then
                local num = hu_info.haidilao > 1 and "X"..tostring(hu_info.haidilao) or ""
                playOthertypeStr = playOthertypeStr .. "海底捞月 "..num
            end
            if hu_info.haidipao then
                local num = hu_info.haidipao > 1 and "X"..tostring(hu_info.haidipao) or ""
                playOthertypeStr = playOthertypeStr .. "海底炮 "..num
            end
            if hu_info.seven_hu then
                local num = hu_info.seven_hu > 1 and "X"..tostring(hu_info.seven_hu) or ""
                playOthertypeStr = playOthertypeStr .. "七小对 "..num
            end
            if hu_info.hao_seven_hu then
                local num = hu_info.hao_seven_hu > 1 and "X"..tostring(hu_info.hao_seven_hu) or ""
                playOthertypeStr = playOthertypeStr .. "豪华七小对 "..num
            end
            if hu_info.shuang_hao_seven_hu then
                local num = hu_info.shuang_hao_seven_hu > 1 and "X"..tostring(hu_info.shuang_hao_seven_hu) or ""
                playOthertypeStr = playOthertypeStr .. "双豪华七小对 "..num
            end
            if hu_info.ganghua then
                local num = hu_info.ganghua > 1 and "X"..tostring(hu_info.ganghua) or ""
                playOthertypeStr = playOthertypeStr .. "杠上开花 "..num
            end
            if hu_info.qiangganghu then
                local num = hu_info.qiangganghu > 1 and "X"..tostring(hu_info.qiangganghu) or ""
                playOthertypeStr = playOthertypeStr .. "抢杠胡 "..num
            end
            if hu_info.gangpao then
                local num = hu_info.gangpao > 1 and "X"..tostring(hu_info.gangpao) or ""
                playOthertypeStr = playOthertypeStr .. "杠上炮 "..num
            end
            if hu_info.baoting then
                local num = hu_info.baoting > 1 and "X"..tostring(hu_info.baoting) or ""
                playOthertypeStr = playOthertypeStr .. "报听 "..num
            end
            if hu_info.menqing then
                local num = hu_info.menqing > 1 and "X"..tostring(hu_info.menqing) or ""
                playOthertypeStr = playOthertypeStr .. "门清 "..num
            end
            if hu_info.nolaizihu then
                local num = hu_info.nolaizihu > 1 and "X"..tostring(hu_info.nolaizihu) or ""
                playOthertypeStr = playOthertypeStr .. "无王大胡 "..num
            end
        end
        playOthertypeStr = playOthertypeStr .. self:getHutype(play.huType) .." "
        if  play.getbird > 0 then
            playOthertypeStr = playOthertypeStr .. "中鸟X" .. play.getbird
        end
        print("playOthertypeStr" .. playOthertypeStr)
    end
    return playOthertypeStr
end

function CardResultUI:getHutype(hutype)
    if UserData:isZhuanZhuan() or UserData:isChenZhou() or UserData:isHongZhong() or UserData:isChangDe() then
        --#1:自摸、2:接炮、3:抢杠胡,4:放炮、5:被抢杠  0:没胡
        if hutype==1 then
            return "自摸胡"..TSpace
        elseif hutype==2 then
            return "接炮胡"..TSpace
        elseif hutype==3 then
            return "抢杠胡"..TSpace
        elseif hutype==4 then
            return "放炮"..TSpace
        elseif hutype==5 then
            return "被抢杠"..TSpace
        else
            return ""
        end
    elseif UserData:isChangSha() or UserData:isNingXiang() then
        --#胡的类型 （1自摸胡， 2 点炮， 3，接炮 4 大胡点炮 ， 大胡接炮）
        if hutype==1 then
            return "自摸胡"..TSpace
        elseif hutype==2 then
            return "点炮"..TSpace
        elseif hutype==3 then
            return "接炮"..TSpace 
        elseif hutype==4 then
            return "大胡点炮"..TSpace
        elseif hutype==5 then
            return "大胡接炮"..TSpace
        else
            return ""
        end 
    end
    return ""
end

function CardResultUI:getGangType(gangTypeStr)
--# {anGang:1,jieGang:1,fangGang:1,mingGang:1} json
--# 暗杠数    接杠数    放杠数     明杠数
    if gangTypeStr ~=nil then
       local gangType = json.decode(gangTypeStr)
       if gangType ~=nil then
          local anGang = ""
          local jieGang = ""
          local fangGang = ""
          local mingGang = ""
          if gangType.anGang~=nil and gangType.anGang>0 then
             anGang = "暗杠X"..gangType.anGang ..TSpace
          end
          if gangType.jieGang~=nil and gangType.jieGang>0 then
             jieGang = "接杠X"..gangType.jieGang..TSpace
          end
          if gangType.fangGang~=nil and gangType.fangGang>0 then
             fangGang = "放杠X"..gangType.fangGang..TSpace
          end
          if gangType.mingGang~=nil and gangType.mingGang>0 then
             mingGang = "明杠X"..gangType.mingGang..TSpace
          end
          return anGang..jieGang..fangGang..mingGang
       end
    end
    return ""
end

function CardResultUI:getBirdCount(chair_id)
    if chenzhouGoldBird then
        return "金鸟 "
    elseif UserData.cardResult.birdPlayer ~= nil and  UserData.cardResult.birdPlayer==chair_id then
        -- if UserData:isHongZhong() then
        --     return "中码X"..self.bridCount
        -- elseif UserData:isChangDe() then
        if UserData:isChangDe() or UserData:isHongZhong() then
            if 1 == #UserData.cardResult.birdCard then
                if 45 == UserData.cardResult.birdCard[1] then
                    return "中码X10"
                else
                    return "中码X"..(UserData.cardResult.birdCard[1] % 10)
                end
            else
                return "中码X"..self.bridCount
            end
        else
            return "中鸟X"..self.bridCount
        end
    end
    return ""
end

--庄
function CardResultUI:isBanker(chair_id)
    if UserData.cardResult.banker == chair_id then
       return true  
    end
    return false
end

--总结算
function CardResultUI:isBalanceResult()
    if UserData.table_config~= nil and UserData.cardResult~=nil then
        if UserData.table_config.game_count<=UserData.cardResult.game_index or UserData.roomDismiss then
            return true
        end
    end
    return false
end

--红中癞子最前面排序
function CardResultUI:laiziSort(listtiles)
    local listount = #listtiles
    local tilescount = #listtiles[listount]
    local newtiles = {}
    local zhongtiles = {}
    for i = 1,tilescount do
        if (listtiles[listount])[i]==45 then
            table.insert(zhongtiles,(listtiles[listount])[i])
        else
            table.insert(newtiles,(listtiles[listount])[i])
        end
    end
    self:sort(newtiles)
    if #zhongtiles>0 then
       for z=1,#zhongtiles do
           table.insert(newtiles,1,zhongtiles[z])
       end
    end
    listtiles[listount] = newtiles
end

function CardResultUI:isTableEmpty(lists)
   if lists~=nil and #lists>0 then
      return false
   end
   return true
end

return CardResultUI