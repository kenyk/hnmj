
local ChatUI = class("ChatUI", cc.load("mvc").UIBase)

-- ChatUI.RESOURCE_FILENAME = "uiChat/UI_Chat.csb"
-- ChatUI.RESOURCE_FILENAME = "uiChat/UI_Chat2.csb"
ChatUI.RESOURCE_FILENAME = "uiChat/UI_Chat3.csb"
ChatUI.RESOURCE_MODELNAME = "app.views.ui.chat.ChatModel"

function ChatUI:onCreate(params)
    self:setInOutAction()
    -- self.lMsg= helper.findNodeByName(self.resourceNode_,"lMsg")
    -- self.tabMsg = helper.findNodeByName(self.resourceNode_,"tabMsg")
    -- self.tMsg= helper.findNodeByName(self.resourceNode_,"tMsg")
    -- self.lEmoji= helper.findNodeByName(self.resourceNode_,"lEmoji")
    -- self.tabEmoji= helper.findNodeByName(self.resourceNode_,"tabEmoji")
    -- self.tEmoji= helper.findNodeByName(self.resourceNode_,"tEmoji")
    self.svContainer= helper.findNodeByName(self.resourceNode_,"svContainer")
    self.bg = helper.findNodeByName(self.resourceNode_,"bg")
    self.Image_bottem = helper.findNodeByName(self.resourceNode_,"Image_bottem")

    -- self.notSelectStr = "uires/chat/img_not_select.png"
    -- self.notSelectCSize = cc.p()
    -- self.selectedStr = "uires/chat/btn_selected.png"
    -- self.selectedStr = cc.p()

    --self.img_title1 = helper.findNodeByName(self.resourceNode_,"img_title1")
    --self.img_title2 = helper.findNodeByName(self.resourceNode_,"img_title2")
    self.img_di1 = helper.findNodeByName(self.resourceNode_,"img_di1")          --选中
    self.img_di1_not = helper.findNodeByName(self.resourceNode_,"img_di1_not")
    self.title_Image_1 = helper.findNodeByName(self.resourceNode_,"title_Image_1")          --选中
    self.title_Image_1_not = helper.findNodeByName(self.resourceNode_,"title_Image_1_not")
    self.img_di2 = helper.findNodeByName(self.resourceNode_,"img_di2")          --选中
    self.img_di2_not = helper.findNodeByName(self.resourceNode_,"img_di2_not")
    self.title_Image_2 = helper.findNodeByName(self.resourceNode_,"title_Image_2")          --选中
    self.title_Image_2_not = helper.findNodeByName(self.resourceNode_,"title_Image_2_not")
    self.Image_37 = helper.findNodeByName(self.resourceNode_,"Image_37")
    self.list_txt = helper.findNodeByName(self.resourceNode_,"list_txt")
    self.list_emoji = helper.findNodeByName(self.resourceNode_,"list_emoji")
    --self.list_right = helper.findNodeByName(self.resourceNode_,"list_right")
    self.btn_send = helper.findNodeByName(self.resourceNode_,"btn_send")
    self.Image_15_0 = helper.findNodeByName(self.resourceNode_,"Image_15_0")

    self.img_di1_not:setVisible(false)
    self.title_Image_1_not:setVisible(false)
    self.img_di2:setVisible(false)
    self.title_Image_2:setVisible(false)
    self.Image_15_0:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self.img_di1:setVisible(not self.img_di1:isVisible())
                self.img_di1_not:setVisible(not self.img_di1_not:isVisible())
                self.title_Image_1:setVisible(not self.title_Image_1:isVisible())
                self.title_Image_1_not:setVisible(not self.title_Image_1_not:isVisible())
                self.img_di2:setVisible(not self.img_di2:isVisible())
                self.img_di2_not:setVisible(not self.img_di2_not:isVisible())
                self.title_Image_2:setVisible(not self.title_Image_2:isVisible())
                self.title_Image_2_not:setVisible(not self.title_Image_2_not:isVisible())
                self:changeTab()
            end
        end)
    self:changeTab()
    -- self:changeTab("msg")

    local shieldWord = require "utils.shieldWord"
    self.btn_send:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local txt = self.edit:getText()
                for _, v in ipairs(shieldWord["Sheet1"]) do
                    txt = string.gsub(txt, v, "*")
                end
                print("begin~~~", txt)
                --处理换行
                txt = string.gsub(txt, "\\n", "")
                txt = string.gsub(txt, "\n", "")
                print("end~~~", txt)
                local script = string.format("local msg={type = 2,txt = \'%s\',len=%s,sex = %d}  return msg", txt,2,UserData.userInfo.gender)
                self:send("game_talk_and_picture", {id = script})
                self.edit:setText("")
                self:close()
            end
        end)

    local size = self.Image_37:getContentSize()
    --local edit = ccui.EditBox:create(size, "green_edit.png")
    local edit = ccui.EditBox:create(cc.size(290, 60), "green_edit.png")
    --edit:setAnchorPoint(cc.p(0, 0.5))
    edit:setAnchorPoint(cc.p(0, 0))
    edit:setFontSize(32)
    edit:setFontColor(helper.str2Color("#834824"))
    edit:setPlaceHolder("请输入聊天内容")
    edit:setPlaceholderFontColor(helper.str2Color("#d1b990"))
    edit:setMaxLength(30)
    edit:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    edit:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD)
    --edit:setPosition(self.Image_37:getPosition())
    edit:setPosition(cc.p(48,34))
    edit:setMaxLength(24)
    edit:addTo(self.Image_bottem)
    self.edit = edit

    self:updateChatHistory()
