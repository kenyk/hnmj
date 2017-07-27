--
-- Author: LXL
-- Date: 2016-11-08 09:20:25
--

local ClubInputCreate = class("ClubInputCreate", cc.load("mvc").UIBase)
local index = 0

ClubInputCreate.RESOURCE_FILENAME = "uiClub/ClubInputCreate.csb"
-- ClubInputCreate.RESOURCE_MODELNAME = "app.views.ui.join.JoinModel"

function ClubInputCreate:onCreate(rate)
 	self.closeBtn = helper.findNodeByName(self.resourceNode_,"closeBtn")
 	self.closeBtn:setPressedActionEnabled(true)
    self:setInOutAction()
    self.textList = {}
    for i = 1 , 6 do
    	self.textList[i] = helper.findNodeByName(self.resourceNode_,"Text_"..i)
    end
   	for i = 0 , 11 do
		helper.findNodeByName(self.resourceNode_,"Button_"..i):setPressedActionEnabled(true)
   	end

    self.box_1 = helper.findNodeByName(self.resourceNode_,"box_1")
    self.box_2 = helper.findNodeByName(self.resourceNode_,"box_2")
    self.box_3 = helper.findNodeByName(self.resourceNode_,"box_3")
    self.txt_num1 = helper.findNodeByName(self.resourceNode_,"txt_num1")
    self.txt_num2 = helper.findNodeByName(self.resourceNode_,"txt_num2")
    self.txt_num3 = helper.findNodeByName(self.resourceNode_,"txt_num3")
    self.box_1:setSelected(true)
    local boxHandler = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            for i=1,3 do
                if self["box_"..i] == sender then
                    self["box_"..i]:setSelected(true)
                else
                    self["box_"..i]:setSelected(false)
                end
            end
        end
    end
    self.box_1:addTouchEventListener(boxHandler)
    self.box_2:addTouchEventListener(boxHandler)
    self.box_3:addTouchEventListener(boxHandler)

    self.rate = rate
    for i=1,3 do
        local cost = UserData.groupHolderTbl["rule"..i]
        -- local str = string.gsub(self["txt_num"..i]:getString(),"X","")
        self["txt_num"..i]:setString(tonumber(cost) * rate)
    end
end



function ClubInputCreate:onEnter()
    ClubInputCreate.super.onEnter(self)
	self.numStr = ""
	index = 0
end

function ClubInputCreate:setInput()
	for k,v in ipairs(self.textList) do
		if k<=index then
			v:setString(string.sub(self.numStr,k,k))
		else
			v:setString("")
		end
	end
end

function ClubInputCreate:queryRoom()

	--需要获取定位的房间
	if(UserData.numStrTmp and UserData.numStrTmp == self.numStr)then
		local result = self:needLocation()
		if(not result)then return end
	end

	local sendData = {enter_code =  self.numStr}

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
            	UserData.numStrTmp = nil
                local addressSplit = string.split(entity.address, ":")
                local ip =  addressSplit[1]
                local port = addressSplit[2]
                GnetMgr:initConnect(ip, port,handler(self,self.connectSuccess))
            elseif response and response.errCode then
                UIMgr:closeUI(consts.UI.LoadingDialogUI)
                if(response.errCode == -100)then
                	UserData.numStrTmp = self.numStr
                	self:locationTip("   无法获取您的位置信息\n         请打开定位功能",function() LuaCallPlatformFun.toLocationSetting() end)
                else
                	GnetMgr:showErrorTips(response.errCode, true)
                end
            else
                self:queryRoom()
            end
        end)
end

function ClubInputCreate:connectSuccess()
	UserData.numStr = self.numStr
	self:send("room_enter_room",{enter_code = self.numStr})
end

function ClubInputCreate:numberHandler(sender)
	local tag = sender:getTag()
	if #self.numStr >=2 and tag < 10 then return end
    if #self.numStr == 0 and 0 == tag then return end
	if tag < 10 then
		self.numStr = self.numStr .. tag
		index = index + 1
	elseif tag == 10 then
		self.numStr = ""
		index = 0
	elseif tag == 11 then
		if index < 2 then
			self.numStr = ""
			index = 0
		else
			index = index - 1
			self.numStr = string.sub(self.numStr, 1, index)
		end
	end
    if self.numStr ~= "" and tonumber(self.numStr) > 30 then
        self.numStr = tostring(30)
    end
	self:setInput()
	print(tag,index,self.numStr)
end

function ClubInputCreate:onClose()
	self:close()
end

function ClubInputCreate:onConfirm()
    print(tonumber(self.numStr))
    local cost
    for i=1,3 do
        if self["box_"..i]:isSelected() then
            cost = tonumber(self["txt_num"..i]:getString()) / self.rate
            break
        end
    end
    if "" == self.numStr then
        return
    end
    NotifyMgr:push(consts.Notify.PILIANGCREATE, {roomNum = tonumber(self.numStr), cost = cost})
    self:close()
end

return ClubInputCreate