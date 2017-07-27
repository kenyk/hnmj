
LuaCallPlatformFun = {}

local LuaBridge
local platform = device.platform

if platform == "android" then
	LuaBridge = require "cocos.cocos2d.luaj"
elseif platform == "ios" then
	LuaBridge = require "cocos.cocos2d.luaoc"
else
	LuaBridge = require "cocos.cocos2d.luaTmp"
end

local defaultJavaClassName = "com/yiniu/klmj/LuaHelper"
local defaultObjCClassName = "OCLuaHelper"

--分享方法
function LuaCallPlatformFun.share(args)
	if platform == "android" then
        local sargs = {args.title,args.desc,args.webUrl,args.imageUrl}
        local ok,ret = LuaBridge.callStaticMethod(defaultJavaClassName, "share", sargs)
        return ok,ret
	elseif platform == "windows" then
		--			GameUtil.startGame()
	elseif platform == "ios" then
		if args.imageUrl and string.find(args.imageUrl,"shareImage.jpg") ~= nil then
			LuaBridge.callStaticMethod(defaultObjCClassName, "shareToImage", args)
		else
        	LuaBridge.callStaticMethod(defaultObjCClassName, "share", args)
        end
	end
end

--分享朋友圈
function LuaCallPlatformFun.shareToCircle(args)
	if platform == "android" then
        local sargs = {args.title,args.desc,args.webUrl,args.imageUrl}
        local ok,ret = LuaBridge.callStaticMethod(defaultJavaClassName, "shareToCircle", sargs)
        return ok,ret
	elseif platform == "windows" then
		--			GameUtil.startGame()
	elseif platform == "ios" then
        LuaBridge.callStaticMethod(defaultObjCClassName, "shareToCircle", args)
	end
end


--第三方平台登录
function LuaCallPlatformFun.login(args)
	if platform == "android" then
		-- local args = {CC_VERSION or "1.0"}
		-- local sig = "(Ljava/lang/String;)V"
		local ok,ret = LuaBridge.callStaticMethod(defaultJavaClassName, "login")
		return ok,ret
	elseif platform == "windows" then
		--			GameUtil.startGame()
	elseif platform == "ios" then
        -- local args = {}
        local ok,ret LuaBridge.callStaticMethod(defaultObjCClassName, "login", {callBack=onLoginCallBack})
		return ok,ret
	end
end



--杀死进程
function LuaCallPlatformFun:killProcess()
	if platform == "android" then
		local args = {}
		local sig = "()V"
		local className = "com/sanguo/util/LuaHelper"
		local ok,ret = LuaBridge.callStaticMethod(className, "exitGame", args,sig)
		return ok,ret
	elseif platform == "windows" then
    elseif platform == "ios" then
        local ok,ret = LuaBridge.callStaticMethod(defaultObjCClassName, "exitGame")
        return ok,ret
	end
end

--主包的更新检查
function startAppCheck(startGame,jsonData)
	if platform == "android" then
		local args = {jsonData}
		local sig = "(Ljava/lang/String;)V"
		local className = "com/sanguo/util/LuaHelper"
		local ok,ret = LuaBridge.callStaticMethod(className, "startAppCheck", args,sig)
		return ok,ret
	elseif platform == "ios" then
		local args = {callBack=startGame,jsonData=jsonData}
		local ok,ret = LuaBridge.callStaticMethod(defaultObjCClassName, "startAppCheck", args)
		return ok,ret
	end
end

--显示logo画面
function LuaCallPlatformFun:showLogoView(logoViewBack)
	if platform == "android" then
		local args = {}
		local sig = "()V"
		local className = "com/sanguo/util/LuaHelper"
		local ok,ret = LuaBridge.callStaticMethod(className, "showLogoView", args,sig)
		return ok,ret
	elseif platform == "ios" then
		local args = {callBack=logoViewBack}
		local ok,ret = LuaBridge.callStaticMethod(defaultObjCClassName, "showLogoView", args)
		return ok,ret
	end
end

--得到手机品牌
function LuaCallPlatformFun:getPhoneBrand(  )
	if platform == "android" then
		local sig = "()Ljava/lang/String;"
		local className = "com/sanguo/util/LuaHelper"
		local ok,ret = LuaBridge.callStaticMethod(className, "getPhoneBrand", {},sig)
		-- cclog("getPhoneModel:",ret)
		return ret
	elseif platform == "windows" then
		return "windows"
	elseif platform == "ios" then
		local ok,ret = LuaBridge.callStaticMethod(defaultObjCClassName, "getPhoneBrand")
		-- cclog("getPhoneBrand:",ret)
		return ret
	else
		return "UnKnow Brand"
	end
