-- 麻将战斗场景背景图层
local ChatUI = require ("app.views.ui.chat.ChatUI")
local AnimationView = require("utils.extends.AnimationView")
MahjongBgLayer = class("MahjongBgLayer",function()
    return cc.Layer:create()
end)

function MahjongBgLayer:ctor(params)
    self:enableNodeEvents()
    self:initLayer()
    self:initEvent()
    self:showUpdate()
end

function MahjongBgLayer:initLayer()
    local font = "Arial"
    -- 背景图片
    self.mahjong_bg = display.newSprite("mj/"..UserData:getCurBgType().."/mahjong_back.png", 1366 / 2, 768 / 2)
    self.mahjong_bg:addTo(self, 1)

    -- 麻将类型选项文本
    self.labelMahjongType = cc.LabelTTF:create("", font, 19)
    self.labelMahjongType:setPosition(cc.p(consts.Size.width/2+10, consts.Size.height-273))
    -- self.labelMahjongType:setColor(cc.c3b(52, 105, 53))
    -- self.labelMahjongType:setColor(cc.c3b(6, 56, 91))
    self.labelMahjongType:setColor(consts.bg_type[UserData:getCurBgType()].mjDescColor)
    self.labelMahjongType:addTo(self, 1)
    self.labelMahjongType:setVisible(false)
    -- self.labelMahjongType:setAnchorPoint(cc.p(0.5, 1))
    -- self.labelMahjongType:setVisible(false)

    --电量
    local bgBatteryY = consts.Size.height - 23
    -- self.bgBattery = display.newSprite("mj/"..UserData:getCurBgType().."/battery_bg.png", consts.Size.width - 60, bgBatteryY):addTo(self, 10)
    -- self.battery = display.newSprite("mj/"..UserData:getCurBgType().."/battery.png", 0,  self.bgBattery:getContentSize().height / 2):addTo(self.bgBattery, 1)
    -- self.battery:setAnchorPoint(cc.p(0,0.5))
    -- self.bgBattery:setVisible(not Is_App_Store)

    --wifi
    local wifiBgX = 32
    self.wifiBg = display.newSprite("mj/"..UserData:getCurBgType().."/wifi_bg.png", wifiBgX,bgBatteryY):addTo(self, 10)
    self.wifiStrong = display.newSprite("mj/"..UserData:getCurBgType().."/wifi_strong.png", 0, self.wifiBg:getContentSize().height / 2):addTo(self.wifiBg, 1)
    self.wifiStrong:setAnchorPoint(cc.p(0,0.5))
    self.wifiWeak = display.newSprite("mj/"..UserData:getCurBgType().."/wifi_weak.png", 0, self.wifiBg:getContentSize().height / 2):addTo(self.wifiBg, 1)
    self.wifiWeak:setAnchorPoint(cc.p(0,0.5))
    self.wifiWeak:setVisible(false)
    self.wifiSuperWeak = display.newSprite("mj/"..UserData:getCurBgType().."/wifi_super_weak.png", 0, self.wifiBg:getContentSize().height / 2):addTo(self.wifiBg, 1)
    self.wifiSuperWeak:setAnchorPoint(cc.p(0,0.5))
    self.wifiSuperWeak:setVisible(false)
    self.wifiBg:setVisible(not Is_App_Store)

    --ping值
    -- self.txt_ping = ccui.Text:create("0ms", nil, 28):addTo(self, 10)
    -- self.txt_ping:setPosition(cc.p(wifiBgX + 65, bgBatteryY ))
    -- self.txt_ping:setColor(cc.c3b(78,206,78))

    --信号
    -- self.signalStrong = display.newSprite("mj/"..UserData:getCurBgType().."/signal_strong.png", wifiBgX,bgBatteryY):addTo(self, 10)
    -- self.signalWeak = display.newSprite("mj/"..UserData:getCurBgType().."/signal_weak.png",  wifiBgX,bgBatteryY):addTo(self, 10)
    -- self.signalWeak:setVisible(false)
    -- self.signalStrong:setVisible(not Is_App_Store)
    
    --时间
    self.tTime = ccui.Text:create(os.date("%H:%M", os.time()),nil, 26):addTo(self, 10)
    self.tTime:setPosition(cc.p(wifiBgX + 55, bgBatteryY))
    -- self.tTime:setColor(cc.c3b(199,199,199))
    self.tTime:setColor(consts.bg_type[UserData:getCurBgType()].roomIdColor)
    -- self.tTime:setColor(cc.c3b(230,230,230))
    self.schedulerTims = gScheduler:scheduleScriptFunc(handler(self,self.onTimeChange),60,false)

    -- 时间背景
    -- local rightCornerBg = display.newSprite("mj/timeBg.png"):addTo(self, 9)
    -- rightCornerBg:setAnchorPoint(cc.p(0,0.5))
    -- rightCornerBg:setScale(1.1)
    -- rightCornerBg:setPosition(cc.p(wifiBgX - 30, bgBatteryY - 15))

    -- 设置按钮（新菜单按钮）
    self.btn_setting = ccui.Button:create("uires/battle/battle_btn_pull.png", "uires/battle/battle_btn_pull.png", "")
    self.btn_setting:setAnchorPoint(cc.p(1,0.5))
    self.btn_setting:setPosition(consts.Size.width-30, bgBatteryY - 25)
    self.btn_setting:addTo(self, 99)
    self.btn_setting:setVisible(false)
    self.btn_setting:setPressedActionEnabled(true)

    -- 规则按钮
    self.btn_rule = ccui.Button:create("uires/battle/battle_btn_rule.png", "uires/battle/battle_btn_rule.png", "")
    self.btn_rule:setAnchorPoint(cc.p(1,0.5))
    self.btn_rule:setPosition(consts.Size.width-130, bgBatteryY - 25)
    self.btn_rule:addTo(self, 99)
    self.btn_rule:setVisible(false)
    self.btn_rule:setPressedActionEnabled(true)

    -- 表情按钮
    self.btn_emoji = ccui.Button:create("mj/bn_emoji.png", "mj/bn_emoji.png", "")
    self.btn_emoji:setAnchorPoint(cc.p(1,0.5))
    self.btn_emoji:setPosition(consts.Size.width-30, 350)
    self.btn_emoji:addTo(self, 99)
    self.btn_emoji:setVisible(false)
    self.btn_emoji:setPressedActionEnabled(true)

    -- 消息按钮
    self.btn_message = ccui.Button:create("mj/bn_voice.png", "mj/bn_voice.png", "")
    self.btn_message:setAnchorPoint(cc.p(1,0.5))
    self.btn_message:setPosition(consts.Size.width-30, 250)
    self.btn_message:addTo(self, 99)
    self.btn_message:setPressedActionEnabled(true)
    self.btn_message:setVisible(not Is_App_Store)

    --听牌提示按钮
    -- self.btn_ting = ccui.Button:create("mj/bn_tingTip.png", "mj/bn_tingTip.png", "")
    -- self.btn_ting:setAnchorPoint(cc.p(1,0.5))
    -- self.btn_ting:setPosition(consts.Size.width-30, 150)
    -- self.btn_ting:addTo(self, 99)
    -- self.btn_ting:setPressedActionEnabled(true)
    -- self.btn_ting:setVisible(false)
    --听牌提示按钮动画
    self.btn_ting = AnimationView:create("ting_btn", "action/ting_btn.csb")
    self.btn_ting:setPosition(consts.Size.width-66, 150)
    self.btn_ting:setAnchorPoint(cc.p(1,0.5))
    self.btn_ting:gotoFrameAndPlay(0, true)
    self.btn_ting:addTo(self, 99)
    local layout = ccui.Layout:create():addTo(self.btn_ting, -1)
    -- layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    -- layout:setBackGroundColor(cc.c3b(0x00, 0x00, 0xff))
    layout:setContentSize(cc.size(80, 80))
    layout:setPosition(cc.p(-40, -40))
    layout:setTouchEnabled(true)
    self.btn_ting.touchLayout = layout

    -- 飘
    for i = 1, 4 do
        self["piao"..i] = ccui.Button:create("mj/btn_piao_normal.png", "mj/btn_piao_normal.png", "")
        display.newSprite(string.format("mj/piao_%d.png", i-1)):addTo(self["piao"..i]):setPosition(cc.p(self["piao"..i]:getContentSize().width / 2, self["piao"..i]:getContentSize().height / 2 + 5))
        self["piao"..i]:setAnchorPoint(cc.p(1,0.5))
        self["piao"..i]:setPosition(-20 + consts.Size.width / 4 + i * 180, consts.Size.height / 2 - 130)
        self["piao"..i]:addTo(self, 99)
        self["piao"..i]:setVisible(false)
        -- self["piao"..i]:setVisible(true)
        self["piao"..i]:setPressedActionEnabled(true)
        self["piao"..i]:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
               GnetMgr:send("game_piao_point", {point = i - 1})
               self:waitOtherSelectPiao({data = i - 1})
            end
        end)
    end

    self.tip_di = display.newSprite("mj/tip_di.png")
    self.tip_di:setPosition(consts.Size.width / 2, consts.Size.height / 2 - 210)
    self.tip_di:addTo(self, 99)
    self.tip_di:setVisible(false)
    self.tip_txt = cc.LabelTTF:create("等待其他玩家选择飘分", "Arial", 28)
    self.tip_txt:setPosition(cc.p(self.tip_di:getContentSize().width / 2, self.tip_di:getContentSize().height / 2))
    self.tip_txt:addTo(self.tip_di)

    --位置
    if(not Is_App_Store and Is_Cheat_Set)then
        self.locationNode = ccui.Widget:create()
        self.locationNode:setTouchEnabled(true)
        self.locationNode:setPosition(cc.p(wifiBgX + 145,consts.Size.height))
        self.locationNode:addTo(self, 99)
        self.locationNode:setContentSize(cc.size(80,70))
        self.locationNode:setAnchorPoint(cc.p(0.5,1))

        self:updateFangAction()
        self.m_fangIconCall = gScheduler:scheduleScriptFunc(handler(self,self.updateFangAction),10,false)
    end
