local MainScene = class("MainScene", cc.load("mvc").ViewBase)
local net = require "net.net"

function MainScene:onCreate()
    UserData.isInGame = false
    math.randomseed(os.time())
    if UserData.login then
        UIMgr:openUI(consts.UI.mainUI,nil,self)
    else
        UIMgr:openUI(consts.UI.login,nil,self)
    end
  -- local image = NetSprite:getSpriteUrl(self,"http://preview.quanjing.com/fo011/fo-7445308.jpg","btn_green.png")
  -- self:addChild(image)
    AudioMgr:playMusic()
end

function MainScene:onEnter()
    print("main scene on enter")
end

return MainScene