end

function LuaCallPlatformFun:enterGameRoleInfo(roleId,roleLevel,roleName,zoneId,zoneName,vipLevel,ingot)
	cclog("enterGameRoleInfo:",roleId,roleLevel,roleName,zoneId,zoneName,vipLevel,ingot)
	if CHANNEL then
		if platform == "android" then
			if CHANNEL==CHANNEL_UC then
				local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z"
				local args = { roleId,roleLevel,roleName,zoneId,zoneName}
				local className = "com/sanguo/util/LuaHelper"
				local ok,ret = LuaBridge.callStaticMethod(className, "enterGameRoleInfo", args,sig)
				-- cclog("getPhoneModel:",ret)
				return ret
			elseif CHANNEL==CHANNEL_GOGAME then
				local serverInfo = DATA.GetConfig("SG_server")[zoneId]
				local serverName = nil
				if serverInfo then
					serverName = serverInfo.name
				else
					serverName = "测试"
				end
				zoneName = "["..zoneId..Font.str_266.."]"..serverName
				local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z"
				local args = {roleId,roleLevel,roleName,zoneId,zoneName,vipLevel,ingot}
				local className = "com/sanguo/util/LuaHelper"
				local ok,ret = LuaBridge.callStaticMethod(className, "enterGameRoleInfo", args,sig)
				-- cclog("getPhoneModel:",ret)
				return ret
			elseif CHANNEL==CHANNEL_PAOJIAO then
				local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z"
				local args = {roleLevel,roleName,zoneName,ingot}
				local className = "com/sanguo/util/LuaHelper"
				local ok,ret = LuaBridge.callStaticMethod(className, "enterGameRoleInfo", args,sig)
				-- cclog("getPhoneModel:",ret)
				return ret
			end
		elseif platform == "ios" then
			local args = {roleId=roleId,roleLevel=roleLevel,roleName=roleName,zoneId=zoneId,zoneName=zoneName}
			local ok,ret = LuaBridge.callStaticMethod(defaultObjCClassName, "enterGameRoleInfo",args)
			-- cclog("getPhoneIMIE:",ret)
			return ret
		else
			return  nil
		end
	end
end

function LuaCallPlatformFun:showCenter()
	if platform == "android" then
		local sig = "()V"
		local className = "com/sanguo/util/LuaHelper"
		local ok,ret = LuaBridge.callStaticMethod(className, "showCenter", {},sig)
		return ret
	elseif platform == "ios" then
		local ok,ret = LuaBridge.callStaticMethod(defaultObjCClassName, "showCenter")
		return ret
	else
		return  nil
	end
end

function LuaCallPlatformFun.sendStatisData(params)
    if not HASSDK then return end
	if not params then params = {} end
	if platform == "android" then
		local sig = "(Ljava/lang/String;)V"
		local className = "base/interfaces/AbstractLuahelper"
		local argsStr = json.encode(params)
		local ok,ret = LuaBridge.callStaticMethod(className, "dataStatistic", {argsStr},sig)
		if ok then
			print("ok",ret)
		else
			print("luaj error ",ret)
		end
	elseif platform == "ios" then
		local ok,ret = LuaBridge.callStaticMethod(defaultObjCClassName, "dataStatistic",params)
		return ret
	else
		return  nil
	end
end

function LuaCallPlatformFun.payVerifyCallBack(params)
	if platform == "android" then
	elseif platform == "ios" then
		local ok,ret = LuaBridge.callStaticMethod(defaultObjCClassName, "payVerifyCallBack", {result = params})
		return ret
	else
		return  nil
	end
end


-------------------------------------------------klmj----------------------------------------
--得到手机IMIE
function LuaCallPlatformFun.getPhoneIMEI()
	if platform == "android" then
		local sig = "()Ljava/lang/String;"
		local ok,ret = LuaBridge.callStaticMethod(defaultJavaClassName, "getPhoneIMEI", {},sig)
		-- cclog("getPhoneModel:",ret)
		return ret
	elseif platform == "ios" then
		local ok,ret = LuaBridge.callStaticMethod(defaultObjCClassName, "getPhoneIMEI")
		-- cclog("getPhoneIMIE:",ret)
		return ret
	else
		return "UnKnow IMIE"
	end
