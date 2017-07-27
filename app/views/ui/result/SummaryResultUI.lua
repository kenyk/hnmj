-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成



-- endregion

local SummaryResultUI = class("SummaryResultUI", cc.load("mvc").UIBase)
local AnimationView = require("utils.extends.AnimationView")
SummaryResultUI.RESOURCE_FILENAME = "uiResult/UI_Summary_Result.csb"

local uiname = consts.UI.SummaryResultItemReportUI;
local uiRoot = require(uiname);
local uiGameInfo = require(consts.UI.GameInfoUI);
local uiWidth = 255;    

function SummaryResultUI:onCreate()
    self.btnShare = helper.findNodeByName(self.resourceNode_, "btnShare")
    self.btnShare:setPressedActionEnabled(true)
    self.btnShare:setVisible(not Is_App_Store)
    self.txRoomNum = helper.findNodeByName(self.resourceNode_, "txRoomNum")
    self.txRule = helper.findNodeByName(self.resourceNode_, "txRule")
    self.txTime = helper.findNodeByName(self.resourceNode_, "txTime")
    self.btnBack = helper.findNodeByName(self.resourceNode_, "btnBack")
    self.btnBack:setPressedActionEnabled(true)
    self.image3 = helper.findNodeByName(self.resourceNode_, "Image_3")
    local gameInfo = uiGameInfo:create()
    gameInfo:addTo(self.image3, 0)
    gameInfo:setAnchorPoint(cc.p(0,0))
    gameInfo:setPosition(cc.p(76, 24));
    --gameInfo:setVisible(false)
    self:updateSummaryUI()
    helper.updateGameCard()
    self.isCanshare = true
    helper.findNodeByName(self.resourceNode_,"Image_3"):loadTexture("mj/"..UserData:getCurBgType().."/result_bg.jpg")

    --俱乐部
    local clubData = UserData.table_config.rule.clubData
    local node_club = helper.findNodeByName(self.resourceNode_,"node_club")
    node_club:setVisible(clubData ~= nil)
    if clubData then
        local richTextU = string.format("<div fontcolor=#ee531d >%s</div><div fontSize=22 fontcolor=#c5b6a1>的俱乐部</div>",clubData.clubName)
        local clubTipU = helper.createRichLabel({maxWidth = 300,fontSize = 22,fontColor = cc.c3b(65, 135, 67)})
        clubTipU:setAnchorPoint(cc.p(0,1))
        clubTipU:setPosition(cc.p(40,30)):addTo(node_club,100)
        clubTipU:setString(richTextU)
        helper.findNodeByName(node_club,"Text_jewel_num"):setString(tostring(clubData.jewelNum))
        if 1 == UserData.table_config.rule.roomData[1][2] then
            helper.findNodeByName(node_club,"Text_jewel_num"):setString(tostring(clubData.jewelNum * 2))
        end
    end 
end

function SummaryResultUI:onShare(event)
     --UIMgr:showLoadingDialog("处理中...")
     if self.isCanshare then
        self.isCanshare = false
        print("onShareonShareonShare")
        cc.utils:captureScreen(handler(self,self.captureScreenCallback),"shareImage.jpg")
     end
     performWithDelay(self,function()
        self.isCanshare = true
    end,3)
end

function SummaryResultUI:captureScreenCallback(isSuccess,imagePath)
    if isSuccess then
        --成功
        print("成功....",consts.App.APP_FILE_PATH)
        print("成功",imagePath)
        local args = {title="么么麻将",desc="么么湖南麻将，大家一起来玩耍吧！",webUrl="",imageUrl=imagePath}
        LuaCallPlatformFun.share(args)
    else
        --失败
        local dialogContentLabel1 = cc.LabelTTF:create("分享失败,请稍后重试" , "Arial", 28)
        dialogContentLabel1:setPosition(cc.p(display.width/2-140, 400))
        dialogContentLabel1:setColor(cc.c3b(153, 78, 46))
        dialogContentLabel1:setAnchorPoint(cc.p(0,0.5))
        local dialogContent =cc.Layer:create()
        dialogContentLabel1:addTo(dialogContent,1)
	    UIMgr:showConfirmDialog("提示",{child=dialogContent,height=320},function() 

        end,nil)
    end
    UIMgr:closeUI(consts.UI.LoadingDialogUI)
end

function SummaryResultUI:onBack(event)
    if(not Is_App_Store)then
        GnetMgr:closeConnect()
    end
    self:close()
    MyApp:goToMain()
end

--.player_balance_result {
--  uid 0 : integer
--  ziMo 1 : integer
--  jiePao 2 : integer
--  dianPao 3 : integer
--  anGang 4 : integer
--  mingGang 5 : integer
--  suoGang 6 : integer
--  point 7 : integer
--}
function SummaryResultUI:updateSummaryUI()
    dump(UserData.game_balance_result)
    local entity  = nil
    if UserData.game_balance_result  == nil then return end
        
    if UserData:isZhuanZhuan() or UserData:isChenZhou() or UserData:isHongZhong() or UserData:isChangDe() then
        entity = UserData.game_balance_result.player_result
    elseif UserData:isChangSha() or UserData:isNingXiang() then
        entity = UserData.game_balance_result.player_changsha_result
    else
        return
    end

    --红包
    if(not Is_App_Store and Is_Open_Hongbao)then
        local uidLs = ""
        self.m_uidLs = {}
        for i=1,#entity do
            local parse = (i == #entity) and "" or "-"
            uidLs = uidLs..entity[i].uid..parse
            table.insert(self.m_uidLs,entity[i].uid)
        end
        self:requestGetMoney(uidLs)
    end

    local maxPoint 
    self.uiList = {}
    for i = 1, #entity do
        if i == 1 then
           maxPoint = entity[i].point; 
        else
           maxPoint = math.max(maxPoint,entity[i].point)
        end
        table.insert(self.uiList,self:updateLayerInfo(i, entity[i]))
    end

    -- entity = {{},{},{},{}}

    -- self.uiList = {}
    -- for i = 1, 2 do
    --     -- if i == 1 then
    --     --    maxPoint = entity[i].point; 
    --     -- else
    --     --    maxPoint = math.max(maxPoint,entity[i].point)
    --     -- end
    --     table.insert(self.uiList,self:updateLayerInfo(i, entity[i]))
    -- end
    
    self:updateWinnerFlag(maxPoint)
    self:updatePaoShouFlag()
end

-- 1）转转麻将
-- 分数都为0，没有大赢家
-- 分数最高的是大赢家，
-- 分数相同，糊牌次数（自摸+接炮）最多的为大赢家，
-- 糊牌次数也相同，则都为大赢家
-- 2）长沙麻将
--1、本轮中，总成绩最高的玩家，会显示【大赢家】标识；
--2、如有多个玩家同分且分数最高，则均显示【大赢家】标识；
--3、如所有玩家分数都为0时，则不会显示【大赢家】标识；
function SummaryResultUI:updateWinnerFlag(maxPoint)
    if not UserData.game_balance_result then return end
    local maxPointIndexList = {}
    local entity = nil
    if UserData:isZhuanZhuan() or UserData:isChenZhou() or UserData:isHongZhong() or UserData:isChangDe() then
        entity = UserData.game_balance_result.player_result
    elseif UserData:isChangSha() or UserData:isNingXiang() then
        entity = UserData.game_balance_result.player_changsha_result
    else
        return
    end

    local winner = UserData.game_balance_result.win
    for i = 1, #entity do

        self.uiList[i].sFlagWinner:setVisible(entity[i].uid == winner)

    end

    --分数都为0，没有大赢家
   if(maxPoint == 0) then
       for i = 1, #entity do
           self.uiList[i].sFlagWinner:setVisible(false)
       end
       return
   end

   for k,v in ipairs(maxPointIndexList) do
       self.uiList[v].sFlagWinner:setVisible(true)
   end

end

-- 最佳炮手标识
-- 1、本轮中点炮次数最多的玩家，会显示【最佳炮手】标识；
-- 2、如多个玩家点炮次数相同，则同时显示该标识（仅计算点炮总次数，不区分大、小胡点炮）；
-- 3、如本轮中无人点炮，则不会显示【最佳炮手】标识；
function SummaryResultUI:updatePaoShouFlag()

    print("设置最佳炮手标识")
    local entity = nil
    if UserData:isZhuanZhuan() or UserData:isChenZhou() or UserData:isHongZhong() or UserData:isChangDe() then
        entity = UserData.game_balance_result.player_result
    elseif UserData:isChangSha() or UserData:isNingXiang() then
        entity = UserData.game_balance_result.player_changsha_result
    else
        return
    end

    local maxDianPao = 0  
    local dianPaoList = {}  

    for i = 1, #entity do
        if UserData:isChangSha() or UserData:isNingXiang() then
            table.insert(dianPaoList,entity[i].dahudianpao + entity[i].xiaohudianpao)
        else
            table.insert(dianPaoList,entity[i].dianPao)
        end
        --找最大
        if dianPaoList[i] > maxDianPao then
            maxDianPao = dianPaoList[i]
        end
    end

    if maxDianPao > 0 then
        for i = 1, #entity do
            self.uiList[i].sFlagPaoShou:setVisible(dianPaoList[i] == maxDianPao)
        end
    end
end

function SummaryResultUI:updateLayerInfo(i, entity)
    local count = 0
    if (UserData:isZhuanZhuan() or UserData:isChangDe()) and  UserData.game_balance_result.player_result then
        count = #UserData.game_balance_result.player_result
    elseif (UserData:isChenZhou() or UserData:isHongZhong()) and  UserData.game_balance_result.player_result then
        count = #UserData.game_balance_result.player_result
    elseif UserData:isChangSha() or UserData:isNingXiang() and UserData.game_balance_result.player_changsha_result then
        count = #UserData.game_balance_result.player_changsha_result
    end
    local ui = uiRoot:create(uiname);
    local dividerWidth =( consts.Size.width - count * uiWidth) / (count + 1)
    dividerWidth = dividerWidth-5
    local playerInfo = UserData:getPlayerInfoById(entity.uid)
    ui:addTo(self, 0);
    ui:setAnchorPoint(cc.p(.0, .0))
    -- ui:setPosition(cc.p(dividerWidth+12 +(i - 1) *(uiWidth + dividerWidth), 132));
    ui:setPosition(cc.p(dividerWidth+12 +(i - 1) *(uiWidth + dividerWidth), 147));
    ui.txPlayerName:setString(playerInfo.nickname);
    if  UserData:isRoomMaster(entity.uid) then
        ui.sFlagRoomHost:setVisible(true)
        ui.sFlagRoomHost:setZOrder(10)
    else
        ui.sFlagRoomHost:setVisible(false)
    end
    if(Is_App_Store)then
        local image = display.newSprite("uires/main/guest_icon_1.png", 1, 19)
        image:setPosition(cc.p(50,47))
        image:setScale(1.42)
        image:addTo(ui.iPlayerAvatar)
    elseif  playerInfo and playerInfo.image_url then
        local image = NetSprite:getSpriteUrl(playerInfo.image_url,"mj/bg_default_avatar_1.png")
        image:setPosition(cc.p(50,47))
        image:setImageContentSize(cc.size(100,100))
        image:addTo(ui.iPlayerAvatar)
    end
    if (UserData:isZhuanZhuan() or UserData:isChangDe()) and  UserData.game_balance_result.player_result then
        ui.txZiMoCount:setString("自摸次数:   " .. entity.ziMo);
        ui.txJiePaoCount:setString("接炮次数:   " .. entity.jiePao);
        ui.txDianPaoCount:setString("点炮次数:   " .. entity.dianPao);
        ui.txAnGangCount:setString("暗杠条数:   " .. entity.anGang);
        ui.txMingGangCount:setString("明杠条数:   " .. (entity.mingGang + entity.suoGang));
    elseif (UserData:isHongZhong() or UserData:isChenZhou()) and  UserData.game_balance_result.player_result then
        ui.txZiMoCount:setString("自摸次数:   " .. entity.ziMo);
        ui.txJiePaoCount:setString("接炮次数:   " .. entity.jiePao);
        ui.txDianPaoCount:setString("点炮次数:   " .. entity.dianPao);
        ui.txAnGangCount:setString("暗杠条数:   " .. entity.anGang);
        ui.txMingGangCount:setString("明杠条数:   " .. (entity.mingGang + entity.suoGang));
    elseif (UserData:isChangSha() or UserData:isNingXiang()) and UserData.game_balance_result.player_changsha_result then
        ui.txDZiMoCount:setString("大胡自摸:   " .. entity.dahuzimo);
        ui.txXZiMoCount:setString("小胡自摸:   " .. entity.xiaohuzimo);
        ui.txDDianPaoCount:setString("大胡点炮:   " .. entity.dahudianpao);
        ui.txXDianPaoCount:setString("小胡点炮:   " .. entity.xiaohudianpao);
        ui.txDJiePaoCount:setString("大胡接炮:   " .. entity.dahujiepao);
        ui.txXJiePaoCount:setString("小胡接炮:   " .. (entity.xiaohujiepao));
    end
    ui.txPlayerAccount:setString("账号:" .. entity.uid);
    ui.txScores:setString(( string.gsub(tostring(entity.point),"-" ,"/") ))
    return ui
end


-- function SummaryResultUI:updateLayerInfo(i, entity)
--     local count = 0
--     if (UserData:isZhuanZhuan() or UserData:isChangDe()) and  UserData.game_balance_result.player_result then
--         count = #UserData.game_balance_result.player_result
--     elseif (UserData:isChenZhou() or UserData:isHongZhong()) and  UserData.game_balance_result.player_result then
--         count = #UserData.game_balance_result.player_result
--     elseif UserData:isChangSha() or UserData:isNingXiang() and UserData.game_balance_result.player_changsha_result then
--         count = #UserData.game_balance_result.player_changsha_result
--     end
--     count = 2
--     local ui = uiRoot:create(uiname);
--     local dividerWidth =( consts.Size.width - count * uiWidth) / (count + 1)
--     dividerWidth =( 1202 - 57*2- count * uiWidth) / (count + 1)
--     --dividerWidth = dividerWidth-5
--     --local playerInfo = UserData:getPlayerInfoById(entity.uid)
--     --ui:addTo(self, 0);
--     ui:addTo(self.image3, 0);
--     ui:setAnchorPoint(cc.p(.0, .0))
--     ui:ignoreAnchorPointForPosition(false)
--     ui:setPosition(cc.p(dividerWidth+57 +(i - 1) *(uiWidth + dividerWidth), 144));
--     print("liujialin ---- dividerWidth is"..dividerWidth)
--     --ui.txPlayerName:setString(playerInfo.nickname);
--     if  UserData:isRoomMaster(entity.uid) then
--         ui.sFlagRoomHost:setVisible(true)
--         ui.sFlagRoomHost:setZOrder(10)
--     else
--         ui.sFlagRoomHost:setVisible(false)
--     end
--     -- if(Is_App_Store)then
--     --     local image = display.newSprite("uires/main/guest_icon_1.png", 1, 19)
--     --     image:setPosition(cc.p(50,47))
--     --     image:setScale(1.42)
--     --     image:addTo(ui.iPlayerAvatar)
--     -- elseif  playerInfo and playerInfo.image_url then
--     --     local image = NetSprite:getSpriteUrl(playerInfo.image_url,"mj/bg_default_avatar_1.png")
--     --     image:setPosition(cc.p(50,47))
--     --     image:setImageContentSize(cc.size(100,100))
--     --     image:addTo(ui.iPlayerAvatar)
--     -- end
--     if (UserData:isZhuanZhuan() or UserData:isChangDe()) and  UserData.game_balance_result.player_result then
--         ui.txZiMoCount:setString("自摸次数:   " .. entity.ziMo);
--         ui.txJiePaoCount:setString("接炮次数:   " .. entity.jiePao);
--         ui.txDianPaoCount:setString("点炮次数:   " .. entity.dianPao);
--         ui.txAnGangCount:setString("暗杠条数:   " .. entity.anGang);
--         ui.txMingGangCount:setString("明杠条数:   " .. (entity.mingGang + entity.suoGang));
--     elseif (UserData:isHongZhong() or UserData:isChenZhou()) and  UserData.game_balance_result.player_result then
--         ui.txZiMoCount:setString("自摸次数:   " .. entity.ziMo);
--         ui.txJiePaoCount:setString("接炮次数:   " .. entity.jiePao);
--         ui.txDianPaoCount:setString("点炮次数:   " .. entity.dianPao);
--         ui.txAnGangCount:setString("暗杠条数:   " .. entity.anGang);
--         ui.txMingGangCount:setString("明杠条数:   " .. (entity.mingGang + entity.suoGang));
--     elseif (UserData:isChangSha() or UserData:isNingXiang()) and UserData.game_balance_result.player_changsha_result then
--         ui.txDZiMoCount:setString("大胡自摸:   " .. entity.dahuzimo);
--         ui.txXZiMoCount:setString("小胡自摸:   " .. entity.xiaohuzimo);
--         ui.txDDianPaoCount:setString("大胡点炮:   " .. entity.dahudianpao);
--         ui.txXDianPaoCount:setString("小胡点炮:   " .. entity.xiaohudianpao);
--         ui.txDJiePaoCount:setString("大胡接炮:   " .. entity.dahujiepao);
--         ui.txXJiePaoCount:setString("小胡接炮:   " .. (entity.xiaohujiepao));
--     end
--     print(ui)
--     --ui.txDZiMoCount:setString("大胡自摸:   " .. 2);
--         --ui.txXZiMoCount:setString("小胡自摸:   " .. 2);
--         --ui.txDDianPaoCount:setString("大胡点炮:   " );
--         --ui.txXDianPaoCount:setString("小胡点炮:   " .. 2);
--         --ui.txDJiePaoCount:setString("大胡接炮:   " .. 2);
--         --ui.txXJiePaoCount:setString("小胡接炮:   " .. 2);
--     --ui.txPlayerAccount:setString("账号:" .. entity.uid);
--     --ui.txScores:setString(( string.gsub(tostring(entity.point),"-" ,"/") ))
--     return ui
-- end

--请求结算红包金额
function SummaryResultUI:requestGetMoney(uidLs)
    HttpServiers:queryRedpackGetMoney({
        userIds = uidLs,
        roomId = UserData.roomId,
        },
    function(entity,response,statusCode)
        if response and (response.status == 1 and response.errCode == 0) then
            self:updateHongbao(response.data)
        end
    end)
end

function SummaryResultUI:updateHongbao(data)
    local getNum = function ( uid )
        for i=1,#data do
            if(data[i].userId == tostring(uid))then
                return data[i].money or 0
            end
        end
        return 0
    end

    for i=1,#self.uiList do
        local num = getNum(self.m_uidLs[i])
        self.uiList[i].hongbao_node:setVisible(tonumber(num) > 0)
        self.uiList[i].hb_num:setString(( string.gsub(tostring(num),'%.' ,"/") ))

        if(tonumber(num) > 0)then
            local an = AnimationView:create("hongbao","action/hongbao/hongbaoget.csb")
            an:gotoFrameAndPlay(0,false)
            an:addTo(self.uiList[i].hb_act_node,1)

            performWithDelay(self,function (  )
                self.uiList[i].money_node:setVisible(true)
            end,.71)
        end
    end
end

return SummaryResultUI