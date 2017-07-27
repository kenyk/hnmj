--
-- Author: LXL
-- Date: 2016-11-08 09:20:25
--

local ClubRankView = class("ClubRankView", cc.load("mvc").UIBase)
local index = 0

ClubRankView.RESOURCE_FILENAME = "uiClub/ClubRankView.csb"
local ClubTabBtn = require "app.views.ui.club.ClubTabBtn"

function ClubRankView:onCreate(data)
 	self.closeBtn = helper.findNodeByName(self.resourceNode_,"closeBtn")
 	self.content_node = helper.findNodeByName(self.resourceNode_,"content_node")
    self.list_tab = helper.findNodeByName(self.resourceNode_,"list_tab")
    self.list_item = helper.findNodeByName(self.resourceNode_,"list_item")
 	self.real_bg = helper.findNodeByName(self.resourceNode_,"real_bg")
 	self.closeBtn:setPressedActionEnabled(true)
    self:setInOutAction()

    for i=1,2 do
        local btn = ClubTabBtn:create(i)
        self.list_tab:pushBackCustomItem(btn)
        btn.m_btn:setTag(i)
        self["tab_btn_"..i] = btn
        btn.m_btn:addClickEventListener(function(sender) self:tabSelect(sender:getTag()) end)
    end

    -- for i=1,10 do
    --     local item = cc.CSLoader:createNode("uiClub/ClubRankItem.csb")
    --     local widget = ccui.Widget:create()
    --     widget:addChild(item)
    --     widget:setContentSize(item:getChildByName("panel"):getContentSize())
    --     self.list_item:pushBackCustomItem(widget)
    -- end

    local rt = helper.createRichLabel({maxWidth = 520,fontSize = 20,fontColor = cc.c3b(0, 0, 0), lineSpace = 0})
    rt:setAnchorPoint(cc.p(0, 1))
    rt:setPosition(cc.p(250, 410)):addTo(self.real_bg, 100)
    -- rt:setString("电饭锅地方关服和发改局刚回家刚回家大概好风光和峰哥个发广告发过火峰哥好")
    self.announce = rt

    self:tabSelect(1)
    self.data = data
end

function ClubRankView:onEnter()
    ClubRankView.super.onEnter(self)

    -- dump(self.data)
    HttpServiers:getRankList({userId = UserData.uid, clubId = self.data.clubId},
        function(entity,response,statusCode)
            if entity  then
                self.yesterdayList = entity.yesterday
                self.todayList = entity.today
                self.announce:setString(entity.rankSet.note)
                self:updateData()
            else
                
            end
        end)
end

function ClubRankView:onClose()
	self:close()
end

function ClubRankView:tabSelect(index)
    self.list_item:removeAllItems()
    print(index)
    -- if(self.m_select_tab == index)then return end
    for i=1, 2 do
        self["tab_btn_"..i]:setSelect(false)
    end
    self["tab_btn_"..index]:setSelect(true)
    self.curTab = index
    self:updateData()
end

function ClubRankView:updateData()
    local dataList
    if 1 == self.curTab then
        dataList = self.todayList
    else
        dataList = self.yesterdayList
    end
    if nil == dataList then
        return
    end

    for _, v in pairs(dataList) do
        local item = cc.CSLoader:createNode("uiClub/ClubRankItem.csb")
        local widget = ccui.Widget:create()
        widget:addChild(item)
        widget:setContentSize(item:getChildByName("panel"):getContentSize())
        item:getChildByName("panel"):getChildByName("txt1"):setString(v.rankNum)
        item:getChildByName("panel"):getChildByName("txt2"):setString(v.nickName)
        item:getChildByName("panel"):getChildByName("txt3"):setString(v.userId)
        item:getChildByName("panel"):getChildByName("txt4"):setString(v.playNum)
        item:getChildByName("panel"):getChildByName("txt5"):setString(v.point)
        self.list_item:pushBackCustomItem(widget)
    end
end

return ClubRankView