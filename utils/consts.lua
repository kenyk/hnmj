--[["
	desc: 系统常量定义类
	author: LXL
	since: 2015-07-30
 "]]

consts = {}

import(".consts_Notify")

consts.Size = {
    width = cc.Director:getInstance():getVisibleSize().width,
    height = cc.Director:getInstance():getVisibleSize().height
}

consts.Point = {
    CenterAnchorPoint = cc.p(0.5,0.5),
    CenterPosition = cc.p(consts.Size.width/2, consts.Size.height/2)
}



consts.App = {
    APP_FILE_PATH = cc.FileUtils:getInstance():getWritablePath(), --文件系统路径,
    APP_PLATFORM = cc.Application:getInstance():getTargetPlatform() --运行平台
}

--颜色
consts.ColorType = {
    BLACK  = cc.c3b(0,0,0),     -- 黑色色字体颜色
    WHITE = cc.c3b(255,255,255),    --白色
    RED = cc.c3b(255,0,0),  --红色
    GREEN = cc.c3b(0,255,0),    --绿色
    BLUE = cc.c3b(0,0,255),     --蓝色
    YELLOW = cc.c3b(255,255,0),  --黄色
    GREY = cc.c3b(110,110,110),     --灰色
    GOLD = cc.c3b(255,215,0),    --金色
    THEME = cc.c3b(153, 78, 46)
}


consts.UI = {
    login = "app.views.ui.login.LoginUI",
    loginlow = "app.views.ui.login.LoginLowUI",
    mainUI = "app.views.ui.main.GameMainUI",
    createRoomUI = "app.views.ui.create.CreateRoomUI",
    joinRoomUI = "app.views.ui.join.JoinUI",
    cardResultUI = "app.views.ui.result.CardResultUI",
    SummaryResultUI = "app.views.ui.result.SummaryResultUI",
    SummaryResultItemReportUI = "app.views.ui.result.SummaryResultItemReportUI",
    GameInfoUI = "app.views.ui.common.GameInfoUI",
    SettingUI = "app.views.ui.setting.SettingUI",
    ConfirmDialogUI = "app.views.ui.common.ConfirmDialogUI",
    PlayerInfoUI = "app.views.ui.common.PlayerInfoUI",
    HelpUI = "app.views.ui.setting.HelpUI",
    UserAgreementUI = "app.views.ui.login.UserAgreementUI",
    WebViewUI =  "app.views.ui.common.WebViewUI",
    LoadingDialogUI =  "app.views.ui.common.LoadingDialogUI",
    SharePanelUI = "app.views.ui.share.SharePanelUI",
    ChatUI =  "app.views.ui.chat.ChatUI",
    RecordMainItemUI =  "app.views.ui.record.RecordMainItemUI",
    RecordMainUI =  "app.views.ui.record.RecordMainUI",
    RecordDetailUI =  "app.views.ui.record.RecordDetailUI",
    RecordDetailItemUI =  "app.views.ui.record.RecordDetailItemUI",
    FankuiUI = "app.views.ui.fankui.FankuiUI",
    createRoomUITwo = "app.views.ui.create.CreateRoomUITwo",
    buyCardPanel = "app.views.ui.common.BuyCardPanel",
    ClubRoomUI = "app.views.ui.club.ClubRoomUI",
    BattleSettingUI = "app.views.ui.battle.BattleSetting",
    PayUI = "app.views.ui.pay.PayUI",
    haidiui = "app.views.ui.haidi.HaidiUI",
    ReplayUI = "app.views.ui.replay.ReplayUI",
    RuleUI = "app.views.ui.rule.RuleUI",
    HongbaoUI = "app.views.ui.hongbao.HongbaoUI",
    MotanUI = "app.views.ui.motan.MotanUI",
    BindAccountUI = "app.views.ui.hongbao.BindAccountUI",
    LocationUI = "app.views.ui.location.LocationUI",
    ClubInputCreate = "app.views.ui.club.ClubInputCreate",
    ClubCreateMany = "app.views.ui.club.ClubCreateMany",
    ClubSingleRoom = "app.views.ui.club.ClubSingleRoom",
    ClubRankView = "app.views.ui.club.ClubRankView",
    DismissRoomDialog = "app.views.ui.dismiss.DismissRoomApplyDialogLayerSec",
    PlayerVoteStatusUI = "app.views.ui.dismiss.PlayerVoteStatusUI",
}

consts.GameType = {
    zhuanzhuan = "zhuanzhuan",
    changsha = "changsha",
}

consts.GameHuType = {
    "点炮胡",
    "自摸胡"
}

consts.GameTypeName = {
    "转转",
    "长沙",
    "郴州",
    "红中",
    "宁乡",
    "常德",
}
--能使用听牌提示的麻将类型 ps：对应GameTypeName，改的时候顺便改下
consts.TingPaiGameType = {true,false,true,true,false,true}

-- consts.PlayScene = "testPlayScene"  --LXL
-- consts.PlayScene = "MahjongScene"   --江宝添

consts.DefauleGameType = consts.GameType.zhuanzhuan

---内网
 -- consts.HttpHost = "10.17.174.171:8192"
 -- consts.GameHttpHost = "10.17.174.116:8001"

--consts.BIHttpHost_lan = "10.17.174.171:8081"
consts.BIHttpHost_lan = "121.201.48.188:8192"
consts.BIHttpHost_wan = "bidata.kuailai88.com"

---外网
consts.HttpHost = "121.201.48.188:8192"
--consts.HttpHost = "192.168.1.103:20002"
consts.GameHttpHost = "121.201.48.188:8001"
consts.BIHttpHost = consts.BIHttpHost_lan

consts.HttpUrl = {
    thirdPartyLogin =  "/user/thirdPartyLogin",
    getFunds  = "/user/getFunds",
    getClubInfo  = "/Club/getClubInfo",
    getRankList  = "/Club/rankList",
    getResultList = "/Game/getResultLst",
    getResultDetail = "/Game/getResultDetail",
    getShareDetail = "/Game/getShareDetail",
    getFankuiResult = "/Suggestion/add",
    getCodeCrashesResult = "/Log/appError",  
    getArticleList = "/Article/lst", 
    getClubList = "/User/getClubList",
    getRechargeList = "/Buy/getRechargeList",
    getPayList = "/Buy/getPayList",
    rechargeAccount = "/Buy/rechargeAccount",
    pingValue = "/Log/pingValue",
    redpackMain = "/Redpackage/main",
    redpackUserLog = "/Redpackage/getUserLog",
    redpackFetch = "/Redpackage/fetchRedpackage",
    redpackBindAcc = "/Redpackage/bindAccount",
    redpackGetMoney = "/Redpackage/getMoneyByUsers"
}

consts.GameHttpUrl = {
    createRoom  = "/create_room",
    queryRoom  = "/query_room",
    queryStaus  = "/player_status",
    createRoomBatch  = "/create_room_batch",
}

consts.BIHttpUrl = {
    BIeventInfo = "/klmj/eventInfo"
}

consts.appId = 1
consts.appCode = "klmj"
--客户端来源标志
consts.clientFrom = {
    ios = 1,
    android = 2,
    windows = 3
}

consts.gender = {
    man = 1,
    woman = 2
}


--注册来源
consts.loginFrom = {
    normal = 0,
    weixin = 10,
    weobo = 20,
}

consts.clientVer = "0.1"

consts.chatMsgArray = {
        "不好意思，我有事要先走一步了",
        "大家好，很高兴见到各位",
        "哈哈，手气真好",
        "今天真高兴",
         "快点出牌哦",
        "你的牌打得太好了",
        "你放炮我不胡",
        "你家里是开银行的吧",
        "你太牛了",
        "怎么又断线了，网络怎么这么差啊",
        "这个吃的好",
        "别急嘛,让我再想想",

        }


consts.BIsessionId = tostring(os.time())
consts.BIAppId = {
    ios = "2",
    android = "1",
    windows = "6"
}

consts.BIosType = {
    ios = "2",
    android = "1",
    windows = "3"
}

consts.BIeventType = {
   page = "1",
   click = "2"
}

consts.BIcurrentPath = {
   indexPage = "indexPage",
   loginSuccessClick = "loginSuccessClick",
   loginPage = "loginPage"
}

consts.bgSize={
    s={
        w = 610,
        h = 226
    },
    m={
        w = 736,
        h = 300
    },
    l={
        w = 896,
        h = 566
    }
}

consts.replayTime = 0.0001

consts.GCloudVoice = {
   GCLOUD_GAME_ID = "1410288508",
   GCLOUD_GAME_KEY = "4538d544bfc6f869357aa88d23c3d9da"
}

consts.wechatAppId =  "wxf0862d65306b025a"
consts.roomCreateMsg = {}
-- consts.roomCreateMsg.tab_1 = 
-- {
--     {"局数",{1," 8局","createC8","(房卡x1)"},{1,"16局","createC16","(房卡x2)"}},
--     {"人数",{1,"4人局","createP4"},{1,"3人局","createP3"},{1,"2人局","createP2"}},
--     {"玩法",{1,"点炮胡","createWin1"},{1,"自摸胡","createWin2"},{2,"抢杠胡","createWin3"}},
--     {"",{2,"庄闲算分","createCon1"},{2,"可胡七对","createCon2"},{2,"红中癞子","createCon3"}},
--     {"抓鸟",{1,"抓2鸟","createPick2"},{1,"抓4鸟","createPick4"},{1,"抓6鸟","createPick6"},{2,"鸟2分","createCoin2"}}
-- }

consts.roomCreateMsg.tab_1 = 
{
    {"局数:",{1," 8局","createC8","(房卡x1)"},{1,"16局","createC16","(房卡x2)"}},
    {"人数:",{1,"4人局","createP4"},{1,"3人局","createP3"},{1,"2人局","createP2"}},
    {"玩法:",{1,"点炮胡","createWin1"},{1,"自摸胡","createWin2"},nil},
    {"",{2,"抢杠胡","createWin3"},{2,"可抢明杠","createWin5"}, nil},
    {"",{2,"庄闲算分","createCon1"},{2,"可胡七对","createCon2"},{2,"红中癞子","createCon3"}},
    {"抓鸟:",{1,"抓2鸟","createPick2"},{1,"抓4鸟","createPick4"},{1,"抓6鸟","createPick6"},{2,"鸟2分","createCoin2"}}
}

consts.roomCreateMsg.tab_2 = 
{
    {"局数:",{1," 8局","createC8","(房卡x1)"},{1,"16局","createC16","(房卡x2)"}},
    {"人数:",{1,"4人局","createP4"},{1,"3人局","createP3"}},
    {"-",{1},{1},{2}},
    {"玩法:",{2,"庄闲算分","createCon1"},{2},{2}},
    {"抓鸟:",{1,"抓2鸟","createPick2"},{1,"抓4鸟","createPick4"},{1,"抓6鸟","createPick6"},{2,"鸟2分","createCoin2"}}
}

consts.roomCreateMsg.tab_3 = 
{
    {"局数:",{1," 8局","createC8","(房卡x1)"},{1,"16局","createC16","(房卡x2)"}},
    {"人数:",{1,"4人局","createP4"}},
    {"玩法:",{1,"点炮胡（可抢杠胡）","createWin4"}, nil,{1,"自摸胡","createWin2"}},
    {"",{2,"飘","createCon4"},{2,"可胡七对","createCon2"},{2,"红中","createCon5"}},
    {"抓鸟:",{1,"抓2鸟","createPick2"},{1,"抓4鸟","createPick4"},{1,"抓6鸟","createPick6"},{2,"金鸟","createPick7"}}
}

consts.roomCreateMsg.tab_4 = 
{
    {"局数:",{1," 8局","createC8","(房卡x1)"},{1,"16局","createC16","(房卡x2)"}},
    {"人数:",{1,"4人局","createP4"}},
    {"玩法:",{1,"自摸胡","createWin2"}, {2,"可胡七对","createCon2"}, {2,"可抢明杠","createWin5"}},
    {"扎码:",{1,"一码全中","yimaquanzhong"}},
    {"",{1,"扎2码","createma2"},{1,"扎4码","createma4"},{1,"扎6码","createma6"}}
}

consts.roomCreateMsg.tab_5 = 
{
    {"局数:",{1," 8局","createC8","(房卡x1)"},{1,"16局","createC16","(房卡x2)"}},
    {"人数:",{1,"4人局","createP4"},{1,"3人局","createP3"}},
    {"玩法:",{2,"开王","createCon6"},{2,"起手胡","createCon7"},{2}},
    {"大胡:",{1,"6分","6fen"},{1,"7分","7fen"},{1,"8分","8fen"}},
    {"抓鸟:",{1,"抓2鸟","createPick2"},{1,"抓4鸟","createPick4"},{1,"抓6鸟","createPick6"},{2,"鸟2分","createCoin2"}}
}

consts.roomCreateMsg.tab_6 = 
{
    {"局数:",{1," 8局","createC8","(房卡x1)"},{1,"16局","createC16","(房卡x2)"}},
    {"人数:",{1,"4人局","createP4"},{1,"3人局","createP3"}},
    {"玩法:",{2,"红中癞子","createCon3"},{2,"荒庄荒杠","createCon8"},{2}},
    {"扎码:",{1,"一码全中","yimaquanzhong"}},
    {"",{1,"扎2码","createma2"},{1,"扎4码","createma4"},{1,"扎6码","createma6"}}
}

consts.bg_type = 
{
    ck_bg_1 = {roomIdColor = cc.c3b(31, 230, 227), timeColor = cc.c3b(199, 199, 199), textInfoColor = cc.c3b(239, 237, 224), mjDescColor = cc.c3b(6, 56, 91)},
    ck_bg_2 = {roomIdColor = cc.c3b(204, 195, 50), timeColor = cc.c3b(77, 133, 69), textInfoColor = cc.c3b(105, 215, 92), mjDescColor = cc.c3b(8, 56, 34)},
    ck_bg_3 = {roomIdColor = cc.c3b(204, 195, 50), timeColor = cc.c3b(77, 133, 69), textInfoColor = cc.c3b(105, 215, 92), mjDescColor = cc.c3b(8, 56, 34)},
}