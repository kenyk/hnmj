MasterDismissRoomDialogLayer = class("MasterDismissRoomDialogLayer", function()
    return cc.Layer:create()
end)

local RichLabel = require("utils.richlabel.RichLabel")

-- 房主解散房间成功对话框图层

function MasterDismissRoomDialogLayer:ctor(msg)
    self:enableNodeEvents()
    self.timeLeft=3
    self.master=UserData:getPlayerInfoById(UserData.table_config.master_id)
    self.dialogText="<div fontcolor=#994e2e>房主</div><div fontcolor=#ff6c00>"
    self.dialogText=self.dialogText.."【"..self.master.nickname.."】 "
    self.dialogText=self.dialogText.."</div><div fontcolor=#994e2e>已经解散房间"..UserData.roomId.."，请加入新的房间</div>"
    local dialogContentLabel=helper.createRichLabel({maxWidth = 600,fontSize=28})
    dialogContentLabel:setString(self.dialogText)
    dialogContentLabel:setPosition(cc.p(683, 445))
    dialogContentLabel:addTo(self,1)
    self.label_time=helper.createRichLabel({maxWidth = 550,fontSize=23})
    self.label_time:setAnchorPoint(cc.p(0.5, 0.5))
    self.label_time:setPosition(cc.p(683, 270))
    self.label_time:addTo(self,3)
    self:startTimer()
end

function MasterDismissRoomDialogLayer:updateTime()
    if self.timeLeft then
        if self.timeLeft > 0 then
            self.timeLeft = self.timeLeft - 1
            self.label_time:setString("<div fontcolor=#994e2e>"..self.timeLeft.."秒后自动回到大厅".."</div>")
            if self.timeLeft==0 then
                MyApp:goToMain()
                self:closeTimer()
            end
        end
    end
end

function MasterDismissRoomDialogLayer:startTimer()
    if self.timeEntity == nil then
        self.timeEntity = gScheduler:scheduleScriptFunc(handler(self,self.updateTime), 1, false)
    end
end

function MasterDismissRoomDialogLayer:closeTimer()
    if self.timeEntity then
        gScheduler:unscheduleScriptEntry(self.timeEntity)
        self.timeEntity = nil
    end
end

function MasterDismissRoomDialogLayer:onEnter()
    print("MasterDismissRoomDialogLayer on exit")
    self:startTimer()
end

function MasterDismissRoomDialogLayer:onExit()
    print("MasterDismissRoomDialogLayer on exit")
    self:closeTimer()
end

return MasterDismissRoomDialogLayer