

local PayUI = class("PayUI", cc.load("mvc").UIBase)
PayUI.RESOURCE_FILENAME = "uiPay/UI_Pay.csb"
require  "mime"

function PayUI:onCreate()
    self:setInOutAction()
    self.m_payPanel = helper.findNodeByName(self.resourceNode_, "pay_type_panel")
    self.m_itemNode = helper.findNodeByName(self.resourceNode_, "item_node")
    self.m_itemPanel = helper.findNodeByName(self.resourceNode_, "content_node")

    self:requestPayItem()
end

--请求商品列表
function PayUI:requestPayItem(  )
    
    HttpServiers:queryRechargeList({},
    function(entity,response,statusCode)
        if response and (response.status == 1 or response.errCode == 0) then
            if(#response.data < 1)then
                self.m_itemNode:removeAllChildrenWithCleanup(true)
            else
                self.m_itemLs = response.data
                self:updateView()
            end
        else
            
        end
    end)
end

function PayUI:updateView(  )
    if self.m_itemLs ~= nil and #self.m_itemLs > 0 then
        for i=1,#self.m_itemLs do
            local ui = self:createItem(i)
            ui:setPosition(cc.p((i-1)*238,0))
            ui:addTo(self.m_itemNode, 1)
        end
   end
end

function PayUI:createItem( index )
    local data = self.m_itemLs[index]
    local item = cc.CSLoader:createNode("uiPay/UI_Cell_pay.csb")
    local item_panel = helper.findNodeByName(item,"item_panel")
    item_panel:setTag(index)
    item_panel:addClickEventListener(function(sender) self:onCellClick(sender) end)

    local payIcon = helper.findNodeByName(item,"pay_icon")
    payIcon:setTexture("uires/pay/pay_icon_"..index..".png")

    local des = {"x"..data.buyNum,"¥"..data.money}
    for i=1,2 do
        local desLab = helper.findNodeByName(item,"des_"..i)
        desLab:setString(des[i])
    end
   
    return item
end

function PayUI:onCellClick(obj)
    local tag = obj:getTag()
    print("cell：",tag)
    self.m_itemIndex = tag

    self:showPayPanel()
end

function PayUI:showPayPanel(  )
    self.m_itemPanel:setVisible(false)
    self.m_payPanel:setVisible(true)
    if(self.m_payLs)then return end

    --请求支付渠道
    HttpServiers:queryPayList({},
    function(entity,response,statusCode)
        if response and (response.status == 1 or response.errCode == 0) then
            print("返回可支付项:",#response.data)
            self.m_payLs = response.data
            self:updatePayView()
        end
    end)
end

function PayUI:updatePayView()

    local desStr = {self.m_itemLs[self.m_itemIndex].money.."元",self.m_itemLs[self.m_itemIndex].buyNum.."张"}
    for i=1,2 do
        local desLab = helper.findNodeByName(self.resourceNode_,"item_des_"..i)
        desLab:setString(desStr[i])
    end
    if(not self.m_payLs)then return end

    local platId = {{3,1},{80,2}}--微信，支付宝
    for i=1,2 do
        if(self.m_payLs[i])then
            for j=1,#platId do
                if(self.m_payLs[i].pid == platId[j][1])then
                    local payBtn = helper.findNodeByName(self.resourceNode_,"pay_btn_"..platId[j][2])
                    payBtn:setVisible(true)
                    payBtn:setTag(i)
                    payBtn:addClickEventListener(function(sender) self:onPayClick(sender) end)
                    break
                end
            end
        end
    end
end

--下单点击
function PayUI:onPayClick(obj)
    local tag = obj:getTag()

    HttpServiers:queryrechargeAccount({rechargeId = self.m_itemLs[self.m_itemIndex].id,pid = self.m_payLs[tag].pid},
    function(entity,response,statusCode)
        if response and (response.status == 1 or response.errCode == 0) then
            if(self.m_payLs[tag].pid == 80)then--支付宝
                local unBase64Str = mime.unb64(response.data.parameter)  
                print("支付宝参数解码：",unBase64Str)
                --拉起支付宝支付
                local args = {orderInfo = unBase64Str,appScheme = "meme-hnmj"}
                LuaCallPlatformFun.aliPay(args)

            elseif(self.m_payLs[tag].pid == 3)then--微信
                --拉起微信支付
                response.data.parameter.timestamp = tostring(response.data.parameter.timestamp)
                LuaCallPlatformFun.wxPay(response.data.parameter)
            end
            self:close()
        else
            
        end
    end)
end

function PayUI:onCloseBtnClick()
    self:close()
end

return PayUI




