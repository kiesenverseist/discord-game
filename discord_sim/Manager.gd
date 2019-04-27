extends Node

var r_p = 0
var y_p = 0
var g_p = 0
var b_p = 0

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

func _on_user_join(data):
	var role_id = str([RED, BLUE, YELLOW, GREEN][randi()%4])
	
	var send = {}
	send["type"] = "set_role"
	send["user_id"] = data["user_id"]
	send["role_id"] = role_id
	ws.send_data(send)

func _on_message_receved(data):
	if not data["is_dm"]:
		if data["channel_name"] == "generator":
			match data["category_name"]:
				"Red":
					gd.teams["Red"].add_points(1)
				"Green":
					gd.teams["Green"].add_points(1)
				"Blue":
					gd.teams["Blue"].add_points(1)
				"Yellow":
					gd.teams["Yellow"].add_points(1)
				_:
					pass
			
			var send_update = {}
			send_update["type"] = "replace_last"
			send_update["category_name"] = "Super"
			send_update["channel_name"] = "leaderboard"
			send_update["message"] = "Red: %s \nGreen: %s \nYellow: %s \nBlue: %s" \
					% [gd.teams["Red"].points, gd.teams["Green"].points, gd.teams["Yellow"].points, gd.teams["Blue"].points]
			ws.send_data(send_update)
	else:
		var reply_dm = {}
		reply_dm["type"] = "message"
		reply_dm["channel_id"] = data["channel_id"]
		reply_dm["message"] = "Plox noe dm ;-;"
		ws.send_data(reply_dm)
		