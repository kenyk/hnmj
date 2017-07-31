--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

--战绩

local RecordMainUI = class("RecordMainUI", cc.load("mvc").UIBase)

-- RecordMainUI.RESOURCE_FILENAME = "uiRecord/UI_Record_Main.csb"
RecordMainUI.RESOURCE_FILENAME = "uiRecord/UI_Record_Main3.csb"

local uiname = consts.UI.RecordMainItemUI;
local uiRoot = require(uiname);

function RecordMainUI:onCreate()
    self:setInOutAction()
    self.btnBack = helper.findNodeByName(self.resourceNode_,"btnBack")
    self.btnBack:setPressedActionEnabled(true)

    self.scrollview = helper.findNodeByName(self.resourceNode_,"scrollview")
    self.noRecordNode = helper.findNodeByName(self.resourceNode_,"no_record_node"):setVisible(false)

    performWithDelay(self, function()
        HttpServiers:queryResultList({
        userId = UserData.uid},
            function(entity, response, statusCode)
                if entity  then
                    self:updateData(entity)
                    -- performWithDelay(self, function()
                    --   self:updateData(entity)
                    -- end, 1)
                else
                    self.noRecordNode:setVisible(true)
                end
            end)
    end, 0.2)
end

function RecordMainUI:onBack(event)
    self:close()
end

function RecordMainUI:updateData(records)
   self.noRecordNode:setVisible(records==nil or #records<1)
   if records~=nil and #records>0 then
      local itemHeight = 140
      local lineInterval = 3
      --local scrollviewWidth = 1050
      local scrollviewWidth = 1060
      local scrollviewHeight = #records * (itemHeight+lineInterval)
      if scrollviewHeight<570 then
         scrollviewHeight = 570
      end
      self.scrollview:setInnerContainerSize(cc.size(scrollviewWidth, scrollviewHeight))
      self.scrollview:setContentSize(cc.size(scrollviewWidth, 570))
      for i=1,#records do
          scrollviewHeight = scrollviewHeight-itemHeight-lineInterval
          local ui = uiRoot:create(uiname, {index = i})
          ui:setAnchorPoint(cc.p(0,1))
          ui:setPosition(cc.p(0, scrollviewHeight))
          ui:setItemData(records[i])
          ui:addTo(self.scrollview, 1)
      end
   end
end

return RecordMainUI