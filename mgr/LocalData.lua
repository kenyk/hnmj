--
-- Author: LXL
-- Date: 2016-11-17 18:24:31
--

--data = {_is_music_enable 背景音乐
			-- _is_sound_enable 音效
			-- _is_music_volume 音乐音量
			-- _is_sound_volume 音效音量
            --user_info 用户信息
--		}



LocalData = {}
--the game data that should save
--LocalData.data = {user_info = ""}
LocalData.data = {_is_music_enable = true, _is_sound_enable = true}
--the game data that needn't to save

function serialize(obj)
	local lua = ""
	local t = type(obj)
	if t == "number" then
		lua = lua .. obj
	elseif t == "boolean" then
		lua = lua .. tostring(obj)
	elseif t == "string" then
		lua = lua .. string.format("%q", obj)
	elseif t == "table" then
		lua = lua .. "{\n"		for k, v in pairs(obj) do
			lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"

		end
		local metatable = getmetatable(obj)
			if metatable ~= nil and type(metatable.__index) == "table" then
			for k, v in pairs(metatable.__index) do
				lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"
			end
		end
		lua = lua .. "}"
	elseif t == "nil" then
		return nil
	else
		error("can not serialize a " .. t .. " type.")
	end
	return lua
end

function unserialize(lua)
	local t = type(lua)
	if t == "nil" or lua == "" then
		return nil
	elseif t == "number" or t == "string" or t == "boolean" then
		lua = tostring(lua)
	else
		error("can not unserialize a " .. t .. " type.")
	end
	lua = "return " .. lua
	local func = loadstring(lua)
	if func == nil then
		return nil
	end
	return func()
end

function LocalData:encode()
	local content = serialize(LocalData.data)
	return content
end

function LocalData:decode(lua)
    local t = unserialize(lua)
    if t ~= nil then
        LocalData.data = t
    end
end

function LocalData:save()
	local content = self:encode()
	cc.UserDefault:getInstance():setStringForKey("my_game_data", content)
end

function LocalData:load()
	local content = cc.UserDefault:getInstance():getStringForKey("my_game_data")
	if content then
		self:decode(content)
	end
end

return LocalData