--
-- Author: LXL
-- Date: 2016-11-03 16:13:47
--
local GameMainUI = class("GameMainUI", cc.load("mvc").UIBase)
local PlayerInfoUI = require(consts.UI.PlayerInfoUI);
local AnimationView = require("utils.extends.AnimationView")
GameMainUI.RESOURCE_FILENAME = "UI_Main.csb"
GameMainUI.RESOURCE_MODELNAME = "app.views.ui.main.GameMainModel"

function GameMainUI:PrintTable( tbl , level, filteDefault)
  local msg = ""
  filteDefault = filteDefault or true --默认过滤关键字（DeleteMe, _class_type）
  level = level or 1
  local indent_str = ""
  for i = 1, level do
    indent_str = indent_str.."  "
  end

  print(indent_str .. "{")
  for k,v in pairs(tbl) do
    if filteDefault then
      if k ~= "_class_type" and k ~= "DeleteMe" then
        local item_str = string.format("%s%s = %s", indent_str .. " ",tostring(k), tostring(v))
        print(item_str)
        if type(v) == "table" then
          self:PrintTable(v, level + 1)
        end
      end
    else
      local item_str = string.format("%s%s = %s", indent_str .. " ",tostring(k), tostring(v))
      print(item_str)
      if type(v) == "table" then
        PrintTable(v, level + 1)
      end
    end
  end
  print(indent_str .. "}")
end

