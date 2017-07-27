
DismissRoomApplyDialogLayer = class("DismissRoomApplyDialogLayer", function()
    return cc.Layer:create()
end)

-- 申请解散房间对话框图层

function DismissRoomApplyDialogLayer:ctor(msg)
    self:enableNodeEvents()
    local lineHieght=15
    if UserData.table_config.player_count==4 then
        lineHieght=8
    elseif UserData.table_config.player_count==3 then
        lineHieght=13
    end

    self.dialogContent= helper.createRichLabel({maxWidth = 730,lineSpace=lineHieght})
    self.dialogContent:setAnchorPoint(cc.p(0.5, 1))
    self.dialogContent:setPosition(cc.p(683, 534))
    self.dialogContent:addTo(self,1)

    self.label_time = cc.LabelAtlas:_create(tostring(UserData.disMissTime), "mj/dialog_timer_fonts.png", 14, 20,  string.byte("0"))
    self.label_time:setAnchorPoint(cc.p(0.5, 0.5))
    self.label_time:setPosition(cc.p(1095, 652))
    self.label_time:addTo(self,3)

    self.timer_clock_bg = display.newSprite("uires/common/dialog/dialog_timer_clock.png", 1095,652)
    self.timer_clock_bg:addTo(self, 1)
    self.timer_clock_bg:setScale(1.1)
end

function DismissRoomApplyDialogLayer:update(msg)
    local applyPlayerNickName=""
    local applyPlayer=UserData:getPlayerInfoById(msg.apply)
    if applyPlayer then
        applyPlayerNickName=applyPlayer.nickname
    end
    self.dialogContentText="<div fontcolor=#994e2e>玩家</div><div fontcolor=#ff6c00>【"..applyPlayerNickName.."】</div><div fontcolor=#994e2e>申请解散房间,请问是否同意？（超过五分钟未做选择，则默认同意）\n</div>"
    if UserData.players then
        for i,player in ipairs(UserData.players) do
           print(player.nickname)
           if player.uid==msg.uid then
                player.option=msg.option
           end
           if player.uid~=msg.apply then 
                self.statusText="等待选择"
                if player.option and player.option==0 then self.statusText="已同意"
                elseif player.option and player.option==1 then self.statusText="已拒绝"
                end
                self.dialogContentText=self.dialogContentText.."<div fontcolor=#ff6c00>【"..player.nickname.."】</div><div fontcolor=#994e2e>"..self.statusText .. "\n" .."</div>"
            end
        end
    end
    if self.dialogContent then
        self.dialogContent:setString(self.dialogContentText)
    end
end

-- function DismissRoomApplyDialogLayer:setTimeEndCallBack(callback)
--     self.timeEndCallBack=callback
-- end


function DismissRoomApplyDialogLayer:updateTime()
    if UserData.disMissTime then
        if UserData.disMissTime > 0 then
            UserData.disMissTime = UserData.disMissTime - 1
            self.label_time:setString(UserData.disMissTime)
            if UserData.disMissTime == 0 then
                -- print("DismissRoomApplyDialogLayer：时间到了")
                -- mahjongModel:send("room_vote_dismiss_room",{room_id = UserData.roomId,option=0})
            end
        end
    end
end

function DismissRoomApplyDialogLayer:startTimer()
    if self.timeEntity == nil then
        self.timeEntity = gScheduler:scheduleScriptFunc(handler(self,self.updateTime), 1, false)
    end
end

function DismissRoomApplyDialogLayer:closeTimer()
    if self.timeEntity then
        gScheduler:unscheduleScriptEntry(self.timeEntity)
        self.timeEntity = nil
    end
end

function DismissRoomApplyDialogLayer:onEnter()
    print("DismissRoomApplyDialogLayer on exit")
    self:startTimer()
end

function DismissRoomApplyDialogLayer:onExit()
    print("DismissRoomApplyDialogLayer on exit")
    self:closeTimer()
end





return DismissRoomApplyDialogLayer