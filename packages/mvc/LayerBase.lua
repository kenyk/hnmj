local LayerBase = class("LayerBase", cc.Layer)

function LayerBase:ctor(name)
    local model = rawget(self.class, "RESOURCE_MODELNAME")
    if model then
        self:createModel(model)
    end
    if self.onCreate then self:onCreate() end
end

--服务器数据收集处理
function LayerBase:createModel(modelname)
    if self.model_ then
        self.model_:destroy()
        self.model_ = nil
    end
    local model = import(modelname)
    self.model_ = model:create(handler(self,self.proListHandler))
end

function LayerBase:proListHandler(msg)
end

function LayerBase:send(name,data)
    if self.model_ then
        self.model_:send(name,data)
    else
        assert(self.model_,"no model_")
    end
end

