-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成



-- endregion
local bit = require("bit")

function unicodeToUtf8(convertStr)
    if type(convertStr) ~= "string" then
        return convertStr
    end
    local resultStr = ""
    local i = 1
    while true do
        local num1 = string.byte(convertStr, i)
        local unicode
        if num1 ~= nil and string.sub(convertStr, i, i + 1) == "\\u" then
            unicode = tonumber("0x" .. string.sub(convertStr, i + 2, i + 5))
            i = i + 6
        elseif num1 ~= nil then
            unicode = num1
            i = i + 1
        else
            break
        end
        if unicode <= 0x007f then
            resultStr = resultStr .. string.char(bit.band(unicode, 0x7f))
        elseif unicode >= 0x0080 and unicode <= 0x07ff then
            resultStr = resultStr .. string.char(bit.bor(0xc0, bit.band(bit.rshift(unicode, 6), 0x1f)))
            resultStr = resultStr .. string.char(bit.bor(0x80, bit.band(unicode, 0x3f)))
        elseif unicode >= 0x0800 and unicode <= 0xffff then
            resultStr = resultStr .. string.char(bit.bor(0xe0, bit.band(bit.rshift(unicode, 12), 0x0f)))
            resultStr = resultStr .. string.char(bit.bor(0x80, bit.band(bit.rshift(unicode, 6), 0x3f)))
            resultStr = resultStr .. string.char(bit.bor(0x80, bit.band(unicode, 0x3f)))
        end
    end
    resultStr = resultStr .. '\0'
    print(resultStr)
    return resultStr
end

function utf8ToUnicode(convertStr)
    if type(convertStr) ~= "string" then
        return convertStr
    end
    local resultStr = ""
    local i = 1
    local num1 = string.byte(convertStr, i)
    while num1 ~= nil do
        print(num1)
        local tempVar1, tempVar2
        if num1 >= 0x00 and num1 <= 0x7f then
            tempVar1 = num1
            tempVar2 = 0
        elseif bit.band(num1, 0xe0) == 0xc0 then
            local t1 = 0
            local t2 = 0
            t1 = bit.band(num1, bit.rshift(0xff, 3))
            i = i + 1
            num1 = string.byte(convertStr, i)
            t2 = bit.band(num1, bit.rshift(0xff, 2))
            tempVar1 = bit.bor(t2, bit.lshift(bit.band(t1, bit.rshift(0xff, 6)), 6))
            tempVar2 = bit.rshift(t1, 2)
        elseif bit.band(num1, 0xf0) == 0xe0 then
            local t1 = 0
            local t2 = 0
            local t3 = 0
            t1 = bit.band(num1, bit.rshift(0xff, 3))
            i = i + 1
            num1 = string.byte(convertStr, i)
            t2 = bit.band(num1, bit.rshift(0xff, 2))
            i = i + 1
            num1 = string.byte(convertStr, i)
            t3 = bit.band(num1, bit.rshift(0xff, 2))
            tempVar1 = bit.bor(bit.lshift(bit.band(t2, bit.rshift(0xff, 6)), 6), t3)
            tempVar2 = bit.bor(bit.lshift(t1, 4), bit.rshift(t2, 2))
        end
        resultStr = resultStr .. string.format("\\u%02x%02x", tempVar2, tempVar1)
        print(resultStr)
        i = i + 1
        num1 = string.byte(convertStr, i)
    end
    print(resultStr)
    return resultStr
end

function urlDecode(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end

function urlEncode(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end


function urlEncodeForSign(s)
    local resultStr="";
    -- s="appCode=klmj&appId=1&avatar=http%3A%2F%2Fwx.qlogo.cn%2Fmmopen%2FQ3auHgzwzM6nEskPeSqOe78B8P3UFLjPkTCqw5cdvbgnxcODHRObrbtORaw5ibctCRicqnj5ZNSj0qhbWQDtm4ZOn4WlKdQx4tkk3ZdJjdbPE%2F0&chanId=321321321&city=%E5%B9%BF%E5%B7%9E&clientFrom=1&clientVer=1&country=%E4%B8%AD%E5%9B%BD&gender=f&imei=321321312&language=zh%5FCN&loginFrom=10&macAddr=32132321321&model=31232121&nettype=321321321&nickName=%E7%BB%9D%E5%AF%B9%E6%B5%B7%E8%B4%BC%E8%BF%B7&openId=oUJxOvwzquDt2hsXFom2fP6c9eow&operator=321321321&osVer=321321321&pKey=string&province=%E5%B9%BF%E4%B8%9C&secretKey=U2FsdGVkX18fIUZvnjd4tmmlRjsojAJ2&uuId=321321321"
    print("urlEncodeForSign:"..s)
    print("urlEncodeForSign:"..string.len(s))
    for i=1 ,string.len(s)  do
        local singlestr=string.sub(s,i,i)
        if singlestr~="%" then
            if singlestr==" " then
                resultStr=resultStr.."+"
            elseif string.find(".-*_",singlestr)~=nil then
                resultStr=resultStr..singlestr
            elseif string.byte(singlestr)>=string.byte("a") and string.byte(singlestr)<=string.byte("z") then
                resultStr=resultStr..singlestr
            elseif string.byte(singlestr)>=string.byte("A") and string.byte(singlestr)<=string.byte("Z") then
                resultStr=resultStr..singlestr
            elseif string.byte(singlestr)>=string.byte("0") and string.byte(singlestr)<=string.byte("9") then
                resultStr=resultStr..singlestr
            end
        end
    end
    print("urlEncodeForSign:"..resultStr)
    return resultStr
end