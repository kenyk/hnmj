--
-- Created by IntelliJ IDEA.
-- User: LXL
-- Date: 2015/8/7
-- Time: 13:58
-- To change this template use File | Settings | File Templates.
--

consts.Notify = {
    --LOGIN
    SDK_LOGIN_BACK = "sdkLoginBack", --SDK登录回调
    -- Mahjong
    MAH_JONG_START_PLAY="mahjong_start_play",
    MAH_JONE_CHANGE_GAME_STATUS="mahjong_change_game_status", --打麻将状态改变
    -- 战斗场景设置玩家信息
    MAH_JONG_START_GAME="mahjong_start_game",
    CONFIRM_DLALOG_CLOSE="comfirm_dialog_close",
    RECONNECT_CARD="reconnect_card",
    --获取房卡
    GET_FUNDS="GET_FUNDS",
    --获取解散投票信息
    GET_VOTE_MSG="GET_VOTE_MSG",
    --关闭解散房间提示框
    CLOSE_DISMISS_CONFIRM_FRAME = "CLOSE_DISMISS_CONFIRM_FRAME",

    GCLOUDVOICE_START = "gcloudvoice_start",
    GCLOUDVOICE_COMPLETE = "gcloudvoice_complete",
    --电量变化
    BATTERY_CHANGE="battery_change",
    --网络状态变化
    NET_INFO_CHANGE="net_info_change",
    --解散房间消息
    DISMISS_ROOM = "dismiss_room",
    --选定一张牌
    SELECT_ONE_MJ = "SELECT_ONE_MJ",
    --清除重复牌的标记
    CLEAR_SAME_CARD_TAG = "CLEAR_SAME_CARD_TAG",
    --显示 选飘
    SELECT_PIAO_SHOW = "SELECT_PIAO_SHOW",
    --等待其他玩家选飘
    WAIT_OTHER_SELECT_PIAO = "WAIT_OTHER_SELECT_PIAO",
    --更换桌布
    CHANGE_BG_TYPE = "CHANGE_BG_TYPE",
    --开王
    SHOW_LAIZI_CARD = "SHOW_LAIZI_CARD",
    --刷新邮件
    UPDATE_MAIL = "UPDATE_MAIL",
    --刷新帮助
    UPDATE_HELP_UI = "UPDATE_HELP_UI",
    --回放 暂停
    REPLAY_PAUSE = "REPLAY_PAUSE",
    --回放 前进
    REPLAY_SPEED = "REPLAY_SPEED",
    --回放 后退
    REPLAY_BACK = "REPLAY_BACK",
    UPDATE_PING = "UPDATE_PING",
    --切后台
    APP_ENTER_BACKGROUND = "APP_ENTER_BACKGROUND",
    PILIANGCREATE = "PILIANGCREATE",
    --刷新房卡数量
    UPDATE_CARD_NUM = "UPDATE_CARD_NUM",
}