end

function ChatUI:updateChatHistory()
    if not UserData.chatList then
        return
    end
    --self.list_right:removeAllItems()
    local begani, endi
    --保留最后15条
    if #UserData.chatList > 15 then
        begani = #UserData.chatList - 15
        endi = #UserData.chatList
    else
        begani = 1
        endi = #UserData.chatList
    end
    -- for i, tab in ipairs(UserData.chatList) do
    for i = begani, endi do
        local tab = UserData.chatList[i]
        local chatType = tonumber(tab.type)
        local id = tab.id
        local item = cc.CSLoader:createNode("uiChat/UI_Chat_Item.csb")
        item:setContentSize(cc.size(550, 70))
        local widget = ccui.Widget:create()
        widget:addChild(item)
        widget:setContentSize(cc.size(550, 90))
        --self.list_right:pushBackCustomItem(widget)
        item:getChildByName("Panel_self"):setVisible(tonumber(tab.uid) == UserData.uid)
        item:getChildByName("Panel_other"):setVisible(not (tonumber(tab.uid) == UserData.uid))
        local img_head
        local img_bubble
        local layout
        if tonumber(tab.uid) == UserData.uid then
            layout = item:getChildByName("Panel_self")
            img_head = layout:getChildByName("img_head")
            img_bubble = layout:getChildByName("img_bubble")
        else
            layout = item:getChildByName("Panel_other")
            img_head = layout:getChildByName("img_head")
            img_bubble = layout:getChildByName("img_bubble")
        end
        for i, v in ipairs(UserData.players) do
            if tab.uid == v.uid then
                self.head  = NetSprite:getSpriteUrl(v.image_url,"mj/bg_default_avatar_1.png")
                self.head:setAnchorPoint(cc.p(0, 0))
                self.head:setImageContentSize(cc.size(70,70))
                self.head:addTo(img_head, 1)
            end
        end
        local img_emoji = layout:getChildByName("img_emoji")
        if chatType == 1 then --颜文字
            img_emoji:loadTexture("mj/emoji/" .. id .. ".png")
            img_bubble:setContentSize(cc.size(img_emoji:getContentSize().width + 40, 59))
        elseif chatType == 2 then --文字聊天
            img_emoji:setVisible(false)
            local index = tonumber(tab.id)
            local str
            if index then --常用语
                str = consts.chatMsgArray[index]
            else --文字聊天
                str = tab.txt
            end
            local content = string.format("<div fontcolor=#834824 fontSize=25 >%s", str)
            -- local content = string.format("<div fontcolor=#000000 fontSize=25 >%s", "电饭锅电饭锅电饭锅电饭锅电饭锅电饭锅地方个地")
            -- local content = string.format("<div fontcolor=#000000 fontSize=25 >%s", "电饭锅电饭锅电饭锅电")
            local rt = helper.createRichLabel({maxWidth = 460,fontSize = 20,fontColor = cc.c3b(0, 0, 0), lineSpace = 0})
            -- rt:layout()
            if tonumber(tab.uid) == UserData.uid then
                rt:setAnchorPoint(cc.p(1, 0.5))
                rt:setPosition(cc.p(img_bubble:getPositionX() - 25, img_bubble:getPositionY())):addTo(layout,100)
            else
                rt:setAnchorPoint(cc.p(0, 0.5))
                rt:setPosition(cc.p(img_bubble:getPositionX() + 25, img_bubble:getPositionY())):addTo(layout,100)
            end
            rt:setString(content)
            img_bubble:setContentSize(cc.size(rt:getSize().width + 30, 59))
        end
    end
