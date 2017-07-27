time = {}

-- 秒数 -> 天,时,分,秒
local function getTime(sec)
    local secondsPerMinute = 60
    local minutesPerHour   = 60
    local hoursPerDay      = 24
    local secondsPerHour   = secondsPerMinute * minutesPerHour
    local secondsPerDay    = secondsPerHour   * hoursPerDay
    local days    = math.floor(sec / secondsPerDay)
    local hours   = math.floor((sec - days*secondsPerDay) / secondsPerHour)
    local minutes = math.floor((sec - days*secondsPerDay - hours*secondsPerHour) / secondsPerMinute)
    local seconds = math.floor(sec - days*secondsPerDay - hours*secondsPerHour - minutes*secondsPerMinute)
    return days, hours, minutes, seconds
end

-- 转换时间格式 如 3天9时5分10秒
function time.secToStr(sec)
    local days,hours,minutes,seconds = getTime(sec)
    local str = ""
    if days > 0 then
        str = str..days.."天"
    end
    if hours > 0 then
        str = str..hours.."时"
    end
    if minutes > 0 then
        str = str..minutes.."分"
    end
    str = str..seconds.."秒"
    return str
end

-- 转换时间格式 如 23:59:59
function time.secToDayTime(sec)
    local time = 0
    if sec then
        time = sec
    end
    local days,hours,minutes,seconds = getTime(time)
    hours = days*24 + hours
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

-- 转换时间格式 如 59:59
function time.secToHourTime(sec)
    local days,hours,minutes,seconds = getTime(sec)
    return string.format("%02d:%02d",minutes, seconds)
end

-- 转换时间格式 如 59
function time.secToMinuteTime(sec)
    local days,hours,minutes,seconds = getTime(sec)
    return string.format("%02d",seconds)
end

--获取指定某年某月的总天数
function time.getDayNumOfMonth(Year, Month) -- 返回Year Month有多少天
	local CurTime = os.date("*t")
	Year = Year or CurTime.year
	Month = Month or CurTime.month

	local StartTime = { year = Year, month = Month, day = 1, hour = 0, min = 0, sec = 0, }

	local EndTime = nil
	if Month == 12 then
		EndTime = { year = Year + 1, month = 1, day = 1, hour = 0, min = 0, sec = 0, }
	else
		EndTime = { year = Year, month = Month + 1, day = 1, hour = 0, min = 0, sec = 0, }
	end

	local StartSecs = os.time(StartTime)
	local EndSecs = os.time(EndTime)

	local SubSecs = EndSecs - StartSecs
	assert(SubSecs > 0)

	return math.floor((SubSecs / 86400)) -- 理论上不会有小数
end

--获取指定时间当月的天数
function time.getDayNumOfMonthBySec(sec)
    local date = os.date("*t",sec)
    return time.getDayNumOfMonth(date.year,date.month)
end

-- 格式化时间字符串
function time.formatDate(mytime)
	return os.date("%Y-%m-%d %H:%M:%S", mytime)
end

local function split(str, pat)
	local t = {}  
	local fpat = "(.-)" .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(t, cap)
		end
		last_end = e+1
		s, e, cap = str:find(fpat, last_end)
	end

	if last_end <= #str then
		cap = str:sub(last_end)
		table.insert(t, cap)
	end

	return t
end

function time.formatSecond(time)
	local a = split(time, " ")
	local b = split(a[1], "-")
	local c = split(a[2], ":")
	local t = os.time({year=b[1],month=b[2],day=b[3], hour=c[1], min=c[2], sec=c[3]})

	return t
end

--将"2006-06-01 10:00:00"这样的时间转换为秒
function time.sDate2Sec(sDateTime)
	return os.time(sDate2Table(sDateTime))
end

--将秒数转成字符串 "2009.01.03 22:10:53"
function time.sSec2DateTime( Sec )
	return os.date("%Y-%m-%d %H:%M:%S", Sec)
end

function time.sSec2DateTimeCn( Sec, OnlyDate )
	if OnlyDate then
		return os.date('%Y年%m月%d日', Sec)
	else
		return os.date('%Y年%m月%d日 %H时%M分%S秒', Sec)
	end
end