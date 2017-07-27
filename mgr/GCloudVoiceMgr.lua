--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

--腾讯语音
GCloudVoiceMgr = {}

--初始化
function GCloudVoiceMgr:init()
    if device.platform=="android" then
       if self.gCloudVoice == nil then
            self.gCloudVoice = gcv.GCloudVoiceHelper:getInstance()
       end
       if self.gCloudVoice then
          local uid= UserData.uid or tostring(os.time())
          self.gCloudVoice:initGCloudVoice(consts.GCloudVoice.GCLOUD_GAME_ID,consts.GCloudVoice.GCLOUD_GAME_KEY,uid)
       end
    else
      LuaCallPlatformFun.initRecordVoice()
    end
end

--录音开始(离线)
function GCloudVoiceMgr:beginRecordVoice()
    if self.gCloudVoice then
       AudioMgr:pauseMusic()
       self.gCloudVoice:beginRecordVoice()
    end
end

--录音结束(离线)
function GCloudVoiceMgr:endRecordVoice()
    if self.gCloudVoice then
       self.gCloudVoice:endRecordVoice()
       AudioMgr:resumeMusic()
    end
end

--中断录音(离线)
function GCloudVoiceMgr:breakRecordVoice()
    if self.gCloudVoice then
       self.gCloudVoice:breakRecordVoice()
       AudioMgr:resumeMusic()
    end
end

--实时语音开
function GCloudVoiceMgr:openRealTimeVoice(roomId)
    if self.gCloudVoice then
       self.gCloudVoice:openRealTimeVoice(roomId)
    end
end

--实时语音关
function GCloudVoiceMgr:closeRealTimeVoice()
    if self.gCloudVoice then
       self.gCloudVoice:closeRealTimeVoice()
    end
end

--播放语音
function GCloudVoiceMgr:playVoiceById(fileId)
    if self.gCloudVoice then
       self.gCloudVoice:playVoiceById(fileId)
    end
end

--暂停语音
function GCloudVoiceMgr:stopVoice()
    if self.gCloudVoice then
       self.gCloudVoice:stopVoiceById()
    end
end

return GCloudVoiceMgr