--
-- Author: LXL
-- Date: 2016-11-29 18:29:38
--

local MjActionLogic = {}

local AnimationView = require("utils.extends.AnimationView")
local curHuType = nil
local curHuPlayer = nil
local executeBirdCardOnce = false
function MjActionLogic:dealCardsAction(playerList,chairId,overHandler) --chairid
	local firstPlayer = playerList[chairId]
	local nextChairId = chairId
	local nextPlayer
	local overIndex = 0
	local playerNum = #playerList
	local callback
	callback = function(isOver)
		if isOver then 
			overIndex = overIndex + 1
			if overIndex == #playerList then
				overHandler()
				return
			end
		end
		nextChairId = (nextChairId + 1) > playerNum and (nextChairId + 1 - playerNum) or (nextChairId + 1)
		nextPlayer = playerList[nextChairId]
		nextPlayer:deal(callback)
	end
	firstPlayer:deal(callback)
end

local nomalPosition = {cc.p(683,245),cc.p(1076,384),cc.p(683,568),cc.p(290,384)}

function MjActionLogic:pengAction(pos,layer)
	local animation = AnimationView:create("peng","action/peng.csb")
	animation:setPosition(nomalPosition[pos])
    animation:gotoFrameAndPlay(0,false)
    animation:addTo(layer,1000)
end

function MjActionLogic:buAction(pos,layer)
	local animation = AnimationView:create("bu","action/bu.csb")
	animation:setPosition(nomalPosition[pos])
    animation:gotoFrameAndPlay(0,false)
    animation:addTo(layer,1000)
end

function MjActionLogic:chiAction(pos,layer)
	local animation = AnimationView:create("chi","action/chi.csb")
	animation:setPosition(nomalPosition[pos])
    animation:gotoFrameAndPlay(0,false)
    animation:addTo(layer,1000)
end

function MjActionLogic:baotingAction(pos,layer)
    local animation = AnimationView:create("baoting", "action/baoting.csb")
    animation:setPosition(nomalPosition[pos])
    animation:gotoFrameAndPlay(0,false)
    animation:addTo(layer,1000)
end

local gangPath = {"action/mgang.csb","action/agang.csb","action/gang.csb"}

function MjActionLogic:gangAction(gangtype,pos,layer)
	local animation = AnimationView:create("gang",gangPath[3])
	animation:setPosition(nomalPosition[pos])
    animation:gotoFrameAndPlay(0,false)
    animation:addTo(layer,1000)
    if gangtype < 3 and not UserData.isInReplayScene then
		local animation1 = AnimationView:create("gang",gangPath[gangtype])
		animation1:setPosition(consts.Point.CenterPosition)
	    animation1:gotoFrameAndPlay(0,false)
	    animation1:addTo(layer,1000)
	end
end

local function isGetBird(tile, getbird)
    -- if UserData.isZhuanZhuan() then
    if UserData.isZhuanZhuan() or UserData.isChenZhou() or UserData:isChangDe() then
        local mode = tile%10
        if (tile < 40 and ( mode ==1 or mode ==5 or mode ==9)) or (tile==45 and UserData:isLaizi()) then
            return true
        end
    elseif (UserData.isChangSha() or UserData:isNingXiang() or UserData.isHongZhong()) and getbird then
        for _k,v in pairs(getbird) do
            if tile == v then
                return true
            end
        end
    end
    return false
end

