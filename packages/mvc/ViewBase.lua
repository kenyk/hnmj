
local ViewBase = class("ViewBase", cc.Node)

function ViewBase:ctor(app, name)
    UIMgr:clear()
    self:enableNodeEvents()
    self.app_ = app
    self.name_ = name

    -- check CSB resource file
    local res = rawget(self.class, "RESOURCE_FILENAME")
    if res then
        self:createResourceNode(res)
    end

    local binding = rawget(self.class, "RESOURCE_BINDING")
    if res and binding then
        self:createResourceBinding(binding)
    end

    if self.onCreate then self:onCreate() end
end

function ViewBase:getApp()
    return self.app_
end

function ViewBase:getName()
    return self.name_
end

function ViewBase:getResourceNode()
    return self.resourceNode_
end

function ViewBase:createResourceNode(resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_:removeSelf()
        self.resourceNode_ = nil
    end
    self.resourceNode_ = cc.CSLoader:createNode(resourceFilename, handler(self,self.createCallback))
    assert(self.resourceNode_, string.format("ViewBase:createResourceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:addChild(self.resourceNode_)
end

function ViewBase:createResourceBinding(binding)
    assert(self.resourceNode_, "ViewBase:createResourceBinding() - not load resource node")
    for nodeName, nodeBinding in pairs(binding) do
        local node = self.resourceNode_:getChildByName(nodeName)
        if nodeBinding.varname then
            self[nodeBinding.varname] = node
        end
        for _, event in ipairs(nodeBinding.events or {}) do
            if event.event == "touch" then
                node:onTouch(handler(self, self[event.method]))
            elseif event.event == "click" then
                node:addClickEventListener(handler(self, self[event.method]))
            end
        end
    end
end

function ViewBase:createCallback(node)
    if node and node.getCallbackName and node.getCallbackType then
        local type = node:getCallbackType()
        if type == "Click" then
            node:addClickEventListener(handler(self, self.onViewClick))
        elseif type == "Touch" then
            node:onTouch(handler(self, self.onViewTouch))
        elseif type == "Event" then
            node:addEventListener(handler(self, self.onViewEvent))
        end
    end
end

function ViewBase:onViewClick(node)
    local data = {}
    data.name = node:getCallbackName()
    data.node = node
    if self[data.name] then
        return self[data.name](self,node)
    end
    return false
end

function ViewBase:onViewTouch(event)
    local data = {}
    data.name = event.target:getCallbackName()
    data.event = event
    if self[data.name] then
        return self[data.name](self,event)
    end
    return false
end

function ViewBase:onViewEvent(sender,event)
    local data = {}
    data.name = sender:getCallbackName()
    data.event = event
    data.sender = sender
    if self[data.name] then
        self[data.name](self,sender,event)
    end
end

function ViewBase:showWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene(self.name_)
    scene:addChild(self)
    display.runScene(scene, transition, time, more)
    return self
end

function ViewBase:onExit()
    if self.model_ then
        self.model_:destroy()
        self.model_ = nil
    end
    NotifyMgr:unregWithObj(self)
    print(self.name_,"ViewBase:onExit")
end

function ViewBase:send(name,data)
    if self.model_ then
        self.model_:send(name,data)
    else
        assert(self.model_,"no model_")
    end
end

return ViewBase
