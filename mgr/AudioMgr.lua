
AudioMgr = {}
AudioMgr.curMusicName = ""

function AudioMgr:playMusic()
	if LocalData.data._is_music_enable and LocalData.data._is_music_volume > 0 then
		audio.stopMusic()
		if UserData.isInGame then
			audio.playMusic("audio/bgm/battle.mp3", true)
			AudioMgr.curMusicName = "battle.mp3"
		else
			audio.playMusic("audio/bgm/main.mp3", true)
			AudioMgr.curMusicName = "main.mp3"
		end
	end
end

function AudioMgr:changeTingMusic()
	if LocalData.data._is_music_enable and LocalData.data._is_music_volume > 0 then
		audio.stopMusic()
		audio.playMusic("audio/bgm/ting_bgm.mp3", true)
		AudioMgr.curMusicName = "ting_bgm.mp3"
	end
end

function AudioMgr:set_music_enable(benable)
	LocalData.data._is_music_enable = benable
	if not benable then
		audio.stopMusic()
	else
		self:playMusic()
	end
end

function AudioMgr:get_music_enable()
	return LocalData.data._is_music_enable
end

function AudioMgr:set_sound_enable(benable)
	LocalData.data._is_sound_enable = benable
	if not benable then
		audio.stopAllSounds()
	end
end

function AudioMgr:get_sound_enable()
	return LocalData.data._is_sound_enable
end

function AudioMgr:getMusicVolume()
    return audio.getMusicVolume()
end

function AudioMgr:setMusicVolume(volume)
	LocalData.data._is_music_volume = volume or LocalData.data._is_music_volume or 100
	audio.setMusicVolume(LocalData.data._is_music_volume/100)
	-- if LocalData.data._is_music_volume == 0 then
	-- 	audio.stopMusic()
 --    end
    LocalData:save()
end

function AudioMgr:getSoundsVolume()
    return audio.getSoundsVolume()
end

function AudioMgr:setSoundsVolume(volume)
	LocalData.data._is_sound_volume = volume or LocalData.data._is_sound_volume or 100
    audio.setSoundsVolume(LocalData.data._is_sound_volume/100)
    -- if LocalData.data._is_sound_volume == 0 then
    -- 	audio.stopAllSounds()
    -- end
    LocalData:save()
end

function AudioMgr:on_mahjong()
	if UserData.isSkipAnimate then return end
	if LocalData.data._is_sound_enable and LocalData.data._is_sound_volume > 0 then
		audio.playSound("audio/effect/dianjipai.mp3")
	end
end

function AudioMgr:on_out()
	if UserData.isSkipAnimate then return end
	if LocalData.data._is_sound_enable and LocalData.data._is_sound_volume > 0 then
		audio.playSound("audio/effect/out.mp3")
	end
end

function AudioMgr:getHumanSoundPath(sex)   
    local path = ""
    LocalData.data._language_type = LocalData.data._language_type or 0
    if LocalData.data._language_type == 0 then
        path = tonumber(sex) == 1 and "audio/man_changsha/" or "audio/woman_changsha/"
    elseif LocalData.data._language_type == 1 then
        path = tonumber(sex) == 1 and "audio/man/" or "audio/woman/"
    end
    return path
end

function AudioMgr:on_peng(sex)
	if UserData.isSkipAnimate then return end
	if LocalData.data._is_sound_enable and LocalData.data._is_sound_volume > 0 then
		local curSex = sex or UserData.userInfo.gender
		local defaultPath = AudioMgr:getHumanSoundPath(curSex)
		audio.playSound(defaultPath.."effect/peng.mp3")
	end
end

function AudioMgr:on_gang(sex)
	if UserData.isSkipAnimate then return end
	if LocalData.data._is_sound_enable and LocalData.data._is_sound_volume > 0 then
		local curSex = sex or UserData.userInfo.gender
		local defaultPath = AudioMgr:getHumanSoundPath(curSex)
		audio.playSound(defaultPath.."effect/gang.mp3")
	end
end

function AudioMgr:on_hu(sex,hu_type)
	if UserData.isSkipAnimate or UserData.isInReplayScene then return end
	if LocalData.data._is_sound_enable and LocalData.data._is_sound_volume > 0 then
		local curSex = sex or UserData.userInfo.gender
		local defaultPath = AudioMgr:getHumanSoundPath(curSex)

		if(hu_type and tonumber(hu_type) == 3)then
			audio.playSound(defaultPath.."effect/qiangganghu.mp3")
		elseif(hu_type and tonumber(hu_type) == 1)then
			audio.playSound(defaultPath.."effect/zimo.mp3")
		else
			audio.playSound(defaultPath.."effect/hu.mp3")
		end
	end
end

