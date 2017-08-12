--麻将场景
local MahjongScene = class("MahjongScene", cc.load("mvc").ViewBase)
local MahjongGamePlayLayer = import(".mj.MahjongGamePlayLayer")
local MahjongGameWaitLayer = import(".mj.MahjongGameWaitLayer")
local MahjongBgLayer = import(".mj.MahjongBgLayer")
local MahjongPlayer = import(".mj.MahjongPlayer")
local MahjoneModel = import(".mj.MahjoneModel")


function MahjongScene:onCreate()
    self:initScene()
    self:initEvent()
    self:initData()
    if UserData.isBack then
        self:updateGameStatus()
        UserData.isBack = false
    end
    AudioMgr:playMusic()
    GCloudVoiceMgr:init()
end

function MahjongScene:initScene()
    --print("111111111:",UserData:getCurBgType().."/MahjongTile.plist",UserData:getCurBgType().."/MahjongTile.png")
    display.loadSpriteFrames(UserData:getCurBgType().."/MahjongTile.plist", UserData:getCurBgType().."/MahjongTile.png")
    -- 添加背景图层
    self.MahjongBgLayer = MahjongBgLayer.new()
    self.MahjongBgLayer:addTo(self, 1)
    -- 添加游戏图层
    self.MahjongGamePlayLayer = MahjongGamePlayLayer.new()
    self.MahjongGamePlayLayer:addTo(self.MahjongBgLayer, 2)
    -- 添加等待图层
    self.MahjongGameWaitLayer = MahjongGameWaitLayer.new()
    self.MahjongGameWaitLayer:addTo(self.MahjongBgLayer, 3)

    self.MahjongGamePlayLayer:setVisible(false)
    self.MahjongGameWaitLayer:setVisible(false)
end

function MahjongScene:initEvent()
    NotifyMgr:reg(consts.Notify.GCLOUDVOICE_COMPLETE, self.gCloudvoiceComplete,self)
    NotifyMgr:reg(consts.Notify.MAH_JONE_CHANGE_GAME_STATUS, self.updateGameStatus, self)  --游戏状态改变

    NotifyMgr:reg(consts.Notify.DISMISS_ROOM, self.updateDismissRoom, self)  --游戏解散房间

    -- self.MahjongBgLayer.btn_ting:addClickEventListener(handler(self,self.onBtnTingClick))
    self.MahjongBgLayer.btn_ting.touchLayout:addClickEventListener(handler(self,self.onBtnTingClick))
end
function MahjongScene:onBtnTingClick( )
    self.MahjongGamePlayLayer:updateTingTip(0)
end

function MahjongScene:initData()
    UserData.isInGame = true                --切换打牌标记
    UserData.roomDismiss=false              --解散房间标记
    self.model_ = MahjoneModel:create(handler(self,self.proListHandler))  --创建数据层
    self.MahjongGamePlayLayer:setModel(self.model_)
    self.MahjongGameWaitLayer:setModel(self.model_)
end

-- 解散房间处理
function MahjongScene:updateDismissRoom(msg)
    dump(msg,"updateDismissRoom")
    local disData = msg.data
    local disType = disData.disType
    if disType == 1 then
        self:send("room_vote_dismiss_room",disData.data)
    else

    end
end

-- 处理服务端下发的玩家请求房间解散
function MahjongScene:onRespRoomPostVoteDismiss(msg)
    if not tolua.isnull(self.dismissRoomApplyDialogContent) then
        UIMgr:closeUI(consts.UI.ConfirmDialogUI)
        self.dismissRoomApplyDialogContent = nil
    end

    self:showDismissRoomApplyDialog(msg)
end

-- 显示申请解散房间弹窗
function MahjongScene:showDismissRoomApplyDialog(msg)
    for i,player in ipairs(UserData.players) do
        player.option = nil
    end
    NotifyMgr:push(consts.Notify.CONFIRM_DLALOG_CLOSE)

    if Is_New_DismissRoom then
        if UIMgr:getUI(consts.UI.DismissRoomDialog) then
            NotifyMgr:push(consts.Notify.GET_VOTE_MSG, {apply = msg.apply,option = msg.option,uid = msg.uid})
        else
            if UIMgr:getUI(consts.UI.HelpUI) then
                UIMgr:closeUI(consts.UI.HelpUI)
            end
            UIMgr:openUI(consts.UI.DismissRoomDialog,nil,nil,msg)
        end
    else
        self.dismissRoomApplyDialogContent=DismissRoomApplyDialogLayer:new(msg)
        self.dismissRoomApplyDialogContent:update(msg)
        self.dialogParams={width=consts.bgSize.l.w, height=consts.bgSize.l.h,
            childOffsetY = 0 -  consts.Size.height / 2, childOffsetX = 0 -  consts.Size.width / 2,
            child=self.dismissRoomApplyDialogContent,useForAgreement=true,notDismissDialogForBtnClick=true}
        if UserData.uid == msg.apply or (msg.uid == UserData.uid and msg.option == 0) then
            self.applyDismissDialog=UIMgr:showConfirmDialog("申请解散房间",self.dialogParams,nil,nil,self)
        else
            self.applyDismissDialog=UIMgr:showConfirmDialog("申请解散房间",self.dialogParams,handler(self,self.onDismissRoomAgree),handler(self,self.onDismissRoomReject),self)
        end
        print("showDismissRoomApplyDialog")
    end
