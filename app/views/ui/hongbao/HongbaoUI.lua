

local HongbaoUI = class("HongbaoUI", cc.load("mvc").UIBase)

HongbaoUI.RESOURCE_FILENAME = "uiHongbao/UI_Honghao.csb"

function HongbaoUI:onCreate()
    self:setInOutAction()

    local nodeName = {
    "closeBtn",
    "notice_node","act_time","act_des","reward_node","reward_sv",
    "log_node","log_sv","no_log_node","log_item_node",
    "back_node","all_num_lab","need_num_lab","time_lab","log_lab",
    "pre_node", "get_num_lab","input_1","input_2",
    }

    for i=1,#nodeName do
        self["m_"..nodeName[i]] = helper.findNodeByName(self.resourceNode_,nodeName[i])
    end
    self.m_closeBtn:setPressedActionEnabled(true)
    
    self.m_data = {}
    self:requestMainMsg()
end

--请求主界面信息
function HongbaoUI:requestMainMsg(  )
    
    HttpServiers:queryRedpackMain({
    },
    function(entity,response,statusCode)

        if response and (response.status == 1 and response.errCode == 0) then
            self.m_data = response.data
            self:updateMsg()

            --刷领奖记录
            self.m_rewardIndex = 0
            for i=1,3 do--策划说开始刷3条
                self:updateRewards()
            end
            self.m_rewardCall = gScheduler:scheduleScriptFunc(handler(self,self.updateRewards),10,false)

            --刷新活动结束时间
            self:updateEndTime()
            self.m_endTimeCall = gScheduler:scheduleScriptFunc(handler(self,self.updateEndTime),1,false)
        end
    end)
end

--请求领取红包
function HongbaoUI:requestGetMoney()
    HttpServiers:queryRedpackFetch({},
    function(entity,response,statusCode)
        if response and (response.status == 1 and response.errCode == 0) then
            self.m_data.userInfo.surplusMoney100 = response.data.userInfo.surplusMoney100
            self.m_data.userInfo.cashMoney = response.data.userInfo.cashMoney
            self:updateMsg()
        end
    end)
end

--请求提现记录
function HongbaoUI:requestLogMsg(  )
    
    HttpServiers:queryRedpackUserLog({},
    function(entity,response,statusCode)

        if response and (response.status == 1 and response.errCode == 0) then
            self.m_logData = response.data.list
            self:updateLog()
        end
    end)
end

function HongbaoUI:updateMsg(  )
    local userInfo = self.m_data.userInfo or {cashMoney = 0,surplusMoney100 = 0}
    local rewardsList = self.m_data.rewardsList or {}
    local actInfo = self.m_data.actInfo or {}

    --活动时间规则
    self.m_act_time:setString(actInfo.actTime or "")
    self.m_act_des:setString(actInfo.actDesc or "")

    --累计金额
    self.m_all_num_lab:setString(string.format("累计红包金额：%s元",userInfo.surplusMoney100))

    --提现差额
    local needNum = userInfo.cashMoney - userInfo.surplusMoney100
    local tipDes = "您的红包已满足提现条件，快快领取吧~~"
    if(needNum > 0)then
        tipDes = string.format("距离提现额度还少%s元，快招呼小伙伴们多来几局吧！",needNum)
    end
    self.m_need_num_lab:setString(tipDes)

    --开出的红包钱
    self.m_get_num_lab:setString(userInfo.cashMoney.."元")

    --手机微信
    self.m_input_1:setString(userInfo.phoneNumber or "")
    self.m_input_2:setString(userInfo.userWechatId or "")
end

