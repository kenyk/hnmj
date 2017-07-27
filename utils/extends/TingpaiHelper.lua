

local bit8_base = {}
for i=1,8 do
    bit8_base[i] = 2^(8-i)
end 

local bit32_base = {}
for i=1,32 do
    bit32_base[i] = 2^(32-i)
end

local function bit8_i2b(a) 
	local t = {}
	for i = 1 , 8 do
       if a >= bit8_base[i] then
            t[i]=1
            a = a - bit8_base[i]
        else
            t[i]=0
        end
	end
	return t 
end

local function bit32_i2b(a) 
	local t = {}
	for i = 1 , 32 do
       if a >= bit32_base[i] then
            t[i]=1
            a = a - bit32_base[i]
        else
            t[i]=0
        end
	end
	return t 
end

local function bit8_b2i(a)
    local nr = 0
    for i = 1, 8 do
        if a[i] == 1 then
            nr = nr + bit8_base[i]
        end
    end
    return  math.floor(nr)
end
local function bit32_b2i(a)
    local nr = 0
    for i = 1, 32 do
        if a[i] == 1 then
            nr = nr + bit32_base[i]
        end
    end
    return  math.floor(nr)
end
local function bit8_or(a, b, c, d, e, f, g) -- 
	--print(a, b, c, d, e, f, g)
	local b1 = bit8_i2b(assert(a))
	local b2 = bit8_i2b(assert(b))
	local b3 = bit8_i2b(c or 0)
	local b4 = bit8_i2b(d or 0)
	local b5 = bit8_i2b(e or 0)
	local b6 = bit8_i2b(f or 0)	
	local b7 = bit8_i2b(g or 0)
	local r = {}
	for i = 1, 8 do 
       if b1[i]==1 or b2[i]==1 or b3[i]==1 or b4[i]==1 or b5[i]==1 or b6[i]==1 or b7[i]==1  then
            r[i]=1
        else
            r[i]=0
        end		
	end
	return bit8_b2i(r) 
end

local function bit32_or(a, b, c, d, e, f, g, h, i) -- 
	local b1 = bit32_i2b(assert(a))
	local b2 = bit32_i2b(assert(b))
	local b3 = bit32_i2b(c or 0)
	local b4 = bit32_i2b(d or 0)
	local b5 = bit32_i2b(e or 0)
	local b6 = bit32_i2b(f or 0)	
	local b7 = bit32_i2b(g or 0)
	local b8 = bit32_i2b(h or 0)	
	local b9 = bit32_i2b(i or 0)
	local r = {}
	for i = 1, 32 do 
       if b1[i]==1 or b2[i]==1 or b3[i]==1 or b4[i]==1 or b5[i]==1 or b6[i]==1 or b7[i]==1 or b8[i]==1 or b9[i]==1 then
            r[i]=1
        else
            r[i]=0
        end		
	end
	return bit32_b2i(r) 
end


local function bit8_band(a, b)
	local b1 = bit8_i2b(a)
	local b2 = bit8_i2b(b)
	local r = {}
	for i = 1, 8 do
        if b1[i]==1 and b2[i]==1  then
            r[i]=1
        else
            r[i]=0
        end
	end	
	return bit8_b2i(r) 
end
local function bit32_band(a, b)
	local b1 = bit32_i2b(a)
	local b2 = bit32_i2b(b)
	local r = {}
	for i = 1, 32 do
        if b1[i]==1 and b2[i]==1  then
            r[i]=1
        else
            r[i]=0
        end
	end	
	return bit32_b2i(r) 
end

local function bit_lshit(a, b)
	return math.floor(a * (2 ^ b))
end

local function bit_rshit(a, b)
	return math.floor(a/(2 ^ b))
end


