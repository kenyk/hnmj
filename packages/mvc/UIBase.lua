
local UIBase = class("UIBase", cc.Node)

function UIBase:ctor(name,data)
    self:enableNodeEvents()
    self.name_ = name

    -- check CSB resource file
    local res = rawget(self.class, "RESOURCE_FILENAME")
    if res then
        self:createResourceNode(res)
    end
    local model = rawget(self.class, "RESOURCE_MODELNAME")
    if model then
        self:createModel(model)
    end
    if self.onCreate then self:onCreate(data) end
end

function UIBase:getName()
    return self.name_
end

function UIBase:getResourceNode()
    return self.resourceNode_
end

function UIBase:createResourceNode(resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_:removeSelf()
        self.resourceNode_ = nil
    end
    self.resourceNode_ = cc.CSLoader:createNode(resourceFilename, handler(self,self.createCallback))
    assert(self.resourceNode_, string.format("UIBase:createResourceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:addChild(self.resourceNode_)
end

function UIBase:createCallback(node)
    if node and node.getCallbackName and node.getCallbackType then
        local type = node:getCallbackType()
        if type == "Click" then
            node:addClickEventListener(handler(self, self.onViewClick))
        elseif type == "Touch" then
            node:onTouch(handler(self, self.onViewTouch))
        end
    end
end

--服务器数据收集处理
function UIBase:createModel(modelname)
    if self.model_ then
        self.model_:destroy()
        self.model_ = nil
    end
    print("modelname",modelname)
    local model = import(modelname)
    self.model_ = model:create(handler(self,self.proListHandler))
end

function UIBase:proListHandler(msg)
end

function UIBase:send(name,data)
    if self.model_ then
        self.model_:send(name,data)
    else
        assert(self.model_,"no model_")
    end
end

function UIBase:onViewClick(node)
    local data = {}
    data.name = node:getCallbackName()
    data.node = node
    if self[data.name] then
        return self[data.name](self,node)
    end
    return false
end

function UIBase:onViewTouch(event)
    local data = {}
    data.name = event.target:getCallbackName()
    data.event = event
    if self[data.name] then
        return self[data.name](self,event)
    end
    return false
end

function UIBase:setInOutAction()
    self.m_InOutAction = true
end

function UIBase:getInOutAction()
    return self.m_InOutAction
end

function UIBase:getContentNode()
    return helper.findNodeByName(self.resourceNode_,"content_node") 
end

function UIBase:popupAction()

    if self.m_InOutAction then 

        self.layerEntered = false
        local bg_black = helper.findNodeByName(self.resourceNode_,"bg_black")
        local content_node = helper.findNodeByName(self.resourceNode_,"content_node")
        if content_node then        
            content_node:setScale(0.1)
            content_node:setOpacity(0)

            local enterTime = 0.2
            local scale = cc.ScaleTo:create(enterTime,1.1)
            local Opacity = cc.FadeIn:create(enterTime)
            local spawn  = nil
            spawn  = cc.Spawn:create(scale,Opacity)          
            local scaleBack = cc.ScaleTo:create(enterTime/2,1)
        
            enterAction = cc.Sequence:create(spawn,scaleBack)

            local actions = {}
            if enterAction then
                table.insert(actions,enterAction)
            end
            table.insert(actions,cc.DelayTime:create(0.1))
            table.insert(actions,cc.CallFunc:create(function()               
                self.layerEntered = true
            end))
            content_node:runAction(cc.Sequence:create(actions))
            if bg_black then                 
                local fadeTo = cc.FadeTo:create(enterTime, 255)
                bg_black:setOpacity(0)
                bg_black:runAction(fadeTo)
            end
        end
    end

end

 function UIBase:onEnter()
      self:popupAction()
 end

function UIBase:onExit()
    if self.model_ then
        self.model_:destroy()
        self.model_ = nil
    end
    NotifyMgr:unregWithObj(self)
    print(self.name_,"UIBase:onExit")

    local content_node = helper.findNodeByName(self.resourceNode_,"content_node")
    if content_node then
        content_node:stopAllActions()
    end 
end

function UIBase:close()
    UIMgr:closeUI(self.name_)
end

return UIBase