function GameMainUI:onCreate()
    GMainUi = self
    display.loadSpriteFrames(UserData:getCurBgType().."/MahjongTile.plist", UserData:getCurBgType().."/MahjongTile.png")
    --左边人物动画
    -- local aniLeftGril = AnimationView:create("female","action/female.csb")
    -- local aniLeftGril = AnimationView:create("female","action/newFemaleLeft.csb")
    -- local aniLeftGril = AnimationView:create("female","action/newRoleAniLeft.csb")
    -- aniLeftGril:setPosition(cc.p(460,330))
    -- aniLeftGril:gotoFrameAndPlay(0,true)
    --aniLeftGril:addTo(self,1)

    --self.aniLeftGril = display.newSprite("uires/main/main_female.png", 509,437):addTo(self,1)
    ccui.ImageView:create("uires/main/main_male.png"):addTo(self, 1):setPosition(cc.p(460,330))

    --红色按钮底
    ccui.ImageView:create("uires/main/button_chuangjianfangjian.png"):addTo(self, 1):setPosition(cc.p(270,210)):setAnchorPoint(cc.p(0, 0.5))
    --创建房间
    self.backImage = display.newSprite("uires/main/main_back.png", 485-30,210):addTo(self,1)
    print("UserData is ======")
    print(UserData)
    self:PrintTable(UserData)
    -- if(UserData.isAddClub)then
    --    self.createImage = display.newSprite("uires/main/main_create_2.png", 485-30,210):addTo(self,1)
    -- else
    --     self.createImage = display.newSprite("uires/main/main_create.png", 485-30,210):addTo(self,1)
    -- end
    self.createImage = display.newSprite("uires/main/main_create.png", 485-30,210):addTo(self,1)
    --闪光
    local lightPos = cc.p(425,225)
    local clipStencil = cc.Node:create()         --模板
    local clippingNode = cc.ClippingNode:create(clipStencil)    
    clippingNode:setInverted(false);
    clippingNode:setAlphaThreshold(0.5)
    clippingNode:addTo(self,1)
    local imgMask = display.newSprite("uires/main/main_btn_mask.png",0,0) 
    imgMask:setPosition(lightPos)
    local sizeMask = imgMask:getContentSize()
    clipStencil:addChild(imgMask)
    local imgLight = display.newSprite("uires/main/main_btn_light.png") 
    imgLight:setPosition(cc.p(lightPos.x-sizeMask.width/2-100,lightPos.y))
    clippingNode:addChild(imgLight)
    imgLight:setVisible(false)

    --骰子动画
    -- local aniCreateBtn = AnimationView:create("female","action/createRoom.csb")
    -- aniCreateBtn:setPosition(cc.p(280,230))    
    -- aniCreateBtn:addTo(self,1)
    --ccui.ImageView:create("uires/main/touzi.png"):addTo(self, 2):setPosition(cc.p(330,230))

    local seqAction = cc.Sequence:create({cc.MoveTo:create(1.5, cc.p(lightPos.x+sizeMask.width/2+100,lightPos.y)),                                            
                                          cc.CallFunc:create(function()
                                                -- aniCreateBtn:gotoFrameAndPlay(0,false)
                                                imgLight:setPosition(cc.p(lightPos.x-sizeMask.width/2-100,lightPos.y))
                                            end),
                                          cc.DelayTime:create((20/24)+1.5+(20/24)) })
    imgLight:runAction(cc.Repeat:create(seqAction,cc.REPEAT_FOREVER))

    
    --右边人物动画
    -- local aniRightBoy = AnimationView:create("female","action/male.csb")
    -- local aniRightBoy = AnimationView:create("female","action/newFemaleRight.csb")
    -- local aniRightBoy = AnimationView:create("female","action/newRoleAniRight.csb")
    -- aniRightBoy:setPosition(cc.p(936,330))
    -- aniRightBoy:gotoFrameAndPlay(0,true)
    --aniRightBoy:addTo(self,1)
    --self.aniRightBoy = display.newSprite("uires/main/main_male.png", 509,437):addTo(self,1)
    ccui.ImageView:create("uires/main/main_female.png"):addTo(self, 1):setPosition(cc.p(936,330))
    --蓝色按钮底
    ccui.ImageView:create("uires/main/button_jiarufangjian.png"):addTo(self, 1):setPosition(cc.p(760,210)):setAnchorPoint(cc.p(0, 0.5))

    --加入房间
    local imgAddWord = display.newSprite("uires/main/main_join.png", 975-30,210):addTo(self,1)

    --闪光
    local lightPosR = cc.p(936,228)
    local clipStencilR = cc.Node:create()         --模板
    local clippingNodeR = cc.ClippingNode:create(clipStencilR)    
    clippingNodeR:setInverted(false);
    clippingNodeR:setAlphaThreshold(0.5)
    clippingNodeR:addTo(self,1)
    local imgMaskR = display.newSprite("uires/main/main_btn_mask.png",0,0) 
    imgMaskR:setPosition(lightPosR)
    local sizeMaskR = imgMaskR:getContentSize()
    clipStencilR:addChild(imgMaskR)

    local imgLightR = display.newSprite("uires/main/main_btn_light.png") 
    imgLightR:setPosition(cc.p(lightPosR.x-sizeMaskR.width/2-100,lightPosR.y))
    clippingNodeR:addChild(imgLightR)
    imgLightR:setVisible(false)

    -- local aniAddBtn = AnimationView:create("female","action/addRoom.csb")
    -- aniAddBtn:setPosition(cc.p(792,235))    
    -- aniAddBtn:addTo(self,1)
    --发
    --ccui.ImageView:create("uires/main/majiang.png"):addTo(self, 1):setPosition(cc.p(820,215))

    seqAction = cc.Sequence:create({        cc.DelayTime:create(1.5+(20/24)), 
                                            cc.MoveTo:create(1.5, cc.p(lightPosR.x+sizeMaskR.width/2+100,lightPosR.y)),                                             
                                            cc.CallFunc:create(function()
                                                -- aniAddBtn:gotoFrameAndPlay(0,false)
                                                imgLightR:setPosition(cc.p(lightPosR.x-sizeMaskR.width/2-100,lightPosR.y))
                                            end),
                                            cc.DelayTime:create(20/24)})
                                                                                        
    imgLightR:runAction(cc.Repeat:create(seqAction,cc.REPEAT_FOREVER))


    self.mainBuyBtn = helper.findNodeByName(self.resourceNode_,"mainBuyBtn")
    self.mainMsgBtn = helper.findNodeByName(self.resourceNode_,"mainMsgBtn")
    self.mainHelpBtn = helper.findNodeByName(self.resourceNode_,"mainHelpBtn")
    self.mainSetBtn = helper.findNodeByName(self.resourceNode_,"mainSetBtn")
    self.mainShareBtn = helper.findNodeByName(self.resourceNode_,"mainShareBtn")
    self.mainActivityBtn = helper.findNodeByName(self.resourceNode_,"mainActivityBtn")
    self.mainRecirdBtn = helper.findNodeByName(self.resourceNode_,"mainRecirdBtn")
    self.mainPiLiang = helper.findNodeByName(self.resourceNode_,"mainPiLiang")
    self.mainGiveCardBtn = helper.findNodeByName(self.resourceNode_,"mainGiveBtn")
    self.mainBuyBtn:setPressedActionEnabled(true)
    self.mainMsgBtn:setPressedActionEnabled(true)
    self.mainHelpBtn:setPressedActionEnabled(true)
    self.mainHelpBtn:setVisible(not Is_App_Store)
    self.mainSetBtn:setPressedActionEnabled(true)
    self.mainShareBtn:setPressedActionEnabled(true)
    self.mainActivityBtn:setPressedActionEnabled(true)
    self.mainRecirdBtn:setPressedActionEnabled(true)
    self.mainGiveCardBtn:setPressedActionEnabled(true)
    self.mainGiveCardBtn:setVisible(false)
    self.mainRCLabel = helper.findNodeByName(self.resourceNode_,"mainRCLabel")
    self.mainIcon = helper.findNodeByName(self.resourceNode_,"mainIcon")
    self.Panel_motan = helper.findNodeByName(self.resourceNode_,"Panel_motan")

    -- self.mainPdkBtn = helper.findNodeByName(self.resourceNode_,"mainPdkBtn")
    -- self.mainHbmjBtn = helper.findNodeByName(self.resourceNode_,"mainHbmjBtn")
    -- self.mainGdmjBtn = helper.findNodeByName(self.resourceNode_,"mainGdmjBtn")
    -- self.mainPdkBtn:setPressedActionEnabled(true)
    -- self.mainHbmjBtn:setPressedActionEnabled(true)
    -- self.mainGdmjBtn:setPressedActionEnabled(true)
    
    if(not Is_App_Store)then
        self.mainIcon:loadTexture("mj/bg_default_avatar_2.png")
    end

    self.mainName = helper.findNodeByName(self.resourceNode_,"mainName")
    self.mainUserID = helper.findNodeByName(self.resourceNode_,"mainUserID")
    self.mainBLabel = helper.findNodeByName(self.resourceNode_,"mainBLabel")
    self.notice_lab_1 = helper.findNodeByName(self.resourceNode_,"notice_lab_1")
    self.notice_lab_2 = helper.findNodeByName(self.resourceNode_,"notice_lab_2")

    self.mainHelpBtn2 = helper.findNodeByName(self.resourceNode_,"mainHelpBtn2")
    --self.mainHelpBtn2:setVisible(Is_App_Store)
    self.mainHelpBtn2:setVisible(false)
    self.mainShareBtn_img = helper.findNodeByName(self.resourceNode_,"mainShareBtn_img")
    self.mainShareBtn_img:setVisible(not Is_App_Store)
    self.mainShareBtn = helper.findNodeByName(self.resourceNode_,"mainShareBtn")
    self.mainShareBtn:setVisible(not Is_App_Store)

    self.card_node = helper.findNodeByName(self.resourceNode_,"card_node")
    self.card_node:setVisible(not Is_App_Store)

    if UserData.userInfo then
        -- self.mainName:setString(UserData.userInfo.nickName)
        self.mainName:setString(helper.nameAbbrev(UserData.userInfo.nickName))
        self.mainUserID:setString(UserData.uid)
        self.mainRCLabel:setString(UserData.userInfo.surplusGameCard)
        if  UserData.userInfo.avatar then
            local image = NetSprite:getSpriteUrl(UserData.userInfo.avatar,"mj/bg_default_avatar_2.png")
            image:setPosition(cc.p(self.mainIcon:getContentSize().width / 2, self.mainIcon:getContentSize().height / 2))
            image:setImageContentSize(cc.size(self.mainIcon:getContentSize().width-3, self.mainIcon:getContentSize().height-3))
            image:addTo(self.mainIcon)
         end
    end
    --BIHttpClient:postBIeventInfo(consts.BIeventType.page,consts.BIcurrentPath.indexPage)

    self.mainMsgBtn:setVisible(not Is_App_Store)

    local guset_mask = helper.findNodeByName(self.resourceNode_,"guset_mask")
    guset_mask:setVisible(Is_App_Store)

    self.mainBuildBtn = helper.findNodeByName(self.resourceNode_,"mainBuildBtn")
    self.mainBuildBtn:setVisible(false)


    --世界公告
    if(not Is_App_Store)then
        self.m_noticeList = {}
        self:sendWordNotice()
        self.m_noticeCall = gScheduler:scheduleScriptFunc(handler(self,self.sendWordNotice),50,false )
    end

    --开启定位
    if(Is_Cheat_Set)then
        LuaCallPlatformFun.openLocation()
    end
    --开启麦克风
    if(not Is_App_Store)then
        LuaCallPlatformFun.openMicPhone()
    end

    NotifyMgr:reg(consts.Notify.UPDATE_CARD_NUM, self.updateGameCard, self)
