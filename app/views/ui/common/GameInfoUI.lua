--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

local GameInfoUI = class("GameInfoUI", cc.load("mvc").UIBase)

GameInfoUI.RESOURCE_FILENAME = "common/UI_Game_Info.csb"

function GameInfoUI:onCreate()
    self.txTime = helper.findNodeByName(self.resourceNode_, "txTime")
    self.txRule = helper.findNodeByName(self.resourceNode_, "txRule")
    self.txRoomNum = helper.findNodeByName(self.resourceNode_, "txRoomNum")
    self.txRoomNum:setString("房间 " .. UserData.roomId);
    if UserData.table_config ~= nil then
        if UserData.table_config.rule_txt_first_line ~= nil and #UserData.table_config.rule_txt_first_line > 0 then
            local x = 1346
            --self.txRoomNum:setPosition(cc.p(x,100))
          
            self.txRule:setString(string.sub(UserData.table_config.rule_txt_first_line ,1, #UserData.table_config.rule_txt_first_line - 1))
            --self.txRule:setPosition(cc.p(x,74))
           
            self.txRuleSecondLine = ccui.Text:create(string.sub(UserData.table_config.rule_txt,
              #UserData.table_config.rule_txt_first_line + 2,#UserData.table_config.rule_txt),
               "sfzht.ttf",22)
            self.txRuleSecondLine:setColor(cc.c3b(255,255,255))
            self.txRuleSecondLine:addTo(self, 0)
            self.txRuleSecondLine:setAnchorPoint(cc.p(1,0.5))
            self.txRuleSecondLine:setPosition(cc.p(x, 48))
        else
            self.txRule:setString(UserData.table_config.rule_txt) 
        end            
        self.txTime:setString( os.date("%Y-%m-%d %H:%M:%S"))
    end
  
end

return GameInfoUI;
