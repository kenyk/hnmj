--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

local RecordDetailUI = class("RecordDetailUI", cc.load("mvc").UIBase)

RecordDetailUI.RESOURCE_FILENAME = "uiRecord/UI_Record_Detail1.csb"

local uiname = consts.UI.RecordDetailItemUI;
local uiRoot = require(uiname);

function RecordDetailUI:onCreate(data)
   self.btnBack = helper.findNodeByName(self.resourceNode_,"btnBack")
   self.btnBack:setPressedActionEnabled(true)

   self.scrollview = helper.findNodeByName(self.resourceNode_,"scrollview")
   self.players = {
      helper.findNodeByName(self.resourceNode_,"player1"),
      helper.findNodeByName(self.resourceNode_,"player2"),
      helper.findNodeByName(self.resourceNode_,"player3"),
      helper.findNodeByName(self.resourceNode_,"player4"),
   }
   self.data = data
   if data then
           
        self:setPlayerInfo(data)
        HttpServiers:queryResultDetail({
        roomId = data.room_id,
        owner  = data.owner,
        userId = UserData.uid    
        },
            function(entity, response, statusCode)
                if entity  then
                    self:updateData(entity)
                end
            end)
    end

end

function RecordDetailUI:onBack(event)
    self:close()
end

function RecordDetailUI:setPlayerInfo(data) 
    if data then
        for i=1, 4 do
            local name = "chair_"..i.."_name"
            self.players[i]:setString("□□□□")
            self.players[i]:setString(data[name])
        end
    end
end

function RecordDetailUI:updateData(records)
   if records~=nil and #records>0 then
      local itemHeight = 78
      local lineInterval = 2
      local scrollviewWidth = 1070
      local scrollviewHeight = #records * (itemHeight+lineInterval)
      if scrollviewHeight<500 then
         scrollviewHeight = 500
      end
      self.scrollview:setInnerContainerSize(cc.size(scrollviewWidth, scrollviewHeight))
      self.scrollview:setContentSize(cc.size(scrollviewWidth, 500))
      for i=1,#records do
         scrollviewHeight = scrollviewHeight-itemHeight-lineInterval
         local ui_bg = false
         if i%2==0 then
              ui_bg = true
         else
              ui_bg = false
         end
         local ui = uiRoot:create(uiname)
         ui:setAnchorPoint(cc.p(0,1))
         ui:setPosition(cc.p(0, scrollviewHeight))
         local allData = clone(records[i])
         local shareCode = allData.shareCode
         table.merge(allData, self.data)
         allData.shareCode = shareCode
         ui:setItemData(records[i],ui_bg, allData)
         ui:addTo(self.scrollview, 1)
      end
   end
end

return RecordDetailUI