end

--得到手机型号
function LuaCallPlatformFun.getPhoneModel()
	if platform == "android" then
		local sig = "()Ljava/lang/String;"
		local ok,ret = LuaBridge.callStaticMethod(defaultJavaClassName, "getPhoneModel", {},sig)
		-- cclog("getPhoneModel:",ret)
		return ret
	elseif platform == "windows" then
		return "windows"
	elseif platform == "ios" then
		local ok,ret = LuaBridge.callStaticMethod(defaultObjCClassName, "getPhoneModel")
		-- cclog("getPhoneModel:",ret)
		return ret
	else
		return "UnKnow Platform"
	end
end

---mac地址
function LuaCallPlatformFun.getPhoneMacAddr()
	if platform == "android" then
		local sig = "()Ljava/lang/String;"
		local ok,ret = LuaBridge.callStaticMethod(defaultJavaClassName, "getPhoneMacAddr", {},sig)
		-- cclog("getPhoneModel:",ret)
		return ret
	elseif platform == "windows" then
		return "windows"
	elseif platform == "ios" then
		local ok,ret = LuaBridge.callStaticMethod(defaultObjCClassName, "getPhoneMacAddr")
		-- cclog("getPhoneModel:",ret)
		return ret
	else
		return "UnKnow MacAddr"
	end
end

--手机系统版本
function LuaCallPlatformFun.getPhoneOSVer()
	if platform == "android" then
		local sig = "()Ljava/lang/String;"
		local ok,ret = LuaBridge.callStaticMethod(defaultJavaClassName, "getPhoneOSVer", {},sig)
		-- cclog("getPhoneModel:",ret)
		return ret
	elseif platform == "windows" then
		return "windows"
	elseif platform == "ios" then
		local ok,ret = LuaBridge.callStaticMethod(defaultObjCClassName, "getPhoneOSVer")
		-- cclog("getPhoneModel:",ret)
		return ret
	else
		return "UnKnow OSVer"
	end
end

