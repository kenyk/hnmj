

local BattleSetting = class("BattleSetting", cc.load("mvc").UIBase)

BattleSetting.RESOURCE_FILENAME = "uiBattle/ui_battle_rule.csb"
local OFFSETX = 270

function BattleSetting:onCreate()
    helper.findNodeByName(self.resourceNode_,"Btn_close"):setPressedActionEnabled(true)
    helper.findNodeByName(self.resourceNode_,"Btn_set"):setPressedActionEnabled(true)
    helper.findNodeByName(self.resourceNode_,"Btn_help"):setPressedActionEnabled(true)
    helper.findNodeByName(self.resourceNode_,"Btn_checkout"):setPressedActionEnabled(true)

    helper.findNodeByName(self.resourceNode_,"Image_1"):loadTexture("mj/"..UserData:getCurBgType().."/battle_img_mask.png")
    NotifyMgr:reg(consts.Notify.CHANGE_BG_TYPE, self.onChangeBgType, self)
end

function BattleSetting:onChangeBgType()
    helper.findNodeByName(self.resourceNode_,"Image_1"):loadTexture("mj/"..UserData:getCurBgType().."/battle_img_mask.png")
end

function BattleSetting:onExit()
    NotifyMgr:unregWithObj(self)
end

function BattleSetting:onDialogOutsideClick()
    self:close()
end

function BattleSetting:onClickSetting()
    UIMgr:openUI(consts.UI.SettingUI,nil,nil,{fromType="gameplay"})
end

function BattleSetting:onClickHelp()
    UIMgr:openUI(consts.UI.HelpUI,nil,nil)
end

function BattleSetting:onClickClose()
    self:close()
end

function BattleSetting:onClickCheckOut()
    NotifyMgr:push(consts.Notify.DISMISS_ROOM, {disType=1,data={room_id = UserData.roomId,option=0}})
end

return BattleSetting




