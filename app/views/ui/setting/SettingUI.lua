
local SettingUI = class("SettingUI", cc.load("mvc").UIBase)
local roomId = ""
local index = 0

SettingUI.RESOURCE_FILENAME = "uiSetting/UI_Setting.csb"
SettingUI.RESOURCE_MODELNAME = "app.views.ui.setting.SettingModel"

local SwitchBtn = require "app.views.ui.common.SwitchBtn"

local ck_bg_num = 3

function SettingUI:onCreate(msg)
    self:setInOutAction()
    NotifyMgr:reg(consts.Notify.CONFIRM_DLALOG_CLOSE, self.close,self)
    self.bg = helper.findNodeByName(self.resourceNode_,"bg")
    self.mainBtn = helper.findNodeByName(self.resourceNode_,"btn_setting")
    self.mainBtn:setPressedActionEnabled(true)
    self.closeBtn = helper.findNodeByName(self.resourceNode_,"closeBtn")
    self.closeBtn:setPressedActionEnabled(true)
    self.btn_setting_text= helper.findNodeByName(self.resourceNode_,"btn_setting_text")
    self.fromType=msg.fromType
    if self.fromType=="main" then
        self.btn_setting_text:loadTexture("uires/setting/setting_btn_text_logout.png")
        self.btn_setting_text:setContentSize(cc.size(170,46))
    elseif self.fromType=="gameplay" then
        self.btn_setting_text:loadTexture("mj/btn_text_dismissroom.png")
        self.btn_setting_text:setContentSize(cc.size(240,46))
    end
    self.slider_music = helper.findNodeByName(self.resourceNode_,"slider_music")
    self.slider_sound_effect = helper.findNodeByName(self.resourceNode_,"slider_sound_effect")
    self.slider_music:addEventListener(handler(self,self.musicHandler))
    self.slider_sound_effect:addEventListener(handler(self,self.soundHandler))

    self.slider_music:setPercent(LocalData.data._is_music_volume)
    self.slider_sound_effect:setPercent(LocalData.data._is_sound_volume)

    self.btn_music      = helper.findNodeByName(self.resourceNode_,"btn_music")
    self.btn_music_di   = helper.findNodeByName(self.resourceNode_,"btn_music_0")
    self.btn_sound_effect       = helper.findNodeByName(self.resourceNode_,"btn_sound_effect")
    self.btn_sound_effect_di    = helper.findNodeByName(self.resourceNode_,"btn_sound_effect_0")

    -- self.btn_music:setVisible(AudioMgr:get_music_enable())
    -- self.btn_music_di:setVisible(not AudioMgr:get_music_enable())

    -- self.btn_sound_effect:setVisible(AudioMgr:get_sound_enable())
    -- self.btn_sound_effect_di:setVisible(not AudioMgr:get_sound_enable())

    -- self.checkBoxList = {}
    -- table.insert(self.checkBoxList,helper.findNodeByName(self.resourceNode_,"CheckBox_local"))
    -- table.insert(self.checkBoxList,helper.findNodeByName(self.resourceNode_,"CheckBox_common"))

    for i=1, ck_bg_num do
        self["ck_bg_"..i] = helper.findNodeByName(self.resourceNode_, "ck_bg_"..i)
        self["ck_bg_"..i]:getChildByName("tick"):setVisible(false)
        --self["ck_bg_"..i]:getChildByName("status"):setVisible(true)
    end
    local key = cc.UserDefault:getInstance():getStringForKey("setting_bg_type")
    if self[key] then
        self[key]:setSelected(true)
        self[key]:getChildByName("tick"):setVisible(true)
        --self[key]:getChildByName("status"):setString("正在使用")
    end

    self.FileNode_effect = helper.findNodeByName(self.resourceNode_, "FileNode_effect")
    self.FileNode_music = helper.findNodeByName(self.resourceNode_, "FileNode_music")
    self.FileNode_langue = helper.findNodeByName(self.resourceNode_, "FileNode_langue")

    self.sb_langue = SwitchBtn:create(handler(self, self.onLanguageHandler))
    self.sb_langue:setPosition(self.FileNode_langue:getPosition())
    self.FileNode_langue:setVisible(false)
    self.bg:addChild(self.sb_langue)

    self.sb_music = SwitchBtn:create(handler(self, self.musicHandler))
    self.sb_music:setPosition(self.FileNode_music:getPosition())
    self.FileNode_music:setVisible(false)
    self.bg:addChild(self.sb_music)

    self.sb_effect = SwitchBtn:create(handler(self, self.soundHandler))
    self.sb_effect:setPosition(self.FileNode_effect:getPosition())
    self.FileNode_effect:setVisible(false)
    self.bg:addChild(self.sb_effect)

    self:onSelectLanguage()
    self.sb_music:setState(AudioMgr:get_music_enable())
    self.sb_effect:setState(AudioMgr:get_sound_enable())
end

