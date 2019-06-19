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
	
	if role_id == "Yellow":
		role_id = teams[-2].name
		
	
	var send = {}
	send["type"] = "set_role"
	send["user_id"] = data["user_id"]
	send["role_name"] = role_id
	ws.send_data(send)

func _on_message_receved(data):
	if not data["is_dm"]:
		match data["channel_name"]:
			"generator":
				var t = da.teams
				
				var other_teams = ["Yellow", "Blue", "Red", "Green"]
				other_teams.shuffle()
				other_teams.erase(data["category_name"])
				
				var found = false
				
				for team in other_teams:
					if data["message"].matchn("*%s*" % team) and not found:
						found = true
						t[team].add_points(-1)
				
				if not found:
					t[data["category_name"]].add_points(1)
				da.teams = t
			"team-chat":
				if data["message"].matchn("*p*o*i*n*t*"):
					var t = da.teams
					var reply = {
						"type" : "message",
						"channel_name" : data["channel_name"],
						"category_name": data["category_name"],
						"message" : "Your team has %s points" % str(t[data["category_name"]].points)
					}
					ws.send_data(reply)
				
				var other_teams = ["Yellow", "Blue", "Red", "Green"]
				other_teams.erase(data["category_name"])
				
				for team in other_teams:
					if data["message"].matchn("*%s*" % team):
						var face = [">_>", "<_<", "o_0", "0_o", ":O"]
						face.shuffle()
						face = face.front()
						var reply = {
							"type" : "message",
							"channel_name" : "team-chat",
							"category_name": team,
							"message" : "Another team mentioned this team %s" % face
						}
						ws.send_data(reply)
				
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
	send_update["type"] = "message"
	send_update["category_name"] = "Super"
	send_update["channel_name"] = "leaderboard"
	send_update["message"] = msg
	ws.send_data(send_update)
	
	#update daily
	get_tree().create_timer(3600*24).connect("timeout", self, "update_leaderboard")