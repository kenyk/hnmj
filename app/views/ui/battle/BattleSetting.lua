

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
   HttpServiers:queryArticleList({
        appId = consts.appId,
        appCode = consts.appCode,
        clientFrom = consts.clientFrom[device.platform],
        artCat = "gamePlayNotice",
        -- artCat = "gameNotice",
    },
    function(entity,response,statusCode)
        if response and (response.status == 1 or response.errCode == 0) then
            if(response.data and response.data.list)then
                local urls = {}
                local titles = {}
                for i=1,#response.data.list do
                    table.insert(urls,response.data.list[i].url)
                    table.insert(titles,response.data.list[i].title)
                end
                -- if(#urls > 0)then UIMgr:openUI(consts.UI.HelpUI,nil,nil,{urls = urls,titles = titles})end
                if(#urls > 0)then NotifyMgr:push(consts.Notify.UPDATE_HELP_UI, {urls = urls,titles = titles})end
            end
        else
            --打开出错
            print("错误码：",response.errCode,"错误信息：",response.error)
        end
    end)
    UIMgr:openUI(consts.UI.HelpUI,nil,nil)
end

function BattleSetting:onClickClose()
    self:close()
end

function BattleSetting:onClickCheckOut()
    NotifyMgr:push(consts.Notify.DISMISS_ROOM, {disType=1,data={room_id = UserData.roomId,option=0}})
end

return BattleSetting