function SettingUI:onSelectLanguage()

    LocalData.data._language_type = LocalData.data._language_type or 0
    if LocalData.data._language_type > 1 or LocalData.data._language_type < 0 then
        print("err in language type !! value = ",LocalData.data._language_type)
        return
    end
    if 0 == LocalData.data._language_type then --方言
        self.sb_langue:setState(true)
    else
        self.sb_langue:setState(false)
    end
    -- self.checkBoxList[LocalData.data._language_type+1]:setSelected(true)
    -- self.checkBoxList[2-LocalData.data._language_type]:setSelected(false)
end

function SettingUI:onLanguageHandler(isOpen)
    -- local name = sender:getName()
    -- if name == "Panel_common" then
    --     LocalData.data._language_type = 1
    -- elseif name == "Panel_local" then
    --     LocalData.data._language_type = 0
    -- end
    if isOpen then --方言
        LocalData.data._language_type = 0
    else
        LocalData.data._language_type = 1
    end
    self:onSelectLanguage()
end

-- function SettingUI:musicHandler(sender,state)
function SettingUI:musicHandler(isOpen)
    -- if state == 2 then
    --     local Volume = sender:getPercent()
    --     AudioMgr:setMusicVolume(Volume)
    --     if(Volume > 0) then
    --         self:onMusicDi(nil,Volume)
    --     else
    --         self:onMusic(nil,Volume)
    --     end
    -- end
    if isOpen then
        self:onMusicDi()
    else
        self:onMusic()
    end
end

-- function SettingUI:soundHandler(sender,state)
function SettingUI:soundHandler(isOpen)
    -- if state == 2 then
    --     local Volume = sender:getPercent()
    --     --AudioMgr:setSoundsVolume(Volume)
    --     if(Volume > 0) then
    --         self:onSoundDi(nil,Volume)
    --     else
    --         self:onSound(nil,Volume)
    --     end
    -- end
    if isOpen then
        self:onSoundDi()
    else
        self:onSound()
    end
end

function SettingUI:onCloseBtnClick()
	self:close()
end

function SettingUI:onMainBtnClick()
    if self.fromType=="main" then
        LuaCallPlatformFun.deleteOauth()
        UserData.login=false
        UserData:clearData()
        LocalData.data.user_info = nil
        LocalData.data.thirdLoginData = nil
        LocalData:save()
        MyApp:goToMain()
    elseif self.fromType=="gameplay" then
        NotifyMgr:push(consts.Notify.DISMISS_ROOM, {disType=1,data={room_id = UserData.roomId,option=0}})
    end
    if self.close then
        self:close()
    end
end

function SettingUI:onMusic(sender, volume)
    volume = volume or 0
    -- self.btn_music:setVisible(false)
    -- self.btn_music_di:setVisible(true)
    -- self.slider_music:setPercent(volume)
    AudioMgr:setMusicVolume(volume)
    AudioMgr:set_music_enable(false)
end

function SettingUI:onMusicDi(sender, volume)
    volume = volume or 100
    -- self.btn_music:setVisible(true)
    -- self.btn_music_di:setVisible(false)
    -- self.slider_music:setPercent(volume)
    AudioMgr:setMusicVolume(volume)
    AudioMgr:set_music_enable(true)
end

function SettingUI:onSound(sender, volume)
    volume = volume or 0
    self.btn_sound_effect:setVisible(false)
    self.btn_sound_effect_di:setVisible(true)
    self.slider_sound_effect:setPercent(volume)
    AudioMgr:setSoundsVolume(volume)
    AudioMgr:set_sound_enable(false)
end

function SettingUI:onSoundDi(sender, volume)
    volume = volume or 100
	self.btn_sound_effect:setVisible(true)
    self.btn_sound_effect_di:setVisible(false)
    self.slider_sound_effect:setPercent(volume)
    AudioMgr:setSoundsVolume(volume)
    AudioMgr:set_sound_enable(true)
end

function SettingUI:onExit()
    SettingUI.super.onExit(self)
    NotifyMgr:unregWithObj(self)
    LocalData:save()
end

function SettingUI:onChangeBg(sender)
    print(sender:getName())
    for i = 1, ck_bg_num do
        self["ck_bg_"..i]:setSelected(false)
        self["ck_bg_"..i]:getChildByName("tick"):setVisible(false)
        --self["ck_bg_"..i]:getChildByName("status"):setString("点击使用")
    end
    self[sender:getName()]:setSelected(true)
    self[sender:getName()]:getChildByName("tick"):setVisible(true)
    --self[sender:getName()]:getChildByName("status"):setString("正在使用")
    cc.UserDefault:getInstance():setStringForKey("setting_bg_type", sender:getName())
    --更换麻将图
    display.removeSpriteFrames(UserData:getCurBgType().."/MahjongTile.plist", UserData:getCurBgType().."/MahjongTile.png")
    display.loadSpriteFrames(UserData:getCurBgType().."/MahjongTile.plist", UserData:getCurBgType().."/MahjongTile.png")
    NotifyMgr:push(consts.Notify.CHANGE_BG_TYPE)
end

return SettingUI