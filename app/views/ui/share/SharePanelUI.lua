--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

local SharePanelUI = class("SharePanelUI", cc.load("mvc").UIBase)

SharePanelUI.RESOURCE_FILENAME = "uiShare/UI_Share_Panel.csb"

function SharePanelUI:onCreate()
    self:setInOutAction()
    self.closeBtn = helper.findNodeByName(self.resourceNode_,"closeBtn")
    self.closeBtn:setPressedActionEnabled(true)
    self.weixinBtn = helper.findNodeByName(self.resourceNode_,"btn_share_weixin")
    self.weixinBtn:setPressedActionEnabled(true)
    self.weixincircleBtn = helper.findNodeByName(self.resourceNode_,"btn_share_weixincircle")
    self.weixincircleBtn:setPressedActionEnabled(true)
    self.args = {title="游戏邀请:",desc="邀请您加入【么么湖南麻将】，点击该链接后，进入麻将下载页面，进入下载流程！",webUrl="https://fir.im/3cv1",imageUrl=""}
    -- if UserData.userInfo and UserData.userInfo.shareList and UserData.userInfo.shareList.mainShare then
    --     self.args = {
    --     title = UserData.userInfo.shareList.mainShare.title,
    --     desc = UserData.userInfo.shareList.mainShare.desc,
    --     webUrl = UserData.userInfo.shareList.mainShare.link,
    --     imageUrl = UserData.userInfo.shareList.mainShare.img,
    -- }
    -- end
    print("----share panel---",self.args.title,self.args.desc,self.args.webUrl,self.args.imageUrl)
end

function SharePanelUI:onShareWeixin()
	LuaCallPlatformFun.share(self.args)
end

function SharePanelUI:onShareWeixinCircle()
	LuaCallPlatformFun.shareToCircle(self.args)
end

function SharePanelUI:onCloseBtnClick()
	self:close()
end

return SharePanelUI