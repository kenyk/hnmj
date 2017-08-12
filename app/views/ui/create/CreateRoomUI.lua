--
-- Author: LXL
-- Date: 2016-11-04 16:28:18
--

local dataMgr = import(".CreateRoomData")

local CreateRoomUI = class("CreateRoomUI", cc.load("mvc").UIBase)
CreateRoomUI.RESOURCE_FILENAME = "uiCreate/UI_CreateRoom.csb"
CreateRoomUI.RESOURCE_MODELNAME = "app.views.ui.create.CreateRoomModel"

local function setSelected(btn,isSelect,custom)
	local image = helper.findNodeByName(btn,"Image")
	local label = helper.findNodeByName(btn,"Label")

    if custom then
        local tick = helper.findNodeByName(btn,"tick")
        tick:setVisible(isSelect) 
    else
        if btn:isSelected() ~= isSelect then
		    btn:setSelected(isSelect)
	    end
    end
           
	image:setVisible(isSelect)
	label:setVisible(not isSelect)
end

function CreateRoomUI:onCreate()
    self.btnBack = helper.findNodeByName(self.resourceNode_,"btnBack")
    self.btnBack:setPressedActionEnabled(true)
    self.createBtn = helper.findNodeByName(self.resourceNode_,"createBtn")
    self.createBtn:setPressedActionEnabled(true)
    self.ckHelpCreate = helper.findNodeByName(self.resourceNode_,"ckHelpCreate")

    self.ckBoxList = {{},{},{},{},{}}
    self.ckBoxList[1][1] = helper.findNodeByName(self.resourceNode_,"ckC8")
    self.ckBoxList[1][2] = helper.findNodeByName(self.resourceNode_,"ckC16")
    self.ckBoxList[2][1] = helper.findNodeByName(self.resourceNode_,"ckP4")
    self.ckBoxList[2][2] = helper.findNodeByName(self.resourceNode_,"ckP3")
    self.ckBoxList[2][3] = helper.findNodeByName(self.resourceNode_,"ckP2")
    self.ckBoxList[3][1] = helper.findNodeByName(self.resourceNode_,"ckWin1")
    self.ckBoxList[3][2] = helper.findNodeByName(self.resourceNode_,"ckWin2")
    self.ckBoxList[3][3] = helper.findNodeByName(self.resourceNode_,"ckWinRule")
    self.ckBoxList[4][1] = helper.findNodeByName(self.resourceNode_,"ckRule1")
    self.ckBoxList[4][2] = helper.findNodeByName(self.resourceNode_,"ckRule2")
    self.ckBoxList[4][3] = helper.findNodeByName(self.resourceNode_,"ckRule3")
    self.ckBoxList[4][4] = helper.findNodeByName(self.resourceNode_,"ckPRule")
    self.ckBoxList[5][1] = helper.findNodeByName(self.resourceNode_,"ckPick2")
    self.ckBoxList[5][2] = helper.findNodeByName(self.resourceNode_,"ckPick4")
    self.ckBoxList[5][3] = helper.findNodeByName(self.resourceNode_,"ckPick6")
    dataMgr:init(self.ckBoxList)
    -- self.ckBoxList[4][3]:setVisible(false)
    -- self.ckBoxList[4][4]:setVisible(false)

    self.ckBoxListPanel = {{},{},{},{},{}}
    self.ckBoxListPanel[1][1] = helper.findNodeByName(self.resourceNode_,"Panel_1_1")
    self.ckBoxListPanel[1][2] = helper.findNodeByName(self.resourceNode_,"Panel_1_2")
    self.ckBoxListPanel[2][1] = helper.findNodeByName(self.resourceNode_,"Panel_2_1")
    self.ckBoxListPanel[2][2] = helper.findNodeByName(self.resourceNode_,"Panel_2_2")
    self.ckBoxListPanel[2][3] = helper.findNodeByName(self.resourceNode_,"Panel_2_3")
    self.ckBoxListPanel[3][1] = helper.findNodeByName(self.resourceNode_,"Panel_3_1")
    self.ckBoxListPanel[3][2] = helper.findNodeByName(self.resourceNode_,"Panel_3_2")
    self.ckBoxListPanel[3][3] = helper.findNodeByName(self.resourceNode_,"Panel_3_3")
    self.ckBoxListPanel[4][1] = helper.findNodeByName(self.resourceNode_,"Panel_4_1")
    self.ckBoxListPanel[4][2] = helper.findNodeByName(self.resourceNode_,"Panel_4_2")
    self.ckBoxListPanel[4][3] = helper.findNodeByName(self.resourceNode_,"Panel_4_3")
    self.ckBoxListPanel[4][4] = helper.findNodeByName(self.resourceNode_,"Panel_4_4")
    self.ckBoxListPanel[5][1] = helper.findNodeByName(self.resourceNode_,"Panel_5_1")
    self.ckBoxListPanel[5][2] = helper.findNodeByName(self.resourceNode_,"Panel_5_2")
    self.ckBoxListPanel[5][3] = helper.findNodeByName(self.resourceNode_,"Panel_5_3")
    -- self.ckBoxListPanel[4][3]:setVisible(false)
    -- self.ckBoxListPanel[4][4]:setVisible(false)