end

function ChatUI:changeTab(tab)
    -- if tab == self.tab then return end
    -- print("切换到tab=" .. tab)
    -- self.tab =  tab
    -- if tab == "msg" then
    --     self:showTabMsg()
    -- elseif tab == "emoji" then
    --     self:showTabEmoji()
    -- end
    -- print("------",self.img_di1:isVisible(),self.img_di2:isVisible())
    if self.img_di1:isVisible() then
        self:showTabMsg()
    elseif self.img_di2:isVisible() then
        self:showTabEmoji()
    end
end

function ChatUI:onClickTabEmoji(sender)
    self:changeTab("emoji")
end

function ChatUI:onClickTabMsg(sender)
    self:changeTab("msg")
end

function ChatUI:showTabMsg()
    local emojiWidth = 536
    -- local layoutMsgWidth = 680
    --local layoutMsgWidth = 536
    local layoutMsgWidth = 385
    local msgHeight = 54
    local lineInterval = 10
    local rowInterval =  6
    local layoutMsgHeight =  #consts.chatMsgArray  * (msgHeight + lineInterval)

    local bgMsg
    local tMsg
    local lineIndex 
    local rowIndex 
    if self.svMsg == nil then
        self.svMsg = ccui.ScrollView:create()
        --self.svMsg:addTo(self.bg, 1)
        self.svMsg:addTo(self.Image_bottem, 1)
        --self.svMsg:setAnchorPoint(cc.p(0.5, 1))
        self.svMsg:setAnchorPoint(cc.p(0, 0))
        --self.svMsg:setPosition(cc.p(-220, 196))
        self.svMsg:setPosition(cc.p(48, 115))
        
        self.svMsg:setInnerContainerSize(cc.size(layoutMsgWidth, layoutMsgHeight))
        --self.svMsg:setContentSize(cc.size(layoutMsgWidth+20, 385))
        self.svMsg:setContentSize(cc.size(layoutMsgWidth+20, 320))
        self.svMsg:setBounceEnabled(true)
        self.layoutMsg =  ccui.Layout:create()
        for i = 1,  #consts.chatMsgArray do
            bgMsg = ccui.ImageView:create("uires/chat/bg_chat_msg.png")
            bgMsg:setContentSize(cc.size(layoutMsgWidth - 2 * rowInterval,msgHeight))
            bgMsg:setScale9Enabled(true)
            bgMsg:setAnchorPoint(cc.p(0,1))
            -- bgMsg:setPosition(cc.p(rowInterval, layoutMsgHeight - (i - 1) * (msgHeight + lineInterval)))
            bgMsg:setPosition(cc.p(0, layoutMsgHeight - (i - 1) * (msgHeight + lineInterval)))
            -- tMsg =  ccui.Text:create(consts.chatMsgArray[i] , nil, 34)
            tMsg =  ccui.Text:create(consts.chatMsgArray[i] , nil, 26)
            -- tMsg:setColor(cc.c3b(150,92,69))
            tMsg:setColor(helper.str2Color("#472e21"))
            tMsg:setAnchorPoint(cc.p(0,0.5))
            tMsg:setPosition(cc.p(20,msgHeight / 2))
            tMsg:addTo(bgMsg,1)
            bgMsg:setTouchEnabled(true)
            bgMsg:addClickEventListener(function(sender)
                local idValue = "" .. i
                print("点击常用语,id=" .. idValue)
                local script = string.format("local msg={type = 2,id = %d,len=%s,sex = %d}  return msg",idValue,2,UserData.userInfo.gender)
                self:send("game_talk_and_picture", {id = script})
                -- self.warpper:close()
                self:close()
            end)
            bgMsg:addTo(self.layoutMsg, 1)
        end
        self.layoutMsg:setAnchorPoint(cc.p(0, 0))
        self.layoutMsg:setPosition(cc.p(0, 0))
        self.layoutMsg:setContentSize(cc.size(layoutMsgWidth, layoutMsgHeight))
        self.layoutMsg:addTo(self.svMsg, 1)
        -- self.layoutMsg:addTo(self.svMsg, 1)
    else
        self.svMsg:setVisible(true)
    end
    -- self.tabMsg:loadTexture("uires/common/btn_2.png")
    -- self.tMsg:setColor(cc.c3b(255,255,255))
    -- self.tabEmoji:loadTexture("uires/common/btn_5_yellow.png")
    -- self.tEmoji:setColor(cc.c3b(150,92,69))
    self.svContainer:setVisible(false)
    if self.svMsg then
        self.svMsg:setVisible(true)
    end
