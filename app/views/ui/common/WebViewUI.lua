
local WebViewUI = class("WebViewUI", cc.load("mvc").UIBase)

WebViewUI.RESOURCE_FILENAME = "common/UI_Web_View.csb"

function WebViewUI:onCreate(params)
    self.closeBtn = helper.findNodeByName(self.resourceNode_,"closeBtn")
    self.bgContent= helper.findNodeByName(self.resourceNode_,"bgContent")
    self.bg= helper.findNodeByName(self.resourceNode_,"bg")
    self.title_node= helper.findNodeByName(self.resourceNode_,"title_node")
    self.title_sp= helper.findNodeByName(self.resourceNode_,"title_sp")

    if(params.type == 1)then--协议
        self.title_node:setVisible(false)
        self.bg:setVisible(false)
    elseif(params.type == 2)then--消息
        self.title_node:setVisible(true)
        self.bg:setVisible(true)
        self.title_sp:setTexture("uires/common/messege_title.png")
    elseif(params.type == 3)then--规则玩法
        self.title_node:setVisible(true)
        self.bg:setVisible(true)
        self.title_sp:setTexture("uires/common/help_title.png")
    end

    if device.platform == "ios" or device.platform == "android" then
        local width = self.bgContent:getContentSize().width
        local height = self.bgContent:getContentSize().height
        self.webView = ccexp.WebView:create()
        self.webView:setAnchorPoint(cc.p(0.5,0.5))
        self.webView:setPosition(cc.p(width/ 2,height / 2))
        self.webView:setContentSize(cc.size(width - 40 - 6, height - 40 - 6))
        self.webView:setVisible(true)
        self.webView:loadURL(params.url)
        self.webView:addTo(self.bgContent,1)
    end
end

function WebViewUI:onCloseBtnClick()
     self:close()
end

return WebViewUI