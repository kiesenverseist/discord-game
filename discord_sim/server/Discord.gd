extends Node

onready var ws = $"../Websocket"
onready var da = $"../Data"

func _ready():
	ws.connect("message_recieved", self, "_on_message_receved")
	ws.connect("user_joined", self, "_on_user_join")
	
	randomize()

func _on_user_join(data):
	#var role_id = ["Red", "Blue", "Yellow", "Green"][randi()%4] #random assignment
	
	#assign to lowest scoring
	
	# to make a sorted list of teams
	var teams : Array = []
	var t = da.teams
	for team in t:
		teams.append(da.teams[team])
	teams.sort_custom(self, "leader_board_sort")
	
	var role_id = teams[-1].name
	
	var send = {}
	send["type"] = "set_role"
	send["user_id"] = data["user_id"]
	send["role_name"] = role_id
	ws.send_data(send)

func _on_message_receved(data):
	if not data["is_dm"]:
		if data["channel_name"] == "generator":
			var t = da.teams
			t[data["category_name"]].add_points(1)
			da.teams = t
			
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
	var t = da.teams
	for team in t:
		teams.append(da.teams[team])
	
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