extends Node

onready var ws = $"../Websocket"
onready var da = $"../Data"
var uwou_regex = RegEx.new()

func _ready():
	ws.connect("message_recieved", self, "_on_message_receved")
	ws.connect("user_joined", self, "_on_user_join")
	
	randomize()
	leaderboard_loop()
	
	uwou_regex.compile("[uUwWoO]{3}")

func _on_user_join(data):
	var role_id
	
	if randf() < 0.4:
		role_id = ["Red", "Blue", "Green"][randi()%3] #random assignment
	else:
		#assign to lowest scoring
		
		# to make a sorted list of teams
		var teams : Array = []
		var t = da.teams
		for team in t:
			teams.append(da.teams[team])
		teams.shuffle()
		teams.sort_custom(self, "leader_board_sort")
		
		role_id = teams[-1].name
		
		if role_id == "Yellow":
			role_id = teams[-2].name
	
	print("is to be assigned to ", role_id, " in 3 minutes")
	yield(get_tree().create_timer(180), "timeout")
	
	var send = {}
	send["type"] = "set_role"
	send["user_id"] = data["user_id"]
	send["role_name"] = role_id
	ws.send_data(send)

func _on_message_receved(data):
	if not data["is_dm"]:
		
		#uwou detector
		var uwou_data = uwou_regex.search_all(data["message"])
		if not uwou_data.empty():
			var ret = ""
			for res in uwou_data:
				ret += res.get_string() + " "
			var reply = {
				"type" : "message",
				"channel_name" : data["channel_name"],
				"category_name": data["category_name"],
				"message" : ret + "What's this?"
			}
			ws.send_data(reply)
		
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
						var reply = {
							"type" : "message",
							"channel_name" : data["channel_name"],
							"category_name": data["category_name"],
							"message" : "Sabotage of %s successful" % team
						}
						ws.send_data(reply)
				
				if not found:
					if randf() < 0.08:
						t[data["category_name"]].add_points(3)
						var reply = {
							"type" : "message",
							"channel_name" : data["channel_name"],
							"category_name": data["category_name"],
							"message" : "Critical Success!"
						}
						ws.send_data(reply)
					elif randf() < 0.01:
						t[data["category_name"]].add_points(-3)
						var reply = {
							"type" : "message",
							"channel_name" : data["channel_name"],
							"category_name": data["category_name"],
							"message" : "Critical Failure!"
						}
						ws.send_data(reply)
					else:
						t[data["category_name"]].add_points(1)
				
				#for when a team surpasses 100
				if t[data["category_name"]].points >= 100 and t[data["category_name"]].points <= 101 :
					var reply = {
						"type" : "message",
						"channel_name" : "announcements",
						"category_name": "Super",
						"message" : "Congradulations to %s for reaching 100 points!\nhttps://www.youtube.com/watch?v=1Bix44C1EzY" % data["category_name"]
					}
					ws.send_data(reply)

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
						var culprit = data["category_name"] if randf() < 0.1 else ""
						var reply = {
							"type" : "message",
							"channel_name" : "team-chat",
							"category_name": team,
							"message" : "Another team mentioned this team %s" % face + culprit
						}
						ws.send_data(reply)
				
				if randf() < 0.005:
					var t = da.teams
					t[data["category_name"]].add_points(1)
					da.teams = t
					
					var reply = {
						"type" : "message",
						"channel_name" : data["channel_name"],
						"category_name": data["category_name"],
						"message" : "You found a point."
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

remote func update_leaderboard():
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

func leaderboard_loop():
	get_tree().create_timer(3600).connect("timeout", self, "leaderboard_loop")
	print("current time is: ", str(OS.get_time()))
	if OS.get_time().hour == 20:
		update_leaderboard()