--手机渠道
function LuaCallPlatformFun.getPhoneChanId()
	if platform == "android" then
		local sig = "()Ljava/lang/String;"
		local ok,ret = LuaBridge.callStaticMethod(defaultJavaClassName, "getPhoneChanId", {},sig)
		print("getPhoneModel:",ret)
		local tab = string.split(ret,"-")
		if(#tab > 1)then return tab end
		return {ret}
	elseif platform == "windows" then
		return {"windows 0"}
	elseif platform == "ios" then
		local ok,ret = LuaBridge.callStaticMethod(defaultObjCClassName, "getPhoneChanId")
		-- cclog("getPhoneModel:",ret)
		return {ret}
	else
		return {"UnKnow ChanId"}
	end
end

--手机运营商
function LuaCallPlatformFun.getPhoneOperator()
	if platform == "android" then
		local sig = "()Ljava/lang/String;"
		local ok,ret = LuaBridge.callStaticMethod(defaultJavaClassName, "getPhoneOperator", {},sig)
		-- cclog("getPhoneModel:",ret)
		return ret
	elseif platform == "windows" then
		return "windows Operator"
	elseif platform == "ios" then
		local ok,ret = LuaBridge.callStaticMethod(defaultObjCClassName, "getPhoneOperator")
		-- cclog("getPhoneModel:",ret)
		return ret
	else
		return "UnKnow Operator"
	end
end

--手机网络类型
function LuaCallPlatformFun.getPhoneNettype()
	if platform == "android" then
		local sig = "()Ljava/lang/String;"
		local ok,ret = LuaBridge.callStaticMethod(defaultJavaClassName, "getPhoneNettype", {},sig)
		-- cclog("getPhoneModel:",ret)
		return ret
	elseif platform == "windows" then
		return "windows net"
	elseif platform == "ios" then
		local ok,ret = LuaBridge.callStaticMethod(defaultObjCClassName, "getPhoneNettype")
		-- cclog("getPhoneModel:",ret)
		return ret
	else
		return "UnKnow nettype"
	end
end

--UUId
function LuaCallPlatformFun.getPhoneUUId()
	if platform == "android" then
		local sig = "()Ljava/lang/String;"
		local ok,ret = LuaBridge.callStaticMethod(defaultJavaClassName, "getPhoneUUId", {},sig)
		-- cclog("getPhoneModel:",ret)
		return ret
	elseif platform == "windows" then
		return "windows uuId"
	elseif platform == "ios" then
		local ok,ret = LuaBridge.callStaticMethod(defaultObjCClassName, "getPhoneUUId")
		-- cclog("getPhoneModel:",ret)
		return ret
	else
		return "UnKnow uuId"
	end
end

--第三方平台取消授权登录
function LuaCallPlatformFun.deleteOauth()
	if platform == "android" then
		local ok,ret = LuaBridge.callStaticMethod(defaultJavaClassName, "deleteOauth")
		return ok,ret
	elseif platform == "windows" then

	elseif platform == "ios" then
		local ok,ret = LuaBridge.callStaticMethod(defaultObjCClassName, "deleteOauth")
		return ok,ret
	end
end

--调用跳转连续房间号
function LuaCallPlatformFun.getRoomId()
	if platform == "android" then
        local sig = "()Ljava/lang/String;"
		local ok,ret = LuaBridge.callStaticMethod(defaultJavaClassName, "getRoomId" ,{},sig)
		return ret
	elseif platform == "windows" then
        return ""
	elseif platform == "ios" then
		local ok,ret = LuaBridge.callStaticMethod(defaultObjCClassName, "getRoomId")
		return ret
	end
end

--开始录音
function LuaCallPlatformFun.beginRecordVoice()
	if platform == "ios" then
		LuaBridge.callStaticMethod(defaultObjCClassName, "beginRecordVoice")
	else
		GCloudVoiceMgr:beginRecordVoice()
	end
end
--停止录音
function LuaCallPlatformFun.endRecordVoice()
	if platform == "ios" then
		LuaBridge.callStaticMethod(defaultObjCClassName, "endRecordVoice")
	else
		GCloudVoiceMgr:endRecordVoice()
	end
end
--中断录音
function LuaCallPlatformFun.breakRecordVoice()
	if platform == "ios" then
		LuaBridge.callStaticMethod(defaultObjCClassName, "breakRecordVoice")
	else
		GCloudVoiceMgr:breakRecordVoice()
	end
end
--播放录音
function LuaCallPlatformFun.playVoiceById(fileId)
    --关了音效不播放语音
    if AudioMgr:get_sound_enable() then
	    if platform == "ios" then
		    LuaBridge.callStaticMethod(defaultObjCClassName, "playVoiceById",{file = fileId})
	    else
		    GCloudVoiceMgr:playVoiceById(fileId)
	    end
    end
end
--停止播放
function LuaCallPlatformFun.stopVoiceById()
	if platform == "ios" then
		LuaBridge.callStaticMethod(defaultObjCClassName, "stopVoiceById")
	else
		GCloudVoiceMgr:stopVoice()
	end
end
--打开实时
function LuaCallPlatformFun.openRealTimeVoice()
	if platform == "ios" then
		LuaBridge.callStaticMethod(defaultObjCClassName, "openRealTimeVoice")
	else
		GCloudVoiceMgr:openRealTimeVoice(UserData.roomId)
	end
end
--关闭实时
function LuaCallPlatformFun.closeRealTimeVoice()
	if platform == "ios" then
		LuaBridge.callStaticMethod(defaultObjCClassName, "closeRealTimeVoice")
	else
		GCloudVoiceMgr:closeRealTimeVoice()
	end
end

--授权麦克风
function LuaCallPlatformFun.openMicPhone()
	if platform == "ios" then
		local ok,ret = LuaBridge.callStaticMethod(defaultObjCClassName, "openMicPhone")
		return ret and ret == "1" or false
		-- return true--屏蔽授权，更iOS再打开
	else
		return true
	end
end

--初始化录音
function LuaCallPlatformFun.initRecordVoice()
	if platform == "ios" then
		LuaBridge.callStaticMethod(defaultObjCClassName, "initRecordVoice")
	end
end

--获取网络状态信息
function LuaCallPlatformFun.getNetInfo()
	if platform == "android" then
        local sig = "()Ljava/lang/String;"
		local ok,ret = LuaBridge.callStaticMethod(defaultJavaClassName, "getNetInfo" ,{},sig)
        setNetInfo(ret)
		return ret
	elseif platform == "windows" then
        return ""
	elseif platform == "ios" then
		local ok,ret = LuaBridge.callStaticMethod(defaultObjCClassName, "getNetJsonInfo")
		setNetInfo(ret)
	end
end

--获取电量信息
function LuaCallPlatformFun.getBatteryInfo()
	if platform == "android" then
        local sig = "()Ljava/lang/String;"
		local ok,ret = LuaBridge.callStaticMethod(defaultJavaClassName, "getBatteryInfo" ,{},sig)
        setBatteryInfo(ret)
	-- elseif platform == "windows" then
        -- return ""
	elseif platform == "ios" then
		local ok,ret = LuaBridge.callStaticMethod(defaultObjCClassName, "getBatteryInfo")
		setBatteryInfo(ret)
	end
end

--开启位置
function LuaCallPlatformFun.openLocation()
	if platform == "ios" then
		LuaBridge.callStaticMethod(defaultObjCClassName, "openLocation")
	elseif platform == "android" then
		--获取能定位的，不能再用高德定位
		local pos = LuaCallPlatformFun.getLocation()
		if(not pos)then
        	local sig = "()V"
			LuaBridge.callStaticMethod(defaultJavaClassName, "openGaodeLocation" ,{},sig)
		end
	end
end

--获取位置权限
function LuaCallPlatformFun.isOpenLocation()
	if platform == "android" then
        local sig = "()Z"
		local ok,ret = LuaBridge.callStaticMethod(defaultJavaClassName, "isGpsOpen" ,{},sig)
		print("位置权限:",ret)
		return ret
	-- elseif platform == "windows" then
        -- return ""
	elseif platform == "ios" then
		local ok,ret = LuaBridge.callStaticMethod(defaultObjCClassName, "isOpenLocation")
		print("位置权限:"..ret)
		return ret and ret == "1" or false
	else
		return false
	end
end

--获取经纬度
function LuaCallPlatformFun.getLocation()
	if platform == "android" then
        local sig = "()Ljava/lang/String;"
		local ok,ret = LuaBridge.callStaticMethod(defaultJavaClassName, "getLocation" ,{},sig)
		print("经纬度:",ret)
		local pos = string.split(ret,":")
		local tab = {
		 	longitude = pos[1],
            latitude = pos[2]
		}

		--安卓取不到值
		if(tonumber(pos[1]) == 0 and tonumber(pos[2]) == 0)then return nil end

		return tab
	-- elseif platform == "windows" then
        -- return ""
	elseif platform == "ios" then
		local ok,ret = LuaBridge.callStaticMethod(defaultObjCClassName, "getLocation")
		print("经纬度:"..ret)
		return json.decode(ret)
	else
		return nil
	end
end

--跳转定位设置页
function LuaCallPlatformFun.toLocationSetting()
	if platform == "android" then
        local sig = "()V"
		local ok,ret = LuaBridge.callStaticMethod(defaultJavaClassName, "toSetOpenGPS" ,{},sig)
	-- elseif platform == "windows" then
        -- return ""
	elseif platform == "ios" then
		LuaBridge.callStaticMethod(defaultObjCClassName, "toLocationSetting")
	else
		
	end
end

--微信支付
function LuaCallPlatformFun.wxPay(args)
	if platform == "android" then
		local msg = {args.appid,args.partnerid,args.prepayid,args.package,args.noncestr,args.timestamp,args.sign}
		LuaBridge.callStaticMethod(defaultJavaClassName, "wxPay",msg)

	elseif platform == "ios" then
		LuaBridge.callStaticMethod(defaultObjCClassName, "wxPay",args)
	else
		
	end
end

--支付宝支付
function LuaCallPlatformFun.aliPay(args)
	if platform == "android" then
		LuaBridge.callStaticMethod(defaultJavaClassName, "payAlipay",{args.orderInfo})
		
	elseif platform == "ios" then
		LuaBridge.callStaticMethod(defaultObjCClassName, "aliPay",args)
	else
		
	end
end

--分享战局回放
function LuaCallPlatformFun.shareBattle( shareCode )
	if(not shareCode)then return end

    local shareTitle = "快来湖南麻将"
    local sharedesc = "我分享了一个回放码"..shareCode.."，一起来看看吧"

    local weburl = "http://a.mlinks.cc/AaNG?".."roomId=".."_"..shareCode
    local img = ""
    local args = {title=shareTitle,desc=sharedesc,webUrl=weburl,imageUrl=img}
	LuaCallPlatformFun.share(args)
end

--复制到剪切板
function LuaCallPlatformFun.copyStr(str)

	if platform == "ios" then
		LuaBridge.callStaticMethod(defaultObjCClassName, "copyStr",{str = str})
	elseif platform == "android" then
        LuaBridge.callStaticMethod(defaultJavaClassName, "copyStr", {str})
	end
end

