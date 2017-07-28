-- 麻将游戏战斗准备中图层

local MahjongPlayer = import(".MahjongPlayer")
local MasterDismissRoomDialogLayer=import(".MasterDismissRoomDialogLayer")

MahjongGameWaitLayer = class("MahjongGameWaitLayer",function()
    return cc.Layer:create()
end)


function MahjongGameWaitLayer:ctor()
    self:enableNodeEvents()
    self:initLayer()
    self:initEvent()
    self:initData()
end

function MahjongGameWaitLayer:setModel(model)
    self._model = model
end

function MahjongGameWaitLayer:initData()
    self.m_voiceList    = {}
    self.m_voicePlayNode = cc.Node:create()--语音专用播放node
    self:addChild(self.m_voicePlayNode)
    self._model         = nil
end

function MahjongGameWaitLayer:initEvent()
    self.btn_invite_friend:addClickEventListener(handler(self, self.onBtnInviteFriendCLick))
    self.btn_back_gamecenter:addClickEventListener(handler(self, self.onBtnBackGameCenterCLick))
    self.btn_dismissroom:addClickEventListener(handler(self, self.onBtnDismissRoomCLick))
    self.btn_start:addClickEventListener(handler(self, self.onBtnStartCLick))
end

function MahjongGameWaitLayer:initLayer()
    -- self.bgRoomIdWait = display.newSprite("mj/bg_room_id.png", 35, consts.Size.height)
    -- self.bgRoomIdWait:setAnchorPoint(cc.p(0,1))
    -- self.bgRoomIdWait:addTo(self, 1)
    -- self.labeleRoomIdWait = display.newSprite("mj/label_room_id.png", 83, 730)
    -- self.labeleRoomIdWait:addTo(self, 1)
    -- self.roomIdWait = ccui.TextAtlas:create("", "mj/room_id_font.png", 18, 26,  "0")

    self.roomIdWait = cc.LabelTTF:create("房号：", "Arial", 24)
    self.roomIdWait:setAnchorPoint(cc.p(0.5, 0.5))
    self.roomIdWait:setColor(helper.str2Color("#ccc332"))
    self.roomIdWait:setPosition(cc.p(86, 707))
    self.roomIdWait:addTo(self, 1)

    -- 邀请好友按钮
    -- local btn_invite_friend = ccui.Button:create("uires/common/btn_3_green.png", "uires/common/btn_3_green.png")
    local btn_invite_friend = ccui.Button:create("mj/btn_invite_friend.png", "mj/btn_invite_friend_press.png")
    btn_invite_friend:setPosition(consts.Point.CenterPosition)
    btn_invite_friend:addTo(self, 1)
    btn_invite_friend:setPressedActionEnabled(true)
    self.btn_invite_friend = btn_invite_friend
    -- local text_invite_friend = display.newSprite("mj/btn_text_invite_friend.png")
    -- text_invite_friend:setPosition(btn_invite_friend:getContentSize().width/2-4,btn_invite_friend:getContentSize().height/2+3)
    -- text_invite_friend:addTo(btn_invite_friend)

    -- 返回大厅按钮好友按钮
    -- local btn_back_gamecenter = ccui.Button:create("uires/common/btn_7_green.png", "uires/common/btn_7_green_press.png")
    -- btn_back_gamecenter:setPosition(cc.p(200, 75))
    -- btn_back_gamecenter:addTo(self, 1)
    -- btn_back_gamecenter:setPressedActionEnabled(true)
    -- self.btn_back_gamecenter = btn_back_gamecenter
    -- local text_back_gamecenter = display.newSprite("mj/btn_text_back.png")
    -- text_back_gamecenter:setPosition(btn_back_gamecenter:getContentSize().width/2,btn_back_gamecenter:getContentSize().height/2+2)
    -- text_back_gamecenter:addTo(btn_back_gamecenter)
    -- self.text_back_gamecenter = text_back_gamecenter

    local btn_back_gamecenter = ccui.Button:create("mj/btn_text_back.png", "mj/btn_text_back.png")
    btn_back_gamecenter:setPosition(cc.p(200, 75))
    btn_back_gamecenter:addTo(self, 1)
    btn_back_gamecenter:setPressedActionEnabled(true)
    self.btn_back_gamecenter = btn_back_gamecenter


    -- 解散房间按钮
    -- local btn_dismissroom = ccui.Button:create("uires/common/btn_4_yellow.png", "uires/common/btn_4_yellow_press.png")
    -- btn_dismissroom:setPosition(cc.p(consts.Size.width-200, 75))
    -- btn_dismissroom:addTo(self, 1)
    -- btn_dismissroom:setPressedActionEnabled(true)
    -- self.btn_dismissroom = btn_dismissroom
    -- local text_dismissroom = display.newSprite("mj/btn_text_dismissroom_1.png")
    -- text_dismissroom:setPosition(btn_dismissroom:getContentSize().width/2,btn_dismissroom:getContentSize().height/2+2)
    -- text_dismissroom:addTo(btn_dismissroom)
    -- btn_dismissroom:setVisible(false)

    local btn_dismissroom = ccui.Button:create("mj/btn_text_dismissroom_1.png", "mj/btn_text_dismissroom_1.png")
    btn_dismissroom:setPosition(cc.p(consts.Size.width-200, 75))
    btn_dismissroom:addTo(self, 1)
    btn_dismissroom:setPressedActionEnabled(true)
    self.btn_dismissroom = btn_dismissroom
    btn_dismissroom:setVisible(false)
    -- 开始按钮
    local btn_start = ccui.Button:create("uires/common/btn_7_green.png", "uires/common/btn_7_green_press.png")
    btn_start:setPosition(cc.p(consts.Size.width/2, 230))
    btn_start:addTo(self, 1)
    btn_start:setPressedActionEnabled(true)
    self.btn_start = btn_start
    local text_start = display.newSprite("mj/btn_text_start_game.png")
    text_start:setPosition(btn_start:getContentSize().width/2,btn_start:getContentSize().height/2+5)
    text_start:addTo(btn_start)
    self.btn_start:setVisible(false)

    -- 规则按钮
    self.btn_rule = ccui.Button:create("mj/btn_rule.png", "mj/btn_rule.png", ""):addTo(self, 1)
    self.btn_rule:setAnchorPoint(cc.p(0.5, 1))
    self.btn_rule:setPressedActionEnabled(true)
    self.btn_rule:setPosition(cc.p(consts.Size.width - 160, 755))

    local rule_layout = ccui.Layout:create():addTo(self, 2)
    rule_layout:setAnchorPoint(cc.p(0.5, 1))
    rule_layout:setContentSize(cc.size(self.btn_rule:getContentSize().width * 2, self.btn_rule:getContentSize().height * 2))
    rule_layout:setPosition(cc.p(self.btn_rule:getPositionX(), self.btn_rule:getPositionY()))
    rule_layout:setTouchEnabled(true)
    rule_layout:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                UIMgr:openUI(consts.UI.RuleUI, nil, nil)
            end
        end)