end

-- 同意解散房间
function MahjongScene:onDismissRoomAgree()
    self.applyDismissDialog:hideButtons()
    self:send("room_vote_dismiss_room",{room_id = UserData.roomId,option=0})
end

-- 拒绝解散房间
function MahjongScene:onDismissRoomReject()
    self.applyDismissDialog:hideButtons()
    self:send("room_vote_dismiss_room",{room_id = UserData.roomId,option=1})
end

function MahjongScene:dismissSuccessHandler()
    if UserData.game_balance_result then
        if UserData.game_status == UserData.GAME_STATUS.nextWaiting then
            UIMgr:openUI(consts.UI.SummaryResultUI)
        elseif UserData.game_status == UserData.GAME_STATUS.start then
            if UserData:isChenZhou() and #UserData.cardResult.player_balance > 0 and nil == UserData.cardResult.player_balance[1].piaoPoint
            and UserData.table_config.rule.piao then --郴州选了飘规则在没选飘分前解散，直接总结算
                UIMgr:openUI(consts.UI.SummaryResultUI)
            else
                UIMgr:openUI(consts.UI.cardResultUI)
            end
        else
            MyApp:goToMain()
        end
    else
        MyApp:goToMain()
    end
end

-- 处理房间解散成功事件
function MahjongScene:onRespRoomDismissSuccess(msg)
    UIMgr:closeUI(consts.UI.DismissRoomDialog)
    NotifyMgr:push(consts.Notify.CONFIRM_DLALOG_CLOSE)
    if msg.args.list then
        self.dialogText="<div fontcolor=#994e2e>经玩家</div><div fontcolor=#ff6c00>"
        if msg.args.list then
            for i,uid in ipairs(msg.args.list) do
               self.tmpPlayer=UserData:getPlayerInfoById(uid)
               self.dialogText=self.dialogText.."【"..self.tmpPlayer.nickname.."】 "
            end
        end
        self.dialogText=self.dialogText.."</div><div fontcolor=#994e2e>同意，房间解散成功!</div>"
        local dialogContentLabel=helper.createRichLabel({maxWidth = 600})
        dialogContentLabel:setString(self.dialogText)
        UIMgr:showConfirmDialog("解散成功",{child=dialogContentLabel},self.dismissSuccessHandler)
    else
        local dialogText="</div><div fontcolor=#994e2e>已超出系统最长保留时间，房间解散!</div>"
        local dialogContentLabel=helper.createRichLabel({maxWidth = 600})
        dialogContentLabel:setString(dialogText)
        dialogContentLabel:setPosition(cc.p(683, 465))
        UIMgr:showConfirmDialog("房间解散",{child=dialogContentLabel},self.dismissSuccessHandler)
    end
    self.dismissRoomApplyDialogContent=nil
end

 -- 处理房间解散失败事件
function MahjongScene:onRespRoomDismissFail(msg)
    UserData.disMissTime = 300
    UIMgr:closeUI(consts.UI.DismissRoomDialog)
    NotifyMgr:push(consts.Notify.CONFIRM_DLALOG_CLOSE)
    self.dialogText="<div fontcolor=#994e2e>由于玩家</div><div fontcolor=#ff6c00>"
    if msg.args.list then
        for i,uid in ipairs(msg.args.list) do
           self.tmpPlayer=UserData:getPlayerInfoById(uid)
           self.dialogText=self.dialogText.."【"..self.tmpPlayer.nickname.."】 "
        end
    end
    self.dialogText=self.dialogText.."</div><div fontcolor=#994e2e>拒绝，房间解散失败，游戏继续!</div>"
    local dialogContentLabel=helper.createRichLabel({maxWidth = 600,fontSize = 30})
    dialogContentLabel:setString(self.dialogText)
    UIMgr:showConfirmDialog("解散失败",{child=dialogContentLabel},function() 
        log.print("解散失败")
    end)
    self.dismissRoomApplyDialogContent = nil
