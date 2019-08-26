extends Node

var teams = {} setget set_teams, get_teams
var users = {} setget set_users, get_users

onready var ws = $"../Websocket"

signal teams_updated
signal users_updated

func _ready():
	get_tree().set_auto_accept_quit(false)
	var savefile = File.new()
	if savefile.file_exists("user://game.save"):
		load_all()
	else:
		teams["Red"] = Team.new("Red")
		teams["Green"] = Team.new("Green")
		teams["Blue"] = Team.new("Blue")
		teams["Yellow"] = Team.new("Yellow")
	savefile.close()
	
	get_tree().create_timer(900).connect("timeout", self, "autosave")

func autosave():
	save_all()
	get_tree().create_timer(900).connect("timeout", self, "autosave")

master func save_all() ->void:
	var data = {}
	
	var ts = {}
	for t in teams:
		ts[t] = teams[t].get_all()
	
	var us = {}
	for u in users:
		us[u] = users[u].get_all()
	
	var world = $"../../Playerend/World".get_all()
	
	var ws = $"../Websocket".get_all()
	
	data["teams"] = ts
	data["users"] = us
	data["World"] = world
	data["websocket"] = ws
	
	var data_string = JSON.print(data)
	
	var save_game = File.new()
	save_game.open("user://game.save", File.WRITE)
	save_game.store_line(data_string)
	save_game.close()
	
	print("data saved to %s" % OS.get_user_data_dir())

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		close_server()

func load_all() -> void:
	var save_game = File.new()
	save_game.open("user://game.save", File.READ)
	var data_string = save_game.get_line()
	save_game.close()
	
	var data = JSON.parse(data_string).result
	
	if data.has("teams"):
		var ts = data["teams"]
		for t in ts:
			teams[t] = Team.new(t)
			teams[t].set_all(ts[t])
	else:
		printerr("team data missing")
	
	if data.has("users"):
		var us = data["users"]
		for u in us:
			users[u] = User.new(u)
			users[u].set_all(us[u])
	else:
		printerr("user data missing")
	
	if data.has("World"):
		var world = data["World"]
		$"../../Playerend/World".set_all(world)
	else:
		printerr("world data missing!")
	
	if data.has("websocket"):
		var ws = data["websocket"]
		$"../Websocket".set_all(ws)
	else:
		printerr("world data missing!")
	
	print("done loading")

func add_user(id : String):
	users[id] = User.new(id)

func remove_user(id : String):
	users.erase(id)

func set_teams(t_dict : Dictionary = teams):
	var t_data : Dictionary
	for t in t_dict:
		t_data[t] = t_dict[t].get_all()
	var t_str = JSON.print(t_data)
	for id in get_parent().remote_servers:
		rpc_id(id, "set_networked_teams", t_str)
	set_networked_teams(t_str)
	printt("setting teams")

remote func set_networked_teams(t_str : String):
	var t = JSON.parse(t_str).result
	for team in t:
		var t_new = Team.new(team)
		t_new.set_all(t[team])
		teams[team] = t_new
	printt("teams set")
	emit_signal("teams_updated")

func get_teams() -> Dictionary:
	return teams

func set_users(u_dict : Dictionary = users):
	var u_data : Dictionary
	for u in u_dict:
		u_data[u] = u_dict[u].get_all()
	var u_str = JSON.print(u_data)
	for id in get_parent().remote_servers:
		rpc_id(id, "set_networked_users", u_str)
	set_networked_users(u_str)
	printt("setting users")

remote func set_networked_users(u_str : String):
	var u = JSON.parse(u_str).result
	for user in u:
		var u_new = User.new(user)
		u_new.set_all(u[user])
		users[user] = u_new
	printt("users set")
	emit_signal("users_updated")

func get_users() -> Dictionary:
	return users

master func close_server():
	ws.close()
	yield(get_tree().create_timer(1.1), "timeout")
	save_all()
	get_tree().quit()
