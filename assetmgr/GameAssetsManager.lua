
local GameAssetsManager = {}
local GameVersion = require "assetmgr.GameVersion"
local saveProgress

GameAssetsManager._assetsManager       = nil
GameAssetsManager._pathToSave          = ""

-- GameAssetsManager.isSend = true
-- GameAssetsManager.versionParam = nil


 GameAssetsManager.urlName = "https://localhost:8080/clientUpdate/"
if CC_PACKET_VERSION == 1 then
    GameAssetsManager.urlName = "https://wap.juyun66.com/Uploads/Download/Assets/hnmj/clientUpdate/"     --内网更新地址
elseif CC_PACKET_VERSION == 2 then
    GameAssetsManager.urlName = "https://wap.juyun66.com/Uploads/Download/Assets/hnmj/clientUpdateIos/"     --外网审核包更新地址
elseif CC_PACKET_VERSION == 3 then
    GameAssetsManager.urlName = "https://wap.juyun66.com/Uploads/Download/Assets/hnmj/clientUpdateBeta/" --外网发布包更新地址
end

GameAssetsManager.fileName = "/res.zip"
GameAssetsManager.versionName = "/version.txt" .. "?a=" .. os.time()

GameAssetsManager._packerUrl   = ""
GameAssetsManager._versionUrl  = ""

GameAssetsManager._schedule = 0

GameAssetsManager._scene = nil

GameAssetsManager.retryTimes = 0 -- 无法更新自动重试计数
GameAssetsManager.retryScheduleEntry = nil

GameAssetsManager.updateCallback = nil --更新完毕回调

function GameAssetsManager:init(updateCallback)
    self.updateCallback = self.updateCallback  or updateCallback    
    self.scene = self:initScene()    
    --预先检查是否最新版本
    self.isLatestVersion = false
    self:preCheckVersion()
end

function GameAssetsManager:initScene()
    local scene = display.newScene("update")
    local function onNodeEvent(event)
        if event == "enterTransitionFinish" then
            local function callback()
                self:addUpdateUI(scene)
            end
            self:playSplash(scene,callback)
        end
    end
    scene:registerScriptHandler(onNodeEvent)
    display.runScene(scene)
    return scene
end

function GameAssetsManager:addUpdateUI(scene)
    local updateUI = cc.CSLoader:createNode("SceneUpdate.csb")
    self.progressBar = updateUI:getChildByName("progressBar")
    self.tips = updateUI:getChildByName("tips")
    self.tips_version = updateUI:getChildByName("tips_version")
    scene:addChild(updateUI)    
    self.progressBar:setVisible(false)
    --是否最新版本
    if self.isLatestVersion == true then
        self:ChangToServList()
    else
        self:update()             
    end
end

function GameAssetsManager:update()
    self._pathToSave = string.gsub(createDownloadDir(), "\\" , "/" )
    
    print("GameAssetsManager:init" , self._pathToSave)
    self:assetMgrInit()
    self:setUrl()
    self:ScheduleOnce()
end

function GameAssetsManager:playSplash(scene,callback)
    if device.platform ~= "ios" then
        local logoTips = ccui.ImageView:create("mj/splash.png")
        logoTips:setPosition(display.width/2,display.height/2)
        logoTips:setOpacity(0)
        scene:addChild(logoTips)
        
        local sequence1
        local actions1 = {
            cc.FadeIn:create(2),
            cc.DelayTime:create(0.5),
            cc.FadeOut:create(1),
            cc.CallFunc:create(function ()
                callback()
            end)
        }
        sequence1 = transition.sequence(actions1)
        logoTips:runAction(sequence1)
    else
        callback()
    end
end

function GameAssetsManager:LuaReomve(str,remove)  
    local lcSubStrTab = {}  
    while true do  
        local lcPos = string.find(str,remove)  
        if not lcPos then  
            lcSubStrTab[#lcSubStrTab+1] =  str      
            break  
        end  
        local lcSubStr  = string.sub(str,1,lcPos-1)  
        lcSubStrTab[#lcSubStrTab+1] = lcSubStr  
        str = string.sub(str,lcPos+1,#str)  
    end  
    local lcMergeStr =""  
    local lci = 1  
    while true do  
        if lcSubStrTab[lci] then  
            lcMergeStr = lcMergeStr .. lcSubStrTab[lci]   
            lci = lci + 1  
        else   
            break  
        end  
    end  
    return lcMergeStr  
end

function GameAssetsManager:preCheckVersion()

    local function onErr(errorCode)

        if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
            self.isLatestVersion = true
        elseif errorCode == cc.ASSETSMANAGER_NETWORK then
            
        end

    end
       
    local pathSave = string.gsub(createDownloadDir(), "\\" , "/" )
    local assertManager = cc.AssetsManager:new("","",pathSave):addTo(self.scene)
    assertManager:setDelegate(onErr, cc.ASSETSMANAGER_PROTOCOL_ERROR )
    assertManager:setConnectionTimeout(3)

    local curVersion = assertManager:getVersion()
    if nil == curVersion or #curVersion <= 0 then
        curVersion = GameVersion.CURRENT_VERSION
    else
        local ver1 = string.split(curVersion, ".")
        local ver2 = string.split(GameVersion.CURRENT_VERSION, ".")
        if tonumber(ver1[1]) < tonumber(ver2[1]) then
            assertManager:deleteVersion()
            curVersion = GameVersion.CURRENT_VERSION
        elseif tonumber(ver1[1]) == tonumber(ver2[1]) then
            if tonumber(ver1[2]) < tonumber(ver2[2]) then
                assertManager:deleteVersion()
                curVersion = GameVersion.CURRENT_VERSION
            end
        end
    end

    --fileurl为空 
    assertManager:setPackageUrl("")
    --versionurl
    local versionUrl= self.urlName .. curVersion .. self.versionName
    assertManager:setVersionFileUrl(versionUrl)
    --检查更新
    assertManager:checkUpdate()
end

function GameAssetsManager:assetMgrInit()
    self:ReleaseAssetsMgr()
    self._assetsManager = cc.AssetsManager:new("","",self._pathToSave)
    self._assetsManager:retain()
    self._assetsManager:setDelegate(handler(self,self.onError), cc.ASSETSMANAGER_PROTOCOL_ERROR )
    self._assetsManager:setDelegate(handler(self,self.onProgress), cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
    self._assetsManager:setDelegate(handler(self,self.onSuccess), cc.ASSETSMANAGER_PROTOCOL_SUCCESS )
    self._assetsManager:setConnectionTimeout(3)
    self.version = self._assetsManager:getVersion()
    if nil == self.version or #self.version <= 0 then
        self.version = GameVersion.CURRENT_VERSION
    else
        local ver1 = string.split(self.version, ".")
        local ver2 = string.split(GameVersion.CURRENT_VERSION, ".")
        if tonumber(ver1[1]) < tonumber(ver2[1]) then
            self._assetsManager:deleteVersion()
            self.version = GameVersion.CURRENT_VERSION
        elseif tonumber(ver1[1]) == tonumber(ver2[1]) then
            if tonumber(ver1[2]) < tonumber(ver2[2]) then
                self._assetsManager:deleteVersion()
                self.version = GameVersion.CURRENT_VERSION
            end
        end
    end
    self.tips_version:setString(self.version)
    print("GameAssetsManager:assetMgrInit","GameVersion:init",self.version)
end

function GameAssetsManager:setPackageUrl()
    self._packerUrl = self.urlName .. self.version .. self.fileName
    print("PackageUrlversion=" , self.version , self._packerUrl)
    self._assetsManager:setPackageUrl(self._packerUrl)
end

function GameAssetsManager:setVersionFileUrl()
    self._versionUrl= self.urlName .. self.version .. self.versionName
    print("FileUrlversion=" , self.version , self._versionUrl)
    self._assetsManager:setVersionFileUrl( self._versionUrl )
end

function GameAssetsManager:setUrl()
    self:setPackageUrl()
    self:setVersionFileUrl()
end

--重载版本文件
function GameAssetsManager:reloadModule()
    package.loaded["assetmgr.GameVersion"] = nil
    GameVersion = require("assetmgr.GameVersion")
    --GameVersion:init(self._assetsManager)
end

--进入登陆
function GameAssetsManager:ChangToServList()
    if self._assetsManager then
       print("最终版本:",self._assetsManager:getVersion())
    end    
    self:initGameMain()
end

function GameAssetsManager:initGameMain()
     performWithDelay(self.scene,function()
             self:ReleaseAssetsMgr()
         end, 1)         
     self.updateCallback()
end

function GameAssetsManager:onProgress( percent )
    print("lua-------onProgress",percent)
    local curP = percent
    if curP < 37 then curP = 37 end
    self.progressBar:setVisible(true)
    self.progressBar:setPercent(curP)
    self.tips:setString("正在加载中..."..percent.."%")
end

function GameAssetsManager:onSuccess()
    --更新成功，继续检测下一个版本
    self:reloadModule()
    print("downloading ok")
    self.tips:setString("下载完毕,检测版本")
    self:SetNextVersionUrl()
end

function GameAssetsManager:onError(errorCode)
    if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
        --没有新版本，进入游戏
        print("没有新版本，进入游戏中")
        
        -- 清理自动重试
        -- self.retryTimes = 0
        -- if self.retryScheduleEntry ~= nil then
        --     self.tips:setString( "进入游戏中,请稍等..." )
        --     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.retryScheduleEntry)
        --     self.retryScheduleEntry = nil
        -- end
        -- 进入登陆界面
        self:ChangToServList()
    elseif errorCode == cc.ASSETSMANAGER_NETWORK then
        print("network error")
        print("无法更新游戏，自动重试")
        --[[
        自动重试机制:
        1 更新返回不成功会进入自动重试
        2 自动重试会重试10次,每次间隔3秒
        3 每次重试会调用 GameAssetsManager:init
        4 如果10次尝试都失败,停止重试,提示玩家重启游戏
        ]]--

        local MAX_RETRY_TIMES = 10  -- 10次
        local RETRY_DELAY = 3  -- 3秒
        self.retryTimes = self.retryTimes + 1
        
        -- 跳出条件
        if self.retryTimes > MAX_RETRY_TIMES then
            self.retryTimes = 0
            self.tips:setString("网络错误，游戏更新失败， 请退出游戏并检查网络设置后再尝试")
            return
        end

        -- 循环重试更新
        self.tips:setString( "网络超时，无法更新游戏，自动重连中。。("..GameAssetsManager.retryTimes..")" )
        print( "无法更新游戏，自动重试("..GameAssetsManager.retryTimes..")" )
        -- self:ChangToServList()
        local scheduler = cc.Director:getInstance():getScheduler()
        self.retryScheduleEntry = scheduler:scheduleScriptFunc(
            function ()
                -- 重新初始化
                self:init()
                scheduler:unscheduleScriptEntry(self.retryScheduleEntry)
            end, 
            RETRY_DELAY, false)
    end
end

function GameAssetsManager:ScheduleOnce()
    -- body
    local scheduler = cc.Director:getInstance():getScheduler()
    self._schedule = scheduler:scheduleScriptFunc(handler(self,self.ScheduleOnceCallBack), 0.1, false)
end

function GameAssetsManager:ScheduleOnceCallBack()
    -- body
    print("检测更新")    
    local scheduler = cc.Director:getInstance():getScheduler()
    if self._schedule then scheduler:unscheduleScriptEntry(self._schedule) end
    self._schedule = nil
    -- self.progressBar:setPercent(0)
    self._assetsManager:checkUpdate()
end

function GameAssetsManager:SetNextVersionUrl()
    self:assetMgrInit()
    self:setUrl()
    performWithDelay(self.scene,function ()
            print("开始检测下一个版本")
            self:ScheduleOnce()
        end, 0.5)
end

function GameAssetsManager:getPackageUrl()
    local packurl = self._assetsManager:getPackageUrl()
    print("packurl=" .. packurl)
end
    
function GameAssetsManager:getVersionFileUrl()
    local VersionFileUrl = self._assetsManager:getVersionFileUrl()
    print("VersionFileUrl=" .. VersionFileUrl)
end
    
function GameAssetsManager:ReleaseAssetsMgr()
    if nil ~= self._assetsManager then
        self._assetsManager:release()
        self._assetsManager = nil
    end
end

return GameAssetsManager