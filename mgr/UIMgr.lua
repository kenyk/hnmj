--
-- Author: LXL
-- Date: 2016-11-03 10:47:24
--
local openUIList_ = {}
local topIndex = 100

local PlayerInfoUI = require(consts.UI.PlayerInfoUI)

UIMgr = {}

function UIMgr:openUI(uiname,isNew,parent,data)
	print("=============", uiname)
    openUIList_[uiname] = openUIList_[uiname] or {}
	local uiRoot = require (uiname)
	local uiList = openUIList_[uiname]
	local curParent = parent or display.getRunningScene()
	local ui
	if isNew or uiList[#uiList] == nil then
		ui = uiRoot:create(uiname,data)
		curParent:addChild(ui)
		table.insert(openUIList_[uiname],ui)
	else
		ui = uiList[#uiList]
	end
	ui:setLocalZOrder(topIndex)
	topIndex = topIndex + 1
	return ui
	-- dump(openUIList_,"afteropen")
end


function UIMgr:closeUI(uiname)
	local uiList = openUIList_[uiname]
	if uiList == nil or #uiList == 0 then return end
	local ui = table.remove(openUIList_[uiname],#openUIList_[uiname])

	if(uiname ~= consts.UI.LoadingDialogUI)then
    	local mainUI = self:getUI(consts.UI.mainUI)
    	if(mainUI)then mainUI:uiCloseDo()end
    end

    if ui.getInOutAction and ui:getInOutAction() then
        local time = 0.2
        local scale = cc.ScaleTo:create(time,0)
        local Opacity = cc.FadeOut:create(time)
        
        local spawn  = cc.Spawn:create(scale,Opacity)
        local seque = cc.Sequence:create(spawn,cc.DelayTime:create(0.02), cc.CallFunc:create(function() ui:removeSelf() end))
        local content_node = helper.findNodeByName(ui.resourceNode_,"content_node")
        if content_node then
           content_node:runAction(seque)
        end
    else
        ui:removeSelf()
    end	
end

function UIMgr:getUI(uiname)
	local uiList = openUIList_[uiname]
	if uiList then
		return uiList[#uiList]
	else
		return nil
	end
end

function UIMgr:clear()
	-- dump(openUIList_,"openUIList_:")
	for _,v in pairs(openUIList_) do
		local len = #v
		for i = 1 , len do
			local ui = table.remove(v,1)
			if ui.close then
				ui:close()
			end
		end
	end
	openUIList_ = {}
	topIndex = 100
end

-- 显示确认弹窗
function UIMgr:showConfirmDialog(dialog_title,dialog_params,dialog_yesBtnEvent,dialog_noBtnEvent,parent)
	local params={}
	-- 弹窗标题
	params.title=dialog_title
	-- 弹窗yes按钮事件
	params.yesBtnEvent=dialog_yesBtnEvent
	-- 弹窗no按钮事件
	params.noBtnEvent=dialog_noBtnEvent	
	if dialog_params then
		-- 弹窗内部子视视图
		params.child=dialog_params.child
		-- 弹窗宽度
		params.width=dialog_params.width
        -- 自定义子默认在居中显示，可以通过x y的偏移值来调整位置
        params.childOffsetX=dialog_params.childOffsetX
        params.childOffsetY=dialog_params.childOffsetY
		-- 弹窗高度
		params.height=dialog_params.height
		-- 是否允许点击外部区域关闭弹窗
		params.canCancelOutside=dialog_params.canCancelOutside
		-- 弹窗用作确认/取消还是同意/拒绝
		params.useForAgreement=dialog_params.useForAgreement
		-- 弹窗按钮点击不关闭弹窗
		params.notDismissDialogForBtnClick=dialog_params.notDismissDialogForBtnClick
		-- 弹窗按钮边距
		params.btnPadding=dialog_params.btnPadding

	end
	return self:openUI(consts.UI.ConfirmDialogUI,true,parent,params)
end


-- 显示加载中弹窗
function UIMgr:showLoadingDialog(msg)
	return self:openUI(consts.UI.LoadingDialogUI,nil,nil,msg)
end
-- 关闭 UIMgr:closeUI(consts.UI.LoadingDialogUI)

-- 显示用户信息弹窗
function UIMgr:showPlayerInfoDialog(playerInfo)
    local ui =  PlayerInfoUI:create()
    ui:setAnchorPoint(cc.p(0.5,0.5))
    ui:setPosition(cc.p(consts.Size.width/2, consts.Size.height/2))
    ui:show(playerInfo)
	return UIMgr:showConfirmDialog("",{child = ui,canCancelOutside = true,childOffsetX = 30,childOffsetY = -10},nil,nil)
end

-- 简单的文本提示弹窗
function UIMgr:showTips(str, callBack)
    callBack =  callBack or  function()end
    if str then
        local label = cc.LabelTTF:create(str, "Arial", 30)
        label:setAnchorPoint(cc.p(0.5,0.5))
        label:setPosition(consts.Point.CenterPosition)
        label:setColor(cc.c3b(153, 78, 46))
        local dialogParams={child=label,canCancelOutside = true,childOffsetY = 20}
        UIMgr:showConfirmDialog("",dialogParams, callBack)
    end
end

-- 网络出错，请重试
function UIMgr:showNetErrorTip(callBack)
    self:showTips("网络出错，请检查您的网络后再重试",callBack)
end