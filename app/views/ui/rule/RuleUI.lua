--
-- Author: LHF
-- Date: 2016-12-23
--
local dataMgr = require("app.views.ui.create.CreateRoomData")

local RuleUI = class("RuleUI", cc.load("mvc").UIBase)
RuleUI.RESOURCE_FILENAME = "uiRule/UI_Rule.csb"

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
           
    -- image:setVisible(isSelect)
    -- label:setVisible(not isSelect)
    if isSelect then
        label:setColor(helper.str2Color("#ab2a0c"))
    else
        label:setColor(helper.str2Color("#835f4c"))
    end
end

function RuleUI:onCreate(data)
    self:setInOutAction()
    self.btnBack = helper.findNodeByName(self.resourceNode_,"btnBack")
    self.btnBack:setPressedActionEnabled(true)

    self.m_item_node = helper.findNodeByName(self.resourceNode_,"m_item_node")

    local index = UserData.curMahjongType
    local tab_msg = consts.roomCreateMsg["tab_"..index]
    if(not tab_msg)then return end

    --选择项
    self.m_ckBoxList = {}
    self.m_ckBoxListPanel = {}
    local lastBgBox
    local has_y = 1
    local offsetY = 80
    for i=1,#tab_msg do
        local tmp = tab_msg[i]
        self.m_ckBoxList[i] = {}
        self.m_ckBoxListPanel[i] = {}
        local has_x = 1
        -- if "" ~= tmp[1] or i == #tab_msg then
        if "" ~= tmp[1] and "-" ~= tmp[1] then
            local bg_box = ccui.ImageView:create()
            bg_box:loadTexture("uires/createRoom/baikuang.png")
            bg_box:setScale9Enabled(true)
            bg_box:setContentSize(cc.size(670, 70))
            self.m_item_node:addChild(bg_box)
            bg_box:setPosition(cc.p(-55, -(has_y-1)*offsetY + 35))
            bg_box:setAnchorPoint(cc.p(0, 1))
            lastBgBox = bg_box   
            if i == 1 or i == 2 then
                bg_box:setVisible(false)
            end
        -- end
        -- if "" == tmp[1] or (i == #tab_msg and tab_msg[#tab_msg][5]) then
        elseif "-" ~= tmp[1] then
            lastBgBox:setContentSize(cc.size(670, 150))
            local line = ccui.ImageView:create()
            line:loadTexture("uires/createRoom/fengexian.png")
            line:setContentSize(cc.size(650, 1))
            line:setScale9Enabled(true)
            line:setAnchorPoint(cc.p(0, 0.5))
            lastBgBox:addChild(line, 999)
            line:setPosition(cc.p(10, 80))
        end

        if (i == #tab_msg and tab_msg[#tab_msg][5]) then
            lastBgBox:setContentSize(cc.size(670, 150))
            local line = ccui.ImageView:create()
            line:loadTexture("uires/createRoom/fengexian.png")
            line:setContentSize(cc.size(650, 1))
            line:setScale9Enabled(true)
            line:setAnchorPoint(cc.p(0, 0.5))
            lastBgBox:addChild(line, 999)
            line:setPosition(cc.p(10, 80))
        end
        
        for j=2,#tmp do
            if tmp[j] then
                local item,cb,panel_click = self:createItem(tmp[j])
                self.m_item_node:addChild(item)
                if(tmp[j][2])then
                    item:setPosition(cc.p((has_x-1)*215,-(has_y-1)*offsetY))
                    has_x = has_x + 1
                else
                    item:setVisible(false)
                end

                if 1 == i or 2 == i then
                    item:setVisible(false)
                end
                -- panel_click:addClickEventListener(function(sender)self:onCheckHandler(sender)end)
                if(tmp[j][2] and tmp[j][2] == "鸟2分" or tmp[j][2] ==  "金鸟")then
                    if 1 == UserData.curMahjongType then
                        self.m_ckBoxList[5][4] = cb
                        self.m_ckBoxListPanel[5][4] =panel_click
                    else
                        self.m_ckBoxList[4][4] = cb
                        self.m_ckBoxListPanel[4][4] =panel_click
                    end
                    item:setPosition(cc.p((0)*215,-(has_y)*offsetY))
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

    local defaultData = UserData.table_config.rule.roomData
    for i,data in ipairs(self.m_ckBoxList) do
        for j,v in ipairs(data) do
            setSelected(v,defaultData[i][j] == 1)
        end
    end
end

function RuleUI:onExit()
    self.resourceNode_:stopAllActions()
end

function RuleUI:onBack(event)
    self:close()
end

function RuleUI:onCloseBtnClick()
    self:close()
end

function RuleUI:createItem( str )
    local item = cc.CSLoader:createNode("uiCreate/UI_room_select_item.csb")
    for i=1,2 do
        local cb = helper.findNodeByName(item,"ck_type_"..i)
        cb:setVisible(str[1] == i)
    end

    local item_lab = helper.findNodeByName(item,"item_lab")
    item_lab:setColor(helper.str2Color("#835f4c"))
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

return RuleUI