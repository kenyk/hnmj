--
-- Author: LXL
-- Date: 2016-11-02 14:19:29
--

local LoginUI = class("LoginUI", cc.load("mvc").UIBase)

LoginUI.RESOURCE_FILENAME = "uiLogin/UI_Login.csb"
LoginUI.RESOURCE_MODELNAME = "app.views.ui.login.LoginModel"


function LoginUI:onCreate()
    self.loginBtn = helper.findNodeByName(self.resourceNode_, "loginBtn")
    self.loginBtn:setPressedActionEnabled(true)
    self.loginBtn:setVisible(not Is_App_Store)
    self.loginBtn2 = helper.findNodeByName(self.resourceNode_, "loginBtn_2")
    self.loginBtn2:setPressedActionEnabled(true)
    self.loginBtn2:setVisible(Is_App_Store)
    self.loginAgree = helper.findNodeByName(self.resourceNode_, "loginAgree")
    self.login_test = helper.findNodeByName(self.resourceNode_, "login_test")

    self.test = helper.findNodeByName(self.login_test, "test")
    --self.login_test:setVisible(consts.App.APP_PLATFORM == cc.PLATFORM_OS_WINDOWS)
    --self.test:setString("200015")
    self.test:setString("2000005")
    if WIN32DEBUG then
        self.test:setString(DEBUGACCOUNT)
    end
    self.login_test:setVisible(CC_PACKET_VERSION == 1)
    self.loginAgree:setSelected(true)
    if(not Is_App_Store)then
        NotifyMgr:reg(consts.Notify.SDK_LOGIN_BACK, self.onThirdLogin, self)
    end
    -- test
    self.cbNW = helper.findNodeByName(self.resourceNode_, "cbNW")
    self:onNetChange()
    if(not Is_App_Store)then
        BIHttpClient:postBIeventInfo(consts.BIeventType.page,consts.BIcurrentPath.loginPage)
    end


    self.txt_version = ccui.Text:create("1.1.0", "sfzht.ttf", 35):addTo(self.resourceNode_, 10):setAnchorPoint(cc.p(0, 1))
    self.txt_version:setPosition(cc.p(10, 759))
    self.txt_version:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    -- local curVersion = cc.UserDefault:getInstance():getStringForKey("current-version-codezd")
    -- self.txt_version:setString("当前版本"..curVersion)
    GameVersion = require "assetmgr.GameVersion"
    self.txt_version:setString(GameVersion.CURRENT_VERSION)
end

function LoginUI:onEnter()
    if(Is_App_Store)then return end

    performWithDelay(self,function()
        if LocalData.data.thirdLoginData then
            self:onLogin()
        end
    end,0.2)
end

function LoginUI:onExit()
    LoginUI.super.onExit(self)
     --add by zengbingrong
    if(not Is_App_Store)then
        NotifyMgr:unregWithObj(self)
    end
end

function LoginUI:onNetChange()

    if CC_PACKET_VERSION == 1 then
        if self.cbNW:isSelected() then
            ---内网
            consts.BIHttpHost = consts.BIHttpHost_lan
            --consts.HttpHost = "10.17.174.171:8192"  
            --consts.GameHttpHost = "10.17.173.92:8001" --涛
            --consts.GameHttpHost = "10.17.174.171:8001" --内
            consts.HttpHost = "121.201.48.188:8192" 
            consts.GameHttpHost = "121.201.48.188:8001" --内
        else
            ---外网
            consts.BIHttpHost = consts.BIHttpHost_wan
            -- consts.HttpHost = "api.kuailai88.com"
            consts.HttpHost = "121.201.48.188:8192" --测试外网
            -- consts.GameHttpHost = "dlklmj.kuailai88.com:8001"    --审核外网HTTP地址
            -- consts.GameHttpHost = "dlklmj3.kuailai88.com:8001"     --发布包外网HTTP地址
            consts.GameHttpHost = "dlklmjtest.kuailai88.com:8002"     --测试外网

            consts.HttpHost = "api.kuailai88.com"
            consts.GameHttpHost = "dlklmj.kuailai88.com:8001"
        end
    elseif CC_PACKET_VERSION == 2 then
         --审核包使用
         if consts.App.APP_PLATFORM ~= cc.PLATFORM_OS_WINDOWS then
             consts.HttpHost = "api.kuailai88.com"
             consts.GameHttpHost = "dlklmj.kuailai88.com:8001"
             consts.BIHttpHost = consts.BIHttpHost_wan
         end
     elseif CC_PACKET_VERSION == 3 then
         --发布包使用
         if consts.App.APP_PLATFORM ~= cc.PLATFORM_OS_WINDOWS then

             --consts.HttpHost = "api.kuailai88.com"
             --consts.GameHttpHost = "dlklmj3.kuailai88.com:8001"
             consts.HttpHost = "119.29.64.46:40001"
             consts.GameHttpHost = "119.29.64.46:8001"
             consts.BIHttpHost = consts.BIHttpHost_wan
         end
     end