local function flyBirdAction(layer)
	print("flyBirdAction")
	-- local startPosition = display.center--nomalPosition[curHuPlayer.pos]
	-- local birdNum = 0
	-- for k,v in pairs(layer.playerList) do
        -- local animation = nil
		-- birdNum = birdNum + 1
		-- if v ~= curHuPlayer then
		-- 	animation = AnimationView:create("bird","action/niaofly.csb")
		-- 	animation:setPosition(startPosition)
		--     animation:gotoFrameAndPlay(0,false)
  --           animation:setScaleX(startPosition.x - v:getPositionX() > 0 and -1 or 1)
		--     animation:addTo(layer,1000)
		--     animation:runAction(transition.sequence({ cc.MoveTo:create(0.8,cc.p(v:getPosition())), 
  --                                                     cc.CallFunc:create(function()  
  --                                                        animation:removeFromParent()     
  --                                                        local bombAni = AnimationView:create("bird","action/niaobaozha.csb")
  --                                                        bombAni:setPosition(cc.p(v:getPosition()))
  --                                                        bombAni:gotoFrameAndPlay(0,false)
  --                                                        bombAni:addTo(layer,1000)
  --                                                     end)}))
--            local emitter = cc.ParticleSystemQuad:create("res/particle/bird.plist")
--            emitter:setScale(0.6)
--            emitter:setPosition(cc.p(0,0))
--            emitter:addTo(animation,100)
		-- end
	-- 	if birdNum == UserData.table_config.player_count then
	-- 		performWithDelay(layer, function()
	-- 			if not executeBirdCardOnce then
	-- 				executeBirdCardOnce = true
	-- 				for k,v in ipairs(UserData.cardResult.birdCard) do                       
	-- 		            local isWinBird = isGetBird(v,UserData.cardResult.zhongbird)  
	-- 		            layer.myPlayer:addPlayedCard(v,true,isWinBird)
	-- 		        end
	-- 			end
	-- 	        performWithDelay(layer, function()
	-- 				local function getBirdCount(birds)
	-- 					local count = 0
	-- 					for _, tile in pairs(birds) do
	-- 						local mode = tile%10
	-- 				        if (tile < 40 and ( mode ==1 or mode ==5 or mode ==9)) or (tile==45 and UserData:isLaizi()) then
	-- 				            count = count + 1
	-- 				        end
	-- 					end
	-- 					return count
	-- 				end
	-- 				if UserData:isChenZhou() and UserData.table_config.rule.goldbird and 0 == getBirdCount(UserData.cardResult.birdCard) then --郴州金鸟
	-- 					local animation = AnimationView:create("jinniao", "action/jinniao.csb")
	-- 					animation:setPosition(nomalPosition[curHuPlayer.pos])
	-- 				    animation:gotoFrameAndPlay(0,false)
	-- 				    animation:addTo(layer,1000)
	-- 				    performWithDelay(layer, function ()
	-- 				    	UIMgr:openUI(consts.UI.cardResultUI)
	-- 				    end, 1)
	-- 				else
	-- 		        	UIMgr:openUI(consts.UI.cardResultUI)
	-- 				end
	-- 				curHuType = nil
	-- 				curHuPlayer = nil
	-- 		        UserData.game_status = UserData.GAME_STATUS.nextWaiting
	-- 		    end, 0.7)
	-- 	    end, 34/24)
	-- 	end
	-- end
	if not executeBirdCardOnce then
		executeBirdCardOnce = true
		local MahjongTile = require("app.views.mj.MahjongTile")
		for k,v in ipairs(UserData.cardResult.birdCard) do                       
            local isWinBird = isGetBird(v,UserData.cardResult.zhongbird)  
            -- layer.myPlayer:addPlayedCard(v,true,isWinBird)
            local mj = MahjongTile.new({id = v, type = 1, is_bird = isWinBird}):addTo(layer,10001)
            mj:setPosition(cc.p(693,356))
            local x
            local y = 0
            if k%2 == 1 then
            	x = -5 - math.ceil(k/2) * 125 + 50
            else
            	x = 5 + (k/2-1) * 125 + 50
            end

            if 1 == #UserData.cardResult.birdCard then --只有一个鸟
            	x, y = 0, 0
            end
            mj:runAction(
				cc.Sequence:create(
					cc.DelayTime:create(0.2),
					cc.MoveBy:create(0.2,cc.p(x,y)),
					cc.DelayTime:create(0.6),
					cc.CallFunc:create(function()
	                    mj:fadeOutAction(0.5)
	                end),
	                cc.DelayTime:create(0.5),
	                cc.CallFunc:create(function()
	                    mj:removeSelf()
	                end))
        	)
        end
	end
    performWithDelay(layer, function()
    	UIMgr:openUI(consts.UI.cardResultUI)
		curHuType = nil
		curHuPlayer = nil
        UserData.game_status = UserData.GAME_STATUS.nextWaiting
    end, 1.6)
