local SummaryResultModel = class("SummaryResultModel" , cc.load("mvc").ModelBase)

function SummaryResultModel:ctor(callback)
    JoinModel.super.ctor(self,callback)
end

function SummaryResultModel:getProList()
	--页面数据
    local list = {
    	"game_balance_result",
    }
    return list
end

return SummaryResultModel