end

function MahjongBgLayer:updateFangAction()
    if(self.m_fangAction)then self.m_fangAction:removeFromParent()end
    self.m_fangAction = AnimationView:create("fang","action/fang/fang.csb")
    self.m_fangAction:setPosition(cc.p(50,30))
    self.m_fangAction:gotoFrameAndPlay(0,false)
    self.m_fangAction:addTo(self.locationNode)
end

function MahjongBgLayer:showPiaoBtn(data)
    for i = 1, 4 do
        self["piao"..i]:setVisible(data.data)
    end
    if true == data.data then
        for i=1,4 do
            self["piao"..i]:loadTextureNormal("mj/btn_piao_normal.png", ccui.TextureResType.localType)
            self["piao"..i]:setTouchEnabled(true)
        end
    else
        self.tip_di:setVisible(false)
    end
end

function MahjongBgLayer:waitOtherSelectPiao(data)
    local point = data.data
    for i=1,4 do
        self["piao"..i]:setTouchEnabled(false)
        self["piao"..i]:setVisible(true)
        if i ~= point + 1 then
            self["piao"..i]:loadTextureNormal("mj/btn_piao_disable.png", ccui.TextureResType.localType)
        end
    end
    self.tip_di:setVisible(true)
end

function MahjongBgLayer:initEvent()
    NotifyMgr:reg(consts.Notify.BATTERY_CHANGE, self.onBatteryChange, self)
    NotifyMgr:reg(consts.Notify.NET_INFO_CHANGE, self.onNetInfoChange, self)
    NotifyMgr:reg(consts.Notify.SELECT_PIAO_SHOW, self.showPiaoBtn , self)
    NotifyMgr:reg(consts.Notify.WAIT_OTHER_SELECT_PIAO, self.waitOtherSelectPiao , self)
    NotifyMgr:reg(consts.Notify.CHANGE_BG_TYPE, self.onChangeBgType, self)
    if(not Is_App_Store)then
        -- NotifyMgr:reg(consts.Notify.UPDATE_PING, self.updatePing, self)
    end
    self.btn_setting:addClickEventListener(handler(self,self.onBtnSettingClick))
    self.btn_rule:addClickEventListener(handler(self,self.onBtnRuleClick))
    self.btn_emoji:addClickEventListener(handler(self,self.onBtnEmojiClick))
    if(self.locationNode)then
        self.locationNode:addClickEventListener(handler(self,self.onLocationClick))
    end
    --以下是发语音操作
    self.btn_message:addTouchEventListener(function(sender, state)
        self:onBtnMessageClick(sender, state)
    end)
    LuaCallPlatformFun.getBatteryInfo()     --获取电量
    LuaCallPlatformFun.getNetInfo()         --获取网络信息

    --一分钟刷新一次电量和信号
    self.batteryInfoEntity = gScheduler:scheduleScriptFunc(function ()
        LuaCallPlatformFun.getBatteryInfo()
        LuaCallPlatformFun.getNetInfo()
    end, 60, false)
