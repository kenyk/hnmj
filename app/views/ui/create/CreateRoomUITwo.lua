--
-- Author: LHF
-- Date: 2016-12-23
--

local dataMgr = import(".CreateRoomData")

local CreateRoomUITwo = class("CreateRoomUITwo", cc.load("mvc").UIBase)
-- CreateRoomUITwo.RESOURCE_FILENAME = "uiCreate/UI_createRoom2.csb"
CreateRoomUITwo.RESOURCE_FILENAME = "uiCreate/UI_createRoom4.csb"
CreateRoomUITwo.RESOURCE_MODELNAME = "app.views.ui.create.CreateRoomModel"

local RoomTabBtn = require "app.views.ui.create.RoomTabBtn"
-- local RoomTabBtn = import(".RoomTabBtn")

local tabNum = 6
local function setSelected(btn,isSelect,custom)
    local image = helper.findNodeByName(btn:getParent(),"item_img")
    local label = helper.findNodeByName(btn:getParent(),"item_lab")
    if not btn.isSelected then
        local tick = helper.findNodeByName(btn,"tick")
        tick:setVisible(isSelect) 
    else
        if btn:isSelected() ~= isSelect then
            btn:setSelected(isSelect)
        end
    end
    -- btn.isSelect = isSelect
           
    -- image:setVisible(isSelect)
    -- label:setVisible(not isSelect)
    if isSelect then
        label:setColor(helper.str2Color("#cd320e"))
        -- label:setColor(helper.str2Color("#ab2a0c"))
        -- label:setColor(helper.str2Color("#ff0000"))
    else
        label:setColor(helper.str2Color("#82560b"))
        -- label:setColor(helper.str2Color("#835f4c"))
        -- label:setColor(helper.str2Color("#ab2a0c"))
        -- label:setColor(helper.str2Color("#00ff00"))
    end
end

local function isSelected(btn)
    if not btn.isSelected then
        local tick = helper.findNodeByName(btn,"tick")
        return tick:isVisible()
    else
        return btn:isSelected()
    end
end

function CreateRoomUITwo:onCloseBtnClick()
    -- self:close()
end

function CreateRoomUITwo:onCreate(clubData)
    print("经纬度:============")
    self:setInOutAction()
    self.btnBack = helper.findNodeByName(self.resourceNode_,"btnBack")
    self.btnBack:setPressedActionEnabled(true)

    self.list_tab = helper.findNodeByName(self.resourceNode_,"list_tab")
    --切页
    self.m_tab = {}
    for i=1,tabNum do
        local btn = RoomTabBtn:create(i)
        btn.m_btn:setTag(i)
        self["tab_btn_"..i] = btn
        btn.m_btn:addClickEventListener(function(sender) self:tabSelect(sender:getTag()) end)
        --btn:addClickEventListener(function(sender) self:tabSelect(sender:getTag()) end)
    end
    --1转转 2长沙 3郴州 4红中 5宁乡 6常德
    --顺序
     local tab_seq_list = {1, 2, 5, 4, 3, 6}
    for _, v in pairs(tab_seq_list) do
        self.list_tab:pushBackCustomItem(self["tab_btn_"..v])
    end

    helper.findNodeByName(self.resourceNode_,"createBtn"):setPressedActionEnabled(true)
    --选项点
    self.m_item_node = helper.findNodeByName(self.resourceNode_,"item_node")
    self.m_item_node:setVisible(false)
    self.item_node_bg = helper.findNodeByName(self.resourceNode_,"item_node_bg")

    local card_des = helper.findNodeByName(self.resourceNode_,"card_des")
    card_des:setVisible(not Is_App_Store)
    --card_des:setVisible(false)
    dataMgr:setNeedJewel(nil)
    dataMgr:setClubData(nil)

    --防作弊模式
    local cheat_node = helper.findNodeByName(self.resourceNode_,"cheat_node")
    cheat_node:setVisible(Is_Cheat_Set)
    self.cheat_node = cheat_node

    --俱乐部
    local club_node = helper.findNodeByName(self.resourceNode_,"club_node")
    club_node:setVisible(clubData ~= nil)
    self.club_node = club_node
    if(not clubData)then return end
    self.m_clubData = clubData
    dataMgr:setNeedJewel(self.m_clubData.jewelNum)
    dataMgr:setClubData(clubData)

    local richTextU = string.format("<div fontcolor=#ff0000 >%s</div><div fontSize=25 fontcolor=#8E6C59>的俱乐部</div>",clubData.clubName)
    -- local richTextU = string.format("<div fontcolor=#ff0000 >%s</div><div fontSize=25 fontcolor=#8E6C59>的俱乐部</div>","水电费发过的")
    local clubTipU = helper.createRichLabel({maxWidth = 300,fontSize = 30,fontColor = cc.c3b(65, 135, 67)})
    clubTipU:setAnchorPoint(cc.p(0,1))
    clubTipU:setPosition(cc.p(90,-130)):addTo(club_node,100)
    clubTipU:setString(richTextU)

    helper.findNodeByName(club_node,"Text_jewel_num"):setString(tostring(clubData.jewelNum))
