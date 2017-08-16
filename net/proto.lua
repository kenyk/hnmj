local sprotoparser = require "sprotoparser"

local proto = {}

proto.c2s = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}


.table_config_info {
  player_count 0 : integer                #开局人数
  master_id 1 : integer                   #房主
  game_count 2 : integer                  #局数
  rate 3 : integer                        #倍率
  createtime 4 : integer                  #创建时间
  data 5 : string                         #具体游戏参数
}

.players_info {
  uid 0 : integer             #玩家ID
  chair_id 1 : integer          #玩家chair_id
  nickname 2 : string           #玩家昵称
  image_url 3 : string          #玩家头像
  gender 4 : integer            #玩家性别female:0, male:1
  game_state 5 : integer          #玩家状态(1.坐下2.准备3.观众4.游戏中)
  ip 6 : string
  point 7 : integer

}
login 1001 {
	request {
		account	   0 : integer	# login uid id not role_id ,not character
		token         1 : string    # encryped token or session
	}
}
role_login 1004 {
  request {
    uid    0 : integer  #  character_id
  }
  response {
    nickname 2 : string           #玩家昵称
    image_url 3 : string          #玩家头像
    gender 4 : integer            #玩家性别female:0, male:1
    card   5 : integer
  }   
}



reconnection_synchronize  1002 {
request {
	}
response {
	
  }	
}

#心跳包
heartbeat 1003 {
  response {
    time  0 : integer
  } 
}

build_on_request_new_rooms 2002 {
  request {
    player_count 0 : integer #玩家人数
    rate 1 : integer  #倍率
    game_count 2 : integer #局数
    data 3 : string #json {game_type:1,idle:true,laizi:true,seven_hu:true,find_bird:2,piao:true, goldbird:true, hongzhong:true,
                    #     firstHu:true, kaiwang:true,bighu:1, huangzhuang:true}
                    #     胡牌方式:(1.炮胡，2.自模胡)、是否庄闲、是否有癞子、是否能胡七对、抓鸟数 是否飘 是否金鸟  是否是红中麻将  是否起手胡  是否开王（翻癞子） 荒庄荒杠
  }
  response {
    code 0 : integer        
    enter_code 1 : integer  #进房码
  }
}

.room_batch_info{
    progress 1   : string 
    players  2   : *players_info
    room_id  3   : string
    player_num 4  : integer
    data      5  : string #json
}

get_batch_room_list 2003
{
   request {
    page 0 : integer       #页码
  }
  response {
    code     0  : integer          #
    list     1  : *room_batch_info
    total    2  : integer  
  } 
}

dismiss_batch_room 2004
{
  request {
    handle 0 : *integer      
  }
  response {
    code     0  : integer          #
  } 
}

#玩家进入房间
room_enter_room 4001 {
  request {
    enter_code 0 : string       #进房码
  }
  response {
    code 0 : integer          #
  }
}
#玩家离开房间
room_exit_room 4002 {
  response {
    code 0 : integer
  }
}

#玩家进入桌子
room_enter_table 4003 {
  response {
    code 0 : integer          
    table_id 1 : integer        
    table_config 2 : table_config_info  #桌子配置信息
    players 3 : *players_info     #玩家信息
  }
}
#玩家离开桌子
room_exit_table 4004 {
  response {
    code 0 : integer
  }
}
#玩家坐下
room_sit_down 4005 {
  response {
    code 0 : integer
    chair_id 1 : integer
  }
}
#玩家起立
room_stand_up 4006 {
  response {
    code 0 : integer
  }
}

#玩家准备
room_get_ready 4007 {
  response {
    code 0 : integer
  }
}

#获取房间桌子信息
room_get_table_scene 4008 {
  response {
    table_config 0 : table_config_info  #桌子配置信息
    players 1 : *players_info     #玩家信息
  }
}

#发起解散/同意拒绝解散房间
room_vote_dismiss_room 4009 {
  request {
    room_id 0 : string          #房间ID
    option 1 : integer          #0:同意 1:拒绝
  }
  response {
    code 0 : integer
  }
}
#出牌
game_out_card 3001 {
    request {
        card 0 : integer
    }
    response {
    code 0 : integer
  }
}

#碰牌
game_peng_card 3002 {
  request {
    card 0 : integer
  }
  response {
    code 0 : integer
  }
}

#杠牌
game_gang_card 3003 {
  request {
    card 0 : integer
    gang_type 1 : integer     #1.明杠2.暗杠3.梭杠
  }
  response {
    code 0 : integer
  }
}