end


-- 登录回调
-- 数据结构
-- {
-- "access_token"
-- "city"
-- "country"
-- "expires_in"
-- "gender"
-- "language"
-- "openid"
-- "profile_image_url"
-- "province"
-- "refresh_token"
-- "screen_name"
-- "unionid"
-- }
function LoginUI:onThirdLogin(data)
    if data == nil or data.data == nil then 
        UIMgr:closeUI(consts.UI.LoadingDialogUI)    
        return 
    end
    self.thirdLoginData = data 
    data = data.data
    HttpServiers:login({
        openId           = data.openid,
        accessToken      = data.access_token or data.accessToken,
        refreshToken = data.refresh_token or data.refreshToken,
        wechatAppId = consts.wechatAppId }, handler(self, self.loginCallback))
end

function LoginUI:loginSuccess()
    UserData.uid = tonumber(UserData.userInfo.userId)
	UserData.login = true
    if self.thirdLoginData then
        self.thirdLoginData.data.access_token = UserData.userInfo.wechatAccessToken or self.thirdLoginData.data.access_token
        self.thirdLoginData.data.refresh_token = UserData.userInfo.wechatRefreshToken or self.thirdLoginData.data.refresh_token
    end
    LocalData.data.thirdLoginData = self.thirdLoginData
    LocalData:save()
    BIHttpClient:postBIeventInfo(consts.BIeventType.click,consts.BIcurrentPath.loginSuccessClick)
    self:queryStaus()
end  

function LoginUI:queryStaus()
    HttpServiers:queryStaus(nil, 
        function(entity,response,statusCode)
            UIMgr:closeUI(consts.UI.LoadingDialogUI)
            if entity then
                local addressSplit = string.split(entity.address, ":")
                local ip =  addressSplit[1]
                local port = addressSplit[2]
                GnetMgr:initConnect(ip, port,handler(self,self.connectSuccess))
            elseif response and response.errCode == -1 then
                UIMgr:openUI(consts.UI.mainUI)
                if self.close then
	                self:close()
                end
            elseif response and response.errCode then
                GnetMgr:showErrorTips(response.errCode, true)
            else
                UIMgr:showNetErrorTip(function()
                    UIMgr:showLoadingDialog("登录中...")
                    self:queryStaus()
                end)
            end
        end)
end

function LoginUI:connectSuccess()
    MyApp:goToGame()
end

--服务器数据收集处理
function LoginUI:proListHandler(msg)
    if msg.name == "role_login" then
        UserData.userInfo = UserData.userInfo or {}
        UserData.userInfo.surplusGameCard = msg.args.card
        -- UserData.userInfo.nickName = msg.args.nickname
        UserData.userInfo.nickName = helper.nameAbbrev(msg.args.nickname)
        UserData.userInfo.gender = msg.args.gender
        UserData.userInfo.userId = UserData.uid
        UserData.login = true
        UIMgr:closeUI(consts.UI.LoadingDialogUI)
        UIMgr:openUI(consts.UI.mainUI)
        if self.close then
            self:close()
        end
    end
end