local function isMentsu(m)
	local a = bit32_band(m , 7)
	local b = 0
	local c = 0
	if a == 1 or a == 4 then
		b = 1 
		c = 1
	elseif a == 2 then
		b = 2 
		c = 2
	end
	m = bit_rshit(m ,3) 
	a = bit32_band(m,7) -b
	if  a < 0 then
		return false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
	end
	b = c 
	c = 0 
	if  a == 1 or a ==4 then
		b = b + 1
		c = c + 1
	elseif a == 2 then
		b = b + 2
		c = c + 2
	end
	m = bit_rshit(m ,3) 
	a = bit32_band(m,7) -b
	if a < 0 then
		return false
	end
	b = c 
	c = 0 
	if a == 1 or a == 4 then
		b = b + 1
		c = c + 1
	elseif  a == 2 then
		b = b + 2
		c = c + 2
	end
	m = bit_rshit(m ,3) 
	a = bit32_band(m,7) -b
	if a < 0 then
		return false
	end
	b = c 
	c = 0 
	if a == 1 or a == 4 then
		b = b + 1
		c = c + 1
	elseif  a == 2 then
		b = b + 2
		c = c + 2
	end	
	m = bit_rshit(m ,3) 
	a = bit32_band(m,7) -b
	if a < 0 then
		return false
	end
	b = c 
	c = 0 
	if a == 1 or a == 4 then
		b = b + 1
		c = c + 1
	elseif  a == 2 then
		b = b + 2
		c = c + 2
	end
	m = bit_rshit(m ,3) 
	a = bit32_band(m,7) -b
	if a < 0 then
		return false
	end
	b = c 
	c = 0 
	if a == 1 or a == 4 then
		b = b + 1
		c = c + 1
	elseif  a == 2 then
		b = b + 2
		c = c + 2
	end
	m = bit_rshit(m ,3) 
	a = bit32_band(m,7) -b
	if a < 0 then
		return false
	end
	b = c 
	c = 0 
	if a == 1 or a == 4 then
		b = b + 1
		c = c + 1
	elseif  a == 2 then
		b = b + 2
		c = c + 2
	end
	m = bit_rshit(m ,3) 
	a = bit32_band(m,7) -b
	if a ~= 0 and a ~= 3 then
		return false
	end
	m = bit_rshit(m ,3) 
	a = bit32_band(m,7) - c
	return a == 0 or a == 3
end
local function getValue(c, tab, pos)
	if pos > -1 and pos < 9 then
		return c[pos] + tab[pos]
	end
	return nil
end


local function probe_lazi(c, pos, tab)
	local current = getValue(c,	tab, pos)

	if current == nil then
		return 0
	end

	if current == 0 then
		return 0
	elseif current == 3 then
		local next_1 = getValue(c,	tab, pos + 1)
		local next_2 = getValue(c,	tab, pos + 2)		
		if next_1 == nil or next_2 == nil then
			return 0
		end
		if 	next_1 <= 0 or next_2 <= 0 then
			return 0
		end
		
		if next_1 == 1 and next_2 == 1 then
			tab[pos + 1] = tab[pos + 1] - 1
			tab[pos + 2] = tab[pos + 2] - 1			
			return 1
		elseif next_1 == 1 and next_2 == 2 then
			tab[pos + 1] = tab[pos + 1] - 1
			tab[pos + 2] = tab[pos + 2] - 1			
			return 1			
		elseif next_1 == 1 and next_2 == 3 then
			tab[pos + 1] = tab[pos + 1] - 1
			tab[pos + 2] = tab[pos + 2] - 1			
			return 1			
		else
			return 0
		end
		return 0
	elseif current == 1 or current == 4 then
		local next_1 = getValue(c,	tab, pos + 1)
		local next_2 = getValue(c,	tab, pos + 2)

		if next_1 == nil or next_2 == nil then
			return 2
		end	
		if next_1 <= 0 and next_2 <= 0 then
			return 2
		end
		if next_1 > 0 and  next_2 > 0 then
			tab[pos + 1] = tab[pos + 1] - 1
			tab[pos + 2] = tab[pos + 2] - 1
			return 0
		end
		if next_1 > 0 then
			tab[pos + 1] = tab[pos + 1] - 1
		end
		if next_2 > 0 then
			tab[pos + 2] = tab[pos + 2] - 1
		end
		return 1
	elseif current == 2 then
		local next_1 = getValue(c,	tab, pos + 1)
		local next_2 = getValue(c,	tab, pos + 2)

		if next_1 == nil or next_2 == nil then
			return 1
		end	
		if next_1 >= 2 and next_2 >= 2 then
			tab[pos + 1] = tab[pos + 1] - 2
			tab[pos + 2] = tab[pos + 2] - 2			
			return 0
		end
		return 1		
	else
		assert(nil)
	end

end

local function isMentsu_need(c)

	local lazi = 0
	local tab = {[0] = 0,0,0,0,0,0,0,0,0}
	for i = 0 , 8 do
		lazi = lazi +probe_lazi(c,i,tab)
	end

	return lazi
end