#补张
game_bu_card 3009{
  request {
    card 0 : integer
    bu_type 1 : integer     #1.明补2.暗补3.梭补
  }
  response {
    code 0 : integer
  }
}

#吃牌
game_chi_card 3004 {
  request {
    chi_card 0 : integer    #上家打出的牌
    will_chi_card 1 : *integer  #手上要吃这个牌的牌
  }
  response {
    code 0 : integer
  }
}

#胡牌
game_hu_card 3005 {
  request {
    card 0 : integer    #上家打出的牌
  }
  response {
    code 0 : integer
  }
}

#取消动作
game_cancel_action 3006 {
  response {
    code 0 : integer
  }
}

.cardinfo {
  chair_id 0 : integer            #玩家chair_id
  outCards 1 : *integer           #玩家出過的牌(不包括被碰，杠，吃掉的牌)
  pengCards 2 : string            #玩家碰的牌 json {"12":1,"13":1}->碰了2萬 3萬
  gangCards 3 : string            #玩家杠的牌 json {"16":2}-> 杠了6萬（1:明杠(碰牌后再杠)，2:暗杠，3:接杠）
  chiCards 4 : string           #玩家吃的牌  chiCards 4 : *integer #{{23,24,25}, {25,26,27}}
  handCards 5 : *integer          #玩家的手牌
  cardNum 6 : integer             #玩家当前手上的牌数
  piaoPoint 7: integer            #飘的分数
}

#玩家重連獲取牌局信息
game_reconnect_gameinfo 3007 {
  response {
    code 0 : integer
    playerCard 1 : *cardinfo        #玩家的牌      #json:{canChi:true,canPeng:integer,canGang:integer,canHu:true,hutype:integer,hucard:integer}
    canOperation 2 : string         #玩家可執行的操作 json  {"canPeng":integer, "canGang":[42], "hucard":42,"hutype":1,"canhu":true}*changsha的hucard是一个*integer
    curOutCHair 3 : integer         #當前該出牌的玩家
    lastOutChair 4 : integer        #上次出牌的玩家
    lastOutCard 5 : integer         #上次出的牌 
    banker 6 : integer              #莊家
    leftNum 7 : integer             #剩下的牌數
    gameIndex 8 : integer           #當前局數
    gangLock 9 : boolean            #杠牌的锁  
    state 10 : boolean              #长沙特有的起手胡钱不让出牌
    laizi 11 : integer              #癞子
    laizipi 12 : integer              #癞子皮
    canOperation1 13 : string      #同上 长沙特有
  }
}

#玩家固定聊天信息和图片
game_talk_and_picture 3008 {
  request {
    id 0 : string        #文字或图片标记
  }
}
#起手胡
game_first_hu 3010 {
    response {
    code 0 : integer
  }
}
#飘
game_piao_point 3011{
    request {
        point 0 : integer        #分
  }
}
#报听
game_ting_card 3012{
  response {
        code 0 : integer       # 
  }
}
#海底
game_haidi_card 3013{
    response {
        code 0 : integer        #
    }
}
]]

proto.s2c = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}


.table_config_info {
  player_count 0 : integer        #开局人数
  master_id 1 : integer         #房主
  game_count 2 : integer        #局数
  rate 3 : integer          #倍率
  createtime 4 : integer   #房間創建時間
  data 5 : string           #具体游戏参数
}

.players_info {
  uid 0 : integer           #玩家ID
  chair_id 1 : integer        #玩家chair_id
  nickname 2 : string         #玩家昵称
  image_url 3 : string        #玩家头像
  gender 4 : integer          #玩家性别female:0, male:1
  game_state 5 : integer        ##玩家状态(1.坐下2.准备3.观众4.游戏中)
  ip 6 : string               #玩家ip
  point 7 : integer
}
#推送桌子信息
room_post_table_scene 4001 {
  request {
    table_config 0 : table_config_info    #桌子配置信息
    players 1 : *players_info       #玩家信息
  }
}

#推送玩家准备
room_post_get_ready 4002 {
  request {
    uid 0 : integer
    chair_id 1 : integer
  }
}

#推送同意/拒绝解散
room_post_vote_dismiss 4003 {
  request {
    apply  0 : integer
    uid    1 : integer
    option 2 : integer              #0:同意 1:拒绝
  }
}


