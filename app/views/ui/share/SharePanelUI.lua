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
    local weburl = "https://acz5fi.mlinks.cc/AcqJ?".."roomId=".."_"..1    
    self.args = {title="一起来玩么么湖南麻将吧！",desc="邀请您加入【么么湖南麻将】，点击该链接后，进入麻将下载页面，进入下载流程！",webUrl=weburl,imageUrl=""}
   
    --self.args = {title="我在玩么么湖南麻将，一起来玩吧！",desc="邀请您加入【么么湖南麻将】，点击该链接后，进入麻将下载页面，进入下载流程！",webUrl="https://fir.im/3cv1",imageUrl=""}
    --print("----share panel---",self.args.title,self.args.desc,self.args.webUrl,self.args.imageUrl)
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