end

function CreateRoomUITwo:checkJewelNum()
    if self.m_clubData then
        if isSelected(self.m_ckBoxList[1][1]) then
            helper.findNodeByName(self.club_node,"Text_jewel_num"):setString(tostring(self.m_clubData.jewelNum))
        else
            helper.findNodeByName(self.club_node,"Text_jewel_num"):setString(tostring(self.m_clubData.jewelNum * 2))
        end
    end
end

function CreateRoomUITwo:onEnter()
    CreateRoomUITwo.super.onEnter(self)
    self.m_select_tab = 0
    if(Is_App_Store)then
        self:tabSelect(1)
    else
        self:tabSelect(LocalData.data._mahjongTypeTab or 1)
    end
    NotifyMgr:reg(consts.Notify.PILIANGCREATE, self.creatRoom, self)
end

function CreateRoomUITwo:tabSelect( index )
    if(self.m_select_tab == index)then return end
    self.m_select_tab = index

    for i=1, tabNum do
        self["tab_btn_"..i]:setSelect(false)
    end
    self["tab_btn_"..index]:setSelect(true)

    dataMgr:setMahjongType(index)

    self.m_item_node:removeAllChildren()
    self.item_node_bg:removeAllChildren()
    local tab_msg = consts.roomCreateMsg["tab_"..index]
    if(not tab_msg)then return end

    local width = 800

    local bgHeight = 699
    local  startY = 450
    local  startX = 0

    --选择项
    self.m_ckBoxList = {}
    self.m_ckBoxListPanel = {}
    local lastBgBox
    local lastBgView
    local has_y = 1
    local y = 1
    local offsetY = 75
    local rowNum = 1
    for i=1,#tab_msg do
        local tmp = tab_msg[i]
        self.m_ckBoxList[i] = {}
        self.m_ckBoxListPanel[i] = {}
        -- if "" ~= tmp[1] and "-" ~= tmp[1] then
        --     local title =  ccui.Text:create(tmp[1], nil, 30):addTo(self.item_node_bg, 100)
        --     title:setColor(helper.str2Color("#82560b"))
        --     --title:setPosition(cc.p(cc.p(-60, -(has_y-1)*offsetY)))
        --     title:setAnchorPoint(cc.p(0,0))
        --     title:setPosition(cc.p(cc.p(0, -(has_y-1)*offsetY)))
        -- end

        
            --title:setPosition(cc.p(cc.p(-60, -(has_y-1)*offsetY)))

        local has_x = 1
        if "" ~= tmp[1] and "-" ~= tmp[1] then

            local bg_box = ccui.ImageView:create()
            bg_box:loadTexture("uires/createRoom/button2.png")
            bg_box:setScale9Enabled(true)
            bg_box:setContentSize(cc.size(width, 70))
            self.item_node_bg:addChild(bg_box)
            bg_box:setPosition(cc.p(startX, startY))

            local bgView = ccui.ImageView:create()
            bgView:loadTexture("uires/createRoom/baikuang.png")
            bgView:setScale9Enabled(true)
            bgView:setContentSize(cc.size(width, 70))
            bg_box:addChild(bgView)
            bgView:setAnchorPoint(cc.p(0, 1))
            bgView:setPosition(cc.p(0, 70))
            lastBgView = bgView

            --local bg_box_node = ccui.Node:create()

            bg_box:setAnchorPoint(cc.p(0, 1))
            lastBgBox = bg_box
            
            local title =  ccui.Text:create(tmp[1], nil, 30):addTo(bg_box, 100)
            title:setColor(helper.str2Color("#613d1b"))
            title:setAnchorPoint(cc.p(0,1))
            title:setPosition(cc.p(15, 70-20))

            rowNum = 1
            startY = startY - 70 -10

        elseif "-" ~= tmp[1] then
            --lastBgBox:setContentSize(cc.size(width, 140))
            rowNum = rowNum+1
            lastBgView:setContentSize(cc.size(width, rowNum*70))
            local line = ccui.ImageView:create()
            line:loadTexture("uires/createRoom/xuxian.png")
            line:setAnchorPoint(cc.p(0, 0.5))
            --lastBgBox:addChild(line)
            line:setPosition(cc.p(100, 75))
            local title =  ccui.Text:create(tmp[1], nil, 30):addTo(lastBgBox, 100)
            title:setColor(helper.str2Color("#613d1b"))
            title:setAnchorPoint(cc.p(0,1))
            title:setPosition(cc.p(15, 140-20))

            if 1 == self.m_select_tab then
                line:setPosition(cc.p(100, 145))
                title:setPosition(cc.p(15, 210-20))
            end
            startY = startY - 70
        end
        
        local x = 1
        y = rowNum
        for j=2,#tmp do
            if tmp[j] then
                local item,cb,panel_click = self:createItem(tmp[j])
                --self.m_item_node:addChild(item)
                item:setAnchorPoint(cc.p(0, 0.5))
                lastBgBox:addChild(item)
                
                if(tmp[j][2])then
                    print("the has_y is "..has_y)
                    
                    if(#tmp[j]==4) then
                        --item:setPosition(cc.p((has_x-1)*220,-(has_y-1)*offsetY))
                        item:setPosition(cc.p((has_x-1)*240+120,35-(y -1)*70))
                    else
                        --item:setPosition(cc.p((has_x-1)*(220-50),-(has_y-1)*offsetY))
                        item:setPosition(cc.p((has_x-1)*(220-40)+120,35-(y -1)*70))
                    end
                    has_x = has_x + 1
                    x = x + 1
                else
                    item:setVisible(false)
                end
                panel_click:addClickEventListener(function(sender)self:onCheckHandler(sender)end)
                if(tmp[j][2] and tmp[j][2] == "鸟2分" or tmp[j][2] ==  "金鸟")then
                    if 1 == self.m_select_tab then
                        self.m_ckBoxList[5][4] = cb
                        self.m_ckBoxListPanel[5][4] =panel_click
                    else
                        self.m_ckBoxList[4][4] = cb
                        self.m_ckBoxListPanel[4][4] =panel_click
                    end
                else
                    table.insert(self.m_ckBoxList[i],cb)
                    table.insert(self.m_ckBoxListPanel[i],panel_click)
                end
            else
                has_x = has_x + 1
            end
        end
        if(has_x > 1)then has_y = has_y + 1 end
    end
    dataMgr:init(self.m_ckBoxList)

    --默认设定
    local defaultData = dataMgr:getGameTypeData(index)
    for i,data in ipairs(self.m_ckBoxList) do
        for j,v in ipairs(data) do
            -- if i == 4 or (i == 3 and j  == 3) then
            --     setSelected(v,defaultData[i][j] == 1, true)
            -- else
            --     setSelected(v,defaultData[i][j] == 1)
            -- end
            setSelected(v,defaultData[i][j] == 1)
        end
    end
    self:checkPlayerNum()
    self:checkBird()

    if 1 == self.m_select_tab then
        self:setEnabled(self.m_ckBoxList[4][2], isSelected(self.m_ckBoxList[4][1]) and isSelected(self.m_ckBoxList[3][2]))
    end  

    self:checkJewelNum()
end

function CreateRoomUITwo:checkPlayerNum()
    if self.m_ckBoxList[2][3] and self.m_ckBoxList[2][3]:isSelected() then
        setSelected(self.m_ckBoxList[6][1],false)
        setSelected(self.m_ckBoxList[6][2],false)
        setSelected(self.m_ckBoxList[6][3],false)
    end
    --转转二人不能选红中癞子
    if self.m_ckBoxList[2][3] then
        self.m_ckBoxListPanel[5][3]:setTouchEnabled(not self.m_ckBoxList[2][3]:isSelected())
        self.m_ckBoxListPanel[6][1]:setTouchEnabled(not self.m_ckBoxList[2][3]:isSelected())
        self.m_ckBoxListPanel[6][2]:setTouchEnabled(not self.m_ckBoxList[2][3]:isSelected())
        self.m_ckBoxListPanel[6][3]:setTouchEnabled(not self.m_ckBoxList[2][3]:isSelected())

        self:setEnabled(self.m_ckBoxList[5][3],not self.m_ckBoxList[2][3]:isSelected())
        -- self.m_ckBoxList[4][3]:setEnabled(not self.m_ckBoxList[2][3]:isSelected())
        self.m_ckBoxList[6][3]:setEnabled(not self.m_ckBoxList[2][3]:isSelected())
        self.m_ckBoxList[6][2]:setEnabled(not self.m_ckBoxList[2][3]:isSelected())
        self.m_ckBoxList[6][1]:setEnabled(not self.m_ckBoxList[2][3]:isSelected())
    end
    
    self:checkBird()
end

function CreateRoomUITwo:setEnabled(ui,bool)
    if not ui then
        return
    end
    -- local image = helper.findNodeByName(ui:getParent(),"item_img")
    local label = helper.findNodeByName(ui:getParent(),"item_lab")
    local tick = helper.findNodeByName(ui,"tick")
    if bool then
        ui:loadTexture("uires/common/chose_1_N.png")
    else
        -- image:setVisible(false)
        label:setVisible(true)
        tick:setVisible(false)
        ui:loadTexture("uires/common/chose_1_D.png")
    end
end

function CreateRoomUITwo:checkBird()
    local selected = false

    if 1 == self.m_select_tab then
        for k,btn in ipairs(self.m_ckBoxList[6]) do
            selected = selected or btn:isSelected()
        end
        self:setEnabled(self.m_ckBoxList[5][4], selected)
        if self.m_ckBoxListPanel[5][4] then
            self.m_ckBoxListPanel[5][4]:setTouchEnabled(selected)
        end
    else
        for k,btn in ipairs(self.m_ckBoxList[5]) do
            selected = selected or btn:isSelected()
        end
        self:setEnabled(self.m_ckBoxList[4][4], selected)
        if self.m_ckBoxListPanel[4][4] then
            self.m_ckBoxListPanel[4][4]:setTouchEnabled(selected)
        end
    end
end

function CreateRoomUITwo:onCreateHandler(event)
    if self.isPiLiang then
        local rate
        if isSelected(self.m_ckBoxList[1][1]) then
            rate = 1
        else
            rate = 2
        end
        UIMgr:openUI(consts.UI.ClubInputCreate, nil, nil, rate)
        return
    end


    if not self.m_clubData and tonumber(UserData.userInfo.surplusGameCard) < dataMgr:getUseNum() then
        if(not Is_App_Store)then
            UIMgr:showTips("房卡不足，创建失败\n\n购买房卡：请联系代理！")
        else
            UIMgr:showTips("房卡不足，创建失败")
        end
        return
    end

    UIMgr:showLoadingDialog("创建房间中...")
    dataMgr:setGameTypeData(self.m_select_tab)
    
    if(Is_App_Store)then
        self:createRoomByIos()
    else
        self:creatRoom()
    end
end

function CreateRoomUITwo:queryRoom()

    local sendData = {enter_code = self.enter_code}

    --防作弊模式
    if(Is_Cheat_Set and LuaCallPlatformFun.isOpenLocation())then
        if(not Is_App_Store) then                   -- android开启高德地图
            LuaCallPlatformFun.openLocation()
        end
        local pos = LuaCallPlatformFun.getLocation()
        if pos ~= nil and pos.longitude ~= 0 and pos.latitude ~= 0 then
            sendData.antiCheatLon = pos.longitude
            sendData.antiCheatLat = pos.latitude
        end
    end
    
    HttpServiers:queryRoom(sendData,
        function(entity,response,statusCode)
            if entity then
                local addressSplit = string.split(entity.address, ":")
                local ip =  addressSplit[1]
                local port = addressSplit[2]
                GnetMgr:initConnect(ip, port,handler(self,self.connectSuccess))
                if not self.isPiLiang then
                    UIMgr:closeUI(consts.UI.mainUI)
                end
            elseif response and response.errCode then
                UIMgr:closeUI(consts.UI.LoadingDialogUI)
                if(response.errCode == -100)then
                    self:locationTip("   无法获取您的位置信息\n         请打开定位功能",function() LuaCallPlatformFun.toLocationSetting() end)
                else
                    GnetMgr:showErrorTips(response.errCode, true)
                end
            else
                UIMgr:showNetErrorTip(function()
                    self:queryRoom()
                end)
            end
        end)
end

function CreateRoomUITwo:creatRoom(data)
    local game_id
    if 3 == self.m_select_tab then --郴州麻将为7
        game_id = 7
    elseif 4 == self.m_select_tab then --红中麻将为8
        game_id = 8
    elseif 5 == self.m_select_tab then --宁乡
        game_id = 10
    elseif 6 == self.m_select_tab then --常德
        game_id = 28
    else
        game_id = self.m_select_tab
    end
    local sendData = {
        useNum = dataMgr:getUseNum(),
        orderType = "1",
        player_count = dataMgr:getPlayerNum(),
        rate = 1,
        gameId = game_id,
        game_count = dataMgr:getGameNum(),
        data = dataMgr:getGameRule(self.m_select_tab)}

    --俱乐部加钻
    if(self.m_clubData)then
        sendData.orderType = "10"
        sendData.clubId = self.m_clubData.clubId
        sendData.useDiamondNum = self.m_clubData.jewelNum
    end

    --防作弊模式
    if(Is_Cheat_Set)then
        local cheat_gou = helper.findNodeByName(self.resourceNode_,"cheat_gou")
        if(cheat_gou:isVisible())then
            local pos = LuaCallPlatformFun.getLocation()
            if pos ~= nil and pos.longitude ~= 0 and pos.latitude ~= 0 then
                sendData.antiCheatLon = pos.longitude
                sendData.antiCheatLat = pos.latitude
                dataMgr:setCheatRoom(true)
                sendData.data = dataMgr:getGameRule(self.m_select_tab)
                sendData.antiCheat = 1
            end
        end
    end

    if self.isPiLiang then
        sendData.orderType = "10"
        sendData.clubId = UserData.groupHolderTbl.clubId
        -- sendData.useDiamondNum = UserData.groupHolderTbl.rule1
        if data then
            sendData.roomNum = data.data.roomNum
            sendData.useDiamondNum = data.data.cost
        end
    end
    
    if self.isPiLiang then
        HttpServiers:createRoomBatch(sendData, 
            function(entity,response,statusCode)
                if entity then
                    -- --保存群主ip端口
                    cc.UserDefault:getInstance():setStringForKey("clubGroupHolderIpAndPort", entity.ip)
                    local addressSplit = string.split(entity.ip, ":")
                    local ip =  addressSplit[1]
                    local port = addressSplit[2]
                    GnetMgr:initConnect(ip, port, function ()
                        GnetMgr:send("get_batch_room_list", {page = 1})
                    end)
                    self:close()
                    -- self.enter_code  = entity.enter_code
                    -- self:queryRoom()
                elseif response and response.errCode then
                    UIMgr:closeUI(consts.UI.LoadingDialogUI)
                    GnetMgr:showErrorTips(response.errCode, true)
                else
                    UIMgr:showNetErrorTip(function()
                        self:creatRoom()
                    end)
                end
            end)
    else
        HttpServiers:creatRoom(sendData, 
            function(entity,response,statusCode)
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
    
    -- UIMgr:closeUI(consts.UI.mainUI)
end

--ios审核用
function CreateRoomUITwo:createRoomByIos()

    self:send("build_on_request_new_rooms",{
        player_count  = dataMgr:getPlayerNum(),
        rate = 1,
        game_count = dataMgr:getGameNum(),
        data = dataMgr:getGameRule(self.m_select_tab)
        })
    
end

function CreateRoomUITwo:connectSuccess()
    UserData.roomId = self.enter_code
    self:send("room_enter_room",{enter_code = self.enter_code})
    --方便在WIN32上调试
    if consts.App.APP_PLATFORM == cc.PLATFORM_OS_WINDOWS and WIN32DEBUG then
        local str = "local JoinDebug = {}\nJoinDebug.roomId = "..self.enter_code.."\nreturn JoinDebug"
        io.writefile("src/JoinDebug.lua", str ,"w")
    end
end

function CreateRoomUITwo:checkList1or2(i,j)
    for k,btn in ipairs(self.m_ckBoxList[i]) do
        setSelected(btn,k == j)
    end
    if i == 2 then
        self:checkPlayerNum()
    end
end

function CreateRoomUITwo:checkList3(i,j)
    local btn = self.m_ckBoxList[i][j]
    if 5 == self.m_select_tab or 6 == self.m_select_tab then
         setSelected(btn,not helper.findNodeByName(btn,"tick"):isVisible(), true)
    elseif 4 == self.m_select_tab then
        if 2 == j or 3 == j then
            setSelected(btn,not helper.findNodeByName(btn,"tick"):isVisible(), true)
        end
    else
        if j == 3 then
            setSelected(btn,not helper.findNodeByName(btn,"tick"):isVisible(), true)
        else
            setSelected(self.m_ckBoxList[i][1],btn == self.m_ckBoxList[i][1])
            if self.m_ckBoxList[i][2] then
                setSelected(self.m_ckBoxList[i][2],btn == self.m_ckBoxList[i][2])
            end
        end
        if 1 == self.m_select_tab then
            self:setEnabled(self.m_ckBoxList[4][2], isSelected(self.m_ckBoxList[4][1]) and isSelected(self.m_ckBoxList[3][2]))
        end
    end
end

function CreateRoomUITwo:checkList5(i,j)
    local ckPRule = self.m_ckBoxList[4][4]
    local btnIsSelect = self.m_ckBoxList[i][j]:isSelected()
    if btnIsSelect then
        setSelected(self.m_ckBoxList[i][j],false)
    else
        for k,btn in ipairs(self.m_ckBoxList[i]) do
            setSelected(btn,k == j)
        end
    end
    if 6 == self.m_select_tab or 4 == self.m_select_tab then
        setSelected(self.m_ckBoxList[i-1][1], false)
    end

    self:checkBird()
end

function CreateRoomUITwo:checkList4(i,j)
    if 6 == self.m_select_tab or 4 == self.m_select_tab then
        local btnIsSelect = self.m_ckBoxList[i][j]:isSelected()
        if btnIsSelect then
            setSelected(self.m_ckBoxList[i][j],false)
        else
            for k,btn in ipairs(self.m_ckBoxList[i]) do
                setSelected(btn,k == j)
            end
        end
        for k,btn in ipairs(self.m_ckBoxList[i+1]) do
            setSelected(btn, false)
        end
    else
        for k,btn in ipairs(self.m_ckBoxList[i]) do
            setSelected(btn,k == j)
        end
    end
end

function CreateRoomUITwo:onCheckHandler(sender)
    for i,data in ipairs(self.m_ckBoxListPanel) do
        for j,btn in ipairs(data) do
            if btn == sender then
                if i == 1 or i == 2 then
                    self:checkList1or2(i,j)
                    self:checkJewelNum()
                elseif i == 3 then
                    self:checkList3(i,j)
                elseif i == 5 and j~=4 and 1 ~= self.m_select_tab then
                    self:checkList5(i,j)
                elseif i == 6 and j~= 4 then
                    self:checkList5(i,j)
                else
                    local tick = helper.findNodeByName(self.m_ckBoxList[i][j],"tick")
                    if tick then
                        setSelected(self.m_ckBoxList[i][j],not tick:isVisible(), true)
                        if 1 == self.m_select_tab then
                            self:setEnabled(self.m_ckBoxList[4][2], isSelected(self.m_ckBoxList[4][1]) and isSelected(self.m_ckBoxList[3][2]))
                        end
                    else
                        self:checkList4(i,j)
                    end
                end
                return
            end
        end
    end
end

function CreateRoomUITwo:onBack(event)
    -- UIMgr:openUI(consts.UI.mainUI)
    self:close()
end

function CreateRoomUITwo:proListHandler(msg)
    if msg.name == "build_on_request_new_rooms" then
        print("房号：",msg.args.enter_code)
        if(#tostring(msg.args.enter_code) < 6)then return end
        self.enter_code = msg.args.enter_code
        self:connectSuccess()
        if not self.isPiLiang then
            UIMgr:closeUI(consts.UI.mainUI)
        end
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

function CreateRoomUITwo:createItem( str )

    local item = nil
    if(#str == 4) then
        item = cc.CSLoader:createNode("uiCreate/UI_room_select_item_msg.csb")
    else
        item = cc.CSLoader:createNode("uiCreate/UI_room_select_item.csb")
    end
    --local item = cc.CSLoader:createNode("uiCreate/UI_room_select_item.csb")
    for i=1,2 do
        local cb = helper.findNodeByName(item,"ck_type_"..i)
        cb:setVisible(str[1] == i)
    end

    local item_lab = helper.findNodeByName(item,"item_lab")
    item_lab:setString(str[2] or "")
    --不用图片
    helper.findNodeByName(item,"item_img"):setVisible(false)
    -- if(str[3])then
    --     local item_img = helper.findNodeByName(item,"item_img")
    --     item_img:setTexture(string.format("uires/createRoom/%s.png",str[3]))
    -- end
    local item_msg = helper.findNodeByName(item,"item_msg")
    if(Is_App_Store)then
        item_msg:setString("")
    else
        item_msg:setString(str[4] or "")
    end

    local panel_click = helper.findNodeByName(item,"panel_click")
    
    return item,helper.findNodeByName(item,"ck_type_"..str[1]),panel_click
end

--防作弊提示
function CreateRoomUITwo:onTipShow(event)
    local tip_panel = helper.findNodeByName(self.resourceNode_,"tip_panel")
    tip_panel:setVisible(true)
end
function CreateRoomUITwo:onTipClose(event)
    local tip_panel = helper.findNodeByName(self.resourceNode_,"tip_panel")
    tip_panel:setVisible(false)
end

function CreateRoomUITwo:onCheatChange(event)

    local cheat_gou = helper.findNodeByName(self.resourceNode_,"cheat_gou")
    
    if(not cheat_gou:isVisible())then
        --开启定位
        print("开启")
        local dialogContentLabel1=helper.createRichLabel({maxWidth = 600,fontSize = 30})
        dialogContentLabel1:setString("           是否开启防作弊模式?\n（该模式将会屏蔽距离相近/IP相同的玩家）")
        dialogContentLabel1:setColor(cc.c3b(153, 78, 46))
        local dialogContent =cc.Layer:create()
        dialogContentLabel1:addTo(dialogContent,1)
        UIMgr:showConfirmDialog("提示",{child=dialogContent, childOffsetY= 25},handler(self,self.onCheatSureClick),function()end)

    else
        print("关闭")
        local cheat_gou = helper.findNodeByName(self.resourceNode_,"cheat_gou")
        cheat_gou:setVisible(false)
    end
end

function CreateRoomUITwo:onCheatSureClick()

    local cheat_gou = helper.findNodeByName(self.resourceNode_,"cheat_gou")

    --先判断定位是否开启
    local deny = LuaCallPlatformFun.isOpenLocation()
    if(deny)then
        if(not Is_App_Store) then                   -- android开启高德地图
            LuaCallPlatformFun.openLocation()
        end
        local tab = LuaCallPlatformFun.getLocation()
        if(tab)then
            cheat_gou:setVisible(true)
        else
            --获取不到位置提示
            self:locationTip("   暂时无法获取您的位置信息，\n                请稍后尝试",function()end)
        end
    else
        self:locationTip("   无法获取您的位置信息\n         请打开定位功能",function() LuaCallPlatformFun.toLocationSetting() end)
    end
end

function CreateRoomUITwo:locationTip( str ,callback)
    local dialogContentLabel1=helper.createRichLabel({maxWidth = 600,fontSize = 30})
    dialogContentLabel1:setString(str)
    dialogContentLabel1:setColor(cc.c3b(153, 78, 46))
    local dialogContent =cc.Layer:create()
    dialogContentLabel1:addTo(dialogContent,1)
    UIMgr:showConfirmDialog("防作弊模式房间",{child=dialogContent, childOffsetY= 25},callback,function()end)
end

return CreateRoomUITwo
