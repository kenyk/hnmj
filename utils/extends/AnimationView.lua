--
-- Created by IntelliJ IDEA.
-- User: lxl
-- Date: 2015/8/19
-- Time: 16:28
-- To change this template use File | Settings | File Templates.
--
local AnimationView = class("AnimationView",cc.load("mvc").UIBase)

function AnimationView:onCreate(path)
    self:onLoader(path)
end

function AnimationView:onLoader(path)
    self.resourceNode_ = cc.CSLoader:createNode(path)
    print(self.resourceNode_,"111111111",path)
    self.timeline = cc.CSLoader:createTimeline(path)
    self:addChild(self.resourceNode_)
    self.resourceNode_:runAction(self.timeline)
    self.timeline:setFrameEventCallFunc(handler(self,self.onFrameEventCallFunc))
end

function AnimationView:anewLoader(path)
    if path then
        self:removeResourceNod()
        self:onLoader(path)
    end
end

function AnimationView:onFrameEventCallFunc(evnt)
    print("onFrameEventCallFunc:",evnt)
    if self.frameEventCallFunc then
        self.frameEventCallFunc(evnt)
    end
end

function AnimationView:setFrameEventCallFunc(handler)
    self.frameEventCallFunc = handler
end

function AnimationView:onPlay(type,isLoop,callBack)
    if self.timeline:IsAnimationInfoExists(type) then
        if isLoop == nil then
            isLoop = true
        end
        self.timeline:play(type, isLoop)
        self.palyCallBack = callBack
        if not isLoop then
            self.timeline:setLastFrameCallFunc(handler(self,self.onPlayLastCall))
        end
    else
        if callBack then
            callBack()
        end
    end
end

function AnimationView:onResume()
    self.timeline:resume()
end

function AnimationView:onPause()
    self.timeline:pause()
end

function AnimationView:gotoFrameAndPause(...)
    self.timeline:gotoFrameAndPause(...)
end

function AnimationView:gotoFrameAndPlay(...)
    self.timeline:gotoFrameAndPlay(...)
end

function AnimationView:setPlayLastCall(callBack)
    print("setPlayLastCall")
    self.palyCallBack = callBack
    self.timeline:setLastFrameCallFunc(handler(self,self.onPlayLastCall))
end

function AnimationView:onPlayLastCall()
    print("AnimationView:onPlayLastCall()",self.palyCallBack)
    self.timeline:clearLastFrameCallFunc()
    if self.palyCallBack then
        local callBack = self.palyCallBack
        self.palyCallBack = nil
        callBack()
    end
end

function AnimationView:onExit()
    AnimationView.super.onExit(self)
end

function AnimationView:onCleanup()
    self:removeResourceNod()
    if AnimationView.super.onCleanup then
        AnimationView.super.onCleanup(self)
    end
end

function AnimationView:removeResourceNod()
    AnimationView.addAutoRelease(self.resourceNode_)
    self.resourceNode_:removeFromParent(false)
end

function AnimationView.addAutoRelease(ref)
    AnimationView.autoReleaseList = AnimationView.autoReleaseList or {}
    ref:retain()
    table.insert(AnimationView.autoReleaseList,ref)
    if not AnimationView.scheduleTime then
        AnimationView.scheduleTime = gScheduler:scheduleScriptFunc(AnimationView.onScheduleTime, 0, false)
    end
end

function AnimationView.onScheduleTime()
    if #AnimationView.autoReleaseList > 0 then
        local v = table.remove(AnimationView.autoReleaseList)
        v:cleanup()
        v:release()
    else
        if AnimationView.scheduleTime then
            gScheduler:unscheduleScriptEntry(AnimationView.scheduleTime)
            AnimationView.scheduleTime  = nil
        end
    end
end

return AnimationView

