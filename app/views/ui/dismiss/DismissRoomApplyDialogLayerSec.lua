--[[
    For:申请解散房间
        对话框图层
        优化版
--]]
DismissRoomApplyDialogLayerSec = class("DismissRoomApplyDialogLayerSec", cc.load("mvc").UIBase)
local DismissRoomModel = import(".DismissRoomModel")
local PlayerVoteStatusUI = require(consts.UI.PlayerVoteStatusUI)

DismissRoomApplyDialogLayerSec.RESOURCE_FILENAME = "uiDismiss/Dismiss_Vote_Layer.csb"
DismissRoomApplyDialogLayerSec.RESOURCE_MODELNAME = "app.views.ui.dismiss.DismissRoomModel"

local playerCount = UserData.table_config.player_count 
local playerPosX = {215-100, 395-100, 575-100, 755-100}

function DismissRoomApplyDialogLayerSec:onCreate(data)
    self.playerName = helper.findNodeByName(self.resourceNode_, "lbl_apply_player_name")
    self.rejectBtn = helper.findNodeByName(self.resourceNode_, "btn_reject"):setPressedActionEnabled(true)
    self.agreeBtn = helper.findNodeByName(self.resourceNode_, "btn_agree"):setPressedActionEnabled(true)
    self.bellImage = helper.findNodeByName(self.resourceNode_, "image_bell")
    self.bellImage:setVisible(false)
    self.bellNumberLbl = helper.findNodeByName(self.resourceNode_, "lbl_bell_number")
    self.isAgreedLbl = helper.findNodeByName(self.resourceNode_, "lbl_is_agreed"):setVisible(false)
    self.countTime = helper.findNodeByName(self.resourceNode_, "lbl_count_time")
    self.playerInfoNode = helper.findNodeByName(self.resourceNode_, "Node_player_info")
    self.bottemBg = helper.findNodeByName(self.resourceNode_, "Image_bg_bottem")
    self.bg = helper.findNodeByName(self.resourceNode_, "bg")

    self:sortPlayerPos()
    self:loadApplayName(data)
    self:loadPlayerInfo()

    self.userID = nil
    self:updateTime()
    self:setInOutAction()
    NotifyMgr:reg(consts.Notify.GET_VOTE_MSG, self.refreshVoteView, self)
end

function DismissRoomApplyDialogLayerSec:loadApplayName(data)
    local applyID = tonumber(data.apply)
    for i,player in ipairs(UserData.players) do
        if data and applyID == player.uid then
            self.applayID = data.apply
            self.playerName:setString(player.nickname)
            return
        end
    end
end

function DismissRoomApplyDialogLayerSec:loadPlayerInfo()
    if(self.playerInfoNode:getChildrenCount() > 0) then
        self.playerInfoNode:removeAllChildren()
    end
    local infoWidth = 180
    local startPos = consts.Size.width / 3 - 30
    local rowInterval = (playerCount - 1) * 90    
    for i,player in ipairs(self.playersData) do
        local posX = 0
        local pUID = player.uid
        local ui =  PlayerVoteStatusUI:create()
        posX = startPos + infoWidth * (i-1) - rowInterval
        ui:setPosition(cc.p(posX, consts.Size.height / 4 + 10))
        ui:refreshBaseInfo({
            nickname = player.nickname,                    -- helper.playerNameAbbRev(player.nickname)
            image_url = player.image_url
        })
        ui:setTag(pUID)
        ui:addTo(self.playerInfoNode, 1)
        if self.applayID == pUID then           --申请人设为已同意
            ui:refreshStatus({isAgree = 0})
        end
        if self.applayID == UserData.uid then   
            self:hideButtons()                  --申请人本身不可选择
        else
            --self.bellImage:setVisible(true)     --非申请人倒计时选择
        end
    end
end
  
function DismissRoomApplyDialogLayerSec:sortPlayerPos()
    self.playersData = UserData.players
    local function sortPos(p1, p2)
        return p1.chair_id < p2.chair_id
    end
    table.sort(self.playersData, sortPos)
end

function DismissRoomApplyDialogLayerSec:refreshVoteView(voteData)
    local data = voteData.data
    if data and data.uid then  
        self.userID = data.uid
        local player = self:getCurVotePlayer()
        if player then
            player:refreshStatus({isAgree = data.option})
            if data.uid == UserData.uid then
                self:hideButtons()
                self.bellImage:setVisible(false)
                if data.option == 0 then
                    self.isAgreedLbl:setString("您已同意，等待其他玩家投票")
                elseif data.option == 1 then
                    self.isAgreedLbl:setString("您已拒绝，等待其他玩家投票")
                end
            end
        end
    end
end

function DismissRoomApplyDialogLayerSec:getCurVotePlayer()
    local uID = tonumber(self.userID)
    for i,player in ipairs(UserData.players) do
        if not UserData.userInfo then return end
        if uID == tonumber(player.uid) then
            local votePlayer = self.playerInfoNode:getChildByTag(uID)
            return votePlayer
        end
    end
end

function DismissRoomApplyDialogLayerSec:onClickArgeeBtn()
    self:send("room_vote_dismiss_room",{room_id = UserData.roomId,option=0})
end

function DismissRoomApplyDialogLayerSec:onClickRejectBtn()
    self:send("room_vote_dismiss_room",{room_id = UserData.roomId,option=1})
end

function DismissRoomApplyDialogLayerSec:refreshPlayer(status)
    if self.playerInfoNode:getChildrenCount() == playerCount then
        self.playerInfoNode:getChildByTag()
    end
end

function DismissRoomApplyDialogLayerSec:hideButtons()
    self.agreeBtn:setVisible(false)
    self.rejectBtn:setVisible(false)
    self.isAgreedLbl:setVisible(true)
end

function DismissRoomApplyDialogLayerSec:updateTime()
    if UserData.disMissTime then
        if UserData.disMissTime > 0 then
            UserData.disMissTime = UserData.disMissTime - 1
            self.bellNumberLbl:setString("(" .. UserData.disMissTime .. ")")
            self.countTime:setString("(" .. UserData.disMissTime .. ")")
            if UserData.disMissTime == 0 then end
        end
    end
end

function DismissRoomApplyDialogLayerSec:startTimer()
    if self.timeEntity == nil then
        self.timeEntity = gScheduler:scheduleScriptFunc(handler(self,self.updateTime), 1, false)
    end
end

function DismissRoomApplyDialogLayerSec:closeTimer()
    if self.timeEntity then
        gScheduler:unscheduleScriptEntry(self.timeEntity)
        self.timeEntity = nil
    end
end

function DismissRoomApplyDialogLayerSec:proListHandler(msg) 
    -- log.print("--解散房间场景收到服务端消息："..msg.name)
end


function DismissRoomApplyDialogLayerSec:onEnter()
    print("-----DismissRoomApplyDialogLayerSec on Enter----")
    DismissRoomApplyDialogLayerSec.super.onEnter(self)
    self:startTimer()
end

function DismissRoomApplyDialogLayerSec:onExit()
    print("-----DismissRoomApplyDialogLayerSec on exit----")
    DismissRoomApplyDialogLayerSec.super.onExit(self)
    self:closeTimer()
    if self.playerInfoNode then
        self.playerInfoNode:removeAllChildren()
    end
end

return DismissRoomApplyDialogLayerSec