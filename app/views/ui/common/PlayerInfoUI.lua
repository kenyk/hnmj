--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

local PlayerInfoUI = class("PlayerInfoUI", cc.load("mvc").UIBase)

PlayerInfoUI.RESOURCE_FILENAME = "common/UI_Player_Info.csb"

function PlayerInfoUI:onCreate()
    self.iPlayerAvatar = helper.findNodeByName(self.resourceNode_, "iPlayerAvatar")
    self.txPlayerName = helper.findNodeByName(self.resourceNode_, "txPlayerName")
    self.txPlayerAccount = helper.findNodeByName(self.resourceNode_, "txPlayerAccount")
    self.txPlayerIP = helper.findNodeByName(self.resourceNode_, "txPlayerIP")
end

function PlayerInfoUI:show(playerInfo)
    if not playerInfo then
        return
    end

    self.txPlayerName:setString(playerInfo.nickname)
    self.txPlayerAccount:setString("账号: " .. playerInfo.uid)
    self.txPlayerIP:setString(Is_App_Store and "" or "地址: " .. playerInfo.ip or "")
    if(Is_App_Store)then
        local image = display.newSprite("uires/main/guest_icon_1.png", 1, 19)
        image:setPosition(cc.p(50,47))
        image:setScale(1.42)
        image:addTo(self.iPlayerAvatar)
    elseif  playerInfo.image_url then
        local image = NetSprite:getSpriteUrl(playerInfo.image_url,"mj/bg_default_avatar_2.png")
        image:setPosition(cc.p(50,47))
        image:setImageContentSize(cc.size(100,100))
        image:addTo(self.iPlayerAvatar)
        local border = display.newSprite("uires/main/main_playerFrame.png")
        border:setAnchorPoint(cc.p(0,0))
        border:setPosition(cc.p(-2, -8))
        border:setScaleX(1.2)
        border:setScaleY(1.22)
        border:addTo(image)
    end

    local picName = "uires/common/female.png"
    if tonumber(playerInfo.gender)  == 1 then
        picName = "uires/common/male.png"
    end

    local pos = cc.p(self.txPlayerName:getPosition())
    local nameLen = self.txPlayerName:getContentSize().width
    pos.x = pos.x+nameLen+10
    local sexImg = display.newSprite(picName, pos.x, pos.y-2)
                   :setAnchorPoint(cc.p(0,0))
                   :addTo(self.resourceNode_)

end

return PlayerInfoUI;
