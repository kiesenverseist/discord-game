extends Node

enum {
	RED = 566546853294899230,
	GREEN = 566546914674212864,
	YELLOW = 566546977139982339,
	BLUE = 566546944843841536
}

onready var ws = $"../Websocket"
onready var gd = $"../GlobalData"

func _ready():
	ws.connect("message_recieved", self, "_on_message_receved")
	ws.connect("user_joined", self, "_on_user_join")
	
	randomize()

func _on_user_join(data):
	return #automatic role assignment is currently disabled
	var role_id = str([RED, BLUE, YELLOW, GREEN][randi()%4])
	
	var send = {}
	send["type"] = "set_role"
	send["user_id"] = data["user_id"]
	send["role_id"] = role_id
	ws.send_data(send)

func _on_message_receved(data):
	if not data["is_dm"]:
		if data["channel_name"] == "generator":
			gd.teams[data["category_name"]].add_points(1)
			
			update_leaderboard()
	else:
		var reply_dm = {}
		reply_dm["type"] = "message"
		reply_dm["channel_id"] = data["channel_id"]
		reply_dm["message"] = "Plox noe dm ;-;"
		ws.send_data(reply_dm)

static func leader_board_sort(a , b):
	return a.points > b.points

func update_leaderboard():
	# to make a sorted list of teams
	var teams : Array = []
	for team in gd.teams:
		teams.append(gd.teams[team])
	
	teams.sort_custom(self, "leader_board_sort")
	
	var msg : String = ""
	for team in teams:
		msg += team.name + ": " + str(team.points) + " \n"
	
	var send_update = {}
	send_update["type"] = "replace_last"
	send_update["category_name"] = "Super"
	send_update["channel_name"] = "leaderboard"
	send_update["message"] = msg
	ws.send_data(send_update)