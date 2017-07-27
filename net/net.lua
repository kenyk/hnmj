
--the net module used to send the msg and receive the msg
--only need to call the init and sendCommand, the type must base on the protocol

local traceback = __G__TRACKBACK__
local proto1 = require "net.proto"
local sproto1 = require "net.sproto"
local host = sproto1.new(proto1.s2c):host "package"
local request = host:attach(sproto1.new(proto1.c2s))
local session = 0
local c2sTable = {}
local PKG_HEAD_LEN = 2

local L = {
	socket  = nil,
	recv    = '',
	ip      = '',
	pkgLen  = -1,
    port    = -1,
    msg = nil,          -- 回调数据
    cbObj   = nil,      -- 回调对象
    cbRecv  = nil,      -- 接收数据回调
    cbClose = nil,      -- 断线回调
    cbConnectOK = nil,  -- 连接成功回调
    cbConnectFail = nil,-- 连接失败回调
}

-- 清理
local function _clear()
    L.socket = nil
    L.recv = ''
    L.pkgLen = -1
end

-- 客户端被断开连接
local function _onCloseByServer()
    _clear()
    L.cbClose(L.cbObj)
end

-- send出错断开连接
local function _onCloseBySending()
    _clear()
    L.socket:close()
    L.cbClose(L.cbObj)
end

local function _skynet_text_pack_head(length)
    -- uint8_t head[2];
    -- head[0] = (n >> 8) & 0xff;
    -- head[1] = n & 0xff;
    local n = length
    local t1 = bit._and( bit._rshift(n, 8), 0xff)
    local t2 = bit._and( n, 0xff)
    local t = string.char(t1)..string.char(t2)
    return t
end

local function _skynet_text_unpack_head(head)
    -- size_t len = header[0] << 8 | header[1];
    local t1 = string.byte(head, 1)
    local t2 = string.byte(head, 2)
    local n = bit._or( bit._lshift(t1, 8), t2)
    return n
end