end

function MahjongScene:proListHandler(msg) 
    log.print("战斗场景收到服务端消息："..msg.name)
    -- self.MahjongGamePlayLayer.m_tingTip:setVisible(false)
    if msg.name == "room_post_table_scene" then
        GnetMgr:lock()
        UserData:setTableConfig(msg.args.table_config)  --设置牌局信息
        UserData:setPlayersInfo(msg.args.players)       --设置玩家信息
        UserData:setGameStatus(UserData.GAME_STATUS.waiting) -- 刷新显示
        GnetMgr:unlock()
    elseif msg.name == "room_post_get_ready" then
        GnetMgr:lock()
        if msg.args.chair_id then
            print("setReady:",msg.args.chair_id)
            self.MahjongGameWaitLayer:setReady(msg.args.chair_id)
            local pInfo = UserData:getPlayerInfoByChairId(msg.args.chair_id)
            if pInfo then
                pInfo.game_state = 2
            end
        end
        GnetMgr:unlock()
    elseif msg.name == "game_start_game" then
        GnetMgr:lock()
        UserData:clearLaizipiAndLaizi()
        UserData.chatList = {} --清空聊天历史
        UserData:setGameStatus(UserData.GAME_STATUS.start)
        if msg.args.needWait then
            NotifyMgr:push(consts.Notify.SELECT_PIAO_SHOW, true)
        end
        local player_count = UserData.table_config.player_count
        for i = 1, player_count do
            local pInfo = UserData:getPlayerInfoByChairId(i)
            if pInfo then
                pInfo.game_state = 4
            end
        end
        for _,v in pairs(self.MahjongGameWaitLayer.playerList) do
            v:setReady(false)
        end
        GnetMgr:unlock()
    elseif msg.name == "game_deal_card" then
        GnetMgr:lock()
        self.MahjongGamePlayLayer:onRespGameDealCard(msg)
        UIMgr:closeUI(consts.UI.mainUI)
        GnetMgr:unlock()
    elseif msg.name == "replay_game_deal_card" then
        GnetMgr:lock()
        self.MahjongGamePlayLayer:onRespReplayGameDealCard(msg)
        UIMgr:closeUI(consts.UI.mainUI)
        GnetMgr:unlock()
    elseif msg.name == "game_out_card" then
        GnetMgr:lock()
        self.MahjongGamePlayLayer:onRespGameOutCard(msg)
    elseif msg.name == "game_draw_card" then
        GnetMgr:lock()
        self.MahjongGamePlayLayer:onRespGameDrawCard(msg)
    elseif msg.name == "game_have_operation" then
        GnetMgr:lock()
        self.MahjongGamePlayLayer:onRespGameCheckOperation(msg)
        GnetMgr:unlock()
    elseif msg.name == "game_peng_card" then
        GnetMgr:lock()
        self.MahjongGamePlayLayer:onRespGamePengCard(msg)
        self.MahjongGamePlayLayer:unselectTile()
        GnetMgr:unlock()
    elseif msg.name == "game_bu_card" then
        GnetMgr:lock()
        self.MahjongGamePlayLayer:onRespGameBuCard(msg)
        self.MahjongGamePlayLayer:unselectTile()
        GnetMgr:unlock()
    elseif msg.name == "game_gang_card" then
        GnetMgr:lock()
        self.MahjongGamePlayLayer:onRespGameGangCard(msg)
        self.MahjongGamePlayLayer:unselectTile()
        GnetMgr:unlock()
    elseif msg.name == "game_chi_card" then
        GnetMgr:lock()
        self.MahjongGamePlayLayer:onRespGameChiCard(msg)
        self.MahjongGamePlayLayer:unselectTile()
        GnetMgr:unlock()
    elseif msg.name == "game_hu_card" then
        GnetMgr:lock()
        self.MahjongGamePlayLayer:onRespGameHuCard(msg)
        GnetMgr:unlock()
    elseif msg.name == "game_post_timeout_chair" then
        GnetMgr:lock()
        self.MahjongGamePlayLayer:onRespSetPos(msg)
        GnetMgr:unlock()
    elseif msg.name == "game_game_end" then
        GnetMgr:lock()
        UserData.cardResult = msg.args
        if UserData.game_status == UserData.GAME_STATUS.start and not UserData.roomDismiss then
            self.MahjongGamePlayLayer:onRespGameEnd(msg)
        end
        GnetMgr:unlock()
    elseif msg.name == "game_balance_result" then
        GnetMgr:lock()
        UserData.game_balance_result = msg.args
        GnetMgr:unlock()
    elseif msg.name == "room_post_vote_dismiss" then
        GnetMgr:lock()
        if UserData.game_status == UserData.GAME_STATUS.start or 
            UserData.game_status == UserData.GAME_STATUS.nextWaiting then
                self:onRespRoomPostVoteDismiss(msg.args)
        end
        GnetMgr:unlock()
    elseif msg.name =="room_post_player_connect" then
        GnetMgr:lock()
        self.MahjongGamePlayLayer:setOffLine(msg.args)
        self.MahjongGameWaitLayer:setOffLine(msg.args)
        GnetMgr:unlock()
    elseif msg.name =="room_post_room_dismiss" then
        GnetMgr:lock()
        log.print("room_post_room_dismiss")
        if UserData.game_status == UserData.GAME_STATUS.start or 
            UserData.game_status == UserData.GAME_STATUS.nextWaiting then
            if helper.isCallbackSuccess(msg) then
                UserData.roomDismiss = true
                self:onRespRoomDismissSuccess(msg)
            else
                self:onRespRoomDismissFail(msg)
            end
        elseif UserData.game_status == UserData.GAME_STATUS.waiting then
            if helper.isCallbackSuccess(msg) then
                UserData.roomDismiss = true
                self:onRespRoomDismissSuccess(msg)
            end
        end
        GnetMgr:unlock()
    elseif msg.name == "room_exit_room" then
        GnetMgr:lock()
        if helper.isCallbackSuccess(msg) then
            MyApp:goToMain()
        end
        GnetMgr:unlock()
    elseif msg.name == "first_hu_info" then
        GnetMgr:lock()
        self.MahjongGamePlayLayer:onRespGameFirstHuCard(msg.args)
        GnetMgr:unlock()
    elseif msg.name == "game_talk_and_picture" then
        GnetMgr:lock()
        if UserData.game_status == UserData.GAME_STATUS.start or 
            UserData.game_status == UserData.GAME_STATUS.nextWaiting then
            self.MahjongGamePlayLayer:onRespChat(msg)
        elseif UserData.game_status == UserData.GAME_STATUS.waiting then
            self.MahjongGameWaitLayer:onRespChat(msg)
        end
        GnetMgr:unlock()
    elseif msg.name == "changsha_start_out" then
        GnetMgr:lock()
        self.MahjongGamePlayLayer:onRespChangShaStartOut()
        GnetMgr:unlock()
    elseif msg.name == "game_piao_point" then
        GnetMgr:lock()
        self.MahjongGamePlayLayer:onRespUpdatePiaoPoint(msg.args)
        NotifyMgr:push(consts.Notify.SELECT_PIAO_SHOW, false)
        GnetMgr:unlock()
    elseif msg.name == "game_reconnect_piao" then
        GnetMgr:lock()
        if msg.args.point == -1 then
            NotifyMgr:push(consts.Notify.SELECT_PIAO_SHOW, true)
        else
            -- NotifyMgr:push(consts.Notify.SELECT_PIAO_SHOW, false)
            --等待其他玩家选飘
            NotifyMgr:push(consts.Notify.WAIT_OTHER_SELECT_PIAO, msg.args.point)
        end
        GnetMgr:unlock()
     elseif msg.name == "game_open_laizi" then
        GnetMgr:lock()
        self.MahjongGamePlayLayer:onRespGameFlipLaizi(msg.args)
        GnetMgr:unlock()
    elseif msg.name == "game_ting_card" then
        GnetMgr:lock()
        self.MahjongGamePlayLayer:onRespTing(msg.args)
        GnetMgr:unlock()
    elseif msg.name == "game_open_haidi" then
        GnetMgr:lock()
        self.MahjongGamePlayLayer:onRespOpenHaidi(msg.args)
        GnetMgr:unlock()
    end
end

function MahjongScene:updateGameStatus()
    self.MahjongBgLayer:showUpdate()
    self.MahjongGameWaitLayer:showUpdate()
    self.MahjongGamePlayLayer:showUpdate()
end

function MahjongScene:onExit()
    MahjongScene.super.onExit(self)
    --add by zengbingrong
    NotifyMgr:unregWithObj(self)
    self.dismissRoomApplyDialogContent = nil
end

function MahjongScene:gCloudvoiceComplete()
    self.MahjongGamePlayLayer:gCloudvoiceComplete()
    self.MahjongGameWaitLayer:gCloudvoiceComplete()
end

return MahjongScene