--胡牌类型音效
function AudioMgr:on_hu_type(typeStr,sex)
	if UserData.isSkipAnimate then return end
	if(not typeStr)then return end
	if LocalData.data._is_sound_enable and LocalData.data._is_sound_volume > 0 then
		local curSex = sex or UserData.userInfo.gender
		local defaultPath = AudioMgr:getHumanSoundPath(curSex)
		audio.playSound(defaultPath.."hu_type/"..typeStr..".mp3")
		-- local filename = defaultPath.."hu_type/"..typeStr..".mp3"
		-- local voicePath = cc.FileUtils:getInstance():fullPathForFilename(filename)
		-- if(io.Exists(voicePath))then
		-- 	audio.playSound(voicePath)
		-- else
		-- 	AudioMgr:on_hu(sex,2)
		-- end
	end
end

function AudioMgr:on_Bu(sex)
	if UserData.isSkipAnimate then return end
	if LocalData.data._is_sound_enable and LocalData.data._is_sound_volume > 0 then
		local curSex = sex or UserData.userInfo.gender
		local defaultPath = AudioMgr:getHumanSoundPath(curSex) 
		audio.playSound(defaultPath.."effect/bu.mp3")
	end
end

function AudioMgr:on_chi(sex)
	if UserData.isSkipAnimate then return end
	if LocalData.data._is_sound_enable and LocalData.data._is_sound_volume > 0 then
		local curSex = sex or UserData.userInfo.gender
		local defaultPath = AudioMgr:getHumanSoundPath(curSex)
		audio.playSound(defaultPath.."effect/chi.mp3")
	end
end

function AudioMgr:choseMj(sex)
	if UserData.isSkipAnimate then return end
	if LocalData.data._is_sound_enable and LocalData.data._is_sound_volume > 0 then
		audio.playSound(defaultPath.."effect/chi.mp3")
	end
end

function AudioMgr:on_mahjong_tile(tile_id,sex)
	if UserData.isSkipAnimate then return end
	if LocalData.data._is_sound_enable and LocalData.data._is_sound_volume > 0 then
		local sid = tile_id % 10
		local lid = (tile_id - sid) / 10

		local curSex = sex or UserData.userInfo.gender
		local defaultPath = AudioMgr:getHumanSoundPath(curSex)
		if lid == 1 then
			audio.playSound(defaultPath .. "wan/wan" .. sid .. ".mp3")
		elseif lid == 2 then
			audio.playSound(defaultPath .. "tong/tong" .. sid .. ".mp3")
		elseif lid == 3 then
			audio.playSound(defaultPath .. "tiao/tiao" .. sid .. ".mp3")
		elseif lid == 4 then
			audio.playSound(defaultPath .. "zi/zi" .. sid .. ".mp3")
		end
		-- audio.playSound("audio/effect/chupai.mp3")
	end	
end

function AudioMgr:on_mahjong_played()
	if UserData.isSkipAnimate then return end
	if LocalData.data._is_sound_enable and LocalData.data._is_sound_volume > 0 then
		-- local sid = tile_id % 10
		-- local lid = (tile_id - sid) / 10

		-- local curSex = sex or UserData.userInfo.gender
		-- local defaultPath = AudioMgr:getHumanSoundPath(curSex)
		-- if lid == 1 then
		-- 	audio.playSound(defaultPath .. "wan/wan" .. sid .. ".mp3")
		-- elseif lid == 2 then
		-- 	audio.playSound(defaultPath .. "tong/tong" .. sid .. ".mp3")
		-- elseif lid == 3 then
		-- 	audio.playSound(defaultPath .. "tiao/tiao" .. sid .. ".mp3")
		-- elseif lid == 4 then
		-- 	audio.playSound(defaultPath .. "zi/zi" .. sid .. ".mp3")
		-- end
		audio.playSound("audio/effect/chupai2.mp3")
	end	
end
--超时
function AudioMgr:on_overTime()
	if UserData.isSkipAnimate then return end
	if LocalData.data._is_sound_enable and LocalData.data._is_sound_volume > 0 then
		audio.playSound("audio/effect/daojishi.mp3")
	end	
end

function AudioMgr:onChatMsg(index,sex)
	if LocalData.data._is_sound_enable and LocalData.data._is_sound_volume > 0 then
		local defaultPath = AudioMgr:getHumanSoundPath(sex)
		audio.playSound(defaultPath .. "chat/" .. index .. ".mp3")
	end	
end

function AudioMgr:init()
	self:setMusicVolume()
	self:setSoundsVolume()
end

function AudioMgr:pauseMusic()
    audio.pauseMusic()
end

function AudioMgr:resumeMusic()
    audio.resumeMusic()
end

function AudioMgr:stopAudio()
	audio.stopMusic()
	audio.stopAllSounds()
end

function AudioMgr:resumeAudio()
	if LocalData.data._is_music_enable and LocalData.data._is_music_volume > 0 then
		audio.resumeMusic()
		if UserData.isInGame then
			audio.playMusic("audio/bgm/battle.mp3", true)
		else
			audio.playMusic("audio/bgm/main.mp3", true)
		end
	end
	if LocalData.data._is_sound_enable and LocalData.data._is_sound_volume > 0 then
		audio.resumeAllSounds()
	end	
	
end

return AudioMgr