function LoginUI:onLogin(event)
	local agreeStatus = self.loginAgree:isSelected()
	if agreeStatus then
        print("登录")
        UIMgr:showLoadingDialog("登录中...")
		--登录游戏
		local uid = tonumber(self.test:getString())
        if uid == nil or CC_PACKET_VERSION ~= 1 then
            if device.platform=="android" or device.platform=="ios" then
                if LocalData.data.thirdLoginData then
                    dump(LocalData.data.thirdLoginData)
                    self:onThirdLogin(LocalData.data.thirdLoginData)
                else
                    LuaCallPlatformFun.login()
                end
            end
		else
            HttpServiers:login({openId = uid, accessToken="test"}, handler(self, self.loginCallback))
        end
	else
		--弹框提示需要确认用户协议
        print("弹框提示需要确认用户协议")
        local dialogContentLabel1 = helper.createRichLabel({maxWidth = 600,fontSize = 30,fontColor = consts.ColorType.THEME})
        dialogContentLabel1:setString("请确认并同意用户协议！")
        self.tipDialog = UIMgr:showConfirmDialog("提示",{child=dialogContentLabel1,childOffsetY = 10},handler(self, self.onBtnEnter),nil)
	end
end

function LoginUI:onGuestLogin(event)
    print("游客登录")
    local agreeStatus = self.loginAgree:isSelected()
    if agreeStatus then
        local uid = LuaCallPlatformFun.getPhoneUUId()
        if(uid == "UnKnow uuId" or uid == "windows uuId")then--一般是模拟器
            uid = 10000127
        elseif(not string.find(uid,"-"))then
            uid = string.sub(uid,#uid-5,#uid)
        end
        print("设备ID",uid)
        --截取设备UUID
        local tab =string.split(uid, "-")
        local numStr = string.format("%u","0x"..tab[#tab])
        if(#numStr < 8)then 
            for i=1,8-#numStr do numStr = numStr.."0" end
        end
        local lenStr = string.sub(numStr,#numStr-7,#numStr)
        UserData.uid = tonumber(lenStr)
        GnetMgr:initConnect("dlklmjtest.kuailai88.com", "18889",handler(self,self.onGuestConnectCB))
        UIMgr:showLoadingDialog("登录中...")
    else
        local dialogContentLabel1 = helper.createRichLabel({maxWidth = 600,fontSize = 30,fontColor = consts.ColorType.THEME})
        dialogContentLabel1:setString("请确认并同意用户协议！")
        self.tipDialog = UIMgr:showConfirmDialog("提示",{child=dialogContentLabel1,childOffsetY = 10},handler(self, self.onBtnEnter),nil)
    end
end

function LoginUI:onGuestConnectCB(  )
    print("发送的ID：",UserData.uid)
    self:send("role_login",{uid = UserData.uid})
end

function LoginUI:loginCallback(entity, response, statusCode)
    if entity then
        UserData.userInfo = entity
        self:loginSuccess()
    elseif response and response.errCode then
        UIMgr:closeUI(consts.UI.LoadingDialogUI)
        UIMgr:showTips(response.error)
        LocalData.data.thirdLoginData = nil
        LocalData:save()
        UIMgr:closeUI(consts.UI.LoadingDialogUI)
    else
        UIMgr:showNetErrorTip(function()
            UIMgr:closeUI(consts.UI.LoadingDialogUI)
            self:onLogin()
        end)
    end
end


function LoginUI:onBtnEnter()
	self.tipDialog:close()
end

function LoginUI:onLow(event)
    print("用户协议")
	-- UIMgr:openUI(consts.UI.UserAgreementUI,nil,nil,{type = 1})

    HttpServiers:queryArticleList({
        appId = consts.appId,
        appCode = consts.appCode,
        clientFrom = consts.clientFrom[device.platform],
        artCat = "agreementNotice",
    },
    function(entity,response,statusCode)
        if response and (response.status == 1 or response.errCode == 0) then
            if(response.data and response.data.list)then
                --local helpUrl = response.data.list[1].url
                local helpUrl = "http://www.baidu.com" --changed by liujialin
                -- if(helpUrl)then UIMgr:openUI(consts.UI.UserAgreementUI,nil,nil,{url = helpUrl, type = 1}) end
                NotifyMgr:push(consts.Notify.UPDATE_MAIL, {url = helpUrl, type = 1})
            end
        else
            --打开出错
            print("错误码：",response.errCode,"错误信息：",response.error)
        end
    end)
    UIMgr:openUI(consts.UI.UserAgreementUI,nil,nil)
end

return LoginUI