--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
HttpServiers={}
-- 登陆
function HttpServiers:login(params,callback)
   return HttpClient:asyncGet(consts.HttpUrl.thirdPartyLogin, params,callback)
end
-- 房卡余额
function HttpServiers:getFunds(params,callback)
   return HttpClient:asyncGet(consts.HttpUrl.getFunds, params,callback)
end

-- 根据局头用户ID获取俱乐部信息
function HttpServiers:getClubInfo(params,callback)
   return HttpClient:asyncGet(consts.HttpUrl.getClubInfo, params,callback)
end

-- 俱乐部榜单数据
function HttpServiers:getRankList(params,callback)
   return HttpClient:asyncGet(consts.HttpUrl.getRankList, params,callback)
end

-- 创建房间
function HttpServiers:creatRoom(params,callback)
   return HttpClient:asyncGetWhitGameHttpHost(consts.GameHttpUrl.createRoom, params,callback)
end
-- 批量创建房间
function HttpServiers:createRoomBatch(params,callback)
   return HttpClient:asyncGetWhitGameHttpHost(consts.GameHttpUrl.createRoomBatch, params,callback)
end
-- 根据房间号查询战斗服地址，进入房间
function HttpServiers:queryRoom(params,callback)
   return HttpClient:asyncGetWhitGameHttpHost(consts.GameHttpUrl.queryRoom, params,callback)
end
-- 查询用户当前状态（是否是断线重连）
function HttpServiers:queryStaus(params,callback)
   return HttpClient:asyncGetWhitGameHttpHost(consts.GameHttpUrl.queryStaus, params,callback)
end

--历史战绩列表
function HttpServiers:queryResultList(params,callback)
   return HttpClient:asyncGet(consts.HttpUrl.getResultList, params,callback)
end

--历史战绩详细
function HttpServiers:queryResultDetail(params,callback)
   return HttpClient:asyncGet(consts.HttpUrl.getResultDetail, params,callback)
end

--通过分享码获取小局战绩
function HttpServiers:queryResultShareDetail(params,callback)
   return HttpClient:asyncGet(consts.HttpUrl.getShareDetail, params,callback)
end

--反馈
function HttpServiers:queryqFankuiResult(params,callback)
   return HttpClient:asyncGet(consts.HttpUrl.getFankuiResult, params,callback)
end


--活动公告，系统公告，游戏消息，玩法列表
function HttpServiers:queryArticleList(params,callback)
   return HttpClient:asyncGet(consts.HttpUrl.getArticleList, params,callback)
end

--俱乐部
function HttpServiers:queryqClubResult(params,callback)
   return HttpClient:asyncGet(consts.HttpUrl.getClubList, params,callback)
end

--商品购买列表
function HttpServiers:queryRechargeList(params,callback)
   return HttpClient:asyncGet(consts.HttpUrl.getRechargeList, params,callback)
end

--可支付渠道列表
function HttpServiers:queryPayList(params,callback)
   return HttpClient:asyncGet(consts.HttpUrl.getPayList, params,callback)
end

--客户端App充值下单
function HttpServiers:queryrechargeAccount(params,callback)
   return HttpClient:asyncGet(consts.HttpUrl.rechargeAccount, params,callback)
end

-- 上传ping值
function HttpServiers:pingValue(params,callback)
   return HttpClient:asyncGet(consts.HttpUrl.pingValue, params,callback)
end


--红包主界面信息
function HttpServiers:queryRedpackMain(params,callback)
   return HttpClient:asyncGet(consts.HttpUrl.redpackMain, params,callback)
end
--领取的红包日志列表
function HttpServiers:queryRedpackUserLog(params,callback)
   return HttpClient:asyncGet(consts.HttpUrl.redpackUserLog, params,callback)
end
--领取红包
function HttpServiers:queryRedpackFetch(params,callback)
   return HttpClient:asyncGet(consts.HttpUrl.redpackFetch, params,callback)
end
--绑定账号
function HttpServiers:queryRedpackBindAcc(params,callback)
   return HttpClient:asyncGet(consts.HttpUrl.redpackBindAcc, params,callback)
end
--结算获取红包金额
function HttpServiers:queryRedpackGetMoney(params,callback)
   return HttpClient:asyncGet(consts.HttpUrl.redpackGetMoney, params,callback)
end
--查询是否代理
function HttpServiers:queryIsAgent(params,callback)
   return HttpClient:asyncGet(consts.HttpUrl.queryIsAgent, params,callback)
end
--房卡转让
function HttpServiers:cardGive(params,callback)
   return HttpClient:asyncGet(consts.HttpUrl.exchangeCards, params,callback)
end

return HttpServiers
