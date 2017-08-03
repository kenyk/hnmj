

local LocationUI = class("LocationUI", cc.load("mvc").UIBase)

LocationUI.RESOURCE_FILENAME = "uiLocation/UI_Location.csb"

function LocationUI:onCreate()
    self:setInOutAction()
    self.closeBtn = helper.findNodeByName(self.resourceNode_,"closeBtn")
    self.closeBtn:setPressedActionEnabled(true)

    self.m_pNode = {}
    for i=1,4 do
        self.m_pNode[i] = helper.findNodeByName(self.resourceNode_,"node_"..i)
        self.m_pNode[i].head = helper.findNodeByName(self.resourceNode_,"head_"..i)
        self.m_pNode[i].name = helper.findNodeByName(self.resourceNode_,"name_"..i)
    end

    self.m_line = {}
    for i=1,6 do
        self.m_line[i] = helper.findNodeByName(self.resourceNode_,"line_node_"..i)
        self.m_line[i].des = helper.findNodeByName(self.resourceNode_,"line_des_"..i)
        self.m_line[i].line = {}
        if(i > 4)then
            self.m_line[i].line[1] = helper.findNodeByName(self.resourceNode_,"line_"..i.."_1")
            self.m_line[i].line[2] = helper.findNodeByName(self.resourceNode_,"line_"..i.."_2")
        else
            self.m_line[i].line[1] = helper.findNodeByName(self.resourceNode_,"line_"..i)
        end
    end
    self:updateMsg()
end

function LocationUI:updateMsg()

    --2人：13,3人：124
    local player_count = UserData.table_config.player_count
    local game_count = UserData.table_config.game_count
    local posLs = {}
    for i = 1, player_count do
        local pInfo     = UserData:getPlayerInfoByChairId(i)
        local realPos   = helper.getRealPos(i,UserData.myChairId,player_count)
        
        if pInfo then
            self:setPlayerMsg(realPos,{name = pInfo.nickname,url = pInfo.image_url})
            posLs[realPos] = {pInfo.antiCheatLon,pInfo.antiCheatLat}
        end
    end

    --人头
    for i=1,4 do
        self.m_pNode[i]:setVisible(posLs[i] ~= nil)
    end

    local needLs = {{1,4},{3,4},{3,2},{1,2},{4,2},{1,3}}
    local color = {cc.c3b(238, 51, 51),cc.c3b(59, 223, 32),cc.c3b(164, 164, 164)}--红，绿，灰
    local foneSize = {44,28,28}

    --线条
    for i=1,6 do
        self.m_line[i]:setVisible(self.m_pNode[needLs[i][1]]:isVisible() and  self.m_pNode[needLs[i][2]]:isVisible())

        if(self.m_line[i]:isVisible())then
            local aPos = posLs[needLs[i][1]]
            local bPos = posLs[needLs[i][2]]

            local str = "无法识别"
            local colorType = 3
            if(aPos and aPos[1] and bPos and bPos[1])then
                str,colorType = self:getLocatStr(aPos[1],aPos[2],bPos[1],bPos[2])
            end
            self.m_line[i].des:setString(str)
            self.m_line[i].des:setTextColor(color[colorType])
            self.m_line[i].des:setFontSize(foneSize[colorType])

            --线图
            local lineType = i > 4 and 2 or 1
            if(self.m_line[i].line[1])then
                self.m_line[i].line[1]:loadTexture(string.format("uires/location/l_line_%s_%s.png",colorType,lineType))
            end
            if(self.m_line[i].line[2])then
                self.m_line[i].line[2]:loadTexture(string.format("uires/location/l_line_%s_%s.png",colorType,lineType))
            end
        end
    end
end

function LocationUI:getLocatStr( lat1, lng1, lat2, lng2 )

    if(not lat1 or not lng1 or not lat2 or not lng2)then return "无法识别",3 end

    local juli = helper.distance_earth(lat1, lng1, lat2, lng2)

    if(juli > 10000 and juli < 5000000) then
        return string.format("%.1f公里",juli/1000),2
    elseif(juli > 5000000) then
        return "无法识别",3
    else
        return string.format("%d米",juli),juli > 500 and 2 or 1
    end
end

function LocationUI:setPlayerMsg(index, info )

    self.m_pNode[index].name:setString(info.name)

    if(Is_App_Store)then
        self.m_pNode[index].head:loadTexture("uires/main/guest_icon_1.png")
    elseif info.url then
        local newHead = NetSprite:getSpriteUrl(info.url,"mj/bg_default_avatar_1.png")
        -- newHead:setPosition(cc.p(58,58))
        -- newHead:setImageContentSize(cc.size(116,116))
        newHead:setPosition(cc.p(60,60))
        newHead:setImageContentSize(cc.size(120,120))
        newHead:addTo(self.m_pNode[index].head,0)
    else
      self.m_pNode[index].head:loadTexture("mj/bg_default_avatar_1.png")
    end
end


function LocationUI:onClose()
    self:close()
end

return LocationUI




