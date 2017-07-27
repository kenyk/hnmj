--
-- Author: LXL
-- Date: 2016-11-08 09:20:25
--

local ClubCreateMany = class("ClubCreateMany", cc.load("mvc").UIBase)

ClubCreateMany.RESOURCE_FILENAME = "uiClub/ClubCreateMany.csb"
ClubCreateMany.RESOURCE_MODELNAME = "app.views.ui.club.ClubCreateManyModel"
local ClubRoomItem = require "app.views.ui.club.ClubRoomItem"

local page = 1

function ClubCreateMany:onCreate()
 	self.btnBack = helper.findNodeByName(self.resourceNode_,"btnBack")
 	self.content_node = helper.findNodeByName(self.resourceNode_,"content_node")
 	self.btn_right = helper.findNodeByName(self.resourceNode_,"btn_right")
 	self.btn_left = helper.findNodeByName(self.resourceNode_,"btn_left")
 	self.txt_curNum = helper.findNodeByName(self.resourceNode_,"txt_curNum")
 	self.btn_refresh = helper.findNodeByName(self.resourceNode_,"btn_refresh")
 	self.btnBack:setPressedActionEnabled(true)
    self:setInOutAction()

    for i=1,10 do
        local item = ClubRoomItem:create()
        self.content_node:addChild(item)
        print(i /5, i)
        item:setPosition(cc.p(-540 + ((i - 1) % 5) * 220, 60 - (math.ceil(i / 5) - 1) * 220))
        item:setVisible(false)
        self["clubRoomItem"..i] = item
    end

end

function ClubCreateMany:onEnter()
    ClubCreateMany.super.onEnter(self)

    self.curPage = 1
    local str = cc.UserDefault:getInstance():getStringForKey("clubGroupHolderIpAndPort")
    if str ~= "" then
    	local addressSplit = string.split(str, ":")
	    local ip =  addressSplit[1]
	    local port = addressSplit[2]
	    GnetMgr:initConnect(ip, port, function ()
	    	GnetMgr:send("get_batch_room_list", {page = self.curPage})
	    end)
    end
end

function ClubCreateMany:onExit()
	ClubCreateMany.super.onExit(self)
	self:stopAllActions()
end

function ClubCreateMany:onBack()
	self:close()
end

function ClubCreateMany:onCreatePiLiang()
	self.createRoomUITwo = UIMgr:openUI(consts.UI.createRoomUITwo)
	self.createRoomUITwo.isPiLiang = true
	self.createRoomUITwo.cheat_node:setVisible(false)
	-- self:close()
end

function ClubCreateMany:onInvite()
	self:close()
end

function ClubCreateMany:onAllOut()
	local dialogContentLabel1 = helper.createRichLabel({maxWidth = 600,fontSize = 30,fontColor = consts.ColorType.THEME})
    dialogContentLabel1:setString("是否解散当前页的所有房间")
	self.applyDismissDialog=UIMgr:showConfirmDialog("提示", {child = dialogContentLabel1, childOffsetY = 10}, function ()
		local dismissList = {}
		for i=1,10 do
			local data = self["clubRoomItem"..i].data
			if data then
				table.insert(dismissList, tonumber(data.room_id))
			end
		end
		GnetMgr:send("dismiss_batch_room", {handle = dismissList})
	end, function ()
		
	end, self)
end

function ClubCreateMany:onPageFlip(sender)
	-- if self.btn_left == sender then
	-- 	self.curPage = self.curPage - 1
	-- else
	-- 	self.curPage = self.curPage + 1
	-- end
	if self.btn_left == sender then
		page = self.curPage - 1
	else
		page = self.curPage + 1
	end
	GnetMgr:send("get_batch_room_list", {page = page})
	-- self:setPage()
end

function ClubCreateMany:setPage()
	self.btn_left:setVisible(true)
	self.btn_right:setVisible(true)
	if 1 == self.curPage then
		self.btn_left:setVisible(false)
	end
	if self.curPage == self.totalPage then
		self.btn_right:setVisible(false)
	end
end

function ClubCreateMany:proListHandler(msg)
	if msg.name == "get_batch_room_list" then
        -- print("房号：",msg.args.enter_code)
        -- print("****", "get_batch_room_list")
        if 20018 == msg.args.code then
        	local dialogContentLabel1 = helper.createRichLabel({maxWidth = 600,fontSize = 30,fontColor = consts.ColorType.THEME})
		    dialogContentLabel1:setString("每10秒内只可刷新一次")
			self.applyDismissDialog=UIMgr:showConfirmDialog("提示", {child = dialogContentLabel1, childOffsetY = 10}, function ()
				
			end)
        	return
        end
        if nil == msg.args.list then
        	return
        end
        for i=1, 10 do
        	local data = msg.args.list[i]
        	self["clubRoomItem"..i]:updateData(data)
        end
        self.curTotalNum = msg.args.total or 0
        self.txt_curNum:setString(string.format("%d/%d", self.curTotalNum, 30))
        self.totalPage = math.ceil(self.curTotalNum / 10)
        self.curPage = page
        self:setPage()
    elseif msg.name == "room_enter_room" then
        
    end
end

function ClubCreateMany:onRefresh()
	GnetMgr:send("get_batch_room_list", {page = self.curPage})
	-- self.btn_refresh:setVisible(false)
	-- performWithDelay(self, function()
	-- 	self.btn_refresh:setVisible(true)
 -- 	end, 5)
end
return ClubCreateMany