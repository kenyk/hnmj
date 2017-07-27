package.loaded["config"] = nil --重载配置信息
require "config"

if io.exists("src/localConfig.lua") then --本地的配置
    package.loaded["localConfig"] = nil
    require "localConfig"
end

local MyApp = class("MyApp", cc.load("mvc").AppBase)
local ostime = nil
function MyApp:onCreate()
    math.randomseed(os.time())

    local listenerForeground=cc.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT",function ()
        print("切换到前台")
        AudioMgr:resumeAudio()
        local mainUI = UIMgr:getUI(consts.UI.mainUI)
        if mainUI then
            performWithDelay(mainUI, function()
                mainUI:onEnter()
            end, 0.1)
        end
        if GnetMgr:isConnect() then
            --ios重新建立连接
            if device.platform == "ios" then
	           GnetMgr:reConnect()
            else
                performWithDelay(display.getRunningScene(), function()
                    GnetMgr:start()
                end, 0.2)
            end
        end
    end)
    local listenerBackground=cc.EventListenerCustom:create("APP_ENTER_BACKGROUND_EVENT",function ()
        print("切换到后台")
        -- NotifyMgr:push(consts.Notify.APP_ENTER_BACKGROUND)
        ostime = os.time()
        AudioMgr:stopAudio()
        if GnetMgr:isConnect() then
            GnetMgr:pause()
        end

    end)  
    local customEventDispatch=cc.Director:getInstance():getEventDispatcher()
    customEventDispatch:addEventListenerWithFixedPriority(listenerForeground, 1)
    customEventDispatch:addEventListenerWithFixedPriority(listenerBackground, 1)

    if "" == cc.UserDefault:getInstance():getStringForKey("setting_bg_type") then
        cc.UserDefault:getInstance():setStringForKey("setting_bg_type", "ck_bg_2")
    end
end

function MyApp:goToMain()
	UserData:clearTableData()
 --    if mahjongModel then
	--     mahjongModel:destroy()
	--     mahjongModel = nil
	-- end
    if(not Is_App_Store)then
        GnetMgr:closeConnect()
    end
    self:run("MainScene")
end

function MyApp:goToGame()
	self:run("MahjongScene")
end

function MyApp:goToReplayScene()
    self:run("ReplayScene")
end

return MyApp
