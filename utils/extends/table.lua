-- table 的深拷贝,会判断userdata，nil，以及其他值类型并将拷贝结果返回
--（userdata 会判断是否有clone方法如果有返回clone调用结果，如果没有返回nil）
function table.deepcopy(t) 
    if not t then return nil end
    if type(t) ~= "table" then
        if type(t) == "userdata" then
            if t.clone then
                return t:clone()
            else
                return nil
            end
        else
            return t
        end

    end
    local function _deepCopy(from ,to)
        for k, v in pairs(from) do
            if type(v) ~= "table" then
                to[k] = v;
            else
                to[k] = {};
                _deepCopy(v,to[k]);
            end
        end
        return setmetatable(to, getmetatable(from))
    end
    local u = {}
    _deepCopy(t,u)
    return u
end
table.unpack = unpack

function table.map_key_tonumber(t)
    if type(t) ~= "table" then
        return
    end
    local newT = {}
    for k, v in pairs(t) do
        newT[tonumber(k)] = v
    end
    return newT
end