end

function MahjongGameWaitLayer:onExit()
    NotifyMgr:unregWithObj(self)
    self._model = nil
end

function MahjongGameWaitLayer:updateStatus()
    -- 邀请好友按钮
    if UserData.game_status == UserData.GAME_STATUS.waiting then
        self.btn_back_gamecenter:setVisible(true)
        -- self.text_back_gamecenter:setVisible(true)
        self.btn_invite_friend:setVisible(true and not Is_App_Store)
        -- self.text_invite_friend:setVisible(true)
        self:setVisible(true)
    elseif UserData.game_status == UserData.GAME_STATUS.nextWaiting then
        self.btn_back_gamecenter:setVisible(false)
        -- self.text_back_gamecenter:setVisible(false)
        self.btn_invite_friend:setVisible(false and not Is_App_Store)
        -- self.text_invite_friend:setVisible(false)
        self:setVisible(true)
    else
        self:setVisible(false)
    end
    self.roomIdWait:setString("房号：" .. UserData.roomId)
end

function MahjongGameWaitLayer:updatePlayerInfo()
    self.playerList = self.playerList or {}
    local player_count = UserData.table_config.player_count
    local game_count = UserData.table_config.game_count
    for i = 1, player_count do
        local pInfo     = UserData:getPlayerInfoByChairId(i)
        local realPos   = helper.getRealPos(i,UserData.myChairId,player_count)
        local player    = self.playerList[i] or MahjongPlayer:create({status="waiting" ,pos = realPos}):addTo(self, 1)
        self.playerList[i] = player
        if pInfo then
            player:sitDown({parent = self, id = pInfo.uid, chairId = pInfo.chair_id, name = pInfo.nickname, score = pInfo.point, url = pInfo.image_url,sex = pInfo.gender or 1})
            if realPos == 1 then
                if pInfo.game_state == 1 or pInfo.game_state == 3 then
                    self.btn_start:setVisible(true)
                else
                    self.btn_start:setVisible(false)
                end
            end
            player:setReady(pInfo.game_state == 2)
        else
            player:standUp()
        end
    end