end

function MahjongBgLayer:updatePing(data)
    local tmp = math.ceil(data.data)
    self.txt_ping:setString(string.format("%dms", tmp))
    if tmp < 50 then
        self.txt_ping:setColor(cc.c3b(78,206,78))
        self.wifiStrong:setVisible(true)
        self.wifiWeak:setVisible(false)
        self.wifiSuperWeak:setVisible(false)
    elseif tmp < 150 then
        self.txt_ping:setColor(cc.c3b(252,216,93))
        self.wifiStrong:setVisible(false)
        self.wifiWeak:setVisible(true)
        self.wifiSuperWeak:setVisible(false)
    else
        self.txt_ping:setColor(cc.c3b(241,10,10))
        self.wifiStrong:setVisible(false)
        self.wifiWeak:setVisible(false)
        self.wifiSuperWeak:setVisible(true)
    end
end

function MahjongBgLayer:onChangeBgType()
    self.labelMahjongType:setColor(consts.bg_type[UserData:getCurBgType()].mjDescColor)
    self.tTime:setColor(consts.bg_type[UserData:getCurBgType()].timeColor)
    self.mahjong_bg:setTexture("mj/"..UserData:getCurBgType().."/mahjong_back.png")
    -- self.bgBattery:setTexture("mj/"..UserData:getCurBgType().."/battery_bg.png")
    -- self.battery:setTexture("mj/"..UserData:getCurBgType().."/battery.png")
    self.wifiBg:setTexture("mj/"..UserData:getCurBgType().."/wifi_bg.png")
    self.wifiStrong:setTexture("mj/"..UserData:getCurBgType().."/wifi_strong.png")
    self.wifiWeak:setTexture("mj/"..UserData:getCurBgType().."/wifi_weak.png")
    self.wifiSuperWeak:setTexture("mj/"..UserData:getCurBgType().."/wifi_super_weak.png")
    -- self.signalStrong:setTexture("mj/"..UserData:getCurBgType().."/signal_strong.png")
    -- self.signalWeak:setTexture("mj/"..UserData:getCurBgType().."/signal_weak.png")
    if self.m_sendingIcon then
        self.m_sendingIcon:loadTexture("mj/"..UserData:getCurBgType().."/voice_sending.png")
    end
