

local BindAccountUI = class("BindAccountUI", cc.load("mvc").UIBase)

BindAccountUI.RESOURCE_FILENAME = "uiHongbao/UI_BindAccount.csb"

function BindAccountUI:onCreate(data)
    self:setInOutAction()

    self.m_inputTel = helper.findNodeByName(self.resourceNode_, "input_1")
    self.m_inputWx = helper.findNodeByName(self.resourceNode_, "input_2")
    self.m_telTip = helper.findNodeByName(self.resourceNode_, "input_des_1")
    self.m_wxTip = helper.findNodeByName(self.resourceNode_, "input_des_2")
   
    self.m_telTip:setVisible(data.tel == nil or #data.tel < 1)
    self.m_wxTip:setVisible(data.wx == nil or #data.wx < 1)

    self.m_inputTel:addEventListener(function(sender, eventType)
        if(eventType >= 0 and eventType < 4)then
            self.m_telTip:setVisible(#self.m_inputTel:getString() < 1)
        end
    end)

    self.m_inputWx:addEventListener(function(sender, eventType)
        if(eventType >= 0 and eventType < 4)then
            self.m_wxTip:setVisible(#self.m_inputWx:getString() < 1)
        end
    end)
end

--提交
function BindAccountUI:onCommitBtnClick()
    print("提交")

    local tel = self.m_inputTel:getString()
    local wx = self.m_inputWx:getString()

    local numTel = tonumber(tel) or ""
    if(#tostring(numTel) < 11 or #wx < 1)then
        UIMgr:showTips("请输入正确的领奖方式哦~")
        return
    end

    HttpServiers:queryRedpackBindAcc({
        phoneNumber = tel,
        userWechatId = wx,
    },
    function(entity,response,statusCode)

        if response and (response.status == 1 and response.errCode == 0) then
            local hongbaoUI = UIMgr:getUI(consts.UI.HongbaoUI)
            if hongbaoUI then
                hongbaoUI.m_data.userInfo.phoneNumber = tel
                hongbaoUI.m_data.userInfo.userWechatId = wx
                hongbaoUI.m_input_1:setString(tel)
                hongbaoUI.m_input_2:setString(wx)
                hongbaoUI:requestGetMoney()
            end
            UIMgr:showTips("提交成功")
        else
            UIMgr:showTips("提交失败")
            print("错误码：",response.errCode,"错误信息：",response.error)
        end
    end)

    self:close()
end

return BindAccountUI




