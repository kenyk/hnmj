-- --coding:utf8
-- -- -*- coding: utf-8 -*-
-- ------------------------------------------
-- --作者:skillart
-- --bolg:http://blog.csdn.net/skillart/article/details/40422885
-- --
-- ------------------------------------------

m_table = {}
g_NeedHunCount = 0 
callTime = 2
local haswan = true
local hasfeng = true
local hastong = true
local hastiao = true

function print_r(sth)
    if type(sth) ~= "table" then
        print(sth)
        return
    end

    local cache = {  [sth]="<self>" }

    local space, deep = string.rep(' ', 2), 0
    local function _dump(pkey, t)

        for k,v in pairs(t) do
            local key
            if type(k)=='number' then
                key = string.format("[%s]", k)
            else
                key= tostring(k)
            end

            if cache[v] then
                print(string.format("%s%s=%s,", string.rep(space, deep + 1),key,cache[v])) --print.
            elseif type(v) == "table" then
                deep = deep + 2
                cache[v]= string.format("%s.%s",pkey,key)
                print(string.format("%s%s=\n%s{", string.rep(space, deep - 1), key, string.rep(space, deep))) --print.
                _dump(string.format("%s.%s",pkey,key), v)
                print(string.format("%s},",string.rep(space, deep)))
                deep = deep - 2
            else
                if type(v) == 'string' then
                    print(string.format("%s%s='%s',",   string.rep(space, deep + 1),key,v)) --print.
                else
                    print(string.format("%s%s=%s,", string.rep(space, deep + 1),key,tostring(v))) --print.
                end
            end
        end
    end

    print(string.format("{"))
    _dump("<self>", sth)
    print(string.format("}"))
end

function m_table.clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function m_table.removebyvalue(array, value, removeall)
    local c, i, max = 0, 1, #array
    while i <= max do
        if array[i] == value then
            table.remove(array, i)
            c = c + 1
            i = i - 1
            max = max - 1
            if not removeall then break end
        end
        i = i + 1
    end
    return c
end

function sortArr(arr)
    if #arr == 0 then
        return
    end
    -- arr.sort( None, key=lambda v:v%10 )
    table.sort(arr)
end

function seprateArr( mjArr, hunMj )
    reArr = {{},{},{},{},{}}
    ht = math.floor(hunMj / 10)
    hv = hunMj % 10
--    for i, mj in pairs(mjArr) do
    for i = 1 , #mjArr do
        t = math.floor(mjArr[i]/10)
        v = mjArr[i] % 10
        if ht == t and hv == v then
            t = 5
        end
        table.insert(reArr[t], mjArr[i])
        sortArr(reArr[t])
    end
    return reArr
end
function test3Combine( mj1, mj2, mj3 )
    t1, t2, t3 = math.floor(mj1/10), math.floor(mj2/10), math.floor(mj3/10)
    -- 牌型不同不能组合
    if t1 ~= t2 or t1 ~= t3 then
        return false
    end
    v1, v2, v3 = mj1%10, mj2%10, mj3%10
    -- 重牌
    if v1 == v2 and v1 == v3 then
        return true
    end
    if t3 == 4 then
        return false
    end
    if (v1+1) == v2 and (v1+2) == v3 then
        return true
    end
    return false
end

function getModNeedNum(arrLem,isJiang)
    if arrLem <=0 then
        return 0
    end
    modNum = arrLem % 3 + 1
    needNumArr = {0,2,1}
    if isJiang then
        needNumArr = {2,1,0}
    end
    return needNumArr[modNum]
end

local table1 = {}
local table2 = {}
local table3 = {}
local table4 = {}

local table5 = {}
local table6 = {}



