--
-- Author: LXL
-- Date: 2016-11-08 09:20:25
--

local ActivateUI = class("ActivationUI", cc.load("mvc").UIBase)
local index = 0

ActivateUI.RESOURCE_FILENAME = "uiActivate/UI_Activate.csb"
ActivateUI.RESOURCE_MODELNAME = "app.views.ui.activation.ActivationModel"

function ActivateUI:onCreate()
    self:setInOutAction()
    self.textList = {}
    for i = 1 , 7 do
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
			self.activationCode = JoinDebug.activationCode
			self:setActivationCode()
        end, 0.2)
    end
end


function ActivateUI:onEnter()
    ActivateUI.super.onEnter(self)
	self.activationCode = ""
	index = 0
end

function ActivateUI:setCode()
	for k,v in ipairs(self.textList) do
		if k<=index then
			v:setString(string.sub(self.activationCode,k,k))
		else
			v:setString("")
		end
	end
	if #self.activationCode == 7 then
		--self:send("room_enter_room",{enter_code = activationCode})
		UIMgr:showLoadingDialog("设置激活码中...")
		if(not Is_App_Store)then
        	self:setActivationCode()
        else
        	self:connectSuccess()
        end
	end
end

function ActivateUI:setActivationCode()

    local sendData = {userId =  UserData.uid,
                    appId = consts.appId,
                    appCode = consts.appCode,
                    activationCode = self.activationCode,
                    token = UserData.userInfo.token
    }

    HttpServiers:setActivationCode(sendData,
        function(entity,response,statusCode)
            if response and (response.status == 1 or response.errCode == 0) then
                UserData.userInfo.activationCode =  response.data.activationCode
                
                --UIMgr:showTips("成功激活!")
                UIMgr:openUI(consts.UI.mainUI)
                self:onClose()
            else
                UIMgr:showTips(response.error)
                print("错误码：",response.errCode,"错误信息：",response.error)
            end
        end)
end

function ActivateUI:connectSuccess()
	UserData.userInfo.activationCode = self.activationCode
	self:send("room_enter_room",{enter_code = self.activationCode})
end

function ActivateUI:numberHandler(sender)
	local tag = sender:getTag()
	if #self.activationCode >=7 and tag < 10 then return end
	if tag < 10 then
		self.activationCode = self.activationCode .. tag
		index = index + 1
	elseif tag == 10 then
		self.activationCode = ""
		index = 0
	elseif tag == 11 then
		if index < 2 then
			self.activationCode = ""
			index = 0
		else
			index = index - 1
			self.activationCode = string.sub(self.activationCode, 1, index)
		end
	end
	self:setCode()
	print(tag,index,self.activationCode)
end

function ActivateUI:onClose()
	self:close()
	-- body
end

-- function ActivateUI:locationTip( str ,callback)
--     local dialogContentLabel1=helper.createRichLabel({maxWidth = 600,fontSize = 30})
--     dialogContentLabel1:setString(str)
--     dialogContentLabel1:setColor(cc.c3b(153, 78, 46))
--     local dialogContent =cc.Layer:create()
--     dialogContentLabel1:addTo(dialogContent,1)
--     UIMgr:showConfirmDialog("防作弊模式房间",{child=dialogContent, childOffsetY= 25},callback,function()end)
-- end

-- function ActivateUI:needLocation()
--     --先判断定位是否开启
--     local deny = LuaCallPlatformFun.isOpenLocation()
--     if(deny)then
--         if(not Is_App_Store) then                   -- android开启高德地图
--             LuaCallPlatformFun.openLocation()
--         end
--         local tab = LuaCallPlatformFun.getLocation()
--         if(not tab)then
--             self:locationTip("   暂时无法获取您的位置信息，\n                请稍后尝试",function()end)
--         else
--         	return true
--         end
--     else
--         self:locationTip("   无法获取您的位置信息\n         请打开定位功能",function() LuaCallPlatformFun.toLocationSetting() end)
--     end
-- end

return ActivateUI