local function isAtamaMentsu(nn, m , changsha)
	if changsha == false and nn == 0 then
		if bit32_band(m, bit_lshit(7, 6)) >= (bit_lshit(2, 6)) and isMentsu(m-(bit_lshit(2, 6))) then   --3
			return true
		end
		if bit32_band(m, bit_lshit(7, 15)) >= (bit_lshit(2, 15)) and isMentsu(m-(bit_lshit(2, 15))) then --6
			return true
		end
		if bit32_band(m, bit_lshit(7, 24)) >= (bit_lshit(2, 24)) and isMentsu(m-(bit_lshit(2, 24))) then --9
			return true
		end
	elseif nn== 1 then
		if bit32_band(m, bit_lshit(7, 3)) >= (bit_lshit(2, 3)) and isMentsu(m-(bit_lshit(2, 3))) then  --2
			return true
		end	
		if bit32_band(m, bit_lshit(7, 12)) >= (bit_lshit(2, 12)) and isMentsu(m-(bit_lshit(2, 12))) then -- 5
			return true
		end
		if bit32_band(m, bit_lshit(7, 21)) >= (bit_lshit(2, 21)) and isMentsu(m-(bit_lshit(2, 21))) then -- 8
			return true
		end
	elseif changsha == false and nn == 2 then
		if bit32_band(m, bit_lshit(7, 0)) >= (bit_lshit(2, 0)) and isMentsu(m-(bit_lshit(2, 0))) then  -- 1
			return true
		end	
		if bit32_band(m, bit_lshit(7, 9)) >= (bit_lshit(2, 9)) and isMentsu(m-(bit_lshit(2, 9))) then  -- 4
			return true
		end
		if bit32_band(m, bit_lshit(7, 18)) >= (bit_lshit(2, 18)) and isMentsu(m-(bit_lshit(2, 18))) then --7
			return true
		end
	end
	return false					
end


local function cc2m(c, d)
	--return c[d + 0] << 0 | c[d + 1] << 3 | c[d + 2] << 6 | c[d + 3] << 9| c[d + 4] << 12| c[d + 5] << 15| c[d + 6] << 18| c[d + 7] << 21| c[d + 8] << 24
	return bit32_or(bit_lshit(c[d + 0] , 0) , bit_lshit(c[d + 1] , 3) , bit_lshit(c[d + 2] , 6) , bit_lshit(c[d + 3] , 9) , bit_lshit(c[d + 4] , 12) , bit_lshit(c[d + 5] , 15) , bit_lshit(c[d + 6] , 18) , bit_lshit(c[d + 7] , 21) , bit_lshit(c[d + 8] , 24))
end

