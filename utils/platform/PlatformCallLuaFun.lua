
--test md5
--print("<<<<<<<<<", EMd5.Make(1))

--	 os.clock()--测试CPU消耗
--	local testTime = os.time()
--	cclog(os.date("%Y-%m-%d %H:%M:%S:%w",testTime))
--	print_r(os.date("*t",testTime))


--	local function callback(result)
--		cclog("JAVA调用LUA方法:",result)
--	end
--	-- 调用 Java 方法需要的参数
--	local args = {
--	    	callback
--	}
--	-- Java 类的名称
--	local sig = "(I)I"
--	local className = "com/sanguo/game/sanguo"
--	-- 调用 Java 方法
--	local ok,ret = LuaBridge.callStaticMethod(className, "testLua", args,sig)
--	cclog("dsfdfdfdfdfdf")
--	if ok then
--		cclog("调用JAVA方法",ret)
--	end

PlatformCallLuaFun = {}


local http = cc.load("luasocket").socket.http
-----------------还未完成 下面都是没用的-------------------

platformData = {} --平台回调数据

--关闭程序
function closeToLua()
	 CCDirector:sharedDirector():endToLua()
end

--开始游戏
function startGame(channel)
	
end

-- 登录回调
--数据结构
--{
--"access_token"
-- "city"
--"country"
--"expires_in"
--"gender"
--"language"
--"openid"
--"profile_image_url"
--"province"
--"refresh_token"
--"screen_name"
--"unionid" 
--}
function onLoginCallBack(jsonStr)
	-- log.print(jsonStr)
	-- [userInfoDict setObject:userinfo.name forKey:@"name"];
    -- [userInfoDict setObject:userinfo.iconurl forKey:@"iconurl"];
	-- [userInfoDict setObject:userinfo.gender forKey:@"gender"];
    -- [userInfoDict setObject:userinfo.uid forKey:@"uid"];
    -- [userInfoDict setObject:userinfo.openid forKey:@"openid"];
    -- [userInfoDict setObject:userinfo.refreshToken forKey:@"refreshToken"];
    -- [userInfoDict setObject:userinfo.accessToken forKey:@"accessToken"];
	local data = json.decode(jsonStr)
	log.dump(data,10,"LoginInfo")
    NotifyMgr:push(consts.Notify.SDK_LOGIN_BACK,data)
end

function onLoginError()
    NotifyMgr:push(consts.Notify.SDK_LOGIN_BACK, nil)
end

function onLoginCancel()
    NotifyMgr:push(consts.Notify.SDK_LOGIN_BACK, nil)
end

--腾讯语音发出的音频文件id
function addFileId(fileId,len)
    
    local script = string.format("local msg={type = 3,id = '%s',len=%s}  return msg",fileId,len)
    GnetMgr:send("game_talk_and_picture", {id = script})
end

--腾讯语音开始播放
function gCloudVoicePlayStart()
    print("开始播放")
    AudioMgr:pauseMusic()
    -- NotifyMgr:push(consts.Notify.GCLOUDVOICE_START)
end

--腾讯语音播放完成
function gCloudVoicePlayComplete()
    print("播放完成")
    AudioMgr:resumeMusic()
    -- NotifyMgr:push(consts.Notify.GCLOUDVOICE_COMPLETE)
end

--网络信息（类型 强度
--{"type":"2G","typeName":"2G","signalLevel":"0"} 
-- type:       -1     1   2  3  4
-- typeName: UNKNOWN WIFI 2G 3G 4G 
-- signalLevel : 0 1 2 3 4
function setNetInfo(jsonStr)
    UserData.netInfo = json.decode(jsonStr)
    if UserData.netInfo  then
        UserData.netInfo.type = tonumber(UserData.netInfo.type)
        UserData.netInfo.signalLevel = tonumber(UserData.netInfo.signalLevel)
        NotifyMgr:push(consts.Notify.NET_INFO_CHANGE)
    end
end

--电量
--{"batteryPercent":"0.5"} 
function setBatteryInfo(jsonStr)
    UserData.batteryInfo = json.decode(jsonStr)
    dump(UserData.batteryInfo)
    if UserData.batteryInfo then
        UserData.batteryInfo.batteryPercent = tonumber(UserData.batteryInfo.batteryPercent)
        NotifyMgr:push(consts.Notify.BATTERY_CHANGE)
    end
end



--支付成功回调
function paySuccessCB()
    print("lua cb 支付成功")
    helper.updateGameCard()
end
--支付出错回调
function payErrorCB()
    print("lua cb 支付失败")
end
