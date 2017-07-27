local MahjongScene = import(".MahjongScene")
local ReplayScene = class("ReplayScene", MahjongScene)
local MahjongGamePlayLayer = import(".mj.MahjongGamePlayLayer")
local MahjongGameWaitLayer = import(".mj.MahjongGameWaitLayer")
local MahjongBgLayer = import(".mj.MahjongBgLayer")
local MahjongPlayer = import(".mj.MahjongPlayer")
local MahjoneModel = import(".mj.MahjoneModel")

function ReplayScene:onCreate()
    ReplayScene.super.onCreate(self)
end

function ReplayScene:onEnter()
	UserData.isInReplayScene = true
	self.MahjongGamePlayLayer.isReplay = true
	self.MahjongGamePlayLayer.textInfoStr = "剩余%d张                                    "
	self.MahjongGamePlayLayer.textInfo:setVisible(false) --先隐藏
	self.MahjongGamePlayLayer.timeLeft = 0
	self.MahjongGamePlayLayer.battle_di1:setVisible(false)
	self.MahjongGamePlayLayer.battle_di2:setVisible(false)
	-- self.MahjongBgLayer.txt_ping:setVisible(false)
	self.MahjongBgLayer.wifiBg:setVisible(false)
	self.MahjongBgLayer.tTime:setVisible(false)
	self.lastActChairId = nil

	NotifyMgr:reg(consts.Notify.REPLAY_SPEED, self.onSpeed ,self)
	NotifyMgr:reg(consts.Notify.REPLAY_PAUSE, self.onPause ,self)
	NotifyMgr:reg(consts.Notify.REPLAY_BACK, self.onBackOff ,self)

	UserData.roomId = UserData.replayInfo["room_id"]
	--房间信息
	local data = {}
	data.name = "room_post_table_scene"
	data.args = {}
	data.args.players = {}
	data.args.table_config = {}
	data.args.table_config.data = UserData.replayInfo["config"]
	data.args.table_config.game_count = 8
	for i=1,4 do
		if tonumber(UserData.replayInfo["chair_"..i.."_uid"]) ~= 0 then
			table.insert(data.args.players, {uid = UserData.replayInfo["chair_"..i.."_uid"], nickname = UserData.replayInfo["chair_"..i.."_name"],
			 chair_id = i, point = UserData.replayInfo["chair_"..i.."_point"], url = UserData.replayInfo["chair_"..i.."avatar"]})
			data.args.table_config.player_count = i
		end
	end
	GnetMgr:recvInReplayScene(data)

	-- for i, player in ipairs(self.MahjongGamePlayLayer.playerList) do
	-- 	player.head  = NetSprite:getSpriteUrl(UserData.replayInfo["chair_"..i.."_avatar"], "mj/bg_default_avatar_1.png")
 --        player.head:setPosition(cc.p(1,19))
 --        player.head:setImageContentSize(cc.size(70,70))
 --        player.head:addTo(player, 99)
	-- end

	self:loadAllAct()
end