end


local function catchBirdAction(layer)
	print("catchBirdAction")
	local image = ccui.ImageView:create("mj/niao_bg.png")
	image:setPosition(display.center)
	image:setOpacity(0)
	image:addTo(layer,10000)
	image:runAction(
		cc.Sequence:create(
			cc.FadeIn:create(0.5),
			cc.DelayTime:create(1),
        	cc.FadeOut:create(0.5),
			cc.CallFunc:create(function()
                    image:removeSelf()
                end))
		)
	
	-- local animation = AnimationView:create("zhuaniao","action/zhuaniao.csb")
	-- animation:setPosition(consts.Point.CenterPosition)
 --    animation:gotoFrameAndPlay(0,false)
 --    animation:addTo(layer,1000)
    performWithDelay(layer, function()
        flyBirdAction(layer)
    end, 0.5)
end

local function huAction(layer)
	if UserData.isInReplayScene then
		-- local animation = AnimationView:create("hu","action/hu1.csb")
		-- animation:setPosition(nomalPosition[curHuPlayer.pos])
	 --    animation:gotoFrameAndPlay(0,false)
	 --    animation:addTo(layer,1000)
	 	if UserData.isSkipAnimate then return end
	 	local animation =  ccui.ImageView:create("mj/bn_hu.png"):addTo(layer, 1000)
		local defaultPath = AudioMgr:getHumanSoundPath(curHuPlayer:get_sex())
	 	audio.playSound(defaultPath.."effect/hu.mp3")
	 	animation:setPosition(nomalPosition[curHuPlayer.pos])
	 	animation:runAction(
                    transition.sequence({
                        cc.DelayTime:create(1),
                        cc.CallFunc:create(function()
                                animation:removeSelf()
                            end)
                        }))
	elseif UserData:isChangSha() or UserData:isNingXiang() then
		local huList = {}
		local balance
		if UserData:isChangSha() then
			balance = UserData.cardResult.changsha_player_balance
		elseif UserData:isNingXiang() then
			balance = UserData.cardResult.ningxiang_player_balance
		end
		for k,v in ipairs(balance) do
			if #v.hu_info > 0 then
				for i,j in pairs(json.decode(v.hu_info)) do
					if j then
						table.insert(huList,{i,k})
					end
				end
			end
		end
		local playIndex = 1
		local playHu = nil
		playHu = function(huType)
			if huType then
				local animation = nil
				if huType[1] ~= "pinghu" then
					animation = AnimationView:create("hu","action/".. huType[1] ..".csb")
					-- AudioMgr:on_hu_type(huType[1],curHuPlayer:get_sex())--绑音效
				else
					animation = AnimationView:create("hu","action/hu".. curHuType ..".csb")
					-- AudioMgr:on_hu(curHuPlayer:get_sex(),curHuType)
				end
				animation:setPosition(nomalPosition[helper.getRealPos(huType[2],UserData.myChairId,UserData.table_config.player_count)])
			    animation:gotoFrameAndPlay(0,false)
			    animation:addTo(layer,1000)
				performWithDelay(layer, function()
					playHu(huList[playIndex])
			    end, 1)
			else
				if UserData.table_config.rule.find_bird and UserData.table_config.rule.find_bird > 0 then
		        	catchBirdAction(layer)
		        else
		        	curHuType = nil
					curHuPlayer = nil
					UIMgr:openUI(consts.UI.cardResultUI)
					UserData.game_status = UserData.GAME_STATUS.nextWaiting
		        end
			end
			playIndex = playIndex + 1
		end

		--大胡要显示胡的类型
		if huList[1][1] ~= "pinghu" then
			local animation = AnimationView:create("hu","action/hu".. curHuType ..".csb")
			-- AudioMgr:on_hu(curHuPlayer:get_sex(),curHuType)
			animation:setPosition(nomalPosition[helper.getRealPos(huList[1][2],UserData.myChairId,UserData.table_config.player_count)])
		    animation:gotoFrameAndPlay(0,false)
		    animation:addTo(layer,1000)
			performWithDelay(layer, function()
				playHu(huList[playIndex])
		    end, 1)
		else
			playHu(huList[playIndex])
		end
	elseif UserData:isZhuanZhuan() or UserData.isChenZhou() or UserData.isHongZhong() or UserData:isChangDe() then
		local animation = AnimationView:create("hu","action/hu".. curHuType ..".csb")
		AudioMgr:on_hu(curHuPlayer:get_sex(),curHuType)
		animation:setPosition(nomalPosition[curHuPlayer.pos])
	    animation:gotoFrameAndPlay(0,false)
	    animation:addTo(layer,1000)
		performWithDelay(layer, function()
			if UserData.table_config.rule.find_bird and UserData.table_config.rule.find_bird > 0 then
	        	catchBirdAction(layer)
	        else
	        	curHuType = nil
				curHuPlayer = nil
				UIMgr:openUI(consts.UI.cardResultUI)
				UserData.game_status = UserData.GAME_STATUS.nextWaiting
	        end
	    end, 1)
	end