-- 发送原始数据
local function _send(buff)
    if buff == nil or type(buff) ~= 'string' or #buff <= 0 then
        return false
    end
    -- buff = _skynet_text_pack(buff)  -- 转成skynet数据
    if #buff >= 65500 then
        traceback('gnet>send ERROR: message is too large')
        return false
    end
    local res, err, len = L.socket:send(buff)
    -- print("L.socket:send(buff):",res, err, len)
    -- print(#buff)
    -- 一次发送成功
    if type(res) == 'number' and res == #buff then
        return true
    end
    -- 断线/超时退出
    if err == 'closed' then
        print('gnet>send ERROR:disconnect in _send()')
        _onCloseByServer()
        return false
    end
    -- timeout 或者其他情况则继续重试
    local s = res or len -- s:已发送的位置
    local function __send_loop ()
        local cnt = 0
        while(s < #buff) do
            -- 最多循环1000次退出
            cnt = cnt + 1
            if cnt >= 5000 then
--                print("最多循环1000次退出 cnt = ",cnt)
--                print("最多循环1000次退出 len = ",s)
                return false
            end

            res, err, len = L.socket:send( buff, s+1 )
            if err == 'closed' then
                print('gnet>send ERROR:disconnect in __send_loop()')
                return false
            end

            s = res or len -- 更新已发送
        end -- while
        return true
    end -- __send_loop

    local isOk, ret = pcall(__send_loop)
    -- 发送出错
    if not isOk or (isOK and ret == false) then
        print('gnet>__send_loop ERROR:'..tostring(ret))
        _onCloseBySending()
    end
end

local socket = cc.load("luasocket").socket

local net1 = {}

function net1:init(ip, port, cbObj, cbRecv, cbConnectOK, cbConnectFail, cbClose)
    print("init the net module")
    L.ip = ip
    L.port = port
    L.msg = {}
    L.cbObj   = cbObj
    L.cbRecv  = cbRecv
    L.cbClose = cbClose
    L.cbConnectOK = cbConnectOK
    L.cbConnectFail = cbConnectFail
end

function net1:connect()
    if self:isconnect() then
        print('gnet>already connected, can NOT do connect()')
        return
    end
    
    local addrinfo, err = socket.dns.getaddrinfo(L.ip);
    if err then print("err:",err) L.cbConnectFail(L.cbObj) return end
    dump(addrinfo,"addrinfo:")
    local s
    for i, alt in ipairs(addrinfo) do
        if alt.family == "inet" then
            s, err = socket.tcp()
        else
            s, err = socket.tcp6()
            break
        end
    end
    -- local s, err = socket.tcp()
    if not s then
        print('gnet>create socket.tcp ERROR:'..err)
        _clear()
        return false
    else
        print('gnet>create socket.tcp OK')
    end
    -- set connect timeout
    s:settimeout(3)
    print('socket.connect: '..L.ip..':'..tostring(L.port))
    local res, err = s:connect(L.ip, L.port)

    if not res then
        print('gnet>connet ERROR:'..err)
        L.cbConnectFail(L.cbObj)
        return false
    end
    print('gnet>connet OK ['..L.ip..':'..L.port..']')
    --tcp:setoption
    s:settimeout(0)
    L.socket = s
    L.cbConnectOK(L.cbObj)
    return true
end

local function unpack_package(text)
    local size = #text
    if size < 2 then
        return nil, text
    end
    local s = text:byte(1) * 256 + text:byte(2)
    if size < s+2 then
        return nil, text
    end
    return text:sub(3,2+s), text:sub(3+s)
end

local function recv_package(last,s)
    local result
    result, last = unpack_package(last)
    if result then
        return result, last
    end
    local r = s:receive('*a')
    if not r then
        return nil, last
    end
    if r == "" then
        error "Server closed"
    end
    return unpack_package(last .. r)
end

local function print_package(t, name ,args)
	-- print(t,name,grgs,"t,name,grgs")
	name = c2sTable[name] or name
    L.msg = {types = types, name = name, args = args}
    xpcall(function () L.cbRecv(L.cbObj, L.msg) end, traceback)
    -- local status, msg = xpcall(function () L.cbRecv(L.cbObj, L.msg) end, traceback)
    -- if not status then
    --     print(msg)
    -- end
end

local last = ""
function net1.tick()
    if not L.socket then return end
    local res, err = socket.select({L.socket,}, nil, 0)
    if #res == 0 then return end
    local s = res[1]
    local res, err, partial = s:receive('*a')
    res = res or partial
    if (not res) or (#res == 0) then
        if err == 'closed' then
            print('gnet>closed by server')
            _onCloseByServer()
        elseif err == 'timeout' then
            -- 
        end
        return
    end
    L.recv = L.recv..res
    -- print(L.recv..res,"--------------------------")
    local pkgs = {}
    while true do
        if #L.recv < PKG_HEAD_LEN then break end -- 必须大于head长度
        if L.pkgLen == -1 then
            L.pkgLen = _skynet_text_unpack_head( string.sub(L.recv, 1, PKG_HEAD_LEN) )
        end
        local l = #L.recv - (L.pkgLen+PKG_HEAD_LEN)
        if l < 0 then break end -- 长度不足, 不能切
        table.insert(pkgs, string.sub(L.recv, PKG_HEAD_LEN+1, PKG_HEAD_LEN+L.pkgLen))
        if l == 0 then
            L.recv = ''
        elseif l > 0 then -- 切掉之后还有多, 继续循环
        	L.recv = string.sub(L.recv, PKG_HEAD_LEN+L.pkgLen+1)
        end
        L.pkgLen = -1 -- 重新计算长度
    end
    -- 执行
    for _, pkg in pairs(pkgs) do
        -- _recv(pkg)
        print_package(host:dispatch(pkg))
    end
end

function net1:sendRequest(name, args)
    session = session + 1
    -- print(name, args)
    local buff = request(name, args, session)
    local head = _skynet_text_pack_head(#buff)
    -- print(type(str))
    -- mynet.CoreNet:sharedCoreNet():sendNetMsg(str,#str)
    c2sTable[session] = name
    -- print("Request:", session)
    return pcall(function() return _send(head..buff) end)
end

-- 检测是否已经在连接
function net1:isconnect()
    print("L.socket =",L.socket ~= nil)
    return (L.socket ~= nil)
end

-- 客户端主动关闭网络连接
function net1:close()
    if L.socket ~= nil then
        L.socket:close()
        _clear()
    end
end


return net1