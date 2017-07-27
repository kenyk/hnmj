--
-- Author: LXL
-- Date: 2016-11-03 17:20:41
--

UserData = {}

UserData.sex = 1 --1男2女


UserData.GAME_STATUS = {
    -- 游戏等待中
    waiting  = 1,
    -- 游戏已经开局
    start = 2,
    -- 等待下一小局开始
    nextWaiting = 3
}

--游戏中的状态
UserData.game_status = nil

function UserData:setGameStatus(status)
    -- if UserData.game_status == status then return end
    UserData.game_status = status
    NotifyMgr:push(consts.Notify.MAH_JONE_CHANGE_GAME_STATUS)
end

UserData.averPingTbl = {}
--能否上传ping
UserData.canUploadPing = true

UserData.login = false

UserData.playerPoint = {} --key是chair_id

UserData.isBack = false --是否是返回房间

UserData.disMissTime = 300

--.players_info {
--  uid 0 : integer             #玩家ID
--  chair_id 1 : integer          #玩家chair_id
--  nickname 2 : string           #玩家昵称
--  image_url 3 : string          #玩家头像
--  gender 4 : integer            #玩家性别female:0, male:1
--  game_state 5 : integer          #玩家状态(1.坐下2.准备3.观众4.游戏中)

--}

-- UserData.players = nil
-- UserData.cardResult = nil
-- UserData.uid        = nil
-- UserData.icon       = nil
-- UserData.roomId     = nil
-- UserData.myChairId   = nil
-- UserData.roomDismiss= false                     --房间是否被解散
-- UserData.curMahjongType = 0  --当前开局的麻将类型
-- UserData.laiziCardId = nil  --当局癞子牌
-- UserData.laizipiCardId = nil  --当局癞子皮
-- --UserData.tableId = nil



UserData.players = nil
UserData.cardResult = nil
UserData.uid        = nil
UserData.icon       = nil
UserData.roomId     = nil
UserData.myChairId   = nil
UserData.roomDismiss= false                     --房间是否被解散
UserData.curMahjongType = 0  --当前开局的麻将类型
UserData.laiziCardId = nil  --当局癞子牌
UserData.laizipiCardId = nil  --当局癞子皮
--UserData.tableId = nil



-- {game_type:1,idle:true,laizi:true,seven_hu:true,find_bird:2}
--  #胡牌方式:(1.炮胡，2.自模胡)、是否庄闲、是否有癞子、是否能胡七对、抓鸟数
UserData.table_config = nil
-- {
--     rule ={
--         game_type,
--         laizi,
--         find_bird,
--         bird_point,
--         seven_hu,
--         idle,
--         qiang_gang
--     },
--     master_id,
--     rule_txt,
--     rule_txt_first_line,
--     rule_txt_first_line_max_length,
--     create_time,
--     game_count,
--     player_count,
--     rate
-- }

-- 大局结算结果
UserData.game_balance_result = nil

--反馈暂存的电话
UserData.fankuiTel = nil

--暂存的房号，用于防作弊加入房间
UserData.roomIdTmp = nil

--是否加入俱乐部标志
UserData.isAddClub = nil

--登录弹红包UI
UserData.loginOpenHB = false

--清掉癞子和赖子皮信息
function UserData:clearLaizipiAndLaizi()
    UserData.laiziCardId = nil
    UserData.laizipiCardId = nil
end

