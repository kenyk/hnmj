--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

-- local RecordMainItemUI = class("RecordMainItemUI", cc.load("mvc").UIBase)
local RecordMainItemUI = class("RecordMainItemUI", ccui.Layout)

RecordMainItemUI.RESOURCE_FILENAME = "uiRecord/UI_Record_Main_Item1.csb"

function RecordMainItemUI:ctor(name,data)
    self:enableNodeEvents()
    self.name_ = name

    -- check CSB resource file
    local res = rawget(self.class, "RESOURCE_FILENAME")
    if res then
        self:createResourceNode(res)
    end
    if self.onCreate then self:onCreate(data) end
end

function RecordMainItemUI:createResourceNode(resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_:removeSelf()
        self.resourceNode_ = nil
    end
    self.resourceNode_ = cc.CSLoader:createNode(resourceFilename, handler(self,self.createCallback))
    assert(self.resourceNode_, string.format("UIBase:createResourceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:addChild(self.resourceNode_)
end

function RecordMainItemUI:createCallback(node)
    if node and node.getCallbackName and node.getCallbackType then
        local type = node:getCallbackType()
        if type == "Click" then
            node:addClickEventListener(handler(self, self.onViewClick))
        elseif type == "Touch" then
            node:onTouch(handler(self, self.onViewTouch))
        end
    end
end

function RecordMainItemUI:onCreate(data)
    self.font = "Arial"
	self.record_main_item_num = helper.findNodeByName(self.resourceNode_,"record_main_item_num")
    -- self.record_tip_10 = helper.findNodeByName(self.resourceNode_,"record_tip_10")
    -- self.record_main_item_roomid = helper.findNodeByName(self.resourceNode_,"record_main_item_roomid")
    self.record_main_item_time = helper.findNodeByName(self.resourceNode_,"record_main_item_time")
    self.record_main_item_info = helper.findNodeByName(self.resourceNode_,"record_main_item_info")
    self.record_index = helper.findNodeByName(self.resourceNode_,"record_index")
    self.insizeWidth = 1200
    self.inOffsetX = 50
    self.insizeWidth = 1060
    self.inOffsetX = 0
    self.Image_1 = helper.findNodeByName(self.resourceNode_,"Image_1")
    -- self.Image_1:setTouchEnabled(true)
    -- self.Image_1:setSwallowTouches(false)

    self.Image_1:retain()
    self.Image_1:removeFromParent()
    self:addChild(self.Image_1, -1)

    self.record_index:setString(data.index)
end

function RecordMainItemUI:setItemData(item)

    if item then
        -- dump2(item)
        -- self.record_main_item_num:setString(item.ID)
        self.record_main_item_num:setString(item.room_id.."号房间")
        local xx = self.record_main_item_num:getContentSize().width+85
        -- self.record_tip_10:setPosition(cc.p(xx,147))
        -- self.record_main_item_roomid:setString(item.room_id.."号房间")
        self.record_main_item_time:setString(os.date("%m-%d %H:%M",item.end_time))
        local playcount = self:getChairCount(item)
        local iw = math.ceil(self.insizeWidth/playcount)
        local offset_x = iw/2;
        local x = 0;
        local y = 80;
        for i=1,playcount do
            self["Node_"..i] = helper.findNodeByName(self.resourceNode_,"Node_"..i)
            --过长 省略
            if string.len(item["chair_"..i.."_name"]) > 9 then
                item["chair_"..i.."_name"] = string.sub(item["chair_"..i.."_name"], 1, 9).."..."
            end
            self["Node_"..i]:getChildByName("txt_name"):setString("□□□□")
            self["Node_"..i]:getChildByName("txt_name"):setString(item["chair_"..i.."_name"])
            if tonumber(item["chair_"..i.."_point"]) < 0 then
                self["Node_"..i]:getChildByName("txt_score"):setColor(helper.str2Color("#8d1414"))
            end
            self["Node_"..i]:getChildByName("txt_score"):setString(item["chair_"..i.."_point"])
            self["Node_"..i]:getChildByName("txt_score"):setString(item["chair_"..i.."_point"])

            local mainIcon = self["Node_"..i]:getChildByName("mainIcon")
            local image = NetSprite:getSpriteUrl(item["chair_"..i.."_avatar"], "mj/bg_default_avatar_2.png")
            image:setPosition(cc.p(mainIcon:getContentSize().width / 2, mainIcon:getContentSize().height / 2))
            image:setImageContentSize(cc.size(mainIcon:getContentSize().width + 10, mainIcon:getContentSize().height + 10))
            image:addTo(mainIcon)

            if tonumber(item["chair_"..i.."_uid"]) == 0 then
                self["Node_"..i]:setVisible(false)
            end

            -- local playname= cc.LabelTTF:create(item["chair_"..i.."_name"], self.font, 30):addTo(self.record_main_item_info,1)
            -- playname:setPosition(cc.p(x+offset_x, y))
            -- playname:setColor(cc.c3b(142, 108, 89))
            -- local playpoint= cc.LabelTTF:create(item["chair_"..i.."_point"], self.font, 30):addTo(self.record_main_item_info,1)
            -- playpoint:setPosition(cc.p(x+offset_x, y-45))
            -- playpoint:setColor(cc.c3b(142, 108, 89))
            -- x = x+iw
            -- if i<playcount then
            --     local line = display.newSprite("mj/record_line.png", 0, 0):addTo(self.record_main_item_info, 1)
            --     line:setPosition(cc.p(x,0))
            --     line:setAnchorPoint(cc.p(0,0))
            -- end
        end

         self.Image_1:addTouchEventListener(function(sender,eventType)
              if eventType == ccui.TouchEventType.ended then
                  UIMgr:openUI(consts.UI.RecordDetailUI,nil,nil,item)
              end
         end)

       -- self.Image_1:addTouchEventListener(function(sender, eventType)
       --     if eventType == ccui.TouchEventType.began then
       --         sender.canOpen = true
       --     elseif eventType == ccui.TouchEventType.moved then
       --         sender.canOpen = false
       --     elseif eventType == ccui.TouchEventType.ended then
       --         if sender.canOpen then
       --             UIMgr:openUI(consts.UI.RecordDetailUI,nil,nil,item)
       --         end
       --     end
       -- end)
    end
end

function RecordMainItemUI:getChairCount(item)
    if item then
        if item.chair_4_uid then
            return 4
        elseif item.chair_3_uid then
            return 3
        elseif item.chair_2_uid then
            return 2
        end
    end
    return 1
end

function RecordMainItemUI:onItemClick(args)
    UIMgr:openUI(consts.UI.RecordDetailUI)
end

return RecordMainItemUI