function getNeedHunInSub( subArr, hNum , need_table)
    callTime = callTime + 1
    lArr = #subArr
    if hNum + getModNeedNum(lArr,false) >= g_NeedHunCount then
        return
    end
    if lArr == 0 then
        g_NeedHunCount = math.min( hNum, g_NeedHunCount )
        return
    elseif lArr == 1 then
        g_NeedHunCount = math.min(hNum+2, g_NeedHunCount)
        return
    elseif lArr == 2 then
        t = math.floor(subArr[1] / 10)
        v0 = subArr[1] % 10
        v1 = subArr[2] % 10
        if t == 4 then -- 东南西北中发白（无顺）
            if v0 == v1 then
                g_NeedHunCount = math.min( hNum+1, g_NeedHunCount )
                return
            end
        elseif  (v1-v0) < 3 then
            g_NeedHunCount = math.min( hNum+1, g_NeedHunCount )
            return
        end
    elseif lArr >= 3 then -- 大于三张牌
        t  = math.floor(subArr[1] / 10)
        v0 = subArr[1] % 10
        v1 = subArr[2] % 10
        --第一个和另外两个一铺
        arrLen = #subArr
        for i = 2 , arrLen do
            local isgo = true
            if hNum + getModNeedNum(lArr-3,false) >= g_NeedHunCount then
                isgo = false
            end
            v2 = subArr[i] % 10
            --13444   134不可能连一起
            if v1 - v0 > 1  then
                break
            end
            if i+2 < arrLen and isgo then
                if subArr[i+2]%10 == v1 then
                    isgo = false
                end
            end
            if isgo and i < arrLen then
                tmp1, tmp2, tmp3 = subArr[1],subArr[i],subArr[i+1]
                if test3Combine( tmp1, tmp2, tmp3 ) then
                    table.insert(table1, table.remove(subArr, i+1))
                    table.insert(table1, table.remove(subArr, i))
                    table.insert(table1, table.remove(subArr, 1))
                    subLen = #subArr
                    getNeedHunInSub(subArr, hNum)
                    table.insert(subArr, table.remove(table1, #table1))
                    table.insert(subArr, table.remove(table1, #table1))
                    table.insert(subArr, table.remove(table1, #table1))
                    table.sort(subArr)
                end
            end
        end
        -- 第一个和第二个一铺
        v1 = subArr[1] % 10
        if hNum + getModNeedNum(lArr-2,false) +1 < g_NeedHunCount then
            if t == 4 then -- 东南西北中发白（无顺）
                if v0 == v1 then
                    tmp1 = subArr[1]
                    tmp2 = subArr[2]
                    table.insert(table2, table.remove(subArr, 2))
                    table.insert(table2, table.remove(subArr, 1))
                    getNeedHunInSub(subArr, hNum+1)
                    table.insert(subArr, table.remove(table2, #table2))
                    table.insert(subArr, table.remove(table2, #table2))
                    sortArr( subArr )
                end
            else
                arrLen = #subArr
                for i = 2, arrLen do
                    local isgo = true
                    if hNum + getModNeedNum(lArr-2,false) +1  >= g_NeedHunCount then
                        isgo = false
                    end
                    v1 = subArr[i] % 10
                    --如果当前的value不等于下一个value则和下一个结合避免重复
                    if i == arrLen and isgo then
                        v2 = subArr[i-1] % 10
                        if v1 == v2 then
                            isgo = false
                        end
                    end
--                    local mius = v1 - v0
                    local mius = subArr[i]%10 - subArr[1]%10
                    if  mius < 3 and isgo then
                        tmp1 = subArr[1]
                        tmp2 = subArr[i]
                        table.insert(table3, table.remove(subArr, i))
                        table.insert(table3, table.remove(subArr, 1))
                        getNeedHunInSub(subArr, hNum+1)
                        table.insert(subArr, table.remove(table3, #table3))
                        table.insert(subArr, table.remove(table3, #table3))
                        table.sort(subArr)
                    end
                end
            end
        end
        -- 第一个自己一铺
        if  hNum + getModNeedNum(lArr-1,false)+2 < g_NeedHunCount then
            tmp = subArr[1]
            table.insert(table4, table.remove(subArr, 1))
            getNeedHunInSub( subArr, hNum + 2 )
            table.insert(subArr, table.remove(table4, #table4))
            table.sort(subArr)
        end
    else
        return
    end
end

function test2Combine( mj1, mj2 )
    t1, t2 = math.floor(mj1/10), math.floor(mj2/10)
    v1, v2 = mj1 % 10, mj2 % 10
    if t1 == t2 and v1 == v2 then
        return true
    end
    return false
end

function canHu( hunNum, arr )
    tmpArr = {}
    tmpArr = m_table.clone(arr)
    arrLen = #tmpArr
    if arrLen <= 0 then
        if hunNum >= 2 then
            return true
        end
        return false
    end
    if hunNum < getModNeedNum(arrLen,true) then
        return false
    end
    for i = 1 , arrLen do
        if i == arrLen then-- 如果是最后一张牌
            if hunNum > 0 then
                tmp = tmpArr[i]
                hunNum = hunNum - 1
                table.remove(tmpArr, i)
                g_NeedHunCount = 4
                getNeedHunInSub(tmpArr, 0)
                if g_NeedHunCount <= hunNum then
                    return true
                end
                hunNum = hunNum +1
                table.insert(tmpArr, tmp)
                table.sort(tmpArr)
            end
        else
            if ( i+2 ) == arrLen or (tmpArr[i]%10) ~= (tmpArr[i+2]%10) then
                if test2Combine( tmpArr[i], tmpArr[i+1] ) then
                    tmp1 = tmpArr[i]
                    tmp2 = tmpArr[i+1]
                    table.remove(tmpArr, tmp1)
                    table.remove(tmpArr, tmp2)
                    g_NeedHunCount = 4
                    getNeedHunInSub(tmpArr, 0)
                    if g_NeedHunCount <= hunNum then
                        return true
                    end
                    table.insert(tmpArr, tmp1)
                    table.insert(tmpArr, tmp2)
                    table.sort(tmpArr)
                end
            end
            if hunNum>0 and (tmpArr[i]%10) ~= (tmpArr[i+1]%10) then
                hunNum = hunNum -1
                tmp = tmpArr[i]
                table.remove(tmpArr, tmp)
                g_NeedHunCount = 4
                getNeedHunInSub(tmpArr, 0)
                if g_NeedHunCount <= hunNum then
                    return true
                end
                hunNum = hunNum +1
                table.insert(tmpArr, tmp)
                table.sort(tmpArr)
            end
        end
    end
    return false
end

--------------------------------------------------------------------------------------------------------

function getJiangNeedHum(arr)
    minNeedNum = 4
    local tmpArr = m_table.clone(arr)
    arrLen_t = #tmpArr
    if arrLen_t <= 0 then
        return 2
    end
    for i = 1 , arrLen_t do
--        print_r(tmpArr)
        if i == (arrLen_t) then-- 如果是最后一张牌
            local tmp = tmpArr[i]
            table.remove(tmpArr, i)
            g_NeedHunCount = 4
            getNeedHunInSub(tmpArr, 0)
            minNeedNum = math.min(minNeedNum,g_NeedHunCount+1)
            table.insert(tmpArr, tmp)
            sortArr(tmpArr)
        else
            --if i < arrLen_t and (tmpArr[i]%10) == (tmpArr[i+1]%10) then
                if test2Combine( tmpArr[i], tmpArr[i+1] ) then
                    local tmp2 = table.remove(tmpArr, i+1)
                    local tmp1 = table.remove(tmpArr, i)
                    g_NeedHunCount = 4
                    getNeedHunInSub(tmpArr, 0)
                    minNeedNum = math.min(minNeedNum,g_NeedHunCount)
                    table.insert(tmpArr, tmp1)
                    table.insert(tmpArr, tmp2)
                    sortArr(tmpArr)
                else
                    --if i <= arrLen_t-1 and (tmpArr[i]%10) ~= (tmpArr[i+1]%10) then
                        local tmp_4 = table.remove(tmpArr, i)
                        g_NeedHunCount = 4
                        getNeedHunInSub(tmpArr, 0)
                        minNeedNum = math.min(minNeedNum,g_NeedHunCount+1)
                        table.insert(tmpArr, tmp_4)
                        sortArr( tmpArr )
                    --end
                end
           -- end
        end

    end
    return minNeedNum
end

local function check_hu_all(num, nojiang, jiang, curHunNum)
    if curHunNum >= 2 and num == 0  then
        return true
    end 
    for i= 1, 4 do
        if curHunNum >= num -  nojiang[i] + jiang[i] and jiang[i] >= nojiang[i] + 2 then
            return true
        end
    end
    return false
end

function getTingNumArr(mjArr,hunMj)
-- 创建一个麻将数组的copy
    tmpArr = m_table.clone(mjArr)
    sptArr = seprateArr(tmpArr, hunMj)
    ndHunArr = {} -- 每个分类需要混的数组
    for i = 1 , 4 do
        g_NeedHunCount = 4
        getNeedHunInSub( sptArr[i], 0 )
        table.insert(ndHunArr, g_NeedHunCount)
    end
    jaNdHunArr = {}--每个将分类需要混的数组
    for i = 1, 4 do
        jdNeedHunNum = getJiangNeedHum(sptArr[i])
        table.insert(jaNdHunArr, jdNeedHunNum)
    end
--    print_r(sptArr)
--    print_r(ndHunArr)
--    print_r(jaNdHunArr)
    --给一个混看能不能胡
    curHunNum = #sptArr[5] + 1
    tingArr = {}
    --是否单调将
    isAllHu = false
    needNum = 0
    for i = 1, 4 do
        needNum = needNum + ndHunArr[i]
    end
    if curHunNum - needNum == 1 then
        isAllHu = true
    end
    if check_hu_all(needNum, ndHunArr,jaNdHunArr, curHunNum) or curHunNum == 5 then
        if haswan then
            for i= 1, 9 do
                tingArr[10+i] = true
            end
        end
        if hastong then
            for i= 1, 9 do
                tingArr[20+i] = true
            end
        end
        if hastiao then
            for i= 1, 9 do
                tingArr[30+i] = true
            end
        end
        if hasfeng then
            for i= 1, 7 do
                tingArr[40+i] = true
            end
        end
        return tingArr
    end
    if isAllHu then
        table.insert(tingArr, tmpArr)
        return  tingArr
    end
    for i = 1, 4 do
        local tab = {}
        if next(sptArr[i]) then
            local no_jiang = 0
            local need_jiang = 10
            local tmp = {}
            for a, b in pairs(ndHunArr) do
                if a ~= i then
                    no_jiang = no_jiang + b
                    tmp[a] = jaNdHunArr[a]
                end
            end
            for a, b in pairs(tmp) do
                for c , d in pairs(ndHunArr) do
                    if a ~= c and i ~= c then
                        tmp[a] = tmp[a] + d
                    end
                end
            end
            for a , b in pairs(tmp) do
                if need_jiang > b then
                    need_jiang = b
                end
            end
            for j = 1, 9 do
                local card = i*10+j
                local cards_tmp = m_table.clone(sptArr[i])
                table.insert(cards_tmp, card)
                table.sort(cards_tmp)
                g_NeedHunCount = 4
                getNeedHunInSub(cards_tmp, 0)
                if curHunNum - need_jiang -1 >= g_NeedHunCount then
                    tingArr[card] = true
                else
                    tmp1 = getJiangNeedHum(cards_tmp)
                    if tmp1 + no_jiang <= curHunNum -1 then
                        tingArr[card] = true
                    end  
                end
            end
        end
    end
    return tingArr
end

local function checkqidui(tab, laiziNum)
    local has_single = false
    local ting_tab = {}
    for i , k in pairs(tab)do
        if k == 1 or k == 3 then
            if not has_single then
                if laiziNum == 0 then
                    has_single = true
                    ting_tab[i] = true
                else
                    laiziNum = laiziNum - 1
                    ting_tab[i] = true
                end
            else
                return false, {}
            end
        end
    end
    return true , ting_tab
end

local function tranCardsTab(cards)
    local tab_tmp = {}
    for i = 1, #cards do
        tab_tmp[cards[i]] = tab_tmp[cards[i]] or 0
        tab_tmp[cards[i]] = tab_tmp[cards[i]] + 1
    end
    return tab_tmp
end

--听牌入口(cards牌型)
function getAllting(cards, config, laizi)
    local tingArr1 = {}
    local tingArr2 = {}
    local is_ting = false
    if config then
        local stackCards = tranCardsTab(cards)
        if #cards == 13 then
            if config.qidui1 then
                is_ting, tingArr1 = checkqidui(stackCards, 0)
            end
            if config.qidui2 then
                local laizi_num = stackCards[laizi] or 0
                stackCards[laizi] = nil
                _, tingArr1 = checkqidui(stackCards, laizi_num)
            end
        end
    end
    if is_ting then
        return v2ToV1Data(tingArr1)
    else
        tingArr2 = getTingNumArr(cards,laizi)
        if next(tingArr1) then
            for i , k in pairs(tingArr1) do
                tingArr2[i] = true
            end
        end
        return v2ToV1Data(tingArr2)
    end
end