end

function MahjongGameWaitLayer:onBtnInviteFriendCLick()
    local curPlayerNum = 0
    for i=1, UserData.table_config.player_count do
        local pInfo = UserData:getPlayerInfoByChairId(i)
        if pInfo then
            curPlayerNum = curPlayerNum + 1
        end
    end
    local extendStr = string.format("(%d缺%d) ", curPlayerNum, UserData.table_config.player_count - curPlayerNum)

    log.print("邀请好友按钮点击")
    local shareTitle = ""
    local sharedesc = ""
    if UserData.table_config.rule.jewel then
        shareTitle = "俱乐部建房("..UserData.table_config.rule.jewel.."钻)<"..
                          UserData.table_config.player_count .. "人"..
                          consts.GameTypeName[UserData.curMahjongType]..">"
        
        sharedesc = extendStr.."房号["..UserData.roomId.."]"..UserData:getTotalCount().."局"..UserData:getShareDesc().."\n[点击加入房间]"
    else
        
        shareTitle = UserData.table_config.player_count .. "人" .. consts.GameTypeName[UserData.curMahjongType] .. ",".."房号:"..UserData.roomId.."("..UserData:getTotalCount().."局)"
        sharedesc = extendStr..UserData:getShareDesc().."\n[点击加入房间]"
    end
    print(sharedesc)

    local weburl = "https://acz5fi.mlinks.cc/AcqJ?".."roomId="..UserData.roomId
    local img = ""
    -- if UserData.userInfo and UserData.userInfo.shareList and UserData.userInfo.shareList.roomShare then
    --     img = UserData.userInfo.shareList.roomShare.img
    --     if UserData.userInfo.shareList.roomShare.link and #UserData.userInfo.shareList.roomShare.link>1 then
    --         weburl = UserData.userInfo.shareList.roomShare.link.."roomId="..UserData.roomId
    --     end
    -- end
    local args = {title=shareTitle,desc=sharedesc,webUrl=weburl,imageUrl=img}
	LuaCallPlatformFun.share(args)
end

function MahjongGameWaitLayer:onBtnBackGameCenterCLick()
    log.print("返回大厅按钮点击")
    if UserData:isNotRoomMaster() then
        local dialogContentLabel1=helper.createRichLabel({maxWidth = 600,fontSize = 30})
        dialogContentLabel1:setString("是否确定退出房间？")
        dialogContentLabel1:setColor(cc.c3b(153, 78, 46))
        local dialogContent =cc.Layer:create()
        dialogContentLabel1:addTo(dialogContent,1)
        UIMgr:showConfirmDialog("提示",{child=dialogContent, childOffsetY= 25},handler(self,self.playerExitRoom),function()end)
    else
        UIMgr:openUI(consts.UI.mainUI)
    end
end
--房客确定确定退出房间
function MahjongGameWaitLayer:playerExitRoom(  )
    UIMgr:showLoadingDialog("退出房间中…")
    self._model:send("room_exit_room")
end