#推送房间解散
room_post_room_dismiss 4004 {
  request {
  	code    0 : integer  # 0 : sucess 1 : failt
    room_id 1 : integer  
 	list    2 : *integer
  }
}

#玩家重连推送桌子信息
room_post_table_reconnect 4005 {
  request {
    table_config 0 : table_config_info
    players 1 : *players_info
    enter_code 2 : integer
    is_playing 3 : boolean
    game_index 4 : integer
  }
}

#推送玩家掉線或者重連
room_post_player_connect 4006 {
  request {
    chair_id 0 : integer
    connect 1 : boolean  #false:掉線 true:重連
  }
}

#游戏开始
game_start_game 3001 {
  request {
    time 0 : integer             #开始时间
    needWait 1 : boolean          #是否等待
  }
}

#发牌
game_deal_card 3002 {
  request {
    cards 0 : *integer
    card_num 1: *integer
    card_first 2 : integer
  }
}

#玩家出牌
game_out_card 3003 {
  request {
    chair_id 0 : integer
    card 1 : integer
    addtion_bit 2: integer
    addition_card 3: *integer
  }
}

#玩家摸牌
game_draw_card 3004 { 
  request {
 	chair_id 0 : integer
    card     1 : integer
  }
}

#玩家该轮的操作
game_have_operation 3005 {
  request {                                                                                                  
    operation 0 : string        #json:{canChi:true,canPeng:integer,canGang:integer,canHu:true,hutype:integer,hucard:integer, canFirstHu:true, canTing:true, canHaidi:true}
                      #         能吃            能碰           能杠        能胡           1.自摸2.放炮3.抢杠胡  hucard长沙是一个数组湖南是一个integer
    operation1 1 : string        #json:{}
  }
}

#玩家碰牌
game_peng_card 3006 {
  request {
    chair_id 0 : integer
    card 1 : integer           #要碰的牌
    out_chair 2 : integer     #出牌的人
  }
}

#玩家杠牌
game_gang_card 3007 {
  request {
    chair_id 0 : integer
    card 1 : integer          #要杠的牌
    gang_type 2 : integer         #1.明杠2.暗杠3.梭杠
    out_chair 3 : integer     #出牌的人
  }
}

#玩家补张
game_bu_card 3015 {
  request {
    chair_id 0 : integer
    card 1 : integer          #要补的牌
    bu_type 2 : integer         #1.明补2.暗补3.梭补
    out_chair 3 : integer     #出牌的人
  }
}

#玩家吃牌
game_chi_card 3008 {
  request {
    chair_id 0 : integer
    card 1 : integer           #要吃的牌:22
    card_table 2 : *integer              #待吃的牌:{21,23}
  }
}

#玩家胡牌
game_hu_card 3009 {
  request {
    chair_id 0 : integer                  #胡牌玩家chair_id
    card_table 1 : *integer               #胡牌手牌
    hu_type 2: integer                    #胡的类型
  }
}

.player_balance_info {
  huPoint 0 : integer              #胡牌得/失分
  gangPoint 1 : integer            #杠牌得/失分
  birdPoint 2 : integer            #抓鸟得/失分
  handCard 3 : string              #手牌
  huCard 4 : integer               #显示胡的牌
  huType 5 : integer               #1:自摸、2:接炮、3:抢杠胡,4:放炮、5:被抢杠  0:没胡
  gangType 6 : string              # {anGang:1,jieGang:1,fangGang:1,mingGang:1} json   # 暗杠数    接杠数    放杠数     明杠数
  point    7 : integer                     
  piaoPoint     8 : integer             #飘得失分                                          
}

.changsha_player_balance_info {
  getpoint 0 : integer              #得/失分
  getbird 1 : integer                #中鸟数量
  handCard 2 : string              #手牌
  huCard 3 : integer               #显示胡的牌       大四喜         缺一色           板板胡          六六顺
  first_hu 4 : string                          #{bigfour:数量,lose_one_color:true,banban:true,liuliushun:true} json
                                    # 天胡 tianhu  地胡 dihu 全求人 allask 碰碰胡  pengpenghu  将将胡 jiangjianghu   清一色 qingyise   海底捞月 haidilao  海底炮haidipao
                                    #七小对 seven_hu  豪华七小对 hao_seven_hu  双豪华七小队 shuang_hao_seven_hu   杠上开花 ganghua   抢杠胡 qiangganghu 杠上炮 gangpao
                                    #baoting 报听 menqing 门清 nolaizihu无王大胡
  hu_info 5 : string                # {tianhu:数量,dihu:数量 } json
  huType  6 : integer               #胡的类型 （1自摸胡， 2 点炮， 3，接炮 4,大胡点炮 , 5大胡接炮） 
  point 7 : integer                 
  huCard2 8 : integer                 #胡的牌（衡阳麻将会用到）                                        
  gangType 9 : string              # {anGang:1,jieGang:1,fangGang:1,mingGang:1} json   # 暗杠数    接杠数    放杠数     明杠数                                        
}

