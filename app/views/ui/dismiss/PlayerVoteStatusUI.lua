--[[
	For:新投票显示页
		玩家投票状态
--]]
local PlayerVoteStatusUI = class("PlayerVoteStatusUI", cc.load("mvc").UIBase)

PlayerVoteStatusUI.RESOURCE_FILENAME = "uiDismiss/Player_Vote_Status.csb"

function PlayerVoteStatusUI:onCreate()
	self.headIcon = helper.findNodeByName(self.resourceNode_, "head_icon")
    if(Is_App_Store)then
        local icon = display.newSprite("uires/main/guest_icon_1.png", 0, 0)
        icon:setAnchorPoint(cc.p(0.5, 0))
        icon:addTo(self, -1)
    end
	self.playerName = helper.findNodeByName(self.resourceNode_, "player_name")

	self.choosingStatus = helper.findNodeByName(self.resourceNode_, "status_choosing"):setVisible(true)
	self.agreeStatus = helper.findNodeByName(self.resourceNode_, "status_agree"):setVisible(false)
	self.rejectStatus = helper.findNodeByName(self.resourceNode_, "status_reject"):setVisible(false)
	self.infoPanel = helper.findNodeByName(self.resourceNode_, "Panel_info")
end

function PlayerVoteStatusUI:refreshBaseInfo(userInfo)
	dump(userInfo)
	if userInfo then
	    self.playerName:setString(helper.nameAbbrev(userInfo.nickname))
        if  userInfo.image_url then
            local image = NetSprite:getSpriteUrl(userInfo.image_url,"mj/bg_default_avatar_2.png")
            image:setPosition(cc.p(self.headIcon:getContentSize().width / 2, self.headIcon:getContentSize().height / 2))
            image:setImageContentSize(cc.size(self.headIcon:getContentSize().width, self.headIcon:getContentSize().height))
            image:addTo(self.headIcon)
         end
	end
	--self.headframe = display.newSprite("mj/"..UserData:getCurBgType().."/head_kuang.png", 36, -10):setAnchorPoint(cc.p(0.5, 0))
	self.headframe = display.newSprite("mj/"..UserData:getCurBgType().."/head_kuang.png", self.headIcon:getContentSize().width / 2, self.headIcon:getContentSize().height / 2):setAnchorPoint(cc.p(0.5, 0.5))
	self.headframe:addTo(self.headIcon)
end

function PlayerVoteStatusUI:refreshStatus(status)
	local hasChoosed = false
	if status.isAgree == 0 then						-- 同意
		hasChoosed = true
		self.agreeStatus:setVisible(true)
	elseif status.isAgree == 1 then					-- 拒绝
		hasChoosed = true		
		self.rejectStatus:setVisible(true)
	end
	self.choosingStatus:setVisible(not hasChoosed)
end

return PlayerVoteStatusUI