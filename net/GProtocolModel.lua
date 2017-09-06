--
-- Author: LXL
-- Date: 2015-07-31 14:10:48
-- 接受公共消息
--
local GProtocolModel = class("GProtocolModel" , cc.load("mvc").ModelBase)

function GProtocolModel:ctor()
    GProtocolModel.super.ctor(self)
end

function GProtocolModel:getProList()
	local list = {
		"room_post_table_reconnect",  --玩家重连推送桌子信息
		"room_post_player_connect",  --推送玩家掉線或者重連
		"game_reconnect_gameinfo",  --玩家重連獲取牌局信息
		"kick_game",  --被踢下线
		"heartbeat", --心跳
    }
    return list
end

function GProtocolModel:proListHandler(msg)
	if msg.name == "room_post_player_connect" then

	elseif msg.name == "game_reconnect_gameinfo" then
		---重置牌的数据
		UserData.reConnectCardData = msg.args
		NotifyMgr:push(consts.Notify.RECONNECT_CARD)
	elseif msg.name == "kick_game" then
		GnetMgr:closeConnect()
		local function backLogin()
			UserData.login = false
			MyApp:goToMain()
		end
		if display.getRunningScene() then
			local params={}
			params.title="提示"
			params.yesBtnEvent=backLogin
			params.child=cc.LabelTTF:create("网络环境差，请重新登录", "Arial", 30)
			params.child:setColor(cc.c3b(153, 78, 46))
			params.childOffsetY = 20
			UIMgr:openUI(consts.UI.ConfirmDialogUI,true,nil,params)
		else
			backLogin()
		end
	elseif msg.name == "heartbeat" then
		HeartMgr.setServerTime(msg.args.time)
	elseif msg.name == "room_post_table_reconnect" then
		self:reConnectSetGameData(msg)
	end
end

function GProtocolModel:reConnectSetGameData(msg)
	UserData.isReConnect = true
	UserData.isPlaying = msg.args.is_playing
	UserData.roomId = msg.args.enter_code
	UserData:setPlayersInfo(msg.args.players)
	UserData:setTableConfig(msg.args.table_config)
    UserData.reconnectedGameIndex = msg.args.game_index
	if UserData.isPlaying then
		UserData:setGameStatus(UserData.GAME_STATUS.start)
		self:send("game_reconnect_gameinfo")
    else
        if UserData.reconnectedGameIndex == 1 then
        	UserData:setGameStatus(UserData.GAME_STATUS.waiting)
        else
        	UserData:setGameStatus(UserData.GAME_STATUS.nextWaiting)
        	self:send("room_get_ready")
        end
	end
	if UserData.isInGame then
		UIMgr:closeUI(consts.UI.mainUI)
		UIMgr:closeUI(consts.UI.ConfirmDialogUI)
	else
		UserData.isBack = true
		MyApp:goToGame()
	end
end

return GProtocolModel