end

-- 时间变化
function MahjongBgLayer:onTimeChange()
    self.tTime:setString(os.date("%H:%M", os.time()))
end


-- 电量变化
function MahjongBgLayer:onBatteryChange()
    dump(UserData.batteryInfo,"电量变化")
    if UserData.batteryInfo then
        -- self.battery:setScaleX(UserData.batteryInfo.batteryPercent)
    end
end

-- 网络状态变化
function MahjongBgLayer:onNetInfoChange()
    -- dump(UserData.netInfo,"网络状态变化")
    -- if UserData.netInfo then
    --     if UserData.netInfo.typeName == "2G" or UserData.netInfo.typeName == "3G"  or UserData.netInfo.typeName == "4G" then
    --         self.wifiBg:setVisible(false)
    --          if UserData.netInfo.signalLevel > 2 then
    --             self.signalStrong:setVisible(true and not Is_App_Store)
    --             self.signalWeak:setVisible(false)
    --         else 
    --             self.signalStrong:setVisible(false)
    --             self.signalWeak:setVisible(true and not Is_App_Store)
    --         end
    --     elseif UserData.netInfo.typeName == "WIFI" then
    --         self.wifiBg:setVisible(true and not Is_App_Store)
    --         self.signalStrong:setVisible(false)
    --         self.signalWeak:setVisible(false)
    --         if UserData.netInfo.signalLevel > 2 then
    --             self.wifiStrong:setVisible(true)
    --             self.wifiWeak:setVisible(false)
    --         else 
    --             self.wifiStrong:setVisible(false)
    --             self.wifiWeak:setVisible(true)
    --         end
    --     end
    -- end
end

function MahjongBgLayer:onBtnSettingClick()
	--UIMgr:openUI(consts.UI.SettingUI,nil,nil,{fromType="gameplay"})
    UIMgr:openUI(consts.UI.BattleSettingUI)
end

function MahjongBgLayer:onBtnRuleClick()
    UIMgr:openUI(consts.UI.RuleUI)
end

function MahjongBgLayer:onBtnEmojiClick()
    -- UIMgr:showConfirmDialog(nil,{child = ChatUI:create(),width = 732, height = 650, 
    -- childOffsetX = 0 - consts.Size.width / 2, childOffsetY = 0 - consts.Size.height / 2,  canCancelOutside = true}, nil, nil)
    UIMgr:openUI(consts.UI.ChatUI, nil,nil)
end

function MahjongBgLayer:onLocationClick(  )
    UIMgr:openUI(consts.UI.LocationUI)