end

function MjActionLogic:curGameEndAction(layer,huType,huPlayer)
	curHuType = huType
	curHuPlayer = huPlayer
	executeBirdCardOnce = false
	if curHuType and curHuPlayer then
		huAction(layer)
	else
		curHuType = nil
		curHuPlayer = nil
        print("rrrrrrrrrrrrrrrrrrrr--11")
		UIMgr:openUI(consts.UI.cardResultUI)
		UserData:setGameStatus(UserData.GAME_STATUS.nextWaiting)
        print("rrrrrrrrrrrrrrrrrrrr--22")
	end
end

function MjActionLogic:replaySceneHu(layer,huType,huPlayer)
	curHuType = huType
	curHuPlayer = huPlayer
	huAction(layer)
end

function MjActionLogic:firstHuAction(layer,pList,data,callback)
	local index = 1
	local playerList = pList
	local firstHuData = data
	local playPlayerHu = nil
	local playHu = nil
	local playIndex = 1
	playHu = function(player,huTypeList)
		if huTypeList[playIndex] then
			print("pos:",player.pos,"huTyp:",huTypeList[playIndex])
			local animation = AnimationView:create("firsthu","action/".. huTypeList[playIndex] ..".csb")
			-- AudioMgr:on_hu_type(huTypeList[playIndex],player:get_sex())--绑音效
			animation:setPosition(nomalPosition[player.pos])
		    animation:gotoFrameAndPlay(0,false)
		    animation:addTo(layer:getParent(),1000)
		    playIndex = playIndex + 1
			performWithDelay(layer, function()
				playHu(player,huTypeList)
		    -- end, 1)
		    end, 3)
		else
			if player.pos ~= 1 then
				player:hideCards()
			end
			playPlayerHu(playerList[index],firstHuData[tostring(index)])
		end
	end
	playPlayerHu = function (player,huData)
		if index > #playerList then
			callback()
			return 
		end
		index = index + 1
		if huData then
			playIndex = 1
			if player.pos ~= 1 then
				player:hu(huData.huCard)
			end
			playHu(player,huData.huType)
			AudioMgr:on_hu(player:get_sex())
		else
			playPlayerHu(playerList[index],firstHuData[tostring(index)])
		end
	end
	playPlayerHu(playerList[index],firstHuData[tostring(index)])
end

return MjActionLogic