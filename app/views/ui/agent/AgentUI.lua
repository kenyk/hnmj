

local AgentUI = class("AgentUI", cc.load("mvc").UIBase)

AgentUI.RESOURCE_FILENAME = "uiAgent/UI_Agent.csb"

function AgentUI:onCreate()

    print("AgentUI:onCreate() =======")
    self:setInOutAction()
    self.closeBtn = helper.findNodeByName(self.resourceNode_,"closeBtn")
    self.closeBtn:setPressedActionEnabled(true)
    self.m_inputTel = helper.findNodeByName(self.resourceNode_, "input_1")
    self.m_inputDes1 = helper.findNodeByName(self.resourceNode_, "input_des_1")

    if(UserData.fankuiTel)then self.m_inputTel:setString(UserData.fankuiTel)end
    self.m_inputDes1:setVisible(UserData.fankuiTel == nil or #UserData.fankuiTel < 1)

    self.m_inputTel:addEventListener(function(sender, eventType)
        if(eventType >= 0 and eventType < 4)then
            self.m_inputDes1:setVisible(#self.m_inputTel:getString() < 1)
        end
    end)
end

--确认提交
function AgentUI:onMainBtnClick()

    local tel = self.m_inputTel:getString()

    if(#tel < 1 )then
        UIMgr:showTips("请输入您的联系电话")
        return
    end

    local numTel = tonumber(tel) or ""
    if(#tostring(numTel) < 11)then
    	UIMgr:showTips("请输入您的联系电话")
    	return
    end

    -- HttpServiers:applyAgentResult({
    -- 	userId = UserData.uid,
    --     appId = 2,
    --     appCode = 'lnmj',
    --     nickName = UserData.nickname,
    --     -- nickName = 'YK',
    --     phoneNum = tel,
    --     token = 'test'
    -- },
    -- function(entity,response,statusCode)

    --     if response and (response.status == 1 or response.errCode == 0) then
    --         UIMgr:showTips("问题已成功提交，谢谢您宝贵的建议!")
    -- 	else
    -- 		UIMgr:showTips("提交失败")
    -- 		print("错误码：",response.errCode,"错误信息：",response.error)
    --     end
    -- end)

    HttpServiers:applyAgentResult({
        userId = UserData.uid,
        appId = consts.appId,
        appCode = consts.appCode,
        activationCode = UserData.userInfo.activationCode,
        nickName = UserData.userInfo.nickName,
        phoneNum = tel,
        token = UserData.userInfo.token
    },
    function(entity,response,statusCode)

        if response and (response.status == 1 or response.errCode == 0) then
            UIMgr:showTips("你的申请已提交成功，么么管理员很快会联系您!")
        else
            UIMgr:showTips(response.error)
            print("错误码：",response.errCode,"错误信息：",response.error)
        end
    end)
end

function AgentUI:onCloseBtnClick()
	-- UserData.fankuiTel = self.m_inputTel:getString()
    self:close()
end

return AgentUI




