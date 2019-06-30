extends Node

onready var ws = $"../Websocket"
onready var da = $"../Data"

func _ready():
	ws.connect("message_recieved", self, "_on_message_receved")
	ws.connect("user_joined", self, "_on_user_join")
	
	randomize()
	update_loop()

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
	
	var msg = {
		"type" : "message",
		"channel_name" : "team-chat",
		"category_name": role_id,
		"message" : "Welcome your new member %s!" % data["user_name"]
	}
	ws.send_data(msg)

func _on_message_receved(data):
	$MessageHandler.handle_message(data)

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

func update_loop():
	get_tree().create_timer(60).connect("timeout", self, "leaderboard_loop")
	print("current time is: ", str(OS.get_time()))
	
	#update leaderboard
	if OS.get_time().hour == 20:
		update_leaderboard()
	
	#update team flags
	var req = ws.request({
		"type" : "request",
		"request" : "channels"
	})
	yield(req, "request_complete")
	var channels = req.ans_data["channels"]
	req.complete()
	
	var t = da.teams
	
	for team in t:
		if team.data["flag_vc"]:
			if not channels[team.name].has("team-vc"):
				ws.send_data({
					"type" : "create_channel",
					"channel_type" : "vc",
					
				})
		else:
			if channels[team.name].has("team-vc"):
				pass
		if team.data["flag_chat"]:
			if not channels[team.name].has("team-chat"):
				pass
		else:
			if channels[team.name].has("team-chat"):
				pass
		
	