function UserData:setPlayersInfo(players)
    self.myChairId = nil
    self.players = players
    for _,v in pairs(players) do
        --过长 省略
        v.nickname = helper.nameAbbrev(v.nickname)
        if tonumber(v.uid) == tonumber(UserData.uid) then
            UserData.myChairId = v.chair_id
        end
        UserData:setPlayerPoint(v.chair_id,v.point)

        --分离ip和经纬
        local tab = string.split(v.ip,"_")
        v.ip = tab[1]
        if(#tab > 2)then
            v.antiCheatLon = tonumber(tab[2])
            v.antiCheatLat = tonumber(tab[3])
        end
    end
    --如果观看别人的战局 这里会空
    if nil == UserData.myChairId then
        UserData.myChairId = players[1].chair_id
    end
end

function UserData:setRule(someRule)
    if (UserData.table_config.rule_txt_first_line == nil) and  #UserData.table_config.rule_txt + #someRule >  UserData.table_config.rule_txt_first_line_max_length then
            UserData.table_config.rule_txt_first_line = UserData.table_config.rule_txt
            UserData.table_config.rule_txt = UserData.table_config.rule_txt .. "\n"
    end
    UserData.table_config.rule_txt = UserData.table_config.rule_txt .. someRule .. " "
end

function UserData:setTableConfig(table_config)
    UserData.table_config = table_config
    if not table_config.data then
        return
    end
    UserData.table_config.rule = json.decode(table_config.data)
    local temp = UserData.table_config.rule
    if temp.type then
        UserData.curMahjongType = temp.type
    end

    local firstLineMaxLength = 50
    UserData.table_config.rule_txt_first_line_max_length = firstLineMaxLength
    UserData.table_config.rule_txt = ""
    local numAndGameName = UserData.table_config.player_count .. "人" .. consts.GameTypeName[UserData.curMahjongType > 0 and UserData.curMahjongType or 1] .. " "
    if nil == temp.game_type then
        UserData.table_config.rule_txt = numAndGameName .. UserData.table_config.rule_txt .. " "
    else
        UserData.table_config.rule_txt = numAndGameName .. UserData.table_config.rule_txt .. consts.GameHuType[temp.game_type] .. " "
    end
    if temp.qiang_gang then
        UserData:setRule("抢杠胡")
    end
    if temp.ming_gang then
        UserData:setRule("可抢明杠")
    end
    if temp.idle then
        UserData:setRule("庄闲算分")
    end
    if temp.piao then
        UserData:setRule("飘")
    end
    if temp.laizi then
        UserData:setRule("红中癞子")
    end

    if temp.seven_hu then
        UserData:setRule("胡七对")
    end

    if temp.kaiwang then
        UserData:setRule("开王")
    end

    if temp.firstHu then
        UserData:setRule("起手胡")
    end

    if temp.bighu and temp.bighu > 0 then
        UserData:setRule( "大胡" .. temp.bighu .. "分")
    end

    if UserData:isChangDe() or UserData:isHongZhong() then
        if temp.find_bird ~= nil and temp.find_bird > 0 then
            if 1 == temp.find_bird then
                UserData:setRule("一码全中")
            else
                UserData:setRule("扎" .. temp.find_bird .. "码")
            end
        end
    else
        if temp.find_bird ~= nil and temp.find_bird > 0 then
            UserData:setRule("抓" .. temp.find_bird .. "鸟")
        end
    end
    if temp.bird_point ~= nil and temp.bird_point > 0 then
        UserData:setRule( "鸟" .. temp.bird_point .. "分")
    end

    if temp.goldbird then
        UserData:setRule("金鸟")
    end

    if temp.huangzhuang then
        UserData:setRule("荒庄荒杠")
    end

    UserData.table_config.rule_txt = string.sub(UserData.table_config.rule_txt, 1, (#UserData.table_config.rule_txt - 1))
end

function UserData:getShareDesc(data)
    local temp = data or UserData.table_config.rule
    print("------------胡啥呀--------")
    dump(temp)
    print("-----------------------")
    local txt = ""
    --防作弊
    if(temp.is_cheat_room)then
        txt = txt .."防作弊模式 "
    end

    --转转麻将才显示胡
    if(UserData.curMahjongType == 1)then
        txt = txt .. consts.GameHuType[temp.game_type] .. " "
    end

    if temp.qiang_gang then
        txt = txt .."抢杠胡 "
    end
    if temp.ming_gang then
        txt = txt .."可抢明杠 "
    end
    if temp.idle then
       txt = txt .."庄闲算分 "
    end
    if temp.piao then
       txt = txt .."飘 "
    end
    if temp.laizi then
        txt = txt .."红中癞子 "
    end

    if temp.seven_hu then
       txt = txt .."胡七对 "
    end

    if temp.kaiwang then
        txt = txt .."开王 "
    end

    if temp.firstHu then
        txt = txt .."起手胡 "
    end

    if temp.bighu and temp.bighu > 0 then
        txt = txt .."大胡" .. temp.bighu .. "分 "
    end

    if UserData:isChangDe() or UserData:isHongZhong() then
        if temp.find_bird ~= nil and temp.find_bird > 0 then
            if 1 == temp.find_bird then
                txt = txt .."一码全中 "
            else
                txt = txt .."扎" .. temp.find_bird .. "码 "
            end
        end
    else
        if temp.find_bird ~= nil and temp.find_bird > 0 then
            txt = txt .."抓" .. temp.find_bird .. "鸟 "
        end
    end

    if temp.bird_point ~= nil and temp.bird_point > 0 then
        txt = txt .."鸟" .. temp.bird_point .. "分 "
    end

    if temp.goldbird then
        txt = txt .."金鸟 "
    end

    if temp.huangzhuang then
        txt = txt .."荒庄荒杠 "
    end
    
    return txt
end

  
function UserData:isLaizi()
    if self.table_config then
        return self.table_config.rule.laizi or self.table_config.rule.hongzhong
    else
        return false
    end
end

--获取总牌数
function UserData:getTotalCardNum()
    if self.table_config.player_count < 3 then
        return 64
    elseif self:isLaizi() then
        return 112
    else
        return 108
    end
end

--断线重连之后的当前小局数
UserData.reconnectedGameIndex = nil

--获取当前局数
function UserData:getCurCount()
    if self.cardResult then
        return self.cardResult.game_index + 1
    elseif self.reconnectedGameIndex then
        return self.reconnectedGameIndex
    else
        return 1
    end
end

--设置当前局数
function UserData:setCurCount(index)
    self.cardResult = self.cardResult or {}
    self.cardResult.game_index = index
end

--获取总局数
function UserData:getTotalCount()
    return UserData.table_config.game_count
end

--开始新的大局时清空所有数据
function UserData:clearData()
    self.status     = nil
    self.login = false
    self.players = nil
    self.cardResult = nil
    self.name       = nil
    self.uid        = nil
    self.icon       = nil
    self.roomId     = nil
    self.myChairId   = nil
    self.table_config = nil
    self.reconnectedGameIndex = nil
    self.isAddClub = nil
end

--开始新的大局时清空牌桌数据
function UserData:clearTableData()
    print("开始新的大局时清空牌桌数据")
    self.playerPoint = {}
    self.status     = nil
    self.players = nil
    self.roomId     = nil
    self.myChairId   = nil
    self.game_status = nil
    self.roomDismiss = false
    self.cardResult = nil
    self.table_config = nil
    self.game_balance_result = nil
    self.reconnectedGameIndex = nil
    UserData.curMahjongType = 0
    self.laiziCardId = nil  --当局癞子牌
    self.laizipiCardId = nil  --当局赖子皮
    self.disMissTime = 300
end

function UserData:getPlayerInfoById(id)
    if not UserData.players then return nil end
    for k,v in pairs(UserData.players) do
        if v.uid == id then
            return v
        end
    end
    return nil
end

function UserData:getPlayerInfoByChairId(id)
    if not UserData.players then return nil end
    for k,v in pairs(UserData.players) do
        if v.chair_id == id then
            return v
        end
    end
    return nil
end

-- 当前用户非房主
function UserData:isNotRoomMaster()
    if UserData.table_config then
        if UserData.table_config.master_id==UserData.uid then
            return false
        end
        return true
    end
end

-- 当前用户非房主
function UserData:isRoomMaster(uid)
    if UserData.table_config then
        if UserData.table_config.master_id==uid then
            return true
        end
    end
    return false
end

-- 设置积分
function UserData:setPlayerPoint(chairid,add)
    self.playerPoint[chairid] = add
end

function UserData:getPlayerPoint(chairid)
    -- self.playerPoint[chairid] = self.playerPoint[chairid] or 1000
    self.playerPoint[chairid] = self.playerPoint[chairid] or 0
    return self.playerPoint[chairid]
end

---------------断线重连数据
UserData.isInGame = false                   --标记是否在打牌中
UserData.isReConnect = false

UserData.PlatformRoomId = nil
-- #玩家重连推送桌子信息
-- room_post_table_reconnect 4005 {
--   request {
--     table_config 0 : table_config_info
--     players 1 : *players_info
--     enter_code 2 : integer
--     is_playing 3 : boolean
--   }
-- }
UserData.reConnectCardData = nil

--"data" = {
--"ip"              = "10.17.173.79"
--"isNew"           = 0
--"surplusGameCard" = "3"
--"token"           = "d364b37ffb3f98a6316f02cd787e206e"
--"totalGameCard"   = "3"
--"userId"          = "13"
-- nickName
-- gender
--}
UserData.userInfo = nil


UserData.netInfo = nil
UserData.batteryInfo = nil
UserData.replayInfo = nil

function UserData:isChangSha()
    if UserData.curMahjongType == 2 then
        return true
    else
        return false
    end
end

function UserData:isZhuanZhuan()
    if UserData.curMahjongType == 1 then
        return true
    else
        return false
    end
end

function UserData:isChenZhou()
    if UserData.curMahjongType == 3 then
        return true
    else
        return false
    end
end

function UserData:isHongZhong()
    if UserData.curMahjongType == 4 then
        return true
    else
        return false
    end
end

function UserData:isNingXiang()
    if UserData.curMahjongType == 5 then
        return true
    else
        return false
    end
end

function UserData:isChangDe()
    if UserData.curMahjongType == 6 then
        return true
    else
        return false
    end
end

function UserData:getCurBgType()
    return cc.UserDefault:getInstance():getStringForKey("setting_bg_type")
end

--获取可胡七对的params,听牌算法需要用
function UserData:getQiDuiTbl()
    if UserData:isHongZhong() or UserData:isZhuanZhuan() or UserData:isChenZhou() then
        if UserData.table_config.rule.seven_hu then
            return {qidui2 = true}
        else
            return {}
        end 
    else
        return {}
    end
end

function UserData:getLaiziId()
    if UserData:isLaizi() then
        return 45
    elseif UserData.laiziCardId then
        return UserData.laiziCardId
    else
        return 0
    end
end