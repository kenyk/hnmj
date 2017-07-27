

local FankuiUI = class("FankuiUI", cc.load("mvc").UIBase)

FankuiUI.RESOURCE_FILENAME = "uiFankui/UI_Fankui.csb"

function FankuiUI:onCreate()
    self:setInOutAction()
    self.closeBtn = helper.findNodeByName(self.resourceNode_,"closeBtn")
    self.closeBtn:setPressedActionEnabled(true)
    self.m_inputTel = helper.findNodeByName(self.resourceNode_, "input_1")
    self.m_inputMsg = helper.findNodeByName(self.resourceNode_, "input_2")
    self.m_inputDes1 = helper.findNodeByName(self.resourceNode_, "input_des_1")
    self.m_inputDes2 = helper.findNodeByName(self.resourceNode_, "input_des_2")

    if(UserData.fankuiTel)then self.m_inputTel:setString(UserData.fankuiTel)end
    self.m_inputDes1:setVisible(UserData.fankuiTel == nil or #UserData.fankuiTel < 1)

    self.m_inputTel:addEventListener(function(sender, eventType)
        if(eventType >= 0 and eventType < 4)then
            self.m_inputDes1:setVisible(#self.m_inputTel:getString() < 1)
        end
    end)

    self.m_inputMsg:addEventListener(function(sender, eventType)
        if(eventType >= 0 and eventType < 4)then
            self.m_inputDes2:setVisible(#self.m_inputMsg:getString() < 1)
        end
    end)
end

--确认提交
function FankuiUI:onMainBtnClick()

    local tel = self.m_inputTel:getString()
    local msg = self.m_inputMsg:getString()

    if(#tel < 1 and #msg < 1)then
        UIMgr:showTips("请输入您的联系电话与遇到的问题")
        return
    end

    local numTel = tonumber(tel) or ""
    if(#tostring(numTel) < 11)then
    	UIMgr:showTips("请输入您的联系电话")
    	return
    end

    if(#msg < 1)then
    	UIMgr:showTips("请输入您遇到的问题")
    	return
    end

    HttpServiers:queryqFankuiResult({
    	userId = UserData.uid,
    	content = msg,
    	contacts = tel,
    	suggestType = 1,
    	title = "",
    },
    function(entity,response,statusCode)

        if response and (response.status == 1 or response.errCode == 0) then
            UIMgr:showTips("问题已成功提交，谢谢您宝贵的建议!")
    	else
    		UIMgr:showTips("提交失败")
    		print("错误码：",response.errCode,"错误信息：",response.error)
        end
    end)
end

function FankuiUI:onCloseBtnClick()
	UserData.fankuiTel = self.m_inputTel:getString()
    self:close()
end

return FankuiUI