end

function GameMainUI:updateGameCard()
    helper.updateGameCard()--刷新房卡
end

function GameMainUI:onEnter()
    print("GameMainUI:onEnter()")
    helper.updateGameCard()--刷新房卡
    self:updateCreateBtn()
    local ProomId = LuaCallPlatformFun.getRoomId();
    if(ProomId and UserData.PlatformRoomId ~= ProomId)then
        UserData.PlatformRoomId = ProomId
        if(string.find(ProomId,"_"))then
            --分享战局回放
            local shareCode = string.sub(ProomId,2,#ProomId)
            self:battleLook(tonumber(shareCode))
        elseif #ProomId >5 then
            self.roomId = ProomId
            self:queryRoom()
        end
    end
    self.mainGiveCardBtn:setVisible(false)
    self.mainPiLiang:setVisible(false)
    
    if(Is_App_Store)then return end
    performWithDelay(self, handler(self,self.firstSendCard),.5)
    self:checkMail()
    self:queryIsAgent()
end

function GameMainUI:queryIsAgent()
    -- body
    HttpServiers:queryIsAgent({
        userId = UserData.uid
    },
    function(entity,response,statusCode)

        if response and (response.status == 1 or response.errCode == 0) then
            --UIMgr:showTips("问题已成功提交，谢谢您宝贵的建议!")
            if response.data.agentType == "1" or response.data.agentType == "2" then
                self.mainGiveCardBtn:setVisible(true)
                print("self.mainGiveCardBtn:setVisible(true)")
            else
                self.mainGiveCardBtn:setVisible(false)
                print("self.mainGiveCardBtn:setVisible(false)")
            end
        else
            --UIMgr:showTips("提交失败")
            print("错误码：",response.errCode,"错误信息：",response.error)
        end
    end)
end

function GameMainUI:checkMail()
    local cur_date = os.date("*t", os.time())
    local day = cur_date.day
    local month = cur_date.month
    local year = cur_date.year
    local time = year..month..day

    if time ~= cc.UserDefault:getInstance():getStringForKey("mail_check_time") and cur_date.hour >= 6 then
        cc.UserDefault:getInstance():setStringForKey("mail_check_time", time)

        if self.mailRedPoint then
            self.mailRedPoint:removeSelf()
            self.mailRedPoint = nil
        end
        self.mailRedPoint = display.newSprite("mj/red_point.png"):addTo(self.mainMsgBtn):setPosition(cc.p(self.mainMsgBtn:getContentSize().width -20,
                                                self.mainMsgBtn:getContentSize().height - 20))
    end
end

--首次登陆送房卡
function GameMainUI:firstSendCard(  )
    if(UserData.userInfo.isNew == 1 and tonumber(UserData.userInfo.surplusGameCard) > 0)then
        UIMgr:showTips("首次登录赠送房卡"..UserData.userInfo.surplusGameCard.."张")
        UserData.userInfo.isNew = 0
    end
end

function GameMainUI:queryRoom()
    local sendData = {enter_code =  self.roomId}
    if(Is_Cheat_Set and LuaCallPlatformFun.isOpenLocation())then
        if(not Is_App_Store) then                   -- android开启高德地图
            LuaCallPlatformFun.openLocation()
        end
        local pos = LuaCallPlatformFun.getLocation()
        if(pos)then
            sendData.antiCheatLon = pos.longitude
            sendData.antiCheatLat = pos.latitude
        end
    end
    HttpServiers:queryRoom(sendData,
        function(entity,response,statusCode)
            if entity  then
                local addressSplit = string.split(entity.address, ":")
                local ip =  addressSplit[1]
                local port = addressSplit[2]
                GnetMgr:initConnect(ip, port,handler(self,self.connectSuccess))
            elseif response then
                GnetMgr:showErrorTips(response.errCode, true)
            else
                UIMgr:showNetErrorTip(function()
                    self:queryRoom()
                end)
            end
        end)
end

function GameMainUI:connectSuccess()
    UserData.roomId = self.roomId
    self:send("room_enter_room",{enter_code = self.roomId})
end

function GameMainUI:onClickAvatar()
    print("点击主页面头像")    
    local userInfo = UserData.userInfo
    if userInfo then
        UIMgr:showPlayerInfoDialog({nickname = userInfo.nickName, 
            ip = userInfo.ip,
            image_url = userInfo.avatar,
            uid = userInfo.userId,
            gender = userInfo.gender
            })
    end
end


function GameMainUI:updateCreateBtn()
    if UserData.roomId then
        print("UserData.roomId ！=0") 
        self.backImage:setVisible(true)
        self.createImage:setVisible(false)
    else
        print("UserData.roomId == 0") 
        self.backImage:setVisible(false)
        self.createImage:setVisible(true)
    end
end

function GameMainUI:onCreateGame()
    --判断房卡数打开页面
    if not UserData.isInGame then
        -- if(UserData.isAddClub)then
        --     UIMgr:openUI(consts.UI.ClubRoomUI)
        -- else
        --   UIMgr:openUI(consts.UI.createRoomUITwo)
        -- end
        UIMgr:openUI(consts.UI.createRoomUITwo)
    else
        self:close()
    end
    -- self:close()
end

--左上角房卡开房
function GameMainUI:onCreateRoom()
    if not UserData.isInGame then
        UIMgr:openUI(consts.UI.createRoomUITwo)
    else
        self:close()
    end
end

function GameMainUI:onJoin()
    if UserData.isInGame then
        self:close()
    else
        UIMgr:openUI(consts.UI.joinRoomUI)
    end

    --UIMgr:openUI(consts.UI.SummaryResultUI)

    --UIMgr:openUI(consts.UI.cardResultUI)
end

function GameMainUI:onBuy()
    print("点击购买房卡按钮")
    if(Is_App_Store or not Is_Open_Pay)then
        UIMgr:openUI(consts.UI.buyCardPanel)
    else
        UIMgr:openUI(consts.UI.PayUI)
    end
end

function GameMainUI:onMessage()
    UIMgr:openUI(consts.UI.UserAgreementUI,nil,nil)
    local helpUrl = "uires/uiSetting/message.html"
    if(helpUrl) then 
        NotifyMgr:push(consts.Notify.UPDATE_MAIL, {url = helpUrl,type = 2})
    end
    if self.mailRedPoint then
        self.mailRedPoint:removeSelf()
        self.mailRedPoint = nil
    end
end

function GameMainUI:onHelp()
    UIMgr:openUI(consts.UI.HelpUI,nil,nil)
end

function GameMainUI:onSet()
    -- body
    UIMgr:openUI(consts.UI.SettingUI,nil,nil,{fromType="main"})
end

function GameMainUI:onShare()
    -- body
    print("onShareItemClick")
    UIMgr:openUI(consts.UI.SharePanelUI)
end
--反馈UI
function GameMainUI:onActivity()
    -- body
    print("onActivityClick")
    UIMgr:openUI(consts.UI.FankuiUI)
end

function GameMainUI:onGiveCardClick()
    UIMgr:openUI(consts.UI.GiveCardUI)
end

function GameMainUI:onRecird()
    -- body
    UIMgr:openUI(consts.UI.RecordMainUI)
end

function GameMainUI:onClub()
    if not UserData.isInGame then
        UIMgr:openUI(consts.UI.ClubRoomUI)
    else
        self:close()
    end
    -- self:close()
end

function GameMainUI:onPiLiangCreate()
    UIMgr:openUI(consts.UI.ClubCreateMany)
end

function GameMainUI:onHongbao(  )
end

function GameMainUI:onMotan()
end

function GameMainUI:onPdkClick()

end

function GameMainUI:onHbmjClick()
end

function GameMainUI:onPhzClick()

end

function GameMainUI:proListHandler(msg)
    if msg.name == "room_enter_room" then
        if helper.isCallbackSuccess(msg) then
            UIMgr:closeUI(consts.UI.LoadingDialogUI)
            MyApp:goToGame()
        else
            GnetMgr:showErrorTips(msg.args.code)
            UserData.roomId = nil
            self.roomId = nil
        end
    end
end
--请求世界公告
function GameMainUI:sendWordNotice(  )
    HttpServiers:queryArticleList({
        appId = consts.appId,
        appCode = consts.appCode,
        clientFrom = consts.clientFrom[device.platform],
        artCat = "sysNotice",
    },
    function(entity,response,statusCode)
        if response and (response.status == 1 or response.errCode == 0) then
            if(response.data and response.data.list)then
                local desc = response.data.list[1].desc
                if(desc) and self and self.m_noticeList then 
                    table.insert(self.m_noticeList,1,desc) 
                    if(not self.mainBLabel:isVisible())then self:playWorldNotice()end
                end
            end
        else
            --打开出错
            if response then
                print("错误码：",response.errCode,"错误信息：",response.error)
            else
                print("错误response不存在")
            end
        end
    end)
end

function GameMainUI:playWorldNotice(  )
    self.mainBLabel:setVisible(#self.m_noticeList > 0)
    if(#self.m_noticeList < 1)then return end

    self.notice_lab_1:setString(self.m_noticeList[#self.m_noticeList])
    local size = self.notice_lab_1:getContentSize()

    local sudu = 70
    local pathLen = size.width + 700
    local time = pathLen/sudu

    self.notice_lab_1:runAction(
        transition.sequence({
            cc.MoveTo:create(time, cc.p(-size.width,20)),
            cc.CallFunc:create(function()
                self.notice_lab_1:setPosition(cc.p(700,20))
                if(#self.m_noticeList > 1)then table.remove(self.m_noticeList)end
                self:playWorldNotice()
            end)}))
end

function GameMainUI:uiCloseDo()
    local dialog = UIMgr:showLoadingDialog("")
    dialog.bg:setVisible(false)
    performWithDelay(self, handler(self,function ()
        UIMgr:closeUI(consts.UI.LoadingDialogUI)
    end),.2)
end

--更新房卡
function GameMainUI:updateCard()
    if UserData.userInfo then
        self.mainRCLabel:setString(UserData.userInfo.surplusGameCard)
    end
end

--查询是否有俱乐部
function GameMainUI:requestClub()
    UserData.isAddClub = false
    HttpServiers:queryqClubResult({},
    function(entity,response,statusCode)
        if response and (response.status == 1 or response.errCode == 0) then
            if(#response.data > 0)then
                -- self.createImage:setTexture("uires/main/main_create_2.png")
                -- UserData.isAddClub = true
            end
            self.mainClubBtn:setVisible(false)
            self.mainBuildBtn:setVisible(false)
        else
            
        end
    end)
end

function GameMainUI:addHongbao(  )
    local animation = AnimationView:create("hongbao","action/hongbao/zong.csb")
    animation:setPosition(cc.p(1300,556))
    animation:gotoFrameAndPlay(0,true)
    animation:addTo(self,1)
    self.m_hbAction = animation
    self.m_hbAction.moving = true
end

function GameMainUI:addMotan()
    local animation = AnimationView:create("motanzhengba","action/motanzhengba.csb")
    animation:setPosition(cc.p(self.Panel_motan:getContentSize().width / 2, self.Panel_motan:getContentSize().height / 2))
    animation:gotoFrameAndPlay(0,true)
    animation:addTo(self.Panel_motan,1)
    self.m_mtAction = animation
    self.m_mtAction.moving = true
end

function GameMainUI:updateHbAction()
    if(self.m_hbAction.moving)then
        self.m_hbAction.moving = false
        self.m_hbAction:onPause()
    else
        self.m_hbAction.moving = true
        self.m_hbAction:onResume()
    end
end

function GameMainUI:updateMtAction()
    if(self.m_mtAction.moving)then
        self.m_mtAction.moving = false
        self.m_mtAction:onPause()
    else
        self.m_mtAction.moving = true
        self.m_mtAction:onResume()
    end
end

--微信分享跳转战局回放
function GameMainUI:battleLook( shareCode )
    HttpServiers:queryResultShareDetail({
    shareCode = shareCode},
        function(entity, response, statusCode)
            if entity then
                -- print(entity)
                UserData.replayInfo = entity
                MyApp:goToReplayScene()
            end
        end)
end

function GameMainUI:onExit()
    GameMainUI.super.onExit(self)
    if self.m_noticeCall then
        gScheduler:unscheduleScriptEntry(self.m_noticeCall)
        self.m_noticeCall = nil
    end

    if self.m_hbIconCall then
        gScheduler:unscheduleScriptEntry(self.m_hbIconCall)
        self.m_hbIconCall = nil
    end

    if self.m_mtIconCall then
        gScheduler:unscheduleScriptEntry(self.m_mtIconCall)
        self.m_mtIconCall = nil
    end
end



return GameMainUI