

local ClubRoomUI = class("ClubNoEnter", cc.load("mvc").UIBase)

ClubRoomUI.RESOURCE_FILENAME = "uiClub/UI_Room_Club.csb"
local KEY_CLUB_ID = "KEY_CLUB_ID"

function ClubRoomUI:onCreate()
  self:setInOutAction()
  self.closeBtn = helper.findNodeByName(self.resourceNode_,"closeBtn")
  self.closeBtn:setPressedActionEnabled(true)
  self.m_sv = helper.findNodeByName(self.resourceNode_, "sv")
  self.m_club_node = helper.findNodeByName(self.resourceNode_,"club_node")
  helper.findNodeByName(self.m_club_node,"btn_yes"):setPressedActionEnabled(true)
  self.m_no_club_node = helper.findNodeByName(self.resourceNode_,"no_club_node")
  ---- self:updateView()
  --self:requestMsg()
end

function ClubRoomUI:requestMsg(  )
	
    HttpServiers:queryqClubResult({
    },
    function(entity,response,statusCode)

        if response and (response.status == 1 or response.errCode == 0) then
            print("查詢成功")
            if(#response.data < 1)then--未加入
            	self.m_no_club_node:setVisible(true)
            else
            	self.m_club_node:setVisible(true)
            	self.m_data = response.data
            	self:updateView()
            end
    	else
    		

        end
    end)
end

function ClubRoomUI:updateView(  )
	-- self.m_sv:removeAllChildrenWithCleanup(true)

   if self.m_data ~= nil and #self.m_data > 0 then
      local itemHeight = 190
      local lineInterval = 6
      local scrollviewWidth = 900
      local scrollviewHeight = #self.m_data * (itemHeight+lineInterval)
      if scrollviewHeight<400 then
         scrollviewHeight = 400
      end
      self.m_sv:setInnerContainerSize(cc.size(scrollviewWidth, scrollviewHeight))
      self.m_sv:setContentSize(cc.size(scrollviewWidth, 400))
      self.m_selectImg = {}
      self.m_selectBox = {}
      self.m_index = 1
      self.m_box_index = 1
      
      local preClubID = cc.UserDefault:getInstance():getStringForKey(KEY_CLUB_ID)
      local selCellIdx = nil
      for i=1,#self.m_data do
          scrollviewHeight = scrollviewHeight-itemHeight-lineInterval
          local ui = self:createItem(i)
          ui:setPosition(cc.p(0, scrollviewHeight))
          ui:addTo(self.m_sv, 1)

          if self.m_data[i].clubId == preClubID then
              local cell_panel = helper.findNodeByName(ui,"cell_panel")
              self:onCellClick(cell_panel)
              selCellIdx = i
          end
      end

      if selCellIdx then
          local percent = (selCellIdx/(#self.m_data))*100
          self.m_sv:scrollToPercentVertical(percent,0.5,true)
      end

   end
end

function ClubRoomUI:onCellClick(obj)
	local tag = obj:getTag()
	print("cell：",tag)
	if(self.m_index == tag)then return end

	self.m_selectImg[self.m_index]:setVisible(false)
	self.m_selectBox[self.m_index][self.m_box_index]:setSelected(false)

	self.m_index = tag
	self.m_box_index = 1

	self.m_selectImg[self.m_index]:setVisible(true)
	self.m_selectBox[self.m_index][self.m_box_index]:setSelected(true)

end

function ClubRoomUI:onCheckBoxClick(obj)
	local tag = obj:getTag()
	print("cb:",tag)

	local boxIndex = tag%10
	local cellIndex = (tag - boxIndex)/10
	if(cellIndex ~= self.m_index)then
		self.m_selectImg[self.m_index]:setVisible(false)
		self.m_selectBox[self.m_index][self.m_box_index]:setSelected(false)

		self.m_index = cellIndex
		self.m_box_index = boxIndex
		self.m_selectImg[self.m_index]:setVisible(true)
		self.m_selectBox[self.m_index][self.m_box_index]:setSelected(true)

	elseif(boxIndex ~= self.m_box_index)then
		self.m_selectBox[self.m_index][self.m_box_index]:setSelected(false)
		self.m_box_index = boxIndex
		self.m_selectBox[self.m_index][self.m_box_index]:setSelected(true)
	end
end

function ClubRoomUI:createItem( index )
    local item = cc.CSLoader:createNode("uiClub/UI_Cell_Club.csb")
    local cell_panel = helper.findNodeByName(item,"cell_panel")
    cell_panel:setTag(index)
    cell_panel:addClickEventListener(function(sender) self:onCellClick(sender) end)
    cell_panel:setSwallowTouches(false)

    local btn_jifen = helper.findNodeByName(item,"btn_jifen")
    btn_jifen:setVisible(1 == self.m_data[index].isOpenRank)
    btn_jifen:setPressedActionEnabled(true)
    btn_jifen:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIMgr:openUI(consts.UI.ClubRankView, nil, nil, self.m_data[index])
        end
    end)

    --选中图片
    local select_img = helper.findNodeByName(item,"select_img")
    self.m_selectImg[index] = select_img
    select_img:setVisible(self.m_index == index)

    --头像
    local head_icon = helper.findNodeByName(item,"head_icon")
    if  self.m_data[index].avatar then
        local image = NetSprite:getSpriteUrl(self.m_data[index].avatar,"mj/bg_default_avatar_1.png")
        image:setPosition(cc.p(40,40))
        image:setImageContentSize(cc.size(80,80))
        image:addTo(head_icon)
    end

    --描述
    local des = {"clubName","surplusDiamondNum","rule1","rule2","rule3"}
    for i=1,5 do
    	local club_des = helper.findNodeByName(item,"club_des_"..i)
        if i == 1 then
            club_des:setString(self.m_data[index][des[i]].."的俱乐部")
        else
            club_des:setString(self.m_data[index][des[i]])
        end    	
    end
    
    --checkbox阈
    self.m_selectBox[index] = {}
    for i=1,3 do
    	local cb_panel = helper.findNodeByName(item,"cb_"..i)
    	cb_panel:setTag(index*10 + i)
    	cb_panel:addClickEventListener(function(sender) self:onCheckBoxClick(sender) end)

    	local box = helper.findNodeByName(item,"box_"..i)
    	self.m_selectBox[index][i] = box
    	box:setSelected(self.m_index == index and self.m_box_index == i)
    end
    
    return item
end

function ClubRoomUI:onSureBtnClick()
	local data = self.m_data[self.m_index]
	local needJewel = tonumber(data["rule"..self.m_box_index])
	if(tonumber(data.surplusDiamondNum) < needJewel)then
		UIMgr:showTips("钻石不足，无法创建房间，请联系俱乐部管理员")
		return
	end

  cc.UserDefault:getInstance():setStringForKey(KEY_CLUB_ID, data.clubId)
	UIMgr:openUI(consts.UI.createRoomUITwo,nil,nil,{clubId = data.clubId,clubName = data.clubName,jewelNum = needJewel})
	-- UIMgr:closeUI(consts.UI.mainUI)
	self:close()
end

function ClubRoomUI:onCloseBtnClick()
    self:close()
end

return ClubRoomUI