-- 确认是否解散房间
function MahjongGameWaitLayer:onBtnDismissRoomCLick()
    log.print("请求解散房间按钮点击")
    local dialogContentLabel1=helper.createRichLabel({maxWidth = 600,fontSize = 30})
    if(Is_App_Store)then
        dialogContentLabel1:setString("是否解散房间?")
    else
        dialogContentLabel1:setString("由于未完成一局游戏，当前解散不扣房卡，是\n否确定解散?")
    end
    dialogContentLabel1:setColor(cc.c3b(153, 78, 46))
    local dialogContent =cc.Layer:create()
    dialogContentLabel1:addTo(dialogContent,1)
	UIMgr:showConfirmDialog("提示",{child=dialogContent, childOffsetY= 25},handler(self,self.onBtnDismissRoomConfirmClick),self.onBtnDismissRoomCancelClick)
end

-- 解散房间
function MahjongGameWaitLayer:onBtnDismissRoomConfirmClick()
    log.print("确认解散房间按钮点击")
    self._model:send("room_vote_dismiss_room",{room_id = UserData.roomId,option=0})
end

function MahjongGameWaitLayer:onBtnDismissRoomCancelClick()
    
end

function MahjongGameWaitLayer:onBtnStartCLick()
    log.print("开始游戏按钮点击")
    self._model:send("room_get_ready")
end

-- 更新解散按
function MahjongGameWaitLayer:updateDismissRoomBtn()
    if UserData.game_status == UserData.GAME_STATUS.waiting then
        if UserData:isNotRoomMaster() then
            self.btn_dismissroom:setVisible(false)
        else
            self.btn_dismissroom:setVisible(true)
        end
    elseif UserData.game_status == UserData.GAME_STATUS.nextWaiting then
          self.btn_dismissroom:setVisible(false)
    end
end

function MahjongGameWaitLayer:showUpdate()
    self:updateStatus()
    self:updatePlayerInfo()
    self:updateDismissRoomBtn()
end

function MahjongGameWaitLayer:setReady(chairId)
    for k,v in pairs(self.playerList) do
        v:setPlayerPoint()
        if v.chairId == chairId then
            v:setReady(true)
            if v.pos == 1 then
                self.btn_start:setVisible(false)
            end
        end
        if chairId == nil then
            v:setReady(false)
        end
    end
end

-- 处理房间解散成功事件
function MahjongGameWaitLayer:onRespRoomDismissSuccess(msg)
    NotifyMgr:push(consts.Notify.CONFIRM_DLALOG_CLOSE)
    if(not UserData:isNotRoomMaster())then return end --自己是房主就不提示了
    self.masterDismissRoomDialogLayer=MasterDismissRoomDialogLayer:new(msg)
    self.dialogParams={child=self.masterDismissRoomDialogLayer,btnPadding=120,
    childOffsetX = 0 - consts.Size.width / 2, childOffsetY = 0 - consts.Size.height / 2 - 25}
	UIMgr:showConfirmDialog("提示",self.dialogParams,function() 
        self:dismissRoom()
    end,nil)
end

-- 房间解散成功后的处理
function MahjongGameWaitLayer:dismissRoom()
    log.print("解散成功")
    MyApp:goToMain()
    -- self.masterDismissRoomDialogLayer:closeTimer()
end
      
function MahjongGameWaitLayer:setOffLine(data)
    local chairId = data.chair_id
    local isOnline = data.connect
    self.playerList[chairId]:setOffLine(isOnline)
end      

-- 聊天消息
function MahjongGameWaitLayer:onRespChat(msg)
    print("收到聊天消息")
    dump(msg)
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

function MahjongGameWaitLayer:gCloudvoiceComplete()
    for k,v in pairs(self.playerList) do
        v:dimissVoice()
    end
end

--播放下一个语音
function MahjongGameWaitLayer:showNextVoice(  )
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

function MahjongGameWaitLayer:showChat( tab )
    for k,v in pairs(self.playerList) do
        if v.id == tab.uid then
            v:chat(tab)
            return
        end
    end
end

return MahjongGameWaitLayer