end

function CreateRoomUI:onEnter()
	local defaultData = dataMgr:getGameTypeData(consts.DefauleGameType)
	for i,data in ipairs(self.ckBoxList) do
		for j,v in ipairs(data) do
            if i == 4 or (i == 3 and j  == 3) then
                setSelected(v,defaultData[i][j] == 1, true)
            else
                setSelected(v,defaultData[i][j] == 1)
            end
		end
	end
	self:checkPlayerNum()
	self:checkBird()
end

function CreateRoomUI:checkPlayerNum()
	if self.ckBoxList[2][3]:isSelected() then
		setSelected(self.ckBoxList[5][1],false)
		setSelected(self.ckBoxList[5][2],false)
		setSelected(self.ckBoxList[5][3],false)
	end
    self.ckBoxListPanel[4][3]:setTouchEnabled(not self.ckBoxList[2][3]:isSelected())
	self.ckBoxListPanel[5][1]:setTouchEnabled(not self.ckBoxList[2][3]:isSelected())
	self.ckBoxListPanel[5][2]:setTouchEnabled(not self.ckBoxList[2][3]:isSelected())
	self.ckBoxListPanel[5][3]:setTouchEnabled(not self.ckBoxList[2][3]:isSelected())

    self:setEnabled(self.ckBoxList[4][3],not self.ckBoxList[2][3]:isSelected())
	self.ckBoxList[5][3]:setEnabled(not self.ckBoxList[2][3]:isSelected())
	self.ckBoxList[5][2]:setEnabled(not self.ckBoxList[2][3]:isSelected())
	self.ckBoxList[5][1]:setEnabled(not self.ckBoxList[2][3]:isSelected())
    self:checkBird()
end

function CreateRoomUI:setEnabled(ui,bool)
    local image = helper.findNodeByName(ui,"Image")
	local label = helper.findNodeByName(ui,"Label")
    local tick = helper.findNodeByName(ui,"tick")
    if bool then
        ui:loadTexture("uires/common/chose_1_N.png")
    else
        image:setVisible(false)
	    label:setVisible(true)
        tick:setVisible(false)
        ui:loadTexture("uires/common/chose_1_D.png")
    end
end

function CreateRoomUI:checkBird()
	local selected = false
	for k,btn in ipairs(self.ckBoxList[5]) do
		selected = selected or btn:isSelected()
	end
    self:setEnabled(self.ckBoxList[4][4], selected)
    self.ckBoxListPanel[4][4]:setTouchEnabled(selected)
end

function CreateRoomUI:onCreateHandler(event)
    if tonumber(UserData.userInfo.surplusGameCard) < dataMgr:getUseNum() then
        UIMgr:showTips("房卡不足，创建失败\n\n购买房卡：请联系代理！")
        return
    end
    UIMgr:showLoadingDialog("创建房间中...")
    dataMgr:setGameTypeData(consts.DefauleGameType)
    self:creatRoom()
