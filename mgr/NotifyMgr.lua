
--[["
	desc: 通知管理器
	author: TUYO
	since: 2014-03-31
"]]

NotifyMgr = {}

local maps = {}

function NotifyMgr:init()
	print("NotifyMgr:init")
end

function NotifyMgr:dealloc()
	maps = {}
end

function NotifyMgr:unreg(notifyName, callback, obj)
	local notifyNameTable = maps[notifyName]
	if notifyNameTable == nil then return end

	local index = 1
	while (index <= #notifyNameTable) do
		local T = notifyNameTable[index]

		if (obj == nil and callback == T.callback) or
			(obj ~= nil and obj == T.obj) then
			table.remove(notifyNameTable, index)
            T.isDel = true
		else
			index = index + 1
		end
	end

	if maps[notifyName] ~= nil and #maps[notifyName] == 0 then
		maps[notifyName] = nil
	end
end

---------------------- public ----------------------

-- 打印某通知名相关的信息
function NotifyMgr:log(notifyName)
	print("NotifyMgr:log ", notifyName)

	local notifyNameTable = maps[notifyName]
	if notifyNameTable == nil then return end

	for _, T in ipairs(notifyNameTable) do
		local callback 	= T.callback or "nil"
		local obj 		= T.obj or "nil"

		print("----------callback="..tostring(callback)..",obj="..tostring(obj))
	end
end

-- 打印当前所有的通知信息
function NotifyMgr:logAll()
	print("NotifyMgr:logAll")
	for notifyName, _ in pairs(maps) do
		self:log(notifyName)
	end
end

-- 注册
function NotifyMgr:reg(notifyName, callback, obj)
	assert(type(notifyName) == "string", "NotifyMgr:reg notifyName类型不为字符串")
	assert(type(callback) == "function", "NotifyMgr:reg callback类型不为方法")

	local T 	= {}
	T.callback 	= callback
	T.obj 		= obj

	maps[notifyName] = maps[notifyName] or {}
	table.insert(maps[notifyName], T)
end

-- 通过对象注销
function NotifyMgr:unregWithObj(obj)
	assert(type(obj) ~= "nil", "NotifyMgr:unregWithObj obj为nil")
	for notifyName, _ in pairs(maps) do
		self:unreg(notifyName, nil, obj)
	end 
end

-- 通过回调方法注销
function NotifyMgr:unregWithCallback(callback)
	assert(type(callback) == "function", "NotifyMgr:unregWithCallback callback类型不为方法")
	for notifyName, _ in pairs(maps) do
		self:unreg(notifyName, callback, nil)
	end 
end

-- 通过通知名注销
function NotifyMgr:unregWithName(notifyName)
	assert(type(notifyName) == "string", "NotifyMgr:unregWithName notifyName类型不为字符串")
	maps[notifyName] = nil
end

-- 推送通知
function NotifyMgr:push(notifyName, data)
	assert(type(notifyName) == "string", "NotifyMgr:push notifyName类型不为字符串")
	local notifyNameTable = maps[notifyName]
	if notifyNameTable == nil then return end

    local notifyList = {}
	for _, T in ipairs(notifyNameTable) do
		table.insert(notifyList, T)
	end
	for _, T in ipairs(notifyList) do
        if not T.isDel then
		    local callback 	= T.callback
		    local obj 		= T.obj

		    local dataObj	= {}
		    dataObj.name 	= notifyName
		    dataObj.data 	= data

		    if callback then
			    if obj then
				    callback(obj, dataObj)
			    else
				    callback(dataObj)
			    end
		    end
        end
	end
end

function NotifyMgr:clear()
	self:dealloc()
end

-- test
-- local aaa = {}
-- function aaa:test1(a)
-- 	print("aaa:test1", a.name, a.data)
-- end

-- bbb = {}
-- function bbb:test1(b)
-- 	print("bbb:test1", b.name, b.data)
-- end

-- local function test333(d)
-- 	print("test333", d.name, d.data)
-- end

-- NotifyMgr:logAll()

-- NotifyMgr:reg("kkk", aaa.test1, aaa)
-- NotifyMgr:reg("kkk2", bbb.test1, bbb)
-- NotifyMgr:reg("kkk", test333)

-- NotifyMgr:push("kkk", "AAA")
-- NotifyMgr:push("kkk2", "CCC")

-- NotifyMgr:logAll()

-- NotifyMgr:unregWithObj(bbb)

-- NotifyMgr:logAll()

-- NotifyMgr:unregWithCallback(test333)

-- NotifyMgr:logAll()

-- NotifyMgr:unregWithName("kkk")

-- NotifyMgr:logAll()