--打开红包
function HongbaoUI:onOpenBtnClick()
    if(not self.m_data.userInfo)then return end

    local userInfo = self.m_data.userInfo
    if(tonumber(userInfo.surplusMoney100) < tonumber(userInfo.cashMoney))then
        UIMgr:showTips(string.format("红包金额不足%s元，多玩几把再来哦~~",userInfo.cashMoney))
        return
    end

    self.m_pre_node:setVisible(true)
    self.m_back_node:setVisible(false)

    --弹手机微信填写框
    if(#userInfo.phoneNumber < 1 or #userInfo.userWechatId < 1)then
        UIMgr:openUI(consts.UI.BindAccountUI,nil,nil,{tel = userInfo.phoneNumber,wx = userInfo.userWechatId})
    else
        self:requestGetMoney()
    end
end

function HongbaoUI:onCloseBtnClick()
    self:close()
end

function HongbaoUI:onMoneyLogBtnClick(  )

    if(self.m_log_node:isVisible())then
        --活动详情
        self.m_log_node:setVisible(false)
        self.m_notice_node:setVisible(true)
        self.m_log_lab:setString( "查看提现详情>>")
    else
        --提现记录
        self.m_log_node:setVisible(true)
        self.m_notice_node:setVisible(false)
        if(not self.m_logData)then self:requestLogMsg()end
        self.m_log_lab:setString("查看活动规则>>")
    end
end

--领奖列表
function HongbaoUI:updateRewards()
    if(#self.m_data.rewardsList < 1 or not self.m_notice_node:isVisible())then return end

    if(self.m_rewardIndex >= #self.m_data.rewardsList)then
        self:removeTimeCall({true})
        return
    end

    --创建条目
    self.m_rewardIndex = self.m_rewardIndex + 1
    local curPosY = self.m_rewardIndex * 70
    local msgLab = helper.createRichLabel({maxWidth = 470,lineSpace = 2})
    msgLab:addTo(self.m_reward_node,1)
    msgLab:setAnchorPoint(cc.p(0,1))
    msgLab:setPosition(cc.p(0,curPosY))
    msgLab:setString("       "..self.m_data.rewardsList[self.m_rewardIndex])
    display.newSprite("uires/hongbao/hb_line_1.png",228,curPosY-66):addTo(self.m_reward_node,1)

    --乔正位置
    local heigt = curPosY < 230 and 230 or curPosY
    self.m_reward_sv:setInnerContainerSize(cc.size(470,heigt))
    self.m_reward_node:setPosition(cc.p(0,heigt - curPosY))
end

--提现记录列表
function HongbaoUI:updateLog()
    self.m_no_log_node:setVisible(#self.m_logData < 1)
    if(#self.m_logData < 1)then return end

    --按日期排
    local itemLs = {}
    local keyLs = {}--用于排序
    for i=1,#self.m_logData do
        local key = self.m_logData[i].date
        if(not itemLs[key])then 
            itemLs[key] = {}
            table.insert(keyLs,key)
        end
        table.insert(itemLs[key],self.m_logData[i])
    end

    --排个序
    local sortLs = {}
    local getItemLs = function ( key )
        for k,v in pairs(itemLs) do
            if(k == key)then return v end
        end
    end

    for i=1,#keyLs do
        local itemMsg = getItemLs(keyLs[i])
        if(itemMsg)then table.insert(sortLs,itemMsg) end
    end

    self.m_log_item_node:removeAllChildren(true)
    local curPosY = 0
    for i,v in ipairs(sortLs) do
        --创建日期图片
        local dateIcon = display.newSprite("uires/hongbao/hb_icon_1.png",60,curPosY - 24):addTo(self.m_log_item_node,1)
        local dateLab = cc.LabelTTF:create(keyLs[i],"Arial",24):addTo(dateIcon,1)
        dateLab:setPosition(cc.p(12,20))
        dateLab:setAnchorPoint(cc.p(0,0.5))
        dateLab:setColor(cc.c3b(237,217,96))
        curPosY = curPosY - 76
        for i=1,#v do
            --创建条目
            local msgLab = cc.LabelTTF:create(i.."."..v[i].info,"res/sfzht.ttf",24):addTo(self.m_log_item_node,1)
            msgLab:setPosition(cc.p(60,curPosY))
            msgLab:setAnchorPoint(cc.p(0,0.5))
            curPosY = curPosY - 30

            local lineNum = i == #v and 2 or 1
            display.newSprite(string.format("uires/hongbao/hb_line_%s.png",lineNum),250,curPosY):addTo(self.m_log_item_node,1)
            curPosY = curPosY - 24
        end
    end
    local heigt = -curPosY < 480 and 480 or -curPosY
    self.m_log_sv:setInnerContainerSize(cc.size(500,heigt))
    self.m_log_item_node:setPosition(cc.p(0,heigt))
end

function HongbaoUI:updateEndTime()

    local needTime = self.m_data.actInfo.weekEndTime - self.m_data.actInfo.nowTime
    local tip = ""
    if(needTime > 0)then
        local tabTime = self:getTimeTab(needTime)
        if(tabTime.day > 0)then
            tip = string.format("红包清零剩余时间:%s天%s小时",tabTime.day,tabTime.hour)
        elseif(tabTime.hour > 0)then
            tip = string.format("红包清零剩余时间:%s小时%s分钟",tabTime.hour,tabTime.min)
        elseif(tabTime.min > 0)then
            tip = string.format("红包清零剩余时间:%s分钟%s秒",tabTime.min,tabTime.sec)
        elseif(tabTime.sec > 0)then
            tip = string.format("红包清零剩余时间:%s秒",tabTime.sec)
        end
    else
        self:removeTimeCall({false,true})
    end
    self.m_time_lab:setString(tip)
    self.m_data.actInfo.nowTime = self.m_data.actInfo.nowTime + 1
end

function HongbaoUI:getTimeTab( num )
    if(num < 1)then return {} end
    local sec  = num % 60
    local min  = math.floor((num/60)%60)
    local hour = math.floor(num/3600)%24
    local day  = math.floor(num/(3600*24))
    return {day = day,hour = hour,min = min,sec = sec}
end

function HongbaoUI:removeTimeCall(callTab)

    if callTab[1] and self.m_rewardCall then
        gScheduler:unscheduleScriptEntry(self.m_rewardCall)
        self.m_rewardCall = nil
    end 
    if callTab[2] and self.m_endTimeCall then
        gScheduler:unscheduleScriptEntry(self.m_endTimeCall)
        self.m_endTimeCall = nil
    end
end

function HongbaoUI:onExit()
    HongbaoUI.super.onExit(self)
    self:removeTimeCall({true,true})
end

return HongbaoUI