.ningxiang_player_balance_info{
  getpoint 0 : integer              #得/失分
  getbird 1 : integer                #中鸟数量
  handCard 2 : string              #手牌
  huCard 3 : *integer               #显示胡的牌       大四喜         缺一色           板板胡          六六顺
  first_hu 4 : string                          #{bigfour:数量,lose_one_color:true,banban:true,liuliushun:true} json
                                    # 天胡 tianhu  地胡 dihu 全求人 allask 碰碰胡  pengpenghu  将将胡 jiangjianghu   清一色 qingyise   海底捞月 haidilao  海底炮haidipao
                                    #七小对 seven_hu  豪华七小对 hao_seven_hu  双豪华七小队 shuang_hao_seven_hu   杠上开花 ganghua   抢杠胡 qiangganghu 杠上炮 gangpao
                                    #baoting 报听 menqing 门清 nolaizihu无王大胡
  hu_info 5 : string                # {tianhu:数量,dihu:数量 } json
  huType  6 : integer               #胡的类型 （1自摸胡， 2 点炮， 3，接炮 4,大胡点炮 , 5大胡接炮） 
  point 7 : integer     
}

#单局游戏结束
game_game_end 3010 {
  request {
    game_index 0 : integer           #当前局数
    hu_chairs 1 : *integer           #胡牌玩家chair_id
    birdCard 2 : *integer            #抓鸟
    birdPlayer 3 : integer           #如果中鸟了显示中鸟玩家的chair_id 没中鸟为0
    banker 4 : integer               #庄
    player_balance 5 : *player_balance_info  #玩家当局结算信息
    changsha_player_balance 6 : *changsha_player_balance_info #长沙麻将当局结算信息
    zhongbird 7 : *integer           #中的鸟
    ningxiang_player_balance 8 : *ningxiang_player_balance_info  #宁乡麻将当局结算信息
  }
}
#心跳包
heartbeat 1001 {}


kick_game 1002 {}

#倒计时显示在谁头上
game_post_timeout_chair 3012 {
  request {
    chair_id 0 : integer
  }
}

.player_balance_result {
    uid 0 : integer           
    ziMo 1 : integer
    jiePao 2 : integer
    dianPao 3 : integer
    anGang 4 : integer
    mingGang 5 : integer
    suoGang 6 : integer
    point 7 : integer
}

.changsha_player_balance_result{
    uid 0 : integer
    xiaohuzimo 1 : integer
    dahuzimo 2 : integer
    xiaohudianpao 3 : integer
    dahudianpao 4 : integer
    xiaohujiepao 5 : integer
    dahujiepao 6 : integer
    point 7 : integer
}

#大局结算
game_balance_result 3011 {
  request {
    room_id 0 : string
    player_result 1 : *player_balance_result
    player_changsha_result 2 : *changsha_player_balance_result
    win 3 : integer
  }
}

#玩家固定聊天信息和图片
game_talk_and_picture 3013 {
  request {
    uid 0 : integer       #发送的人id
    id 1 : string        #文字或图片标记
  }
}

#起手胡
first_hu_info 3014 {
    request {
    hu_info 0 : string #胡牌的内容 #json: #json{[胡的人]= {huType={bigfour,banban} ,hucard={}}}
    }
}
#长沙开始出牌的协议
changsha_start_out 3016{

}
#飘
game_piao_point 3017{
    request {
        info 0 : *integer #每个人飘的分
  }
}
#提示前端重连进入选漂分
game_reconnect_piao 3018{
    request {
        point 0 : integer #他选择飘的分 如果没有选是-1
  }
}
#翻癞子
game_open_laizi 3019 {
  request {
    laizi 0 : integer       #癞子牌
    laizipi 1 : integer     #癞子皮
  }
}
#翻海底
game_open_haidi 3020 {
  request {
    card 0 : integer       #海底牌
  }
}
#报听
game_ting_card 3021 {
    request {
    chair_id 0 : *integer       #报听的人
  }
}

]]

return proto