local function isAgari(c ,changsha)  -- 测试是否胡牌
	--local j = (1<<c[27])|(1<<c[28])|(1<<c[29])|(1<<c[30])|(1<<c[31])|(1<<c[32])|(1<<c[33])
	local j = bit8_or(bit_lshit(1, c[27]), bit_lshit(1, c[28]), bit_lshit(1, c[29]), bit_lshit(1, c[30]), bit_lshit(1, c[31]), bit_lshit(1, c[32]), bit_lshit(1, c[33]))
	--print("isAgari j:", j)

	if bit8_band(j,3) == 2 and c[0]*c[8]*c[9]*c[17]*c[18]*c[26]*c[27]*c[28]*c[29]*c[30]*c[31]*c[32]*c[33] == 2 then -- 国士无双
		return true
	end
	if  bit8_band(j,10) == 0 and (
									math.floor(c[0]/2) + math.floor(c[1]/2 ) + math.floor(c[2]/2) + math.floor(c[3]/2) + math.floor(c[4]/22) + math.floor(c[5]/2) + 
									math.floor(c[6]/2) + math.floor(c[7]/2) + math.floor(c[8]/2)+ math.floor(c[9]/2) +
									math.floor(c[10]/2) + math.floor(c[11]/2) + math.floor(c[12]/2) + math.floor(c[13]/2) + math.floor(c[14]/2) + math.floor(c[15]/2) + 
									math.floor(c[16] /2) + math.floor(c[17] /2) + math.floor(c[18] /2)+ math.floor(c[19] /2)  +
									math.floor(c[20] /2) + math.floor(c[21] /2) + math.floor(c[22] /2) + math.floor(c[23] /2) +
									math.floor(c[24] /2) + math.floor(c[25] /2) + math.floor(c[26] /2) + math.floor(c[27] /2) +
									math.floor(c[28] /2) + math.floor(c[29] /2) + math.floor(c[30] /2) + math.floor(c[31] /2) +
									math.floor(c[32] /2) + math.floor(c[33] /2) 
									== 7
								) then
		return true
	end
	if j >= 0x10 then --字牌四张
		return false
	end
	if bit8_band(j,2) > 0 then -- 缺少字牌
		return false
	end
	local n00 = c[0]  + c[3]   + c[6] 
	local n01 = c[1]  + c[4]   + c[7]
	local n02 = c[2]  + c[5]   + c[8]
	local n10 = c[9]  + c[12]  + c[15]
	local n11 = c[10] + c[13]  + c[16]
	local n12 = c[11] + c[14]  + c[17]
	local n20 = c[18] + c[21]  + c[24]
	local n21 = c[19]  +c[22]  + c[25]	
	local n22 = c[20]  +c[23]  + c[26]	
	--print("isAgari n00 ~ n22:", n00,n01,n02,n10,n11,n12,n20,n21,n22)
	local n0 = (n00 + n01 + n02) % 3
	if (n0 == 1) then
		return false
	end
	local n1 = (n10 + n11 + n12) % 3
	if (n1 == 1) then
		return false
	end
	local n2 = (n20 + n21 + n22) % 3
	if (n2 == 1) then
		return false
	end
	--print((n0 /2)  + (n1 /2) + (n3 /2) + (c[27] /2) + (c[28] /2) + (c[29] /2) + (c[30] /2) + (c[31] /2) + (c[32] /2) + (c[33] /2))
	-- if ((n0 /2)  + (n1 /2) + (n2 /2) + (c[27] /2) + (c[28] /2) + (c[29] /2) + (c[30] /2) + (c[31] /2) + (c[32] /2) + (c[33] /2)) ~= 1 then -- 将
	-- 	return false
	-- end
	--print("isAgari n0,n1,n2:",n0,n1,n2)
	local nn0 = (n00 * 1 + n01 * 2) % 3
	local m0  = cc2m(c, 0)
	local nn1 = (n10 * 1 + n11 * 2) % 3
	local m1  = cc2m(c, 9)
	local nn2 = (n20 * 1 + n21 * 2) % 3
	local m2  = cc2m(c, 18)	
	--print("isAgari nn0 m0~ nn2 m2:", nn0,m0,nn1,m1,nn2,m2)
	--print(bit8_band(j, 4))
	if(bit8_band(j, 4) > 0) then
		--print(bit8_or(n0 , nn0 , n1 , nn1 , n2 , nn2))
		--print(isMentsu(m0))
		--print(isMentsu(m1))
		--print(isMentsu(m2))
		return  bit8_or(n0 , nn0 , n1 , nn1 , n2 , nn2) == 0 and isMentsu(m0) and isMentsu(m1) and isMentsu(m2)
	end
	if (n0 == 2 ) then
		return  bit8_or(n1 , nn1 , n2 , nn2) == 0  and isMentsu(m1) and isMentsu(m2)  and isAtamaMentsu(nn0, m0, changsha)
	end
	if (n1 == 2) then
		return bit8_or(n2 , nn2 , n0 , nn0) == 0 and isMentsu(m2) and isMentsu(m0)  and isAtamaMentsu(nn1, m1, changsha)
	end	
	if (n2 == 2) then
		return  bit8_or(n0 , nn0 , n1 , nn1) == 0 and isMentsu(m0) and isMentsu(m1)  and isAtamaMentsu(nn2, m2, changsha)
	end		

	return false
end




local function isMentsu_zi(c)
	local need = 0
	for i = 27 , 33 do
		if c[i] == 1 then
			need = need + 2
		elseif c[i] == 2 then
			need = need + 1
		elseif c[i] == 3 then
		end
	end
	return need
end

local function num_lazi(c)
	local lazi = c[31]
	c[31] = 0
	return lazi
end
local function set_lazi(c, lazi)
	c[31] = lazi
end


local function need_lazi(c, lazi)
	--local m0 = cc2m(c, 0)
	--local m1 = cc2m(c, 9)
	--local m2 = cc2m(c, 18)

	local needWan  = isMentsu_need(c)
	if needWan > lazi then
		return false
	end
	local needBing = isMentsu_need(c)
	if needWan + needBing > lazi then
		return false
	end
	local needSuo  = isMentsu_need(c)	
	if needWan + needBing + needSuo > lazi then
		return false
	end
	local needZi   = isMentsu_zi(c)
	if needWan + needBing + needSuo + needZi > lazi then
		return false
	end		

	return true
