
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 0

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = false

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = false

-- for module display
CC_DESIGN_RESOLUTION = {
    width = 1366,
    height = 768,
    autoscale = "SHOW_ALL",
    callback = function(framesize)
        local ratio = framesize.width / framesize.height
        if ratio <= 1.34 then
            -- iPad 768*1024(1536*2048) is 4:3 screen
            return {autoscale = "SHOW_ALL"}
        end
    end
}

-- release version print switch
RELEASE_PRINT = true

-- testing update   open true close false  更新检测开关
CC_UPDATE_SET = true

-- CC_VERSION = nil  --游戏版本号

--苹果审核版开关
Is_App_Store = false

--打包版本 1 内网包  2 外网审核包 3 外网企业包
CC_PACKET_VERSION = 3

--防作弊模式开关
Is_Cheat_Set = true

--支付开关
Is_Open_Pay = false

--红包活动
Is_Open_Hongbao = false

--魔坛争霸
is_Motan = false

--新的解散房间
Is_New_DismissRoom = true



