--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

local RecordDetailItemUI = class("RecordDetailItemUI", cc.load("mvc").UIBase)

RecordDetailItemUI.RESOURCE_FILENAME = "uiRecord/UI_Record_Detail_Item1.csb"

function RecordDetailItemUI:onCreate()
	self.num = helper.findNodeByName(self.resourceNode_,"num")
    self.time = helper.findNodeByName(self.resourceNode_,"time")
    self.item_bg = helper.findNodeByName(self.resourceNode_,"item_bg")
    self.player1 = helper.findNodeByName(self.resourceNode_,"player1")
    self.player2 = helper.findNodeByName(self.resourceNode_,"player2")
    self.player3 = helper.findNodeByName(self.resourceNode_,"player3")
    self.player4 = helper.findNodeByName(self.resourceNode_,"player4")
    self.btn_check = helper.findNodeByName(self.resourceNode_,"btn_check")
    self.btn_check:setPressedActionEnabled(true)
    -- self.btn_check:setVisible(false)

    self.btn_share = helper.findNodeByName(self.resourceNode_,"btn_share")
    self.btn_share:setPressedActionEnabled(true)
end

function RecordDetailItemUI:setItemData(item,item_bg, allData)
    if item then
        self.num:setString(item.game_index)
        self.time:setString(os.date("%m-%d %H:%M",item.end_time))

        self:setItemColor(self.player1,item.chair_1_point or "0")
        self:setItemColor(self.player2,item.chair_2_point or "0")
        self:setItemColor(self.player3,item.chair_3_point or "0")
        self:setItemColor(self.player4,item.chair_4_point or "0")
    end

    for i=1,4 do
        self["player"..i]:setVisible(not (tonumber(item["chair_"..i.."_uid"]) == 0))
    end

    local bVisible = item_bg and true or false
    self.item_bg:setVisible(bVisible)

    self.btn_check:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                UserData.replayInfo = allData
                MyApp:goToReplayScene()
                -- dump2(allData)
                -- dump(allData)
                -- print(allData.shareCode)
            end
        end)

    self.btn_share:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                -- HttpServiers:queryResultShareDetail({
                -- shareCode = allData.shareCode},
                --     function(entity, response, statusCode)
                --         if entity  then
                --             -- print(entity)
                --             UserData.replayInfo = allData
                --             MyApp:goToReplayScene()
                --         end
                --     end)
                LuaCallPlatformFun.shareBattle(allData.shareCode)
                --test
                -- GMainUi:battleLook(allData.shareCode)
                -- GMainUi:battleLook(1275792)
            end
        end)

    --没数据
    self.cardInfo = json.decode(allData["game_action"])
    self.playerCard = json.decode(self.cardInfo.player_card)
    if 0 == #self.playerCard then
        self.btn_check:setVisible(false)
        self.btn_share:setVisible(false)
    end
end

function RecordDetailItemUI:setItemColor(texvview,point)
    texvview:setString(tostring(point))
    if tonumber(point)>0 then
        texvview:setTextColor(cc.c3b(244,78,51))
    else
        texvview:setTextColor(cc.c3b(142,108,89))
    end
end

return RecordDetailItemUI