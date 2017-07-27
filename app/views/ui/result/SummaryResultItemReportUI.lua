--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

local SummaryResultItemReportUI = class("SummaryResultItemReportUI", cc.load("mvc").UIBase)

SummaryResultItemReportUI.RESOURCE_FILENAME = "uiResult/UI_Summary_Result_Item_Report.csb"

function SummaryResultItemReportUI:onCreate()
        self.iPlayerAvatar = helper.findNodeByName(self.resourceNode_,"iPlayerAvatar");
        self.txPlayerName = helper.findNodeByName(self.resourceNode_,"txPlayerName");
        self.txPlayerAccount = helper.findNodeByName(self.resourceNode_,"txPlayerAccount");
        self.sFlagWinner = helper.findNodeByName(self.resourceNode_,"sFlagWinner");
        self.sFlagPaoShou = helper.findNodeByName(self.resourceNode_,"sFlagPaoShou"):setVisible(false);
        self.txScores = helper.findNodeByName(self.resourceNode_,"txScores");
        self.sFlagRoomHost = helper.findNodeByName(self.resourceNode_, "sFlagRoomHost")
        self.layoutZhuanZhuan = helper.findNodeByName(self.resourceNode_, "layoutZhuanZhuan")
        self.layoutChangSha = helper.findNodeByName(self.resourceNode_, "layoutChangSha")
        self.hongbao_node = helper.findNodeByName(self.resourceNode_, "hongbao_node")
        self.hb_num = helper.findNodeByName(self.resourceNode_, "hb_num")
        self.hb_act_node = helper.findNodeByName(self.resourceNode_,"hb_act_node")
        self.money_node = helper.findNodeByName(self.resourceNode_,"money_node")
    if UserData:isZhuanZhuan() or UserData:isChenZhou() or UserData:isHongZhong() or UserData:isChangDe() then
        self.layoutZhuanZhuan:setVisible(true)
        self.layoutChangSha:setVisible(false)
        self.txZiMoCount = helper.findNodeByName(self.resourceNode_,"txZiMoCount");
        self.txJiePaoCount = helper.findNodeByName(self.resourceNode_,"txJiePaoCount");
        self.txDianPaoCount = helper.findNodeByName(self.resourceNode_,"txDianPaoCount");
        self.txAnGangCount = helper.findNodeByName(self.resourceNode_,"txAnGangCount");
        self.txMingGangCount = helper.findNodeByName(self.resourceNode_,"txMingGangCount");
    elseif UserData:isChangSha() or UserData:isNingXiang() then
        self.layoutZhuanZhuan:setVisible(false)
        self.layoutChangSha:setVisible(true)
        self.txDZiMoCount = helper.findNodeByName(self.layoutChangSha,"txDZiMoCount");
        self.txXZiMoCount = helper.findNodeByName(self.layoutChangSha,"txXZiMoCount");
        self.txDDianPaoCount = helper.findNodeByName(self.layoutChangSha,"txDDianPaoCount");
        self.txXDianPaoCount = helper.findNodeByName(self.layoutChangSha,"txXDianPaoCount");
        self.txDJiePaoCount = helper.findNodeByName(self.layoutChangSha,"txDJiePaoCount");
        self.txXJiePaoCount = helper.findNodeByName(self.layoutChangSha,"txXJiePaoCount");        
    end
end

return SummaryResultItemReportUI