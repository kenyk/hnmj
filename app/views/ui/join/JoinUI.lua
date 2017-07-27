--
-- Author: LXL
-- Date: 2016-11-08 09:20:25
--

local JoinUI = class("JoinUI", cc.load("mvc").UIBase)
local index = 0

JoinUI.RESOURCE_FILENAME = "uiJoin/UI_Join.csb"
JoinUI.RESOURCE_MODELNAME = "app.views.ui.join.JoinModel"

function JoinUI:onCreate()
 --    self.loginBtn = helper.findNodeByName(self.resourceNode_,"loginBtn")
 --    self.loginBtn:setPressedActionEnabled(true)
	-- self.loginAgree = helper.findNodeByName(self.resourceNode_,"loginAgree")
 --    self.login_test = helper.findNodeByName(self.resourceNode_,"login_test")
 	self.closeBtn = helper.findNodeByName(self.resourceNode_,"closeBtn")
 	self.closeBtn:setPressedActionEnabled(true)
    self:setInOutAction()
    self.textList = {}
    for i = 1 , 6 do
    	self.textList[i] = helper.findNodeByName(self.resourceNode_,"Text_"..i)
        self.textList[i]:setString("")
    end
   	for i = 0 , 11 do
		helper.findNodeByName(self.resourceNode_,"Button_"..i):setPressedActionEnabled(true)
   	end

   	--方便在WIN32上调试
	if consts.App.APP_PLATFORM == cc.PLATFORM_OS_WINDOWS and WIN32DEBUG then
		performWithDelay(display.getRunningScene(), function()
            local JoinDebug = require "JoinDebug"
			self.roomId = JoinDebug.roomId
			self:queryRoom()
        end, 0.2)
    end
end



function JoinUI:onEnter()
    JoinUI.super.onEnter(self)
	self.roomId = ""
	index = 0
end

function JoinUI:setRoomId()
	for k,v in ipairs(self.textList) do
		if k<=index then
			v:setString(string.sub(self.roomId,k,k))
		else
			v:setString("")
		end
	end
	if #self.roomId ==6 then
		--self:send("room_enter_room",{enter_code = roomId})
		UIMgr:showLoadingDialog("加入房间中...")
		if(not Is_App_Store)then
        	self:queryRoom()
        else
        	self:connectSuccess()
        end
	end
end

function JoinUI:queryRoom()

	--需要获取定位的房间
	if(UserData.roomIdTmp and UserData.roomIdTmp == self.roomId)then
		local result = self:needLocation()
		if(not result)then return end
	end

	local sendData = {enter_code =  self.roomId}

	--防作弊模式
	if(Is_Cheat_Set and LuaCallPlatformFun.isOpenLocation())then
        if(not Is_App_Store) then                   -- android开启高德地图
            LuaCallPlatformFun.openLocation()
        end
        local pos = LuaCallPlatformFun.getLocation()
        if(pos)then
            sendData.antiCheatLon = pos.longitude
            sendData.antiCheatLat = pos.latitude
        end
	end
    HttpServiers:queryRoom(sendData,
        function(entity,response,statusCode)
            if entity  then
            	UserData.roomIdTmp = nil
                local addressSplit = string.split(entity.address, ":")
                local ip =  addressSplit[1]
                local port = addressSplit[2]
                GnetMgr:initConnect(ip, port,handler(self,self.connectSuccess))
            elseif response and response.errCode then
                UIMgr:closeUI(consts.UI.LoadingDialogUI)
                if(response.errCode == -100)then
                	UserData.roomIdTmp = self.roomId
                	self:locationTip("   无法获取您的位置信息\n         请打开定位功能",function() LuaCallPlatformFun.toLocationSetting() end)
                else
                	GnetMgr:showErrorTips(response.errCode, true)
                end
            else
                self:queryRoom()
            end
        end)
end

function JoinUI:connectSuccess()
	UserData.roomId = self.roomId
	self:send("room_enter_room",{enter_code = self.roomId})
end

function JoinUI:numberHandler(sender)
	local tag = sender:getTag()
	if #self.roomId >=6 and tag < 10 then return end
	if tag < 10 then
		self.roomId = self.roomId .. tag
		index = index + 1
	elseif tag == 10 then
		self.roomId = ""
		index = 0
	elseif tag == 11 then
		if index < 2 then
			self.roomId = ""
			index = 0
		else
			index = index - 1
			self.roomId = string.sub(self.roomId, 1, index)
		end
	end
	self:setRoomId()
	print(tag,index,self.roomId)
end

function JoinUI:onClose()
	self:close()
	-- body
end

function JoinUI:locationTip( str ,callback)
    local dialogContentLabel1=helper.createRichLabel({maxWidth = 600,fontSize = 30})
    dialogContentLabel1:setString(str)
    dialogContentLabel1:setColor(cc.c3b(153, 78, 46))
    local dialogContent =cc.Layer:create()
    dialogContentLabel1:addTo(dialogContent,1)
    UIMgr:showConfirmDialog("防作弊模式房间",{child=dialogContent, childOffsetY= 25},callback,function()end)
end

function JoinUI:needLocation()
    --先判断定位是否开启
    local deny = LuaCallPlatformFun.isOpenLocation()
    if(deny)then
        if(not Is_App_Store) then                   -- android开启高德地图
            LuaCallPlatformFun.openLocation()
        end
        local tab = LuaCallPlatformFun.getLocation()
        if(not tab)then
            self:locationTip("   暂时无法获取您的位置信息，\n                请稍后尝试",function()end)
        else
        	return true
        end
    else
        self:locationTip("   无法获取您的位置信息\n         请打开定位功能",function() LuaCallPlatformFun.toLocationSetting() end)
    end
end

return JoinUI