end

function CreateRoomUI:queryRoom()
    HttpServiers:queryRoom({enter_code =  self.enter_code},
        function(entity,response,statusCode)
            if entity then
                local addressSplit = string.split(entity.address, ":")
                local ip =  addressSplit[1]
                local port = addressSplit[2]
                GnetMgr:initConnect(ip, port,handler(self,self.connectSuccess))
            elseif response and response.errCode then
                UIMgr:closeUI(consts.UI.LoadingDialogUI)
                GnetMgr:showErrorTips(response.errCode, true)
            else
                UIMgr:showNetErrorTip(function()
                    self:queryRoom()
                end)
            end
        end)
end

function CreateRoomUI:creatRoom()
    HttpServiers:creatRoom({
        useNum = dataMgr:getUseNum(),
        orderType = "1",
        player_count = dataMgr:getPlayerNum(),
  	    rate = 1,
  	    game_count = dataMgr:getGameNum(),
  	    data = dataMgr:getGameRule()}, 
        
            function(entity,response,statusCode)
            dump(response)
                if entity then
                    self.enter_code  = entity.enter_code
                    self:queryRoom()
                elseif response and response.errCode then
                    UIMgr:closeUI(consts.UI.LoadingDialogUI)
                    GnetMgr:showErrorTips(response.errCode, true)
                else
                    UIMgr:showNetErrorTip(function()
                        self:creatRoom()
                    end)
                end
            end)
end

function CreateRoomUI:connectSuccess()
	UserData.roomId = self.enter_code
	self:send("room_enter_room",{enter_code = self.enter_code})
end

function CreateRoomUI:checkList1or2(i,j)
	for k,btn in ipairs(self.ckBoxList[i]) do
		setSelected(btn,k == j)
	end
	if i == 2 then
		self:checkPlayerNum()
	end
end

function CreateRoomUI:checkList3(i,j)
	local btn = self.ckBoxList[i][j]
	if j == 3 then
		setSelected(btn,not helper.findNodeByName(btn,"tick"):isVisible(), true)
	else
		setSelected(self.ckBoxList[i][1],btn == self.ckBoxList[i][1])
		setSelected(self.ckBoxList[i][2],btn == self.ckBoxList[i][2])
	end
end

function CreateRoomUI:checkList5(i,j)
	local ckPRule = self.ckBoxList[4][4]
	local btnIsSelect = self.ckBoxList[i][j]:isSelected()
	if btnIsSelect then
		setSelected(self.ckBoxList[i][j],false)
	else
		for k,btn in ipairs(self.ckBoxList[i]) do
			setSelected(btn,k == j)
		end
	end
	self:checkBird()
end

function CreateRoomUI:onCheckHandler(sender)
	for i,data in ipairs(self.ckBoxListPanel) do
		for j,btn in ipairs(data) do
			if btn == sender then
				if i == 1 or i == 2 then
					self:checkList1or2(i,j)
				elseif i == 3 then
					self:checkList3(i,j)
				elseif i == 5 then
					self:checkList5(i,j)
				else
                    local tick = helper.findNodeByName(self.ckBoxList[i][j],"tick")
					setSelected(self.ckBoxList[i][j],not tick:isVisible(), true)
				end
				return
			end
		end
	end
end

function CreateRoomUI:onBack(event)
	UIMgr:openUI(consts.UI.mainUI)
	self:close()
end

function CreateRoomUI:proListHandler(msg)
	if msg.name == "build_on_request_new_rooms" then

	elseif msg.name == "room_enter_room" then
		if helper.isCallbackSuccess(msg) then
			print("UserData.roomId:",UserData.roomId)
            UserData.createRoomTime =  os.date("%Y-%m-%d %H:%M:%S")
            UIMgr:closeUI(consts.UI.LoadingDialogUI)
            MyApp:goToGame()
		else
			UserData.roomId = nil
		end
	end
end

return CreateRoomUI