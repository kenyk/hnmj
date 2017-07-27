--
-- Author: jiangbaotian
--

local SettingModel = class("SettingModel" , cc.load("mvc").ModelBase)

function SettingModel:ctor(callback)
    SettingModel.super.ctor(self,callback)
end

return SettingModel