end

function MahjongBgLayer:onBtnMessageClick(sender, state)
    local canRecord = LuaCallPlatformFun.openMicPhone()
    if state == 0 then
        if(not canRecord)then 
            UIMgr:showTips("请打开麦克风")
            return 
        end
        self.m_beginTime = os.time()
        if(not self.m_sendingIcon)then
            self.m_sendingIcon = ccui.ImageView:create("mj/"..UserData:getCurBgType().."/voice_sending.png"):addTo(self,100)
            self.m_sendingIcon:setPosition(consts.Size.width/2, 250)
        else
            self.m_sendingIcon:setVisible(true)
        end
        LuaCallPlatformFun.beginRecordVoice()
        self.m_recording = true
        --达最大限时，强制发送
        self.m_timeCall = gScheduler:scheduleScriptFunc(handler(self,self.sendVoiceRecord),50,false )
    elseif state == 1 then
    elseif state == 2 then
        if(not canRecord)then return end
        self:sendVoiceRecord()
    else
        if(not canRecord)then return end
        --取消发送
        self.m_recording = false
        self.m_sendingIcon:setVisible(false)
        LuaCallPlatformFun.breakRecordVoice()
        if self.m_timeCall then
            gScheduler:unscheduleScriptEntry(self.m_timeCall)
            self.m_timeCall = nil
        end
    end
end

--发送语音
function MahjongBgLayer:sendVoiceRecord()
    if self.m_timeCall then
        gScheduler:unscheduleScriptEntry(self.m_timeCall)
        self.m_timeCall = nil
    end 
    if(self.m_recording)then
        self.m_recording = false
        self.m_sendingIcon:setVisible(false)
        --最短时长限制
        local time = os.time() - self.m_beginTime
        if(time < 1)then
            LuaCallPlatformFun.breakRecordVoice()
            --此处显示时长短图片
            if(not self.m_faile)then
                self.m_faile = ccui.ImageView:create("mj/"..UserData:getCurBgType().."/voice_send_lose.png"):addTo(display.getRunningScene(),100)
                self.m_faile:setPosition(consts.Size.width/2, 250)
            else
                self.m_faile:setVisible(true)
            end
            performWithDelay(self, function()
                self.m_faile:setVisible(false)
            end,1)
        else
            LuaCallPlatformFun.endRecordVoice()
        end
    end
end

function MahjongBgLayer:showUpdate()
    if UserData.game_status == UserData.GAME_STATUS.waiting then
        self.btn_setting:setVisible(false)
        self.btn_rule:setVisible(false)
        self.btn_emoji:setVisible(false)
        self.btn_message:setVisible(true and not Is_App_Store)
        self.btn_ting:setVisible(false)
    elseif UserData.game_status == UserData.GAME_STATUS.start then
        self.btn_setting:setVisible(true)
        self.btn_rule:setVisible(true)
        self.btn_emoji:setVisible(true)
        self.btn_message:setVisible(true and not Is_App_Store)
    elseif UserData.game_status == UserData.GAME_STATUS.nextWaiting then
        self.btn_setting:setVisible(true)
        self.btn_rule:setVisible(false)
        self.btn_message:setVisible(true and not Is_App_Store)
        self.btn_emoji:setVisible(false)
        self.btn_ting:setVisible(false)
    end
    if UserData.isInReplayScene then
        self.btn_setting:setVisible(false)
        self.btn_rule:setVisible(false)
        self.btn_message:setVisible(false)
        self.btn_emoji:setVisible(false)
        self.btn_ting:setVisible(false)
    end
    self:updateGameInfo()
end

function MahjongBgLayer:updateGameInfo()
    if UserData.table_config then
        self.labelMahjongType:setString(UserData.table_config.rule_txt)
    end
end

function MahjongBgLayer:onExit()
    if self.m_timeCall then
        gScheduler:unscheduleScriptEntry(self.m_timeCall)
        self.m_timeCall = nil
    end
    if self.schedulerTims then
        gScheduler:unscheduleScriptEntry(self.schedulerTims)
        self.schedulerTims = nil
    end
    if self.batteryInfoEntity then
        gScheduler:unscheduleScriptEntry(self.batteryInfoEntity)
        self.batteryInfoEntity = nil
    end
    if self.m_fangIconCall then
        gScheduler:unscheduleScriptEntry(self.m_fangIconCall)
        self.m_fangIconCall = nil
    end
    NotifyMgr:unregWithObj(self)
end

return MahjongBgLayer
