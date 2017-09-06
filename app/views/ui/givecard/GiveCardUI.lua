--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

local GiveCardUI = class("GiveCardUI", cc.load("mvc").UIBase)

GiveCardUI.RESOURCE_FILENAME = "uiGiveCard/UI_Give_Card.csb"

function GiveCardUI:onCreate()
    self:setInOutAction()
    self.closeBtn = helper.findNodeByName(self.resourceNode_,"closeBtn")
    self.closeBtn:setPressedActionEnabled(true)
    self.subBtn = helper.findNodeByName(self.resourceNode_,"btn_sub")
    self.subBtn:setPressedActionEnabled(true)
    self.addBtn = helper.findNodeByName(self.resourceNode_,"btn_add")
    self.addBtn:setPressedActionEnabled(true)
    self.conformBtn = helper.findNodeByName(self.resourceNode_,"Btn_conform_give")
    self.conformBtn:setPressedActionEnabled(true)
    
    self.m_textField_mycard = helper.findNodeByName(self.resourceNode_,"TextField_mycard")
    self.m_textField_give_id = helper.findNodeByName(self.resourceNode_,"TextField_give_id")
    self.m_textField_give_num = helper.findNodeByName(self.resourceNode_,"TextField_give_num")

    self.m_textField_mycard:setTouchEnabled(false)

    self.m_textField_mycard:setString(tostring(UserData.userInfo.totalGameCard))
    self.m_textField_give_id:setString("")
    self.m_textField_give_num:setString("")
    

    self.m_textField_mycard:addEventListener(function(sender, eventType)
        if(eventType >= 0 and eventType < 4)then
            --self.m_inputDes1:setVisible(#self.m_inputTel:getString() < 1)
        end
    end)

    self.m_textField_give_id:addEventListener(function(sender, eventType)
        if(eventType >= 0 and eventType < 4)then
            
        end
    end)

    self.m_textField_give_num:addEventListener(function(sender, eventType)
        if(eventType >= 0 and eventType < 4)then
            
        end
    end)

end

function GiveCardUI:onAdd()
	local givenum = self.m_textField_give_num:getString()
    local numGivenum = tonumber(givenum) or 0

    numGivenum = numGivenum + 10
    if numGivenum > tonumber(UserData.userInfo.totalGameCard) then
        numGivenum = tonumber(UserData.userInfo.totalGameCard)
    end
    self.m_textField_give_num:setString(tostring(numGivenum))
end

function GiveCardUI:onSub()
	local givenum = self.m_textField_give_num:getString()
    local numGivenum = tonumber(givenum) or 0

    numGivenum =  numGivenum - 10
    if numGivenum < 10 then
        numGivenum = 10
    end
    self.m_textField_give_num:setString(tostring(numGivenum))
end

function GiveCardUI:onConformGive()
    local mycard = self.m_textField_mycard:getString()
    local giveid = self.m_textField_give_id:getString()
    local givenum = self.m_textField_give_num:getString()

    local numMycard = tonumber(mycard) or ""
    if(#tostring(numMycard) < 1 or numMycard <= 0)then
        UIMgr:showTips("房卡不足，请联系管理员充值！")
        return
    end
    if(#giveid < 1)then
        UIMgr:showTips("请输入对方玩家ID！")
        return
    end
    if(#giveid < 7)then
        UIMgr:showTips("找不到该玩家，请重新输入！")
        return
    end

    if(tostring(UserData.uid) == giveid) then
        UIMgr:showTips("不能转让给自己，请重新输入赠送ID！")
        return
    end

    if (#givenum < 1) then
        UIMgr:showTips("请输入赠送房卡数量！")
        return
    end

    local numGivenum = tonumber(givenum) or ""
    if(#tostring(numMycard) < 1 or numGivenum <= 0)then
        UIMgr:showTips("请输入赠送房卡数量！")
        return
    end

    if math.floor(numGivenum) < numGivenum then
        UIMgr:showTips("请输入整数！")
        return
    end

    if(numGivenum > tonumber(UserData.userInfo.totalGameCard)) then
        UIMgr:showTips("赠送数量不能超出所拥有的房卡数，请重新输入！")
        return
    end

    HttpServiers:cardGive({
        appId = 1,
        appCode = "hnmj",
        userId = UserData.uid,
        otherId = giveid,
        cards = numGivenum,
        token = UserData.userInfo.token,
    },
    function(entity,response,statusCode)

        if response and (response.status == 1 or response.errCode == 0) then
            UIMgr:showTips("房卡转让成功!")
            self.m_textField_mycard:setString(tostring(tonumber(UserData.userInfo.totalGameCard)-numGivenum))
            NotifyMgr:push(consts.Notify.UPDATE_CARD_NUM)
        else
            UIMgr:showTips(response.error)
            print("错误码：",response.errCode,"错误信息：",response.error)
        end
    end)
end

function GiveCardUI:onCloseBtnClick()
	self:close()
end

return GiveCardUI