end
local function sub_jiang(c, changsha, isLazi)
	if isLazi then
		local lazi = num_lazi(c)
		if lazi > 0 then
			for i = 0 , 2 do
				for j = 0 , 8 do
					local current = c[ 9 * i + j]
					if current >  0 then
						for k = 0 , 2  do
							c[ 9 * i + j] = c[ 9 * i + j] - k
							local jiangLazi = 2 - k
							print(jiangLazi,lazi )
							if jiangLazi <= lazi then 
								print("----->",jiangLazi,lazi )
								local hu = false
								if ((changsha == true and  (j == 1 or j == 4 or j == 7) and  need_lazi(c, lazi - jiangLazi)) or (changsha == false and need_lazi(c, lazi - jiangLazi))) then
									print(" can hu")
									hu = true
									print("k",k)
									--return true
								end
								c[ 9 * i + j] = c[ 9 * i + j] + k
								if hu then

									local str = "[ "
									for pos = 0 , 33 do
										str = str..tostring(c[pos])..","
									end
									str = str.." ] : ".. (9 * i + j)
									print(str)

									set_lazi(c, lazi)
									return true
								end
							end

						end
					end
				end
			end
		end
		set_lazi(c, lazi)
	else
		if isAgari(c, changsha) then
			return true
		end
	end
	
	return false
end


local majiangId = 
    {11,12,13,14,15,16,17,18,19,
     21,22,23,24,25,26,27,28,29,
     31,32,33,34,35,36,37,38,39,
     41,42,43,44,45,46,47
    }
local majiangNum = {
        [0] = 0,0,0,0,0,0,0,0,0, --万
              0,0,0,0,0,0,0,0,0, --筒
              0,0,0,0,0,0,0,0,0, --条
              0,0,0,0,0,0,0  -- 东  南 西 北 中 发 白
    }

--麻将类型列转化为数字列
function mjIdToNumVer( majiangLs )

	local sumLs = {}
    for i=1, #majiangLs do
        local id = majiangLs[i]
        if(not sumLs[id])then sumLs[id] = 0 end
        sumLs[id] = sumLs[id] + 1
    end

    local numLs = {[0] = 0}
    for i=0,33 do
        if(sumLs[majiangId[i+1]])then
            numLs[i] = sumLs[majiangId[i+1]]
        else
        	numLs[i] = 0
        end
    end

    return numLs
end

--麻将数字列转化为类型列
function numVerToMjId( numLs)
	local majiangLs = {}
	for i=0,33 do
		if(numLs[i] > 0)then
			table.insert(majiangLs,majiangId[i+1])
		end
	end
	return majiangLs
end


function getTingPai( hasMajiang ,isChangsha,isLazi)
	-- 手头 13 张牌 可以杠碰吃
 	local majing = hasMajiang

 -- 	local str = ""
 -- 	for i=0,33 do
 -- 		if(i == 0 or i%9 ~= 0)then 
 -- 			str = str..majing[i]..","
 -- 		else
 -- 			print(str)
 -- 			str = majing[i]..","
 -- 		end
	-- end
	-- print(str)

   	local tingLs = {
		[0] = 0,0,0,0,0,0,0,0,0, --万
 	  		  0,0,0,0,0,0,0,0,0, --筒
     		  0,0,0,0,0,0,0,0,0, --条
     		  0,0,0,0,0,0,0  -- 东  南 西 北 中 发 白
   	}

	for i = 0 , 33 do
		if majing[i] < 4 then
			majing[i] = majing[i] + 1
			if sub_jiang(majing, isChangsha,isLazi) then
				tingLs[i] = tingLs[i] + 1
				if i < 9 then
					print("ting",i+1,"wan")
				elseif i < 18 then
					print("ting",i+1 - 9 ,"tong")
				elseif i <  27 then
					print("ting",i+1 - 18 ,"tiao")
				elseif i == 31 then
					print("ting hongzhong")
				else
					print("ting",i+1)
				end
			end
			majing[i] = majing[i] - 1
		end
	end

	local idLs = {}
	for i=0,33 do
		if(tingLs[i] > 0)then
			table.insert(idLs,majiangId[i+1])
		end
	end
	return idLs
end


--test
local cards = {11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14}
-- local cards = {11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 18}
-- local cards = {11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14}
local numLs = mjIdToNumVer(cards)
local result = getTingPai(numLs, false, nil)
print("=============")
for k,v in pairs(result) do
    print(k,v)
end