function ReplayScene:handleAct(actId, chair_id, cards)
	--行为:chair_id:牌
	--1摸牌 2出牌 3碰 4杠 5吃 6胡 7取消 8补张 9飘 10鸟 11中鸟的牌
	local data = {}
	data.args = {}
	-- data.args.code = 0
	if 1 == actId then --摸
		if cards[2] then --摸两张 不处理（长沙，宁乡）
			return
		end
		data.name = "game_draw_card"
		data.args.card = tonumber(cards[1])
		data.args.chair_id = chair_id
		GnetMgr:recvInReplayScene(data)
	elseif 2 == actId then --出牌
		data.name = "game_out_card"
		data.args.card = tonumber(cards[1])
		data.args.chair_id = chair_id
		if cards[2] then
			data.args.addition_card = {tonumber(cards[2])}
		end
		GnetMgr:recvInReplayScene(data)
	elseif 3 == actId then --碰
		data.name = "game_peng_card"
		data.args.card = tonumber(cards[1])
		data.args.chair_id = chair_id
		GnetMgr:recvInReplayScene(data)
	elseif 4 == actId then --杠
		data.name = "game_gang_card"
		data.args.card = tonumber(cards[1])
		data.args.chair_id = chair_id
		data.args.gang_type = 1
		if self.lastActChairId ~= chair_id then
			data.args.gang_type = 3
		end

		GnetMgr:recvInReplayScene(data)
	elseif 5 == actId then --吃
		data.name = "game_chi_card"
		data.args.card = tonumber(cards[1])
		data.args.chair_id = chair_id
		data.args.card_table = {cards[2], cards[3]}
		GnetMgr:recvInReplayScene(data)
	elseif 6 == actId then --胡
		data.name = "game_hu_card"
		local player =  self.MahjongGamePlayLayer:getPlayer(chair_id)
		data.args.card_table = {}
		for i = 1, player.hold_tiles.count do
	        table.insert(data.args.card_table, player.hold_tiles[i].id)
	    end
	    if player.just_got then
	    	table.insert(data.args.card_table, player.just_got.id)
	    end
		data.args.chair_id = chair_id
		data.args.hu_type = 1
		GnetMgr:recvInReplayScene(data)

		-- animation = AnimationView:create("hu","action/hu".. curHuType ..".csb")
		-- animation:setPosition(nomalPosition[helper.getRealPos(huType[2],UserData.myChairId,UserData.table_config.player_count)])
	 --    animation:gotoFrameAndPlay(0,false)
	 --    animation:addTo(layer,1000)
	 local mjaction = import("app.views.mj.MjActionLogic")
	 mjaction:replaySceneHu(self.MahjongGamePlayLayer, nil, self.MahjongGamePlayLayer:getPlayer(chair_id))

	elseif 8 == actId then --补张
		data.name = "game_bu_card"
		data.args.card = tonumber(cards[1])
		data.args.chair_id = chair_id
		data.args.bu_type = 1
		if self.lastActChairId ~= chair_id then
			data.args.bu_type = 3
		end
		GnetMgr:recvInReplayScene(data)
	end
end

function ReplayScene:onPause()
	self.isPause = not self.isPause
	if self.replayUI then
		self.replayUI:changePlayState(self.isPause)
	end
end

function ReplayScene:onBackOff()
	self.curActIndex = self.curActIndex - 3
	if self.curActIndex < 1 then
		self.curActIndex = 1
		--初始化
		self.MahjongGamePlayLayer.firstDraw = true
  		for k, player in pairs(self.MahjongGamePlayLayer.playerList) do
			player.dealCount = 3
			-- player.dealNum = 0
		end
	end
	self:loadStateByIndex(self.curActIndex)
end

function ReplayScene:onSpeed()
	self.curActIndex = self.curActIndex + 3
	if self.curActIndex > self.maxActIndex then
		self.curActIndex = self.maxActIndex
	end
	self:loadStateByIndex(self.curActIndex)
end

function ReplayScene:saveAllPlayerState()
	self.playerStateList[self.curActIndex] = self.playerStateList[self.curActIndex] or {}
	for k, player in pairs(self.MahjongGamePlayLayer.playerList) do
		self.playerStateList[self.curActIndex][k] = player:getPlayerState()
	end
	self.gamePlayLayerState[self.curActIndex] = self.gamePlayLayerState[self.curActIndex] or {}
	self.gamePlayLayerState[self.curActIndex].cardsLeftNum = self.MahjongGamePlayLayer.cardsLeftNum
end

function ReplayScene:loadStateByIndex(index)
	for k, player in pairs(self.MahjongGamePlayLayer.playerList) do
		player:loadState(self.playerStateList[index][k])
	end
	self.MahjongGamePlayLayer.curPlayedMj = nil
	self.MahjongGamePlayLayer.cardsLeftNum = self.gamePlayLayerState[index].cardsLeftNum
	self.MahjongGamePlayLayer:updateInReplay()
end

--加载所有步骤
function ReplayScene:loadAllAct()
	UserData.isSkipAnimate = true
	--游戏开始
	data = {}
	data.name = "game_start_game"
	data.args = {}
	GnetMgr:recvInReplayScene(data)

	self.cardInfo = json.decode(UserData.replayInfo["game_action"])
	self.playerCard = json.decode(self.cardInfo.player_card)

	data = {}
	data.name = "replay_game_deal_card"
	data.args = {}
	data.args.cards = self.playerCard
	data.args.card_first = 1
	data.args.card_num = {13,13,13}
	GnetMgr:recvInReplayScene(data)

	self.actArray = string.split(self.cardInfo.game_action, ";")
	self.playerStateList = {}
	self.gamePlayLayerState = {}
	self.maxActIndex = #self.actArray
	self.isPause = false
	self.curActIndex = 1
	local firstDraw = true

	self.MahjongGamePlayLayer:setVisible(false)
	local time = 0.01
	--test
	-- UserData.isSkipAnimate = false
	-- self.MahjongGamePlayLayer:setVisible(true)
	-- performWithDelay(self, function()
	-- 	UIMgr:openUI(consts.UI.ReplayUI, nil, nil)
	-- end, 0.3)
	-- time = 1

	self.schedulerTims = gScheduler:scheduleScriptFunc(function ()
		if not self.isPause then
			self:saveAllPlayerState()
			local act = self.actArray[self.curActIndex]
			if act then
				for k, player in pairs(self.MahjongGamePlayLayer.playerList) do
					player:sort(player.hold_tiles)
					for i = 1, player.hold_tiles.count do
						player.hold_tiles[i]:setVisible(true)
					end
			        player:update_mj()
				end
				local t1 = string.split(act, ":")
				local actId = tonumber(t1[1])
				local t2 = string.split(t1[2], "-")
				local chair_id = tonumber(t2[1])
				table.remove(t2, 1)
				local cards = t2
				--string to number
				for k,v in pairs(cards) do
					cards[k] = tonumber(v)
				end
				self:handleAct(actId, chair_id, cards)
				self.curActIndex = self.curActIndex + 1
				self.MahjongGamePlayLayer.firstDraw = false
				self.lastActChairId = chair_id
			else
				gScheduler:unscheduleScriptEntry(self.schedulerTims)
				self:start()
			end
		end
	end, time, false)
end

function ReplayScene:start()
	UserData.isSkipAnimate = false
	self.replayUI = UIMgr:openUI(consts.UI.ReplayUI, nil, nil)

	self.MahjongGamePlayLayer:enableToOutAllCards(false)
	self:loadStateByIndex(1)
	self.curActIndex = 1

	for i, player in ipairs(self.MahjongGamePlayLayer.playerList) do
		player.head  = NetSprite:getSpriteUrl(UserData.replayInfo["chair_"..i.."_avatar"], "mj/bg_default_avatar_1.png")
        player.head:setPosition(cc.p(1,19))
        player.head:setImageContentSize(cc.size(70,70))
        player.head:addTo(player, -1)
	end

	self.schedulerTims = gScheduler:scheduleScriptFunc(function ()
		if not self.isPause then
			self.MahjongGamePlayLayer.timeLeft = 0
			self.MahjongGamePlayLayer:setVisible(true)
			self:saveAllPlayerState()
			local act = self.actArray[self.curActIndex]
			if act then
				for k, player in pairs(self.MahjongGamePlayLayer.playerList) do
					player:sort(player.hold_tiles)
					for i = 1, player.hold_tiles.count do
						player.hold_tiles[i]:setVisible(true)
					end
			        player:update_mj()
				end

				local t1 = string.split(act, ":")
				local actId = tonumber(t1[1])
				local t2 = string.split(t1[2], "-")
				local chair_id = tonumber(t2[1])
				table.remove(t2, 1)
				local cards = t2
				--string to number
				for k,v in pairs(cards) do
					cards[k] = tonumber(v)
				end
				self:handleAct(actId, chair_id, cards)
				self.curActIndex = self.curActIndex + 1
				self.MahjongGamePlayLayer.firstDraw = false
				self.lastActChairId = chair_id
			else
				local dialogContentLabel1=helper.createRichLabel({maxWidth = 600,fontSize = 30})
		        dialogContentLabel1:setString("回放已结束，是否退出")
		        dialogContentLabel1:setColor(cc.c3b(153, 78, 46))
		        local dialogContent =cc.Layer:create()
		        dialogContentLabel1:addTo(dialogContent,1)
		        UIMgr:showConfirmDialog("提示",{child=dialogContent, childOffsetY= 18},function ()
		        	self.replayUI:exit()
		        end, function()end)
		        self.isPause = true
		        self.replayUI:changePlayState(self.isPause)
			end
		end
	end, 1, false)
end

function ReplayScene:onExit()
	ReplayScene.super.onExit(self)
	if self.schedulerTims then
		gScheduler:unscheduleScriptEntry(self.schedulerTims)
		self.schedulerTims = nil
	end
	UserData.isInReplayScene = false
end

return ReplayScene