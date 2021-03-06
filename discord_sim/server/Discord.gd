extends Node

onready var ws = $"../Websocket"
onready var da = $"../Data"

func _ready():
	ws.connect("message_recieved", self, "_on_message_receved")
	ws.connect("user_joined", self, "_on_user_join")
	ws.connect("user_left", self, "_on_user_leave")
	
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
	
	#create and publices user object
	da.add_user(data["user_id"])
	update_users()
	
	var u = da.users
	u[data["user_id"]].data["team"] = role_id
	u[data["user_id"]].data["user_name"] = data["user_name"]
	da.users = u
	
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

func _on_user_leave(data):
	discord_message("user left: %s" % data, "dev-general", "Super")
	da.remove_user(data["user_id"])

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

func update_user_leaderboard(data):
	var users : Array = []
	var u = da.users
	for user in u:
		if data.has("team"):
			if u[user].data["team"] == data["team"]:
				users.append(u[user])
		else:
			users.append(u[user])
	
	users.sort_custom(self, "leader_board_sort")
	
	var msg : String = ""
	for user in users:
		msg += user.data["nick"] + ": " + str(user.points) + " \n"
	
	var send_update = {}
	send_update["type"] = "message"
	send_update["category_name"] = data["category_name"]
	send_update["channel_name"] = data["channel_name"]
	send_update["message"] = msg
	ws.send_data(send_update)

func update_loop():
	get_tree().create_timer(3600).connect("timeout", self, "update_loop")
	print("current time is: ", str(OS.get_time()))
	
	var t = da.teams
	
	#update team flags
	var req = ws.request({"request" : "channels"})
	yield(req, "request_complete")
	var channels = req.ans_data["channels"]
	req.complete()
	
	for team in t:
		if t[team].data["flag_vc"]:
			if not channels[team].has("team-vc"):
				ws.send_data({
					"type" : "create_channel",
					"channel_type" : "vc",
					"category_name" : team,
					"channel_name" : "team-vc"
				})
		else:
			if channels[team].has("team-vc"):
				pass
		if t[team].data["flag_chat"]:
			if not channels[team].has("team-chat"):
				ws.send_data({
					"type" : "create_channel",
					"channel_type" : "text",
					"category_name" : team,
					"channel_name" : "team-chat"
				})
		else:
			if channels[team].has("team-chat"):
				pass
		if t[team].data["flag_user_leaderboard"]:
			if not channels[team].has("team-leaderboard"):
				ws.send_data({
					"type" : "create_channel",
					"channel_type" : "text",
					"category_name" : team,
					"channel_name" : "team-leaderboard"
				})
		else:
			if channels[team].has("team-vc"):
				pass
	
	#update leaderboard(s)
	if OS.get_time().hour == 20:
		update_leaderboard()
		for team in t:
			if t[team].data["flag_user_leaderboard"]:
				update_user_leaderboard({
					"team" : team,
					"category_name" : team,
					"channel_name" : "team-leaderboard"
				})

func update_users():
	var req : WSRequest = ws.request({"request" : "users"})
	yield(req, "request_complete")
	var users_raw : Dictionary = req.ans_data["users"]
	req.complete()
	
	var users : Dictionary = da.users
	
	for id in users_raw:
		var u = users_raw[id]
		
		var role : String
		for r in u["roles"]:
			if r in da.teams:
				role = r
		
		if id in users:
			users[id].data["user_name"] = u["user_name"]
			users[id].data["avatar"] = u["avatar"]
			if role: users[id].data["team"] = role
			users[id].data["nick"] = u["nick"]
			users[id].data["mention"] = u["mention"]
		else:
			var usr : User = User.new(id)
			
			usr.data["user_name"] = u["user_name"]
			usr.data["avatar"] = u["avatar"]
			if role: usr.data["team"] = role
			usr.data["nick"] = u["nick"]
			usr.data["mention"] = u["mention"]
			
			users[id] = usr
	
	if not users.empty():
		da.users = users

func discord_message(message : String, Channel : String = "bridge", Category = "super"):
	ws.send_data({
		"type" : "message",
		"channel_name" : Channel,
		"category_name": Category,
		"message" : message
	})