end

function ChatUI:onCloseBtnClick(sender)
    self:close()
    -- self.warpper:close()
end

function ChatUI:setParentWrapper(warpper)
    self.warpper = warpper
end

function ChatUI:showTabEmoji()
    local emojiCount = 39
    local emojiWidth = 62 * 1.5
    local emojiHeight = 60 * 1.5
    -- local rowNum = 7
    local rowNum = 3
    local lineInterval = 55
    local offsetY = 30
    local svContainerScrollWidth =  550
    local svContainerScrollHeight =  math.ceil(emojiCount / rowNum) * (emojiHeight + lineInterval) - lineInterval + offsetY
    print("svContainerScrollHeight=" .. svContainerScrollHeight)
    local rowInterval =  (svContainerScrollWidth - emojiWidth * rowNum) / (rowNum + 1)
    local ivEmoji
    local lineIndex 
    local rowIndex 
    local cutLine
    if self.layoutEmoji == nil then
        self.layoutEmoji =  ccui.Layout:create()
        self.layoutEmoji:setAnchorPoint(cc.p(0, 0))
        self.layoutEmoji:setPosition(cc.p(0, 0))
        self.layoutEmoji:setContentSize(cc.size(svContainerScrollWidth, svContainerScrollHeight))
        for i = 1, emojiCount do
            ivEmoji = ccui.ImageView:create( "mj/emoji/E" .. i .. ".png")
            ivEmoji:setScale(1.5)
            lineIndex =  math.ceil(i / rowNum)
            rowIndex =  i - rowNum * (lineIndex - 1)
            print("--lineIndex----rowIndex----",lineIndex,rowIndex)
            ivEmoji:setAnchorPoint(cc.p(0,1))
            ivEmoji:setPosition(cc.p(rowIndex * rowInterval + (rowIndex - 1) * emojiWidth, 
                svContainerScrollHeight - offsetY - (lineIndex - 1) * (emojiHeight + lineInterval) + 10))
            ivEmoji:setTouchEnabled(true)
            ivEmoji:addClickEventListener(function(sender)
                local idValue = "E" .. i
                print("点击表情,id=" .. idValue)
                local script = string.format("local msg={type = 1,id = '%s',len=%s}  return msg",idValue,2)
                self:send("game_talk_and_picture", {id = script})
                -- self.warpper:close()
                self:close()
            end)
            ivEmoji:addTo(self.layoutEmoji, 1)
        end
        for i = 1, math.ceil(emojiCount / rowNum) do
            local pos = cc.p(50, svContainerScrollHeight - (i - 1) * (emojiHeight + lineInterval) + 10)
            if i == 1 then
                cutLine = ccui.ImageView:create("mj/emoji_line_" .. i .. ".png")
                pos = cc.p(pos.x, pos.y - 20)
            elseif i == math.ceil(emojiCount / rowNum) then
                cutLine = ccui.ImageView:create("mj/emoji_line_3.png")
            else
                cutLine = ccui.ImageView:create("mj/emoji_line_2.png")
            end
            cutLine:setAnchorPoint(cc.p(0, 1))
            cutLine:setPosition(pos)
            cutLine:addTo(self.layoutEmoji, 2)
        end
        self.svContainer:setInnerContainerSize(cc.size(svContainerScrollWidth, svContainerScrollHeight))
        -- self.svContainer:setContentSize(cc.size(svContainerScrollWidth, svContainerScrollHeight))
        self.svContainer:setContentSize(cc.size(svContainerScrollWidth, 410))
        self.layoutEmoji:addTo(self.svContainer, 1)
    else
        self.svContainer:setVisible(true)
    end
    -- self.tabMsg:loadTexture("uires/common/btn_5_yellow.png")
    -- self.tMsg:setColor(cc.c3b(150,92,69))
    -- self.tabEmoji:loadTexture("uires/common/btn_2.png")
    -- self.tEmoji:setColor(cc.c3b(255,255,255))
    self.svContainer:setVisible(true)
    if self.svMsg then
        self.svMsg:setVisible(false)
    end
end

return ChatUI