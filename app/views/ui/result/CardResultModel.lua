--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
local CardResultModel = class("CardResultModel", cc.load("mvc").ModelBase)


function CardResultModel:ctor(callback)
    CardResultModel.super.ctor(self,callback)
end

function CardResultModel:getProList()
    local list = {

    }
    return list
end

return CardResultModel