--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

local HelpUI = class("HelpUI", cc.load("mvc").UIBase)
local RichLabel = require("utils.richlabel.RichLabel")
local MahjongTile = import("...mj.MahjongTile")

local RoomTabBtn = require "app.views.ui.create.RoomTabBtn"
HelpUI.RESOURCE_FILENAME = "uiSetting/UI_Help.csb"

local mjScale = 1.3

local tabPos = {1770,1720,2300,2450}

local tabNum = 6
local size = cc.size(720, 480)
-- local pos = cc.p(440, 130)
local pos = cc.p(10, 10)

function HelpUI:onCreate(params)
    self:setInOutAction()
    self.closeBtn = helper.findNodeByName(self.resourceNode_,"closeBtn")
    self.closeBtn:setPressedActionEnabled(true)
    self.web_node = helper.findNodeByName(self.resourceNode_,"web_node")
    self.bgContent = helper.findNodeByName(self.resourceNode_,"bgContent")
    self.list_tab = helper.findNodeByName(self.resourceNode_,"list_tab")
    self.img_bg_view = helper.findNodeByName(self.resourceNode_,"img_bg_view")
end

function HelpUI:onDrawCsb()

    self.m_sv = helper.findNodeByName(self.resourceNode_,"scrollView")

    self.m_tab_img = {}
    self.m_tab_node = {}
    for i=1,tabNum do
        local tab_img_s = helper.findNodeByName(self.resourceNode_,"tab_"..i.."_img_s")
        local tab_node = helper.findNodeByName(self.resourceNode_,"tab_node_"..i)
        local textNormal = helper.findNodeByName(self.resourceNode_,"tab_"..i.."_text_n")
        textNormal:setString(self.titles[i])
        local tab_text_s = helper.findNodeByName(tab_img_s,"tab_"..i.."_text_s")
        table.insert(self.m_tab_img,tab_img_s)
        table.insert(self.m_tab_node,tab_node)
        tab_img_s:setVisible(1 == i)
        tab_text_s:setString(self.titles[i])
    end
    if(Is_App_Store)then
        local tab_3_text_n = helper.findNodeByName(self.resourceNode_,"tab_3_text_n")
        local tab_4_text_n = helper.findNodeByName(self.resourceNode_,"tab_4_text_n")
        tab_3_text_n:setVisible(false)
        tab_4_text_n:setVisible(false)
    end
end

function HelpUI:onDrawWeb( params )

    local title = params.title or {}
    local url = params.url or {}
    --赋值
    self.m_tab_text = {}
    self.m_tab_img = {}

    for i=1,2 do
        local tab_text_n = helper.findNodeByName(self.resourceNode_,"tab_"..i.."_text_n")
        local tab_text_s = helper.findNodeByName(self.resourceNode_,"tab_"..i.."_text_s")
        local tab_img_s = helper.findNodeByName(self.resourceNode_,"tab_"..i.."_img_s")
        table.insert(self.m_tab_text,{tab_text_n,tab_text_s})
        table.insert(self.m_tab_img,tab_img_s)

        tab_img_s:setVisible(url[i] ~= nil and 1 == i)
        tab_text_n:setString(title[i] or "")
        tab_text_s:setString(title[i] or "")
    end
    self.bgContent= helper.findNodeByName(self.resourceNode_,"bgContent")
    self.m_url = url
    local obj = cc.Node:create()
    obj:setTag(1)
    self:onClickTab(obj)
end

function HelpUI:onClickTab(tag)
    print(tag)
    for i=1, tabNum do
        self["tab_btn_"..i]:setSelect(false)
    end
    self["tab_btn_"..tag]:setSelect(true)

    -- for i=1,tabNum do
    --   self.m_tab_img[i]:setVisible(i == tag)
    --   -- self.m_tab_node[i]:setVisible(i == tag)
    --   self.m_tab_node[i]:setVisible(false)
    -- end

    if self.webview and self.urls[tag] then
        print("webUrl:",self.urls[tag])
        self.webview:removeSelf()

        local view = ccexp.WebView:create()
        view:loadURL(self.urls[tag])
        view:setAnchorPoint(cc.p(0, 0))
        view:setContentSize(size)
        view:setScalesPageToFit(true)
        view:setPosition(pos)
        view:setBounces(false)
        -- self.resourceNode_:addChild(view)
        self.img_bg_view:addChild(view)
        self.webview = view
    end
    self.m_sv:setInnerContainerSize(cc.size(1290, tabPos[tag]))
end

function HelpUI:update(data)
    local params = data.data
    if(params)then    
        self.urls = params.urls
        self.titles = params.titles
        self:onDrawCsb()
        --webview

        if cc.PLATFORM_OS_WINDOWS == cc.Application:getInstance():getTargetPlatform() then
            local layout = ccui.Layout:create()
            layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
            layout:setBackGroundColor(cc.c3b(0x00, 0x00, 0xff))
            layout:setContentSize(size)
            layout:setPosition(pos)
            layout:setTouchEnabled(true)
            -- layout:setAnchorPoint(cc.p(0.5, 0.5))
            -- self.resourceNode_:addChild(layout)
            self.img_bg_view:addChild(layout)
        else
            local view = ccexp.WebView:create()
            -- view:loadURL(self.urls[1])
            view:setAnchorPoint(cc.p(0, 0))
            view:setContentSize(size)
            view:setScalesPageToFit(true)
            view:setPosition(pos)
            view:setBounces(false)
            -- self.resourceNode_:addChild(view)
            self.img_bg_view:addChild(view)
            self.webview = view
        end
    else
        self.web_node:setVisible(false)
        -- performWithDelay(self,handler(self,self.onDrawText), 0.01)
    end

    for i=1,tabNum do
        local btn = RoomTabBtn:create(i)
        btn.m_btn:setTag(i)
        self["tab_btn_"..i] = btn
        btn.m_btn:addClickEventListener(function(sender) self:onClickTab(sender:getTag()) end)
    end
    --1转转 2长沙 3郴州 4红中 5宁乡
    --顺序
    local tab_seq_list = {1, 5, 2, 6, 3, 4}
    for _, v in pairs(tab_seq_list) do
        self.list_tab:pushBackCustomItem(self["tab_btn_"..v])
    end
    self:onClickTab(1)
end

function HelpUI:onEnter()
    HelpUI.super.onEnter(self)
    NotifyMgr:reg(consts.Notify.UPDATE_HELP_UI, self.update ,self)
end

function HelpUI:onExit()
    HelpUI.super.onExit(self)
    self.webview:removeSelf()
    self.img_bg_view:removeAllChildren()
end

function HelpUI:onCloseBtnClick(sender)
    self:close()
end

--缩放大小
function HelpUI:getScaleSize(size)
    return mjScale*size
end

return HelpUI