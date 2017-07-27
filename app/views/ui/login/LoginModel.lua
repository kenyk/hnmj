--
-- Author: LXL
-- Date: 2016-11-09 09:05:54
--

local LoginModel = class("LoginModel" , cc.load("mvc").ModelBase)

function LoginModel:ctor(callback)
    LoginModel.super.ctor(self,callback)
end

function LoginModel:getProList()
    local list = {
    	-- "login_login_by_account"
    	"role_login"
    }
    return list
end

return LoginModel