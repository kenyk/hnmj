
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

--更新搜索路径必须在最后 保证版本文件最新
addSearchPath( string.gsub(createDownloadDir(), "\\" , "/" ) .. "/src",true)
addSearchPath( string.gsub(createDownloadDir(), "\\" , "/" ) .. "/res",true)

package.path = package.path .. ";src/?.lua"

require "config"
require "cocos.init"
require("cocos.ui.GuiConstants")

if io.exists("src/localConfig.lua") then --本地的配置
    require "localConfig"
end

MyApp = nil


local function sendRemoteLog( msg )

    local arrays = {}
    local GameVersion = require "assetmgr.GameVersion"
    arrays["&version="] = GameVersion.CURRENT_VERSION
    arrays["&log="] = msg
    local data = json.encode(arrays)
    local params = {content = data,userId = UserData.uid  }
    local function callback(entity,response,statusCode)
        print("send RemoteLog callback !!",statusCode)
    end
    --HttpClient:asyncGet(consts.HttpUrl.getCodeCrashesResult, params,callback)

end


local limitTime = os.time()
local limitCounter = 0
local limitMax = 2
__G__TRACKBACK__ = function(msg)    

    local msg = debug.traceback(msg, 2)  
    print(msg) 
    if consts.App.APP_PLATFORM == cc.PLATFORM_OS_WINDOWS then    
        local f = io.open("error.lua", "r")
        if f == nil then
            f = io.open("error.lua", "w+")
        else
            f:close()
            f = io.open("error.lua", "a")
        end
        if UserData and UserData.uid then
            f:write(time.formatDate(os.time())..":"..UserData.uid.."\n"..msg.."\n")
        else
            f:write(time.formatDate(os.time()).."\n"..msg.."\n")
        end
        f:close()
    else
         --限制每分钟内发2条
        local now = os.time()
        if now - limitTime >= 60 then
            limitTime = now
            limitCounter = 0
        end
        if limitCounter < limitMax then
            limitCounter = limitCounter + 1
            sendRemoteLog(tostring(msg))
        end
    end
    return msg

end


local function main()
	local assets = require "assetmgr.GameVersion"
	local function updateCallback()
		require "utils.init"
		require "mgr.init"
		LocalData:load()
	    AudioMgr:init()
	    GnetMgr:init()
	    MyApp = require("app.MyApp"):create()
	    MyApp:run()
	end

    if RELEASE_PRINT then --release打印开关
        print = release_print
    end
    if CC_UPDATE_SET then --更新
        local assetsMgr = require "assetmgr.GameAssetsManager"
        assetsMgr:init(updateCallback)
    else            
        updateCallback()
    end
end

xpcall(main, __G__TRACKBACK__)


-- local status, msg = xpcall(main, __G__TRACKBACK__)

-- if not status then
-- 	print(msg)
-- end
