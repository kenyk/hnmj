--
-- Author: LXL
-- Date: 2016-11-10 11:37:54
--

local MahjoneModel = class("MahjoneModel" , cc.load("mvc").ModelBase)

function MahjoneModel:ctor(callback)
    MahjoneModel.super.ctor(self,callback)
end

function MahjoneModel:getProList()
	local list = {
		"game_start_game",
		"game_deal_card",
		"replay_game_deal_card",
		"game_out_card",
		"game_draw_card",
		"game_have_operation",
		"game_peng_card",
		"game_gang_card",
		"game_chi_card",
		"game_hu_card",
		"game_game_end",
		"game_post_timeout_chair",
		"room_post_table_scene",
		"room_post_get_ready",
        "game_balance_result",
		"room_post_vote_dismiss",
		"room_post_room_dismiss",
		"room_vote_dismiss_room",
		"room_post_player_connect",
        "game_talk_and_picture",
        "room_exit_room",
        "game_bu_card",
        "first_hu_info",
        "changsha_start_out",
        "game_piao_point",
        "game_reconnect_piao",
        "game_open_laizi",
        "game_open_haidi",
        "game_ting_card",
    }
